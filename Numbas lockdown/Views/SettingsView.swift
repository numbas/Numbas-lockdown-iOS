//
//  ContentView.swift
//  Numbas lockdown
//
//  Created by Christian Lawson-Perfect on 11/10/2022.
//

import SwiftUI
import CryptoKit

let salt = "45ab2cf2e139c01f8447d17dc653d585"

struct SettingsView: View {
    @EnvironmentObject var launchData : LaunchData
    @State private var decryptFailed = false
    var body: some View {
        VStack {
            VStack(alignment: .center, spacing: 0) {
                Image("Numbas logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: 40)
            }
            VStack(alignment: .leading, spacing: 20) {
                Text("Opening a Numbas link")
                    .font(.title)
                Spacer()
                Text("Enter the password to open this Numbas link.")
                Text("Your instructor should have given you the password.")
            }
            .frame(idealHeight: 100)
            
            Spacer(minLength: 10)
            VStack(alignment: .center, spacing: 20) {
                TextField("Password", text: $launchData.password)
                    .keyboardType(.asciiCapable)
                    .autocapitalization(.none)
                    .textFieldStyle(.roundedBorder)
                    .onChange(of: launchData.password) { password in
                        decryptFailed = false
                    }
                    .onSubmit {
                        loadSettings()
                    }
                Button("Open") {
                    loadSettings()
                }
                .disabled(launchData.password.isEmpty)
                if(decryptFailed) {
                    Text("Decryption failed: maybe the password is incorrect.")
                        .foregroundColor(Color.red)
                } else {
                }
                Spacer()
            }
        }
        .padding()
    }
    
    func loadSettings() {
        launchData.launchSettings = decryptSettings()
        decryptFailed = launchData.launchSettings == nil
    }
    
    func decryptSettings() -> LaunchSettings? {
        if(launchData.password=="") {
            return nil
        }
        guard let opening_url = launchData.opening_url else {
            return nil
        }
        let key = SymmetricKey(password: launchData.password, salt: salt)
        let decrypter = LaunchDataDecrypter(key: key)
        let settings = decrypter?.loadLaunchSettings(encrypted: opening_url.pathComponents[1])
        return settings
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(LaunchData())
    }
}
