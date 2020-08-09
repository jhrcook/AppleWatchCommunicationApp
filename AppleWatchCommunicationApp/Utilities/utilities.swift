//
//  utilities.swift
//  AppleWatchCommunicationApp
//
//  Created by Joshua on 8/3/20.
//  Copyright © 2020 Joshua Cook. All rights reserved.
//

import UIKit

func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
}



/// Delete a file in a background thread.
/// - Parameter URL: The URL of the file to delete.
func deleteFile(at URL: URL) {
    DispatchQueue.global(qos: .background).async {
        do {
            try FileManager.default.removeItem(at: URL)
        } catch {
            print("Unable to delete old image file: \(URL.absoluteString).")
        }
    }
}



enum JPEGQuality: CGFloat {
    case lowest  = 0
    case low     = 0.25
    case medium  = 0.5
    case high    = 0.75
    case highest = 1
}


/// Copy a JPEG file to another file. This is useful to compressing a JPEG file further.
/// - Parameters:
///   - filename: The URL of the original file.
///   - quality: The quality of compression.
/// - Throws: Various errors can be thrown as this process has multiple modes of failure.
/// - Returns: The URL of the compressed file.
func copyJPEG(at filename: URL, quality: JPEGQuality = .highest) throws -> URL {
    let imageData = try Data(contentsOf: filename)
    if let uiImage = UIImage(data: imageData) {
        if let data = uiImage.jpegData(compressionQuality: quality.rawValue) {
            let newFilename = "\(UUID().uuidString)_image.jpeg"
            let newURL = getDocumentsDirectory().appendingPathComponent(newFilename)
            try data.write(to: newURL)
            return newURL
        } else {
            throw WCDataParsingError.unableToCompressJPEGData
        }
    } else {
        throw WCDataParsingError.unableToReadImageData
    }
}
