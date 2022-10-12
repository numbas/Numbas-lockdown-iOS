//
//  LaunchSettings.swift
//  Numbas lockdown
//
//  Created by Christian Lawson-Perfect on 11/10/2022.
//

import Scrypt
import CryptoKit
import Foundation
import CommonCrypto

struct LaunchSettings: Codable {
    var url: String
    var token: String
}
    
// construct an AES key from a password and salt
extension SymmetricKey {
    init(password: String, salt: String) {
        let saltBytes = Array(salt.utf8)

        let hash = try! scrypt(password: Array(password.utf8), salt: saltBytes, length: 24)

        self.init(data: hash);
    }
}

// extension to String.data to convert hexadecimal to Data
// from https://stackoverflow.com/a/56870030
extension String {
    enum ExtendedEncoding {
        case hexadecimal
    }

    func data(using encoding:ExtendedEncoding) -> Data? {
        let hexStr = self.dropFirst(self.hasPrefix("0x") ? 2 : 0)

        guard hexStr.count % 2 == 0 else { return nil }

        var newData = Data(capacity: hexStr.count/2)

        var indexIsEven = true
        for i in hexStr.indices {
            if indexIsEven {
                let byteRange = i...hexStr.index(after: i)
                guard let byte = UInt8(hexStr[byteRange], radix: 16) else { return nil }
                newData.append(byte)
            }
            indexIsEven.toggle()
        }
        return newData
    }
}

// Decrypt an encrypted launch settings JSON string
struct LaunchDataDecrypter {
    private let key: SymmetricKey

    init?(key: SymmetricKey) {
        self.key = key
    }

    func decrypt(data: Data?) -> String? {
        guard let decryptedData = crypt(data: data, option: CCOperation(kCCDecrypt)) else {
            return nil
        }
        return String(bytes: decryptedData, encoding: .utf8)
    }

    func crypt(data: Data?, option: CCOperation) -> Data? {
        guard let data = data else {
            return nil
        }
        
        let iv : Data = data.subdata(in: 0..<16)
        let text = data.subdata(in: 16..<data.count)

        let keyCount : Int = SymmetricKeySize.bits192.bitCount/8
        let cryptLength : Int = text.count + keyCount
        var cryptData : Data = Data(count: cryptLength)
    
        var bytesLength = Int(0)
    
        let status = cryptData.withUnsafeMutableBytes { cryptBytes in
            text.withUnsafeBytes { textBytes in
                iv.withUnsafeBytes { ivBytes in
                    key.withUnsafeBytes { keyBytes in
                    CCCrypt(option, CCAlgorithm(kCCAlgorithmAES), CCOptions(kCCOptionPKCS7Padding), keyBytes.baseAddress, keyCount, ivBytes.baseAddress, textBytes.baseAddress, text.count, cryptBytes.baseAddress, cryptLength, &bytesLength)
                    }
                }
            }
        }
    
        guard Int32(status) == Int32(kCCSuccess) else {
            return nil
        }
    
        cryptData.removeSubrange(bytesLength..<cryptData.count)
        return cryptData
    }
    
    func loadLaunchSettings(encrypted: String) -> LaunchSettings? {
        guard let decrypted = decrypt(data: encrypted.data(using:.hexadecimal)) else {
            return nil
        }

        let decoder = JSONDecoder()

        guard let decryptedData = decrypted.data(using:.utf8) else {
            return nil
        }
        do {
            let launch_settings = try decoder.decode(LaunchSettings.self, from: decryptedData)
            return launch_settings
        } catch {
            return nil
        }
    }

}
