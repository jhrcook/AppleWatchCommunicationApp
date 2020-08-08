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
    
    var watchCommunicator: PhoneAndWatchCommunicator?
    
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    @State private var image: Image
    
    init(garden: Garden, plant: Plant, watchCommunicator: PhoneAndWatchCommunicator? = nil) {
        self.garden = garden
        _plant = State(initialValue: plant)
        self.watchCommunicator = watchCommunicator
        _image = State(initialValue: plant.loadPlantImage())
    }
    
    var body: some View {
        GeometryReader { geo in
            VStack {
                TextField("Plant name", text: self.$plant.name, onCommit: self.updatePlant)
                    .font(.title)
                    .multilineTextAlignment(.center)
                    .frame(width: 200)
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .padding(.bottom, 20)
                
                ZStack {
                    self.image
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width * 0.8, height: geo.size.width * 0.8)
                        .clipShape(Circle())
                        .shadow(radius: 15)
                    
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Button(action: {
                                self.showingImagePicker = true
                            }) {
                                Image(systemName: "camera.circle")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50)
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    .sheet(isPresented: self.$showingImagePicker, onDismiss: self.loadImage) {
                        ImagePicker(image: self.$inputImage)
                    }
                }
                .frame(width: geo.size.width, height: geo.size.width)
                
                
                Spacer()
                
                Button(action: {
                    self.plant.watered = true
                    self.updatePlant()
                }) {
                    ZStack {
                        if self.plant.watered {
                            HStack {
                                Image(systemName: "hand.thumbsup").font(.largeTitle).foregroundColor(.blue)
                                Text("Watered").font(.largeTitle).foregroundColor(.blue)
                            }
                            .frame(width: 200, height: 70)
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
                            .frame(width: 200, height: 70)
                            .background(Color.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                        }
                    }
                    
                }
                .disabled(self.plant.watered)
                
                Spacer()
            }
            .onDisappear {
                self.garden.sortPlants()
            }
        }
    }
    
    func updatePlant() {
        garden.update(plant, updatePlantOrder: false)
        if let communicator = watchCommunicator {
            communicator.update([plant])
        }
    }
    
    func loadImage() {
        guard let inputImage = inputImage else { return }
        plant.savePlantImage(uiImage: inputImage)
        if let communicator = watchCommunicator {
            communicator.transferImage(for: plant)
        }
        updatePlant()
        image = Image(uiImage: inputImage)
    }
    
}

struct PlantDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let garden = Garden()
        return PlantDetailView(garden: garden, plant: garden.plants[0])
    }
}
