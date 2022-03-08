//
//  CustomStyles.swift
//  BCILab
//
//  Created by Scott Miller on 9/3/21.
//

import Foundation
import SwiftUI

//Thanks to: https://www.hackingwithswift.com/quick-start/swiftui/customizing-button-with-buttonstyle

struct GrowingButton: ButtonStyle {
    let color: Color
    
    init(color: Color) {
        self.color = color
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(self.color)
            .foregroundColor(.white)
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed ? 1.2 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

struct ButtonText: View {
    private let text: String
    private let appGeometry: GeometryProxy

    init(_ text: String, _ appGeometry: GeometryProxy) {
        self.text = text
        self.appGeometry = appGeometry
    }

    var body: some View {
        Text(text)
            .fontWeight(.bold)
            .font(.title2)
            .padding()
            .foregroundColor(.white)
            .frame(maxHeight: appGeometry.size.height*0.025)
    }
}

//struct GrowingButton_Previews: PreviewProvider {
//    static var previews: some View {
//        Button(action: { print("test") }) {
//            Text("Retry")
//                .fontWeight(.bold)
//                .font(.title)
//                .padding()
//                .foregroundColor(.white)
//        }
//        .buttonStyle(GrowingButton(color: .green))
//    }
//}
