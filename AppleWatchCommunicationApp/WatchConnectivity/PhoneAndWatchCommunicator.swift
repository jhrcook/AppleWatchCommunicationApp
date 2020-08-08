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
            print("error during Watch Connectivity activation: \(error.localizedDescription)")
            return
        }
        print("Watch Connectivity session activated without error.")
    }
}


// iOS specific methods

#if os(iOS)
extension PhoneAndWatchCommunicator {
    
    /// Is the Watch supported, paired, and app installed?
    /// - Returns: Boolean value to answer this question.
    func checkConnectivityWithWatch() -> Bool {
        return WCSession.isSupported() && session.isPaired && session.isWatchAppInstalled
    }
    
    
    /// Send the latest plant information to the watch and overwrite its data.
    /// - Parameter plants: An array of plants to update.
    ///
    /// The data passed here will replace all of the data on the watch. If you just want to update a specific
    /// set of plants, use `update(_: [Plant])`.
    func replaceAllDataOnWatch(withPlants plants: [Plant]) {
        if session.activationState == .activated && session.isReachable {
            let dataManager = WCDataManager()
            let info = [WCDataType.replaceAllPlants.rawValue: dataManager.convert(plants)]
            do {
                try session.updateApplicationContext(info)
                print("Successfully sent application context.")
            } catch {
                print("Error in updating application context: \(error.localizedDescription)")
            }
        }
    }
    
    
    /// Delete plants on the watch.
    /// - Parameter plants: The plants to be deleted.
    func delete(_ plants: [Plant]) {
        print("Sending request to delete \(plants.count) plant(s).")
        let plantIdsToDelete = plants.map { $0.id }
        let info = [WCDataType.deletePlants.rawValue: plantIdsToDelete]
        sendMessageOrTransfer(info)
    }
}
#endif


// Sending data

extension PhoneAndWatchCommunicator {
    /// Update specific plants on the watch.
    /// - Parameter plants: An array of plants to update.
    func update(_ plants: [Plant]) {
        print("Sending request to update \(plants.count) plant(s).")
        let dataManager = WCDataManager()
        let info = [WCDataType.updatePlants.rawValue: dataManager.convert(plants)]
        sendMessageOrTransfer(info)
    }
    
    
    private func sendMessageOrTransfer(_ info: [String: Any]) {
        #if os(iOS)
        if !checkConnectivityWithWatch() {
            print("No device paired with phone - returning early")
        }
        #endif
        
        if session.activationState == .activated {
            print("Attempting to send message.")
            session.sendMessage(info, replyHandler: { replyMessage in
                if let response = PhoneAndWatchCommunicator.messageReplyType(replyMessage) {
                    switch response {
                    case .success:
                        print("Message successfully recieved.")
                    default:
                        print("Message failed, attempting transfer.")
                        self.session.transferUserInfo(info)
                    }
                }
            }, errorHandler: { errorHandler in
                print("Error on sending message: \(errorHandler.localizedDescription)")
                print("\tAttempting transfer.")
                self.session.transferUserInfo(info)
            })
        }
    }
    
    
    func session(_ session: WCSession, didFinish userInfoTransfer: WCSessionUserInfoTransfer, error: Error?) {
        if let error = error {
            print("Error transfering user info: \(error.localizedDescription)")
            print("user info of failed transfer: \(userInfoTransfer.userInfo)")
        }
        print("Did finish transfering user infomation")
    }
    
    
    static func messageReplyType(_ replyMessage: [String : Any]) -> WCMessageResponse.WCResponseType? {
        if let response = replyMessage[WCMessageResponse.response.rawValue] as? String {
            if let responseType = WCMessageResponse.WCResponseType(rawValue: response) {
                return responseType
            }
        }
        return nil
    }
}


// Recieving data

extension PhoneAndWatchCommunicator {
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        print("Application context recieved.")
        if let plantInfo = applicationContext[WCDataType.replaceAllPlants.rawValue] as? [[String : Any]] {
            let garden = Garden()
            garden.plants = WCDataManager().convert(plantInfo)
            print("Plant data was updated with application context.")
            updateGardenDelegateOnTheMainThread()
        }
    }
    
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        do {
            try parseIncomingInformation(userInfo)
        } catch {
            print("Failed to parse information: \(error.localizedDescription)")
        }
    }
    
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        do {
            try parseIncomingInformation(message)
            replyHandler([WCMessageResponse.response.rawValue : WCMessageResponse.WCResponseType.success.rawValue])
        } catch {
            print("Failed to parse information: \(error.localizedDescription)")
            replyHandler([WCMessageResponse.response.rawValue : WCMessageResponse.WCResponseType.failure.rawValue])
        }
    }
    
    
    /// Parse incoming data from messages or user info transfers.
    /// - Parameter info: The information in a dictionary.
    /// - Throws: If the data fails to parse an error is thrown.
    func parseIncomingInformation(_ info: [String : Any]) throws {
        if let plantsToDelete = info[WCDataType.deletePlants.rawValue] as? [String] {
            print("Recieved \(plantsToDelete.count) plants to delete.")
            deletePlantsFromGarden(withPlantIds: plantsToDelete)
        } else if let updatedPlantInfo = info[WCDataType.updatePlants.rawValue] as? [[String : Any]] {
            print("Recieved data on plants to update.")
            updatePlantsInGarden(withPlantInfo: updatedPlantInfo)
        } else {
            throw WCDataParsingError.unknownDataType
        }
        updateGardenDelegateOnTheMainThread()
    }
    
    
    /// Delete the plants from the garden information on the device.
    /// - Parameter plantIds: An string array of `Plant.id`.
    private func deletePlantsFromGarden(withPlantIds plantIds: [String]) {
        let garden = Garden()
        garden.removePlants(withIds: plantIds)
        garden.savePlants()
    }
    
    
    /// Update hthe plants in the garden on the local device.
    /// - Parameter plantInfo: An array of dictionaries with the plant information.
    private func updatePlantsInGarden(withPlantInfo plantInfo: [[String : Any]]) {
        let plants = WCDataManager().convert(plantInfo)
        let garden = Garden()
        for plant in plants {
            garden.update(plant, addIfNew: true, updatePlantOrder: false)
        }
        garden.sortPlants()
        garden.savePlants()
    }
    
    
    private func updateGardenDelegateOnTheMainThread() {
        if let gardenDelegate = gardenDelegate {
            DispatchQueue.main.async {
                gardenDelegate.gardenPlantsWereUpdated()
            }
        }
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
}
#endif


