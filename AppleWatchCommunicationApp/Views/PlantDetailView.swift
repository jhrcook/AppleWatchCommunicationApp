//
//  PlantDetailView.swift
//  AppleWatchCommunicationApp
//
//  Created by Joshua on 8/3/20.
//  Copyright © 2020 Joshua Cook. All rights reserved.
//

import SwiftUI

struct PlantDetailView: View {
    
    @ObservedObject var garden: Garden
    @State var plant: Plant
    
    var watchCommunicator: PhoneToWatchCommunicator?
    
    init(garden: Garden, plant: Plant, watchCommunicator: PhoneToWatchCommunicator? = nil) {
        self.garden = garden
        _plant = State(initialValue: plant)
        self.watchCommunicator = watchCommunicator
    }
    
    var body: some View {
        VStack {
            TextField("Plant name", text: $plant.name, onCommit: updatePlant)
                .font(.title)
                .multilineTextAlignment(.center)
                .frame(width: 200)
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .padding(.bottom, 50)
            
            plant.loadPlantImage()
                .resizable()
                .scaledToFit()
                .frame(width: 350)
                .clipShape(Circle())
                .shadow(radius: 15)
            
            HStack {
                Spacer()
                Button(action: {}) {
                    Text("Change image").foregroundColor(.gray)
                }
                .padding(.horizontal, 20)
            }
            
            Spacer()
            
            Button(action: {
                self.plant.watered = true
                self.updatePlant()
            }) {
                ZStack {
                    if plant.watered {
                        HStack {
                            Image(systemName: "hand.thumbsup").font(.largeTitle).foregroundColor(.blue)
                            Text("Watered").font(.largeTitle).foregroundColor(.blue)
                        }
                        .frame(width: 200, height: 80)
                        .background(
                            RoundedRectangle(cornerRadius: 15, style: .continuous)
                                .stroke(lineWidth: 3)
                                .foregroundColor(.blue)
                        )
                    } else {
                        HStack {
                            Image(systemName: "cloud.rain").font(.largeTitle).foregroundColor(.white)
                            Text("Water").font(.largeTitle).foregroundColor(.white)
                        }
                        .frame(width: 200, height: 80)
                        .background(Color.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                    }
                }
                
            }
            .disabled(plant.watered)
            
            Spacer()
        }
        .onDisappear {
            self.garden.sortPlants()
        }
    }
    
    func updatePlant() {
        garden.update(plant, updatePlantOrder: false)
        watchCommunicator?.update([plant])
    }
}

struct PlantDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let garden = Garden()
        return PlantDetailView(garden: garden, plant: garden.plants[0])
    }
}
