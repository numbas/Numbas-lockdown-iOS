//
//  AppModel.swift
//  Numbas lockdown
//
//  Created by Christian Lawson-Perfect on 11/10/2022.
//

import Foundation

final class LaunchData: ObservableObject {
    @Published var launchSettings : LaunchSettings? = nil
    @Published var password : String = ""
    @Published var opening_url : URL? = nil
}
