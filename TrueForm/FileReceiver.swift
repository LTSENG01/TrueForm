//
//  FileReceiver.swift
//  TrueForm
//
//  Created by Larry Tseng on 4/22/22.
//

import Foundation
import WatchConnectivity
import UIKit

class WatchConnectivityManager {
    var wcSession: WCSession?
    let fileReceiver = FileReceiver()
    
    init() {
        if WCSession.isSupported() {
            wcSession = WCSession.default
            wcSession?.delegate = fileReceiver
            wcSession?.activate()
        }
    }
}

class FileReceiver: NSObject, WCSessionDelegate, ObservableObject {
    @Published var lastFileReceived: String = ""
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    
    func session(_ session: WCSession, didReceive file: WCSessionFile) {
        print(file.fileURL)
        
        let fileName: String = file.fileURL.lastPathComponent
        
        do {
            let fileURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            try FileManager.default.moveItem(at: file.fileURL, to: fileURL.appendingPathComponent(fileName))
            print("Accel file moved.")
            
            lastFileReceived = fileName
        } catch {
            
        }
        
//        let activityVC = UIActivityViewController(activityItems: [fileURL!], applicationActivities: nil)
//
//        DispatchQueue.main.async {
//            (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController?.present(activityVC, animated: true, completion: nil)
//        }
    }
}
