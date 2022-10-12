//
//  ContentView.swift
//  Numbas lockdown
//
//  Created by Christian Lawson-Perfect on 11/10/2022.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var launchData : LaunchData
    var body: some View {
        if launchData.opening_url == nil {
            BlankView()
        } else if launchData.launchSettings != nil {
            BrowserView(viewModel: launchData)
        } else {
            SettingsView()
                .environmentObject(launchData)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(LaunchData())
    }
}
