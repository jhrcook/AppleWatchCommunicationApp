//
//  ContentView.swift
//  AppleWatchCommunicationApp
//
//  Created by Joshua on 8/2/20.
//  Copyright © 2020 Joshua Cook. All rights reserved.
//

import SwiftUI


struct PlantRow: View {
    
    @ObservedObject var garden: Garden
    var plant: Plant
    
    var body: some View {
        HStack {
            plant.loadPlantImage()
                .resizable()
                .scaledToFit()
                .frame(width: 50)
                .clipShape(Circle())
            
            Text(plant.name)
            
            Spacer()
            
            Image(systemName: "cloud.rain")
                .foregroundColor(.black)
                .font(.system(size: 20, weight: .regular, design: .default))
                .opacity(plant.watered ? 1 : 0)
        }
    }
}


struct ContentView: View {
    
    @ObservedObject var garden = Garden()
    
    var body: some View {
        NavigationView {
            List {
                ForEach(garden.plants) { plant in
                    NavigationLink(destination: PlantDetailView(garden: self.garden, plant: plant)) {
                        PlantRow(garden: self.garden, plant: plant)
                    }
                }
            }
            .navigationBarTitle("Garden")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
