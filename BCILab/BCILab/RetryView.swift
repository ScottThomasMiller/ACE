//
//  Retry.swift
//  BCILab
//
//  Created by Scott Miller on 9/2/21.
//

import SwiftUI

struct RetryView: View {
    let message: String
    let headset: Headset
    @ObservedObject var appState: AppState
    
//    @Binding var isPrepared: Bool

    func setBoardStatus () {
        if let status = try? self.headset.board.isPrepared() {
            self.appState.isHeadsetReady = status }
        else {
            self.appState.isHeadsetReady = false
        }
    }
    
    func retry() {
        try? BoardShim.logMessage(.LEVEL_INFO, "reconnecting")
        try? self.headset.board.releaseSession()
        try? self.headset.board.prepareSession()
        setBoardStatus()
        if self.appState.isHeadsetReady {
            try? BoardShim.logMessage(.LEVEL_INFO, "reconnection successful")
        } else {
            try? BoardShim.logMessage(.LEVEL_INFO, "failed to reconnect")
        }
    }
    
    func cancel() {
        try? BoardShim.logMessage(.LEVEL_INFO, "reconnection canceled by user")
        setBoardStatus()
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

//struct RetryView_Previews: PreviewProvider {
//    static var previews: some UIView {
//        Group {
//            RetryView("The headset is not ready.")
//        }
//    }
//}
    
    
