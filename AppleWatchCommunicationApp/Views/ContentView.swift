//
//  ContentView.swift
//  AppleWatchCommunicationApp
//
//  Created by Joshua on 8/2/20.
//  Copyright © 2020 Joshua Cook. All rights reserved.
//

import SwiftUI


struct ContentView: View {
    
    var body: some View {
        GardenListView(garden: Garden(), watchCommunicator: PhoneAndWatchCommunicator())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
