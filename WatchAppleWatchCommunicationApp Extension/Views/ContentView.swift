//
//  ContentView.swift
//  WatchAppleWatchCommunicationApp Extension
//
//  Created by Joshua on 8/4/20.
//  Copyright © 2020 Joshua Cook. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        GardenListView(garden: Garden(), phoneCommunicator: WatchToPhoneCommunicator())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
