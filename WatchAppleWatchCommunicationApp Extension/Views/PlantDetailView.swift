//
//  PlantDetailView.swift
//  WatchAppleWatchCommunicationApp Extension
//
//  Created by Joshua on 8/4/20.
//  Copyright © 2020 Joshua Cook. All rights reserved.
//

import SwiftUI

struct PlantDetailView: View {
    
    @ObservedObject var garden: Garden
    @State private var plant: Plant
    
    init(garden: Garden, plant: Plant) {
        self.garden = garden
        self._plant = State(initialValue: plant)
    }
    
    var body: some View {
        ScrollView {
            VStack {
                plant.loadPlantImage()
                    .resizable()
                    .scaledToFit()
                    .clipShape(Circle())
                    .padding()
                
                Text(plant.name).padding()
                
                Button(action: {
                    if !self.plant.watered {
                        self.plant.watered = true
                        self.garden.update(self.plant)
                    }
                }) {
                    ZStack {
                        if plant.watered {
                            HStack {
                                Image(systemName: "hand.thumbsup").font(.system(size: 23)).foregroundColor(.white)
                                Text("Watered").font(.system(size: 23)).foregroundColor(.white)
                            }
                            .frame(width: 150, height: 50)
                            .background(
                                RoundedRectangle(cornerRadius: 15, style: .continuous)
                                    .stroke(lineWidth: 3)
                                    .foregroundColor(.blue)
                            )
                        } else {
                            HStack {
                                Image(systemName: "cloud.rain").font(.system(size: 23)).foregroundColor(.white)
                                Text("Water").font(.system(size: 23)).foregroundColor(.white)
                            }
                            .frame(width: 150, height: 50)
                            .background(Color.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                        }
                    }
                    
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}


struct PlantDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let garden = Garden()
        return PlantDetailView(garden: garden, plant: garden.plants[0])
    }
}
