//
//  Retry.swift
//  BCILab
//
//  Created by Scott Miller on 9/2/21.
//

import Foundation
import SwiftUI

struct Retry: View {
    let message: String
    
    init(_ message: String) {
        self.message = message
    }
    
    func retry() {
        print("retrying!")
    }
    
    func cancel() {
        print("cancelling!")
    }
    
    var body: some View {
        VStack {
            Text(message).font(.largeTitle)
                .baselineOffset(40)
            HStack {
                Button(action: retry) {
                    Text("Retry")
                        .fontWeight(.bold)
                        .font(.title)
                        .padding()
                        .foregroundColor(.white)
                }
                .buttonStyle(GrowingButton(color: .green))
                Button(action: cancel) {
                    Text("Cancel")
                        .fontWeight(.bold)
                        .font(.title)
                        .padding()
                        .foregroundColor(.white)
                }
                .buttonStyle(GrowingButton(color: .red))
            }
        }.frame(width: 450, height: 350, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
        .background(Color(.white))
        .border(/*@START_MENU_TOKEN@*/Color.black/*@END_MENU_TOKEN@*/, width: 3)
        .cornerRadius(7)
    }
}

struct Retry_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            Retry("The headset is not ready.")
        }
    }
}
    
    
