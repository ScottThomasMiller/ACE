//
//  Retry.swift
//  BCILab
//
//  Created by Scott Miller on 9/2/21.
//

import SwiftUI

struct RetryView: View {
    @State var message: String
    @ObservedObject var appState: AppState
        
//    @Binding var isPrepared: Bool

    func setBoardStatus () {
        if let status = try? self.appState.headset.board.isPrepared() {
            self.appState.isHeadsetNotReady = !status }
        else {
            self.appState.isHeadsetNotReady = true
        }
    }
    
    func retry() {
        do {
            self.message = "Reconnecting..."
            try? BoardShim.logMessage(.LEVEL_INFO, "reconnecting")
            try? self.appState.headset.board.releaseSession()
            
            if appState.boardId != appState.headset.boardId {
                self.appState.headset = try Headset(boardId: self.appState.boardId)
            } else {
                try self.appState.headset.board.prepareSession()
            }
            
            setBoardStatus()
            if self.appState.isHeadsetNotReady {
                try? BoardShim.logMessage(.LEVEL_INFO, "failed to reconnect")
                self.message = "Try again"
            } else {
                try? BoardShim.logMessage(.LEVEL_INFO, "reconnection successful")
                self.message = "OK!"
            }
        }
        catch let bfError as BrainFlowException {
            try? BoardShim.logMessage(.LEVEL_ERROR, bfError.message)
            self.appState.isHeadsetNotReady = true
        } catch {
            try? BoardShim.logMessage(.LEVEL_ERROR, "\(error)")
            self.appState.isHeadsetNotReady = true
        }
    }
    
    func cancel() {
        try? BoardShim.logMessage(.LEVEL_INFO, "reconnection canceled by user")
        setBoardStatus()
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
    
    
