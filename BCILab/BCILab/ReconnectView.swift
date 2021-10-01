//
//  Retry.swift
//  BCILab
//
//  Created by Scott Miller on 9/2/21.
//

import SwiftUI

struct ReconnectView: View {
    @State var message: String
    @ObservedObject var appState: AppState
        
    func setBoardStatus () {
        if let tempHeadset = self.appState.headset {
            if let _ = try? tempHeadset.board.isPrepared() {
                self.appState.isHeadsetNotReady = false }
            else {
                self.appState.isHeadsetNotReady = true
            }
        } else {
            self.appState.isHeadsetNotReady = true
        }
    }
    
    func retry() {
        self.message = "Connecting..."
        if let tempHeadset = self.appState.headset {
            tempHeadset.isStreaming = false
            try? tempHeadset.board.stopStream()
            sleep(2)
            try? tempHeadset.board.releaseSession()
            sleep(2)
            
        }

        self.appState.headset = try? Headset(boardId: self.appState.boardId)
        setBoardStatus()
        
        if self.appState.isHeadsetNotReady {
            try? BoardShim.logMessage(.LEVEL_INFO, "failed to connect")
            self.message = "Try again"
        } else {
            try? BoardShim.logMessage(.LEVEL_INFO, "connection successful")
            self.message = "OK!"
        }
    }

    var body: some View {
        VStack {
            Text(self.message).font(.largeTitle)
                .baselineOffset(40)
            HStack {
                Button(action: retry) {
                    Text("Connect")
                        .fontWeight(.bold)
                        .font(.title)
                        .padding()
                        .foregroundColor(.white)
                }
                .buttonStyle(GrowingButton(color: .blue))
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
    
    
