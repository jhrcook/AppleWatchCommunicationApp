//
//  ContentView.swift
//  AppleWatchCommunicationApp
//
//  Created by Joshua on 8/2/20.
//  Copyright © 2020 Joshua Cook. All rights reserved.
//

import SwiftUI


struct ContentView: View {
    
    @ObservedObject var garden = Garden()
    var watchCommunicator = PhoneToWatchCommunicator()
    
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
