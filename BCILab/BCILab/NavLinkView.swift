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
                //.font(.title)
                .font(.title2)
                .padding()
                .foregroundColor(.black)
            Spacer(minLength: 2)
            //Image(id).resizable().frame(width: 40, height: 40)
            Image(id)
                .resizable()
                .frame(minWidth: 10, idealWidth: 20, maxWidth: 40, minHeight: 10, idealHeight: 20, maxHeight: 40, alignment: .center)
        }
    }
}
