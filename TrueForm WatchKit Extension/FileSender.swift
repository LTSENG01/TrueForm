//
//  FileSender.swift
//  TrueForm WatchKit Extension
//
//  Created by Larry Tseng on 4/22/22.
//

import Foundation
import WatchConnectivity

class FileSender {
    var wcSession: WCSession?
    let fileReceiver = FileReceiver()
    
    init() {
        if WCSession.isSupported() {
            wcSession = WCSession.default
            wcSession?.delegate = fileReceiver
            wcSession?.activate()
        }
    }
    
    func sendFile(file: URL) throws {
        if wcSession?.activationState == .activated {
            wcSession?.transferFile(file, metadata: nil)
            print("File transfer queued.")
        } else {
            throw WCError(.sessionNotActivated)
        }
    }
}

class FileReceiver: NSObject, WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    func session(_ session: WCSession, didFinish fileTransfer: WCSessionFileTransfer, error: Error?) {
        print("File is transferring: \(fileTransfer.isTransferring)")
        print("File is finished: \(fileTransfer.progress.isFinished)")
    }
}
