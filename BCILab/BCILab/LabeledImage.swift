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
}

struct LabeledImage {
    let image: UIImage
    let label: ImageLabels
}

func appendImages(_ name: String,  label: ImageLabels, labeledImages: inout [LabeledImage])  {
    let urls = Bundle.main.urls(forResourcesWithExtension: ".jpg", subdirectory: name)
    for url in urls! {
        guard let image = try? UIImage(data: Data(contentsOf: url)) else {
            print("Error loading image: \(url)")
            continue
        }
        let labeledImage = LabeledImage(image: image, label: label)
        labeledImages.append(labeledImage)
    }
}

func prepareImages () -> [LabeledImage] {
    // replace the labeled animation images with a new set, which is a shuffling of the current animation images with blanks inserted between each image:
    guard let blankURL = Bundle.main.url(forResource: "green_crosshair", withExtension: ".png") else {
        print("Error: cannot load blank image")
        return [LabeledImage]()
    }
    let blankImage = try! UIImage(data: Data(contentsOf: blankURL))
    let blank = LabeledImage(image: blankImage!, label: ImageLabels.blank)
    var labeledImages = [LabeledImage]()
    appendImages("Faces", label: ImageLabels.face, labeledImages: &labeledImages)
    appendImages("NonFaces", label: ImageLabels.nonface, labeledImages: &labeledImages)
    let shuffledImages = labeledImages.shuffled()
    var finalImages = [LabeledImage]()
    for image in shuffledImages {
        finalImages.append(blank)
        finalImages.append(image)
    }
    return finalImages
}
