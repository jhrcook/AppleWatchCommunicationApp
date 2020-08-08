//
//  GardenListView.swift
//  AppleWatchCommunicationApp
//
//  Created by Joshua on 8/7/20.
//  Copyright © 2020 Joshua Cook. All rights reserved.
//

import SwiftUI

struct GardenListView: View, GardenDelegate {
    @ObservedObject var garden: Garden
    var watchCommunicator: PhoneAndWatchCommunicator
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(garden.plants) { plant in
                        NavigationLink(destination: PlantDetailView(garden: self.garden, plant: plant, watchCommunicator: self.watchCommunicator)) {
                            PlantRow(garden: self.garden, plant: plant)
                        }
                    }
                    .onDelete(perform: delete)
                }
                .navigationBarTitle("Garden")
                
                
                HStack {
                    Button("Clear waterings") {
                        var newPlants = [Plant]()
                        for plant in self.garden.plants {
                            var newPlant = plant
                            newPlant.watered = false
                            newPlants.append(newPlant)
                            self.garden.update(newPlant)
                        }
                        self.watchCommunicator.update(self.garden.plants)
                    }
                    .padding()
                    
                    Spacer()
                    
                    Button("Overwrite watch data") {
                        self.watchCommunicator.replaceAllDataOnWatch(withPlants: self.garden.plants)
                    }
                    .padding()
                    
                    Spacer()
                    
                    Button("Make new plant") {
                        let newPlant = Plant(name: "Plant \(self.garden.plants.count + 1)")
                        self.garden.plants.append(newPlant)
                        self.watchCommunicator.update([newPlant])
                    }
                }
                .padding(15)
            }
        }
        .onAppear {
            self.watchCommunicator.gardenDelegate = self
        }
    }
    
    func gardenPlantsWereUpdated() {
        garden.reloadPlants()
        garden.sortPlants()
    }
    
    func delete(at offsets: IndexSet) {
        var plantsToDelete = [Plant]()
        offsets.forEach { i in
            plantsToDelete.append(garden.plants[i])
        }
        garden.plants.remove(atOffsets: offsets)
        watchCommunicator.delete(plantsToDelete)
        
    }
}


struct GardenListView_Previews: PreviewProvider {
    static var previews: some View {
        GardenListView(garden: Garden(), watchCommunicator: PhoneAndWatchCommunicator())
    }
}
