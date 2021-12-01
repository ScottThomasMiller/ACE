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
            self.headsetStatus = "disconnected" }
        
        if self.isHeadsetReady {
            try? BoardShim.logMessage(.LEVEL_INFO, "connection successful")
            self.headsetStatus = "connected"
            self.isMainMenuActive = false }
        else {
            try? BoardShim.logMessage(.LEVEL_INFO, "failed to connect")
            self.headsetStatus = "disconnected" }
    }

    var body: some View {
        VStack {
            Spacer()
            Text("Connect to Headset")
                .font(.largeTitle)
                .foregroundColor(.black)
                //.baselineOffset(40)
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
            //Spacer()
            //TextRTView(message: $message)
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
    
    
