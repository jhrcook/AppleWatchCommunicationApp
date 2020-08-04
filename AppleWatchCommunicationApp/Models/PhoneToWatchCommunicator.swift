//
//  PhoneToWatchCommunicator.swift
//  AppleWatchCommunicationApp
//
//  Created by Joshua on 8/4/20.
//  Copyright © 2020 Joshua Cook. All rights reserved.
//

import Foundation
import WatchConnectivity

class PhoneToWatchCommunicator: NSObject, WCSessionDelegate {
    
    private let session: WCSession
    
    init(session: WCSession = .default) {
        self.session = session
        super.init()
        if WCSession.isSupported() {
            session.delegate = self
            session.activate()
        }
    }
    
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("error during activation: \(error.localizedDescription)")
            return
        }
        print("Activated without error.")
        compareGardens()
    }
    
    
    func sessionDidDeactivate(_ session: WCSession) {
        print("Session deactivated.")
    }
    
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("Session did become inactive.")
    }
    
    
    func checkConnectivityWithWatch() -> Bool {
        return WCSession.isSupported() && session.isPaired && session.isWatchAppInstalled
    }
}


extension PhoneToWatchCommunicator {
    func compareGardens() {
        if !checkConnectivityWithWatch() {
            print("Watch not connected.")
            return
        }
        print("Watch is connected!")
        
        if !session.isReachable {
            print("Watch not reachable...")
        } else {
            print("Watch reachable!")
        }
        
        // A test message for the watch.
        let message: [String: Any] = ["testmessage": "Hello from the iphone"]

        
        session.sendMessage(message, replyHandler: { replyMessage in
            if let m = replyMessage["testreply"] as? String {
                print("reply message: \(m)")
            }
        }, errorHandler: { error in
            print("Error in sending message: \(error.localizedDescription)")
        })
        
    }
}
