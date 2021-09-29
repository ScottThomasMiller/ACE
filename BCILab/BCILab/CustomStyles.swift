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
            .frame(width: 160, height: 30, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
            .padding()
            .background(self.color)
            .foregroundColor(.white)
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed ? 1.2 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
            .frame(width: 210, height: 60, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
    }
}

//                .frame(width: 150, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
//                .background(Color.green)
//                .cornerRadius(40)

struct GrowingButton_Previews: PreviewProvider {
    static var previews: some View {
        Button(action: { print("test") }) {
            Text("Retry")
                .fontWeight(.bold)
                .font(.title)
                .padding()
                .foregroundColor(.white)
        }
        .buttonStyle(GrowingButton(color: .green))
    }
}
