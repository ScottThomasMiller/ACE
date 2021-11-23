//
//  ErrorView.swift
//  BCILab
//
//  Created by Scott Miller on 11/21/21.
//

import Foundation
import SwiftUI

//
//  Retry.swift
//  BCILab
//
//  Created by Scott Miller on 9/2/21.
//

import SwiftUI

struct ErrorView: View {
    @State var errorMsg: String
    @ObservedObject var appState: AppState

    func ack() {
        self.appState.isMainMenuActive = true
    }

    var body: some View {
        VStack {
            Text(self.errorMsg).font(.largeTitle).baselineOffset(40)
            HStack {
                Button(action: ack) {
                    Text("OK")
                        .fontWeight(.bold)
                        .font(.title)
                        .padding()
                        .foregroundColor(.white)
                }
                .buttonStyle(GrowingButton(color: .blue))
            }
        }
        .frame(width: 450, height: 350, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
        .background(Color(.white))
        .border(/*@START_MENU_TOKEN@*/Color.black/*@END_MENU_TOKEN@*/, width: 3)
        .cornerRadius(7)

    }
}

//struct RetryView_Previews: PreviewProvider {
//    static var previews: some UIView {
//        Group {
//            RetryView("The headset is not ready.")
//        }
//    }
//}
    
    
