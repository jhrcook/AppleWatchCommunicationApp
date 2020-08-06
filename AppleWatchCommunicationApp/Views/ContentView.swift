//
//  ContentView.swift
//  AppleWatchCommunicationApp
//
//  Created by Joshua on 8/2/20.
//  Copyright © 2020 Joshua Cook. All rights reserved.
//

import SwiftUI


struct ContentView: View, GardenDelegate {
        
    @ObservedObject var garden = Garden()
    var watchCommunicator = PhoneToWatchCommunicator()
    
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
                    for plant in self.garden.plants {
                        var newPlant = plant
                        newPlant.watered = false
                        self.garden.update(newPlant)
                    }
                    self.watchCommunicator.update(self.garden.plants)
                }
                
            }
        }
        .onAppear {
            self.watchCommunicator.gardenDelegate = self
            self.watchCommunicator.replace(self.garden.plants)
        }
    }
    
    func gardenPlantsWereUpdated() {
        garden.reloadPlants()
        garden.sortPlants()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
