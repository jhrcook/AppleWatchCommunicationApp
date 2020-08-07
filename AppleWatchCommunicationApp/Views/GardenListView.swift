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
                }
                .navigationBarTitle("Garden")
                
                Button("Remove all waterings") {
                    var newPlants = [Plant]()
                    for plant in self.garden.plants {
                        var newPlant = plant
                        newPlant.watered = false
                        newPlants.append(newPlant)
                        self.garden.update(newPlant)
                    }
                    //                    self.watchCommunicator.replace(newPlants)
                }
                .padding(20)
                
                Button("Test transfer") {
                    self.watchCommunicator.sendTransferTest()
                }
                .padding(20)
                
            }
        }
        .onAppear {
            self.watchCommunicator.gardenDelegate = self
            //            self.watchCommunicator.replace(self.garden.plants)
        }
    }
    
    func gardenPlantsWereUpdated() {
        garden.reloadPlants()
        garden.sortPlants()
    }
}


struct GardenListView_Previews: PreviewProvider {
    static var previews: some View {
        GardenListView(garden: Garden(), watchCommunicator: PhoneAndWatchCommunicator())
    }
}
