//
//  ContentView.swift
//  TrueForm
//
//  Created by Larry Tseng on 4/21/22.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var fileReceiver = WatchConnectivityManager().fileReceiver
    var body: some View {
        VStack {
            if fileReceiver.lastFileReceived.isEmpty {
                Text("Start a run on your Apple Watch.")
                    .padding()
            } else {
                Text(fileReceiver.lastFileReceived)
            }
            
//            if let wcSession = watchManager.wcSession {
//                Text(wcSession.isReachable ? "Connected to Apple Watch" : "Disconnected")
//                    .padding()
//            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
