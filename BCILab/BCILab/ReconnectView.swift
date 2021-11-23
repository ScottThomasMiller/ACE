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
    
    func reconnect() {
        try? BoardShim.logMessage(.LEVEL_INFO, "ReconnectView.reconnect: \(self.appState.boardId.name)")
        
        try? BoardShim.logMessage(.LEVEL_INFO, "deactivating the board")
        self.appState.headset.isActive = false // terminates the streaming loop
        sleep(2)
        
        if let board = self.appState.headset.board {
            try? board.stopStream()
            try? board.releaseSession() }
        
        self.appState.headset.board = nil
        
        do {
            try? BoardShim.logMessage(.LEVEL_INFO, "connect to board ID: \(self.appState.boardId)")
            self.appState.headset = try Headset(boardId: self.appState.boardId)
            self.appState.isHeadsetReady = true }
        catch {
            self.appState.isHeadsetReady = false
            self.appState.headsetStatus = "disconnected" }
        
        if self.appState.isHeadsetReady {
            try? BoardShim.logMessage(.LEVEL_INFO, "connection successful")
            self.message = "Success"
            self.appState.isMainMenuActive = false
            self.appState.headsetStatus = "connected" }
        else {
            try? BoardShim.logMessage(.LEVEL_INFO, "failed to connect")
            self.message = "Try again" }
    }

    var body: some View {
        VStack {
            Text(self.message).font(.largeTitle).baselineOffset(40)
            HStack {
                Button(action: reconnect) {
                    Text("Connect")
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
    
    
