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
        
        ZStack {
            
            LinearGradient(gradient: Gradient(colors: [.blue, .green]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
                .opacity(1)
            
            VStack {
                Text("Apple Watch Communication")
                    .font(.system(size: 29, weight: .bold, design: .default))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(EdgeInsets(top: 10, leading: 5, bottom: 0, trailing: 5))
                
                RoundedRectangle(cornerRadius: 5, style: .circular)
                    .frame(height: 2)
                    .padding(.horizontal, 40)
                    .foregroundColor(.white)
                
                Spacer()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
