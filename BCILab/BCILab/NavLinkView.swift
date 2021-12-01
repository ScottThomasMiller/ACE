//
//  File.swift
//  BCILab
//
//  Created by Scott Miller on 11/27/21.
//

import Foundation
import SwiftUI

struct NavLinkView: View {
    let id: String
    let label: String
    
    var body: some View {
        HStack(alignment: .center) {
            Text(label)
                .fontWeight(.bold)
                .font(.title)
                .padding()
                .foregroundColor(.black)
            Spacer(minLength: 2)
            Image(id).resizable().frame(width: 40, height: 40)
        }
    }
}
