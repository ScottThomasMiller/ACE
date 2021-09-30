//
//  Retry.swift
//  BCILab
//
//  Created by Scott Miller on 9/2/21.
//

import SwiftUI

struct RetryView: View {
    var headset: Headset?
    @State var message: String
    @ObservedObject var appState: AppState
        
    func setBoardStatus () {
        if let tempHeadset = self.headset {
            if let status = try? tempHeadset.board.isPrepared() {
                self.appState.isHeadsetNotReady = !status }
            else {
                self.appState.isHeadsetNotReady = true
            }
        } else {
            self.appState.isHeadsetNotReady = true
        }
    }
    
    func retry() {
        self.message = "Reconnecting..."
        if let tempHeadset = self.headset {
            if tempHeadset.isStreaming {
                tempHeadset.isStreaming = false
                sleep(1)
            }
            _ = tempHeadset.reconnect()
            tempHeadset.isStreaming = true
        }

        setBoardStatus()
        
        if self.appState.isHeadsetNotReady {
            try? BoardShim.logMessage(.LEVEL_INFO, "failed to reconnect")
            self.message = "Try again"
        } else {
            try? BoardShim.logMessage(.LEVEL_INFO, "reconnection successful")
            self.message = "OK!"
//            if let headsetCopy = self.headset {
//                DispatchQueue.global(qos: .background).async {
//                    headsetCopy.streamEEG()
//                }
//            }
        }
    }

    var body: some View {
        VStack {
            Text(self.message).font(.largeTitle)
                .baselineOffset(40)
            HStack {
                Button(action: retry) {
                    Text("Retry")
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
    
    
