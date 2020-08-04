//
//  Plant.swift
//  AppleWatchCommunicationApp
//
//  Created by Joshua on 8/3/20.
//  Copyright © 2020 Joshua Cook. All rights reserved.
//

import SwiftUI

struct Plant: Codable, Identifiable {
    
    let id: UUID
    var name: String
    
    var watered: Bool = false
    var imageName: String? = nil
    
    init(name: String) {
        id = UUID()
        self.name = name
    }
    
    static let defaultImageName = "default-plant-image-1"
}


extension Plant {
    
    mutating func savePlantImage(uiImage: UIImage) {
        if let data = uiImage.jpegData(compressionQuality: 1.0) {
            let oldImageName = self.imageName
            imageName = "\(UUID().uuidString)_image.jpeg"
            let fileName = getDocumentsDirectory().appendingPathComponent(imageName!)
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    try data.write(to: fileName)
                } catch {
                    print("Unable to save image file.")
                }
            }
            
            if let oldImageName = oldImageName {
                deleteFile(at: getDocumentsDirectory().appendingPathComponent(oldImageName))
            }
        }
    }
    

    func deletePlantImageFile() {
        if let imageName = imageName {
            deleteFile(at: getDocumentsDirectory().appendingPathComponent(imageName))
        }
    }
    

    private func deleteFile(at URL: URL) {
        DispatchQueue.global(qos: .background).async {
            do {
                try FileManager.default.removeItem(at: URL)
            } catch {
                print("Unable to delete old image file: \(URL.absoluteString).")
            }
        }
    }
    
    
    func loadPlantImage() -> Image {
        if let imageName = self.imageName {
            let fileName = getDocumentsDirectory().appendingPathComponent(imageName)
            if let imageData = try? Data(contentsOf: fileName) {
                if let uiImage = UIImage(data: imageData) {
                    return Image(uiImage: uiImage)
                }
            }
        }
        return Image(Plant.defaultImageName)
    }
    
}
