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
        if let plantsData = applicationContext["plants"] as? [String: Any] {
            let garden = Garden()
            garden.plants = convertApplicationContext(plantsData)
            garden.savePlants()
            print("parsed \(garden.plants.count) plants")
            if let gardenDelegate = self.gardenDelegate {
                gardenDelegate.gardenPlantsWereUpdated()
            }
        } else {
            print("Plants data not found in applicationContext")
        }
        
    }
    
    
    func convertApplicationContext(_ plantsApplicationContext: [String: Any]) -> [Plant] {
        var plants = [Plant]()
        
        for (idString, plantData) in plantsApplicationContext {
            print("Parsing data for plant: \(idString)")
            if let plantData = plantData as? [String: Any] {
                var plant = Plant(id: idString, name: plantData["name"] as? String ?? "No name")
                plant.watered = plantData["watered"] as? Bool ?? false
                let imageName = plantData["imageName"] as? String ?? nil
                plant.imageName = imageName == "nil" ? nil : imageName
                plants.append(plant)
            }
        }
        
        return plants
    }
    
    
    
}
