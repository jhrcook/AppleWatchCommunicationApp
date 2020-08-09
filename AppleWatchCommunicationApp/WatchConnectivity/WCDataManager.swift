//
//  WatchConnectivityDataManager.swift
//  AppleWatchCommunicationApp
//
//  Created by Joshua on 8/5/20.
//  Copyright © 2020 Joshua Cook. All rights reserved.
//

import Foundation



enum WCDataType: String {
    case replaceAllPlants
    case updatePlants
    case deletePlants
}



enum WCMessageResponse: String {
    case response
    
    enum WCResponseType: String {
        case success
        case failure
    }
}



enum WCDataParsingError: Error {
    case unknownDataType
    case unableToReadImageData
    case unableToCompressJPEGData
}

extension WCDataParsingError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .unknownDataType:
            return NSLocalizedString("Data type is unknown.", comment: "")
        case .unableToReadImageData:
            return NSLocalizedString("Unable to read image data from file.", comment: "")
        case .unableToCompressJPEGData:
            return NSLocalizedString("Unable to compress data to JPEG.", comment: "")
        }
    }
}



enum PlantDataValues: String {
    case id, name, watered, imageName
}



struct WCDataManager {
    
    /// Convert from a plant to a dictionary.
    /// - Parameter plant: Plant
    /// - Returns: A dictionary.
    func convert(_ plant: Plant) -> [String: Any] {
        return [
            PlantDataValues.id.rawValue: plant.id,
            PlantDataValues.name.rawValue: plant.name,
            PlantDataValues.watered.rawValue: plant.watered,
            PlantDataValues.imageName.rawValue: plant.imageName ?? ""
        ]
    }
    
    
    /// Convert an array of plants into an array of dicitonaries.
    /// - Parameter plants: Plants
    /// - Returns: An array of dictionaries.
    func convert(_ plants: [Plant]) -> [[String: Any]] {
        var plantData = [[String: Any]]()
        for plant in plants {
            plantData.append(convert(plant))
        }
        return plantData
    }
    
    
    /// Convert a dictionary back to a plant.
    /// - Parameter plantData: Dictionary with plant information.
    /// - Returns: A `Plant` object.
    func convert(_ plantData: [String: Any]) -> Plant {
        var plant = Plant(id: plantData[PlantDataValues.id.rawValue] as! String,
                          name: plantData[PlantDataValues.name.rawValue] as? String ?? "Wrong name...")
        plant.watered = plantData[PlantDataValues.watered.rawValue] as? Bool ?? false
        
        let imageName = plantData[PlantDataValues.imageName.rawValue] as? String
        plant.imageName = imageName == "" ? nil : imageName
        
        return plant
        
    }
    
    
    /// Convert an array of dictionaries to an array of plants.
    /// - Parameter plantsData: Array of dictionaries with plant information.
    /// - Returns: An array of plants.
    func convert(_ plantsData: [[String: Any]]) -> [Plant] {
        var plants = [Plant]()
        for plantData in plantsData {
            plants.append(convert(plantData))
        }
        return plants
    }
}

