//
//  AppState.swift
//  BCILab
//
//  Created by Scott Miller on 9/28/21.
//

import SwiftUI

//extension UIImage {
//    convenience init?(data: Data) {
//    }
//}

class ImageState: ObservableObject {
    @Published var images = prepareImages()
}
