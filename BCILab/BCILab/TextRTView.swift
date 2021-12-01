//
//  TextRTView.swift
//  BCILab
//
//  Created by Scott Miller on 11/27/21.
//

import Foundation
import SwiftUI

struct TextRTView: View {
    @Binding var message: String
    
    var body: some View {
        Text(message)
            .fontWeight(.bold)
            .font(.title)
            .padding()
            .foregroundColor(.black)
    }
}
