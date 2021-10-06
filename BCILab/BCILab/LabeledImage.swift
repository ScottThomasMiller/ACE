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
    let image: UIImage
    let label: ImageLabels
    var appeared = false
    
    init(image: UIImage, label: ImageLabels) {
        self.image = image
        self.label = label
    }
}

func getAllFromSubdir(subdir: String, label: ImageLabels, maxImages: Int = 10000) -> [LabeledImage]  {
    var count = 0
    var labeledImages = [LabeledImage]()
    
    if let urls = Bundle.main.urls(forResourcesWithExtension: ".jpg", subdirectory: subdir) {
        for url in urls {
            guard let image = try? UIImage(data: Data(contentsOf: url)) else {
                print("Error loading image: \(url)")
                continue
            }
            let labeledImage = LabeledImage(image: image, label: label)
            labeledImages.append(labeledImage) 
            count += 1

            guard count < maxImages else {
                break
            }
        }
    }
    
    print("loaded \(count) images from \(subdir) with label \(label)")
    return labeledImages
}

// Return a randomized array of faces and nonfaces, with blanks inserted between each image.
func prepareImages () -> [LabeledImage] {
    guard let blankURL = Bundle.main.url(forResource: "green_crosshair", withExtension: ".png") else {
        print("Error: cannot load blank image")
        return [LabeledImage]()
    }
    let blankImage = try! UIImage(data: Data(contentsOf: blankURL))
    let blank = LabeledImage(image: blankImage!, label: ImageLabels.blank)
    let faceImages = getAllFromSubdir(subdir: "Faces", label: ImageLabels.face).shuffled()
    let nonFaceImages = getAllFromSubdir(subdir: "NonFaces", label: ImageLabels.nonface).shuffled()
    let shuffledImages = faceImages[..<50] + nonFaceImages[..<50]
    var finalImages = [LabeledImage]()
    
    var nface = 0
    var nnonface = 0
    var nblank = 0
    for image in shuffledImages.shuffled() {
        finalImages.append(blank)
        nblank += 1
        finalImages.append(image)
        switch image.label {
        case .face:
            nface += 1
        case .nonface:
            nnonface += 1
        default:
            print("Error. unknown label")
        }
    }

    print("num blank: \(nblank) num face: \(nface) num nonface: \(nnonface)")
    return finalImages
}
