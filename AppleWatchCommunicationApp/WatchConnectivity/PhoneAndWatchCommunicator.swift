//
//  PhoneAndWatchCommunicator.swift
//  AppleWatchCommunicationApp
//
//  Created by Joshua on 8/6/20.
//  Copyright © 2020 Joshua Cook. All rights reserved.
//

import Foundation
import WatchConnectivity


class PhoneAndWatchCommunicator: NSObject, WCSessionDelegate {
    
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
}

#if os(iOS)
extension PhoneAndWatchCommunicator {
    func sessionDidDeactivate(_ session: WCSession) {
        print("Session deactivated.")
    }
    
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("Session did become inactive.")
    }
    
    
    /// Is the Watch supported, paired, and app installed?
    /// - Returns: Boolean value to answer this question.
    func checkConnectivityWithWatch() -> Bool {
        return WCSession.isSupported() && session.isPaired && session.isWatchAppInstalled
    }
}
#endif


extension PhoneAndWatchCommunicator {
    
    #if os(iOS)
    /// Send the latest plant information to the watch and overwrite its data.
    /// - Parameter plants: An array of plants to update.
    ///
    /// The data passed here will replace all of the data on the watch. If you just want to update a specific
    /// set of plants, use `update(_: [Plant])`.
    func replace(_ plants: [Plant]) {
        updatePlantApplicationContext(plants, asDataType: .allPlants)
    }
    #endif
    
    /// Update specific plants on the watch.
    /// - Parameter plants: An array of plants to update.
    func update(_ plants: [Plant]) {
        updatePlantApplicationContext(plants, asDataType: .updatePlants)
    }
    
    
    /// Send new plant information using the `updateApplicationContext()`method for the watch
    /// connectivity session
    /// - Parameters:
    ///   - plants: An array of plants to update.
    ///   - dataType: What tiype of data is being sent.
    private func updatePlantApplicationContext(_ plants: [Plant], asDataType dataType: ApplicationContextDataType) {
        
        #if os(iOS)
        if !checkConnectivityWithWatch() {
            print("Watch not connected.")
            return
        }
        #endif
        
        let dataManager = WatchConnectivityDataManager()
        let applicationContext = [dataType.rawValue: dataManager.convert(plants)]
        do {
            try session.updateApplicationContext(applicationContext)
            print("Successfully sent plant data to watch.")
        } catch {
            print("Error in updating application context.")
            print("error: \(error.localizedDescription)")
        }
    }
}


extension PhoneAndWatchCommunicator {
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
            print("Updating \(plants.count) plants")
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

