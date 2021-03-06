//
//  Plant.swift
//  AppleWatchCommunicationApp
//
//  Created by Joshua on 8/3/20.
//  Copyright © 2020 Joshua Cook. All rights reserved.
//

import SwiftUI

struct Plant: Codable, Identifiable {
    
    let id: String
    var name: String
    
    var watered: Bool = false
    var imageName: String? = nil
    
    init(name: String) {
        id = UUID().uuidString
        self.name = name
    }
    
    init(id: String, name: String) {
        self.id = id
        self.name = name
    }
    
    static let defaultImageName = "default-plant-image-1"
}


// Images

extension Plant {
    
    func makeImageName() -> String {
        return "\(UUID().uuidString)_image.jpeg"
    }
    
    mutating func savePlantImage(uiImage: UIImage) {
        if let data = uiImage.jpegData(compressionQuality: 1.0) {
            let oldImageName = self.imageName
            imageName = makeImageName()
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
    
    mutating func savePlantImage(fromURL url: URL) {
        let oldImageName = self.imageName
        imageName = makeImageName()
        let fileURL = getDocumentsDirectory().appendingPathComponent(imageName!)
        do {
            try FileManager().copyItem(at: url, to: fileURL)
            print("Copied file to new location successfully")
            if let oldImageName = oldImageName {
                deleteFile(at: getDocumentsDirectory().appendingPathComponent(oldImageName))
            }
        } catch {
            print("Unable to copy file to new location.")
        }
    }
    

    func deletePlantImageFile() {
        if let imageName = imageName {
            deleteFile(at: getDocumentsDirectory().appendingPathComponent(imageName))
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
