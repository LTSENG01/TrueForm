//
//  ContentView.swift
//  TrueForm WatchKit Extension
//
//  Created by Larry Tseng on 4/21/22.
//

import SwiftUI

struct ContentView: View {
    @StateObject var sensorManager = SensorManager()
    
    @State private var showingDeleteAlert = false
    
    var body: some View {
        VStack {
            Text("Hello, World!")
                .padding()
            
            Button(action: {
                if !sensorManager.accelData.isEmpty && !sensorManager.isRecording {
                    showingDeleteAlert = true
                } else {
                    sensorManager.isRecording.toggle()
                }
            }) {
                if sensorManager.isRecording {
                    Text("Stop")
                } else {
                    Text("Start")
                }
            }
        }
        .alert("Warning!", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) {
                print("Canceled")
            }
            Button("Delete", role: .destructive) {
                print("Deleted")
                sensorManager.isRecording = true
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
