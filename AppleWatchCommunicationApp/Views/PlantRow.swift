//
//  PlantRow.swift
//  AppleWatchCommunicationApp
//
//  Created by Joshua on 8/4/20.
//  Copyright © 2020 Joshua Cook. All rights reserved.
//

import SwiftUI


struct PlantRow: View {
    
    @ObservedObject var garden: Garden
    var plant: Plant
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack {
            plant.loadPlantImage()
                .resizable()
                .scaledToFill()
                .frame(width: 50, height: 50)
                .clipShape(Circle())
            
            Text(plant.name)
            
            Spacer()
            
            Image(systemName: "cloud.rain")
                .foregroundColor(colorScheme == .dark ? .white : .black)
                .font(.system(size: 20, weight: .regular, design: .default))
                .opacity(plant.watered ? 1 : 0)
        }
    }
}


struct PlantRow_Previews: PreviewProvider {
    static var previews: some View {
        let garden = Garden()
        return PlantRow(garden: garden, plant: garden.plants[0])
    }
}
