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

protocol InitializedImage {
    //init?(data: Data)
    init()
}

class LabeledImageGeneric<ImageType> where ImageType: InitializedImage {
    let image: ImageType
    let label: ImageLabels
    var appeared = false

    init(image: ImageType, label: ImageLabels) {
        self.image = image
        self.label = label
    }

    func getAllFromSubdir(subdir: String, label: ImageLabels, maxImages: Int = 10000) -> [LabeledImage<ImageType>]  {
        var count = 0
        var labeledImages = [LabeledImage<ImageType>]()
        
        if let urls = Bundle.main.urls(forResourcesWithExtension: nil, subdirectory: subdir) {
            for url in urls {
                guard let data = try? Data(contentsOf: url) else {
                    print("Error loading image: \(url)")
                    continue }
                
                guard let image = ImageType(data: data) else {
                    print("Error converting image: \(url)")
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
    func prepareImages () -> [LabeledImage<ImageType>] {
        guard let blankURL = Bundle.main.url(forResource: "black_crosshair", withExtension: ".jpeg") else {
            try? BoardShim.logMessage(.LEVEL_INFO, "Error: cannot locate blank image")
            return [LabeledImage]()
        }
        
        guard let blankImage = try? ImageType(data: Data(contentsOf: blankURL)) else {
            try? BoardShim.logMessage(.LEVEL_INFO, "Error: cannot load blank image")
            return [LabeledImage]()
        }
        
        let faceImages = getAllFromSubdir(subdir: "Faces", label: ImageLabels.face).shuffled()
        let nonFaceImages = getAllFromSubdir(subdir: "NonFaces", label: ImageLabels.nonface).shuffled()
        var finalImages = [LabeledImage<ImageType>]()
        
        var nImages = 0
        for (faceImage, nonfaceImage) in zip(faceImages, nonFaceImages) {
            guard nImages < 100 else {
                break }
            let blank = LabeledImage(image: blankImage, label: ImageLabels.blank)
            finalImages.append(blank)
            finalImages.append(faceImage)
            finalImages.append(blank)
            finalImages.append(nonfaceImage)
            nImages += 1
        }

        try? BoardShim.logMessage(.LEVEL_INFO, "loaded \(nImages) faces and \(nImages) nonfaces")
        return finalImages
    }

}


