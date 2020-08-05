//
//  GardenListView.swift
//  WatchAppleWatchCommunicationApp Extension
//
//  Created by Joshua on 8/4/20.
//  Copyright © 2020 Joshua Cook. All rights reserved.
//

import SwiftUI



struct GardenListView: View, GardenDelegate {
    
    @ObservedObject var garden: Garden
    var phoneCommunicator: WatchToPhoneCommunicator
    
    var body: some View {
        List {
            ForEach(garden.plants) { plant in
                NavigationLink(destination: PlantDetailView(garden: self.garden, plant: plant)) {
                    HStack {
                        plant.loadPlantImage()
                            .resizable()
                            .scaledToFit()
                            .clipShape(Circle())
                            .frame(height: 50)
                            .padding(5)
                        Text(plant.name)
                        Spacer()
                        Image(systemName: "cloud.rain").opacity(plant.watered ? 1 : 0)
                    }
                }
            }
        }
        .onAppear {
            self.phoneCommunicator.gardenDelegate = self
        }
    }
    
    func gardenPlantsWereUpdated() {
        garden.reloadPlants()
        garden.sortPlants()
    }
    
}

struct GardenListView_Previews: PreviewProvider {
    static var previews: some View {
        return GardenListView(garden: Garden(), phoneCommunicator: WatchToPhoneCommunicator())
    }
}
