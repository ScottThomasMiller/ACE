//
//  LabeledImage.swift
//  BCILab
//
//  Created by Scott Miller on 2/17/22.
//

import Foundation
import SwiftUI

enum MarkerType: Double {
    case unlabeled = -99
    case end = -4
    case start  = -3
    case stop = -2
    case blank = -1
    case image = 1
}

class LabeledImage: Identifiable {
    let id = UUID()
    let image: Image
    let marker: Double
    var appeared = false
    
    init(image: Image, marker: Double) {
        self.image = image
        self.marker = marker
    }
}
