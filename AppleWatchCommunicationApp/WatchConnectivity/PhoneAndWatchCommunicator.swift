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
    var transferTestingDelegate: TransferTestingDelegate? = nil
    
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


extension PhoneAndWatchCommunicator {
    
    #if os(iOS)
    /// Send the latest plant information to the watch and overwrite its data.
    /// - Parameter plants: An array of plants to update.
    ///
    /// The data passed here will replace all of the data on the watch. If you just want to update a specific
    /// set of plants, use `update(_: [Plant])`.
    func replaceAllDataOnWatch(withPlants plants: [Plant]) {
        if session.activationState == .activated && session.isReachable {
            let dataManager = WatchConnectivityDataManager()
            let info = [ApplicationContextDataType.allPlants.rawValue: dataManager.convert(plants)]
            do {
                try session.updateApplicationContext(info)
                print("Successfully sent application context.")
            } catch {
                print("Error in updating application context: \(error.localizedDescription)")
            }
        }
    }
    #endif
    
    
    /// Update specific plants on the watch.
    /// - Parameter plants: An array of plants to update.
    func update(_ plants: [Plant]) {
        let dataManager = WatchConnectivityDataManager()
        sendUpdates(dataManager.convert(plants), asDataType: .updatePlants)
    }
    
    
    private func sendUpdates(_ info: [[String : Any]], asDataType dataType: ApplicationContextDataType) {
        #if os(iOS)
        if !checkConnectivityWithWatch() {
            print("No device paired with phone - returning early.")
            return
        }
        #endif
        
        let info = [dataType.rawValue: info]
        
        if session.activationState == .activated && session.isReachable {
            session.sendMessage(info, replyHandler: nil) { error in
                print("Error in sending message :\(error.localizedDescription)")
            }
        } else if session.activationState == .activated {
            session.transferUserInfo(info)
        }
    }
    
    func sendTransferTest() {
        #if os(iOS)
        if !checkConnectivityWithWatch() {
            print("No device paired with phone - returning early.")
            return
        }
        #endif
        
        if session.activationState == .activated {
            print("Initiating transfer.")
            session.transferUserInfo(["testmessage": "Here is my test message"])
        } else {
            print("Session is inactive - transfer not initiated.")
        }
    }
    
    func session(_ session: WCSession, didFinish userInfoTransfer: WCSessionUserInfoTransfer, error: Error?) {
        if let error = error {
            print("Transfering user info finished with error: \(error.localizedDescription)")
            return
        }
        
        print("User info transfer completed successfully")
        
        if let delegate = self.transferTestingDelegate {
            DispatchQueue.main.async {
                delegate.transferDidFinish()
            }
        }
        
        print(userInfoTransfer.userInfo)
        print("number of outstanding user info transfers: \(session.outstandingUserInfoTransfers.count)")
        if session.outstandingUserInfoTransfers.count > 0 {
            print("outstanding transfers:")
            for transfer in session.outstandingUserInfoTransfers {
                print("   \(transfer.userInfo)")
            }
        }
    }
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        print("Recieved user info!")
        
        if let delegate = self.transferTestingDelegate {
            DispatchQueue.main.async {
                delegate.transferRecieved()
            }
        }
        
        print(userInfo)
    }
}


extension PhoneAndWatchCommunicator {
//    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
//        print("Recieved applicationContext")
//
//        let garden = Garden()
//        let dataManager = WatchConnectivityDataManager()
//
//        if let plantsData = applicationContext[ApplicationContextDataType.allPlants.rawValue] as? [[String: Any]] {
//            garden.plants = dataManager.convert(plantsData)
//            garden.savePlants()
//            print("parsed \(garden.plants.count) plants")
//            if let gardenDelegate = self.gardenDelegate {
//                gardenDelegate.gardenPlantsWereUpdated()
//            }
//        } else if let plantsData = applicationContext[ApplicationContextDataType.updatePlants.rawValue] as? [[String: Any]] {
//            let plants = dataManager.convert(plantsData)
//            print("Updating \(plants.count) plants")
//            for plant in plants {
//                garden.update(plant)
//            }
//            if let gardenDelegate = self.gardenDelegate {
//                gardenDelegate.gardenPlantsWereUpdated()
//            }
//        } else {
//            print("Plants data not found in applicationContext")
//        }
//    }
//
//    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
//        print("Recieved message.")
//
//        let garden = Garden()
//        let dataManager = WatchConnectivityDataManager()
//
//        if let plantsData = message[ApplicationContextDataType.allPlants.rawValue] as? [[String: Any]] {
//            garden.plants = dataManager.convert(plantsData)
//            garden.savePlants()
//            print("parsed \(garden.plants.count) plants")
//            if let gardenDelegate = self.gardenDelegate {
//                gardenDelegate.gardenPlantsWereUpdated()
//            }
//        } else if let plantsData = message[ApplicationContextDataType.updatePlants.rawValue] as? [[String: Any]] {
//            let plants = dataManager.convert(plantsData)
//            print("Updating \(plants.count) plants")
//            for plant in plants {
//                garden.update(plant)
//            }
//            if let gardenDelegate = self.gardenDelegate {
//                gardenDelegate.gardenPlantsWereUpdated()
//            }
//        } else {
//            print("Plants data not found in message.")
//            print(message)
//        }
//    }
    
    
    /// TODO: Rewrite data reception methods for new system.
    /// TODO: Need to figure out issues with `transfer...` methods.
    
    
    
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
