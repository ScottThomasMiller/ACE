//
//  LabeledImage.swift
//  BCILab
//
//  Created by Scott Miller on 8/7/21.
//

import Foundation
import SwiftUI

enum ImageLabels: Double {
    case face = 1.0
    case nonface = 2.0
    case blank = 3.0
    case start = 4.0
    case stop = 5.0
}

class LabeledImage {
    let image: Image
    let label: ImageLabels
    var appeared = false
    
    init(image: Image, label: ImageLabels) {
        self.image = image
        self.label = label
    }
}

func loadURL(_ url: URL) throws -> Image? {
    let data = try Data(contentsOf: url)
    #if os(macOS)
        guard let nsImage = NSImage(data: data) else {
            return nil
        }
        return Image(nsImage: nsImage)
    #else
        guard let uiImage = UIImage(data: data) else {
            return nil
        }
        return Image(uiImage: uiImage)
    #endif
}

func getAllFromSubdir(subdir: String, label: ImageLabels, maxImages: Int = 10000) -> [LabeledImage]  {
    var count = 0
    var labeledImages = [LabeledImage]()
    
    if let urls = Bundle.main.urls(forResourcesWithExtension: ".jpg", subdirectory: subdir) {
        for url in urls {
            guard let image = try? loadURL(url) else {
                print("Error loading image: \(url)")
                continue }
            
            let labeledImage = LabeledImage(image: image, label: label)
            labeledImages.append(labeledImage)
            count += 1

            guard count < maxImages else {
                break }
        }
    }
    
    print("loaded \(count) images from \(subdir) with label \(label)")
    return labeledImages
}


// Return a randomized array of faces and nonfaces, with blanks inserted between each image.
func prepareImages () -> [LabeledImage] {
    guard let blankURL = Bundle.main.url(forResource: "black_crosshair", withExtension: ".jpeg") else {
        try? BoardShim.logMessage(.LEVEL_INFO, "Error: cannot locate blank URL")
        return [LabeledImage]()
    }
    guard let blankImage = try? loadURL(blankURL) else {
        try? BoardShim.logMessage(.LEVEL_INFO, "Error: cannot load blank image")
        return [LabeledImage]()
    }
    
    let faceImages = getAllFromSubdir(subdir: "Faces", label: .face).shuffled()
    let nonFaceImages = getAllFromSubdir(subdir: "NonFaces", label: .nonface).shuffled()
    let allShuffledImages = (faceImages + nonFaceImages).shuffled()
    var finalImages = [LabeledImage]()
    
    var nImages = 0
    for image in allShuffledImages {
        let blank = LabeledImage(image: blankImage, label: .blank)
        finalImages.append(blank)
        finalImages.append(image)
        nImages += 1
    }

    try? BoardShim.logMessage(.LEVEL_INFO, "loaded \(nImages) images")
    return finalImages
}
