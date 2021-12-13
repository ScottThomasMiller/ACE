//
//  LabeledImage.swift
//  BCILab
//
//  Created by Scott Miller on 8/7/21.
//

import Foundation
import SwiftUI

enum MarkerType: Double {
    case unlabeled = -99
    case start  = -3
    case stop = -2
    case blank = -1
    case image = 1
}

class LabeledImage {
    let image: Image
    let marker: Double
    var appeared = false
    
    init(image: Image, marker: Double) {
        self.image = image
        self.marker = marker
    }
}

class SlideShow {
    let maxImages: Int = 10000
    var images = [LabeledImage]()
    var labels = [String]()
    
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

    func loadAllFromURL(from: URL, marker: Double) -> [LabeledImage]  {
        var count = 0
        var labeledImages = [LabeledImage]()
        
        if let urls = FileManager.default.imageURLs(of: from) {
            for url in urls {
                guard let image = try? loadURL(url) else {
                    try? BoardShim.logMessage(.LEVEL_ERROR, "Error loading image: \(url)")
                    continue }
                
                let labeledImage = LabeledImage(image: image, marker: marker)
                labeledImages.append(labeledImage)
                count += 1

                guard count < maxImages else {
                    try? BoardShim.logMessage(.LEVEL_INFO, "reached limit of \(maxImages) images")
                    break }
            }
        }
        
        print("loaded \(count) images from URL \(from) with marker \(marker)")
        return labeledImages
    }

    func loadAllFromSubdir(subdir: String, marker: Double) -> [LabeledImage]  {
        var count = 0
        var labeledImages = [LabeledImage]()
        
        if let urls = Bundle.main.urls(forResourcesWithExtension: ".jpg", subdirectory: subdir) {
            for url in urls {
                guard let image = try? loadURL(url) else {
                    try? BoardShim.logMessage(.LEVEL_ERROR, "Error loading image: \(url)")
                    continue }
                
                let labeledImage = LabeledImage(image: image, marker: marker)
                labeledImages.append(labeledImage)
                count += 1

                guard count < maxImages else {
                    try? BoardShim.logMessage(.LEVEL_INFO, "reached limit of \(maxImages) images")
                    break }
            }
        }
        
        print("loaded \(count) images from \(subdir) with marker \(marker)")
        return labeledImages
    }

    func getBlankImage() -> Image? {
        guard let blankURL = Bundle.main.url(forResource: "black_crosshair", withExtension: ".jpeg") else {
            try? BoardShim.logMessage(.LEVEL_INFO, "Error: cannot locate blank URL")
            return nil
        }
        guard let blankImage = try? loadURL(blankURL) else {
            try? BoardShim.logMessage(.LEVEL_INFO, "Error: cannot load blank image")
            return nil
        }
        
        return blankImage
    }

    // Return a randomized array of faces and nonfaces, with blanks inserted between each image.
    func prepareFaces () -> [LabeledImage] {
        guard let blankImage = getBlankImage() else {
            try? BoardShim.logMessage(.LEVEL_INFO, "Error: cannot load blank image")
            return [LabeledImage]()
        }
        
        let faceImages = loadAllFromSubdir(subdir: "Faces", marker: 1.0).shuffled()
        let nonFaceImages = loadAllFromSubdir(subdir: "NonFaces", marker: 2.0).shuffled()
        let allShuffledImages = (faceImages + nonFaceImages).shuffled()
        var finalImages = [LabeledImage]()
        
        var nImages = 0
        for image in allShuffledImages {
            let blank = LabeledImage(image: blankImage, marker: MarkerType.blank.rawValue)
            finalImages.append(blank)
            finalImages.append(image)
            nImages += 1
        }

        try? BoardShim.logMessage(.LEVEL_INFO, "loaded \(nImages) images")
        return finalImages
    }

    // Return a randomized array of all subfolders, with blanks inserted between each image.
    // Use the subfolder name as the image label.
    func prepareImages (from folder: URL) -> Bool {
        print("before: \(images.count)")
        var marker: Double = 0
        var newImages = [LabeledImage]()
 
        guard let blankImage = getBlankImage() else {
            try? BoardShim.logMessage(.LEVEL_INFO, "Error: cannot load blank image")
            return false
        }
        guard let subFolders = FileManager.default.subFolders(of: folder) else {
            try? BoardShim.logMessage(.LEVEL_INFO, "Error: cannot get subfolders for folder: \(folder)")
            return false
        }

        let unsortedLabelURLs = Dictionary(uniqueKeysWithValues: subFolders.map { ($0.lastPathComponent, $0) })
        self.labels = subFolders.map {$0.lastPathComponent}
        self.labels.sort()
        let labelURLs = unsortedLabelURLs.sorted( by: { $0.0 < $1.0 })
        try? BoardShim.logMessage(.LEVEL_INFO, "preparing images from URL: \(folder)")
        
        for (label, subfolder) in labelURLs {
            guard let offset = self.labels.firstIndex(of: label) else {
                try? BoardShim.logMessage(.LEVEL_ERROR, "Invalid label: \(label)")
                break }
            marker = MarkerType.image.rawValue + Double(offset)
            newImages += loadAllFromURL(from: subfolder, marker: marker)
        }
        
        var finalImages = [LabeledImage]()
        for image in newImages.shuffled() {
            let blank = LabeledImage(image: blankImage, marker: MarkerType.blank.rawValue)
            finalImages.append(blank)
            finalImages.append(image)
        }

        self.images = finalImages
        try? BoardShim.logMessage(.LEVEL_INFO, "loaded \(newImages.count) images total " +
                                               "across \(self.labels.count) labels")
        return true
    }
}
