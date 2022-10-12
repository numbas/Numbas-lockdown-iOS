//
//  BlankView.swift
//  Numbas lockdown
//
//  Created by Christian Lawson-Perfect on 11/10/2022.
//

import SwiftUI

struct BlankView: View {
    var body: some View {
        VStack {
            VStack {
                Image("Numbas logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: 40)
            }
            VStack(alignment: .leading, spacing: 20) {
                Spacer()
                Text("This is the Numbas lockdown app")
                    .font(.title)
                    .fixedSize(horizontal: false, vertical: true)
                Text("You don't normally need to open this app directly.")
                    .fixedSize(horizontal: false, vertical: true)
                Text("Click on a Numbas link in a browser to use this app.")
                    .fixedSize(horizontal: false, vertical: true)
                Spacer()
            }
            
            VStack {
                Link(destination: URL(string: "https://www.numbas.org.uk/lockdown-app/test")!) {
                    Text("Open the test page")
                }
                .frame(alignment: .center)
                .foregroundColor(.white)
                .padding()
                .background(Color.accentColor)
                .cornerRadius(8)
            }
        }
        .padding()
    }
}

struct BlankView_Previews: PreviewProvider {
    static var previews: some View {
        BlankView()
    }
}
