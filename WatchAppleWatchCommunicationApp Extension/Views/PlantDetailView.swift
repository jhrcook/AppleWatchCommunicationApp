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
    
    var phoneCommunicator: PhoneAndWatchCommunicator?
    
    init(garden: Garden, plant: Plant, phoneCommunicator: PhoneAndWatchCommunicator? = nil) {
        self.garden = garden
        self._plant = State(initialValue: plant)
        self.phoneCommunicator = phoneCommunicator
    }
    
    var body: some View {
        ScrollView {
            GeometryReader { geo in
                VStack {
                    self.plant.loadPlantImage()
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width * 0.9, height: geo.size.width * 0.9)
                        .clipShape(Circle())
                        .padding()
                    
                    Text(self.plant.name).padding()
                    
                    Button(action: {
                        if !self.plant.watered {
                            self.plant.watered = true
                            self.garden.update(self.plant)
                            if let phoneCommunicator = self.phoneCommunicator {
                                phoneCommunicator.update([self.plant])
                            }
                        }
                    }) {
                        ZStack {
                            if self.plant.watered {
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
}


struct PlantDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let garden = Garden()
        return PlantDetailView(garden: garden, plant: garden.plants[0])
    }
}
