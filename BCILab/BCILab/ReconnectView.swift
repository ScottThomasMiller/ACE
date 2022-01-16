//
//  Retry.swift
//  BCILab
//
//  Created by Scott Miller on 9/2/21.
//

import SwiftUI

struct ReconnectView: View {
    @Binding var headset: Headset
    @Binding var boardId: BoardIds
    @Binding var headsetStatus: String
    @Binding var isMainMenuActive: Bool
    @Binding var isHeadsetReady: Bool

    //@State private var message: String = "Reconnect to Headet"
    @State private var buttonLabel: String = "Connect"
    //@ObservedObject var appState: AppState
    
    func reconnect() {
        var newStatus = ""
        try? BoardShim.logMessage(.LEVEL_INFO, "reconnect(). deactivating the board")
        self.headset.isActive = false // terminates the streaming loop
        sleep(2)
        
        if let board = self.headset.board {
            try? board.stopStream()
            try? board.releaseSession() }
        
        self.headset.board = nil
        
        do {
            try? BoardShim.logMessage(.LEVEL_INFO, "connect to board ID: \(self.boardId)")
            self.headset = try Headset(boardId: self.boardId)
            self.isHeadsetReady = true }
        catch {
            self.isHeadsetReady = false
            newStatus = "failed to connect" }
        
        if self.isHeadsetReady {
            newStatus = "connected"
            self.isMainMenuActive = false }
        else {
            newStatus = "cannot connect" }
        
        try? BoardShim.logMessage(.LEVEL_INFO, newStatus)
        self.headsetStatus = newStatus
    }

    var body: some View {
        VStack {
            Spacer()
            HStack {
                Button(action: {
                   self.headsetStatus = "reconnecting..."
                   reconnect()
                }) {
                    Text(self.buttonLabel)
                        .fontWeight(.bold)
                        .font(.title)
                        .padding()
                        .foregroundColor(.black)
                }
                .buttonStyle(GrowingButton(color: .blue))
            }

            Spacer()
        }
        //.frame(width: 450, height: 350, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
        //.background(Color(.white))
        //.border(/*@START_MENU_TOKEN@*/Color.black/*@END_MENU_TOKEN@*/, width: 3)
        //.cornerRadius(7)
    }
}

//struct RetryView_Previews: PreviewProvider {
//    static var previews: some UIView {
//        Group {
//            RetryView("The headset is not ready.")
//        }
//    }
//}
    
    
