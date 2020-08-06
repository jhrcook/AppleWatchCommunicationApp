//
//  WatchToPhoneCommunicator.swift
//  WatchAppleWatchCommunicationApp Extension
//
//  Created by Joshua on 8/5/20.
//  Copyright © 2020 Joshua Cook. All rights reserved.
//

import Foundation
import WatchConnectivity


protocol GardenDelegate {
    func gardenPlantsWereUpdated() -> Void
}

class WatchToPhoneCommunicator: NSObject, WCSessionDelegate {
    
    private let session: WCSession
    
    var gardenDelegate: GardenDelegate? = nil
    
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
    }
    
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        if let textMessage = message["testmessage"] as? String {
            print("recieved message: \(textMessage)")
            let replyMessage: [String: Any] = ["testreply": "A message from the Watch, sir 👌🏼!"]
            replyHandler(replyMessage)
        } else {
            print("Expected test message not recieved.")
            print(message)
        }
    }
    
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        print("Recieved applicationContext")

        let garden = Garden()
        let dataManager = WatchConnectivityDataManager()
        
        if let plantsData = applicationContext[ApplicationContextDataType.allPlants.rawValue] as? [[String: Any]] {
            
            garden.plants = dataManager.convert(plantsData)
            garden.savePlants()
            print("parsed \(garden.plants.count) plants")
            
            if let gardenDelegate = self.gardenDelegate {
                gardenDelegate.gardenPlantsWereUpdated()
            }
            
        } else if let plantsData = applicationContext[ApplicationContextDataType.updatePlants.rawValue] as? [[String: Any]] {
            
            let plants = dataManager.convert(plantsData)
            for plant in plants {
                garden.update(plant)
            }
            
            if let gardenDelegate = self.gardenDelegate {
                gardenDelegate.gardenPlantsWereUpdated()
            }
            
        } else {
            print("Plants data not found in applicationContext")
        }
    }
    
    
    
}
