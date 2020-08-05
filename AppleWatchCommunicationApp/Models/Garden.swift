//
//  Garden.swift
//  AppleWatchCommunicationApp
//
//  Created by Joshua on 8/3/20.
//  Copyright © 2020 Joshua Cook. All rights reserved.
//

import SwiftUI

class Garden: ObservableObject {
    
    static private let inTesting = false
    
    @Published var plants = [Plant]() {
        didSet {
            savePlants()
        }
    }
    
    init() {
        if (Garden.inTesting) {
            print("Making mock plants for testing.")
            self.plants = mockPlants()
            sortPlants()
            return
        }
        self.plants = Garden.loadPlants()
        self.sortPlants()
    }
    
    
    static func loadPlants() -> [Plant] {
        if let encodedPlants = UserDefaults.standard.data(forKey: "garden.plants") {
            let decoder = JSONDecoder()
            if let decodedPlants = try? decoder.decode([Plant].self, from: encodedPlants) {
                return decodedPlants
            }
        }
        print("Unable to load plants data.")
        return [Plant]()
    }
    
    
    func reloadPlants() {
        DispatchQueue.main.async {
            self.plants = Garden.loadPlants()
        }
    }
    
    
    func savePlants() {
        print("Saving plants.")
        let encoder = JSONEncoder()
        if let encodedData  = try? encoder.encode(plants) {
            UserDefaults.standard.set(encodedData, forKey: "garden.plants")
        }
    }
    
    
    func sortPlants() {
        DispatchQueue.main.async {
            self.plants.sort { $0.name < $1.name }
        }
    }
    
    func update(_ plant: Plant, updatePlantOrder: Bool = true) {
        let idx = plants.firstIndex(where: { $0.id == plant.id })!
        plants[idx] = plant
        if updatePlantOrder {
            sortPlants()
        }
    }
}


extension Garden {
    private func mockPlants() -> [Plant] {
        var mockPlants = [Plant]()
        for i in 0..<10 {
            mockPlants.append(
                Plant(name: "Plant \(i)")
            )
        }
        return mockPlants
    }
}
