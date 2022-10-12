//
//  Numbas_lockdownApp.swift
//  Numbas lockdown
//
//  Created by Christian Lawson-Perfect on 11/10/2022.
//

import SwiftUI

@main
struct Numbas_lockdownApp: App {
    @StateObject private var launchData : LaunchData = LaunchData()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(launchData)
                .handlesExternalEvents(preferring: ["numbaslockdown"], allowing: ["numbaslockdown"])
                .onOpenURL{ url in
                    launchData.opening_url = url
                    launchData.launchSettings = nil
                }
        }
    }
}
