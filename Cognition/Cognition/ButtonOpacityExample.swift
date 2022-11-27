//
//  ButtonOpacityExample.swift
//  Cognition
//
//  Created by Scott Miller on 11/24/22.
//

import Foundation
import SwiftUI


struct ButtonOpacityExample: View {
    @State private var opacity = 1.0
    
    var body: some View {
        Button("Press here") {
            withAnimation {
                opacity -= 0.2
            }
        }
        .padding()
        .opacity(opacity)
    }
}
