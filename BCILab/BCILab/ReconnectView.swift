//
//  Retry.swift
//  BCILab
//
//  Created by Scott Miller on 9/2/21.
//

import SwiftUI

struct Message: Identifiable {
    let id = UUID()
    let text: String
}

struct ReconnectView: View {
    @Binding var headset: Headset
    @Binding var boardId: BoardIds
    @Binding var isMainMenuActive: Bool
    @State private var buttonLabel: String = "Connect"
    
    func reconnect() {
        try? BoardShim.logMessage(.LEVEL_INFO, "reconnect(). deactivating the board")
        self.buttonLabel = "Reconnecting..."
        self.headset.isActive = false // terminates the streaming loop
        sleep(2)
        
        if let board = self.headset.board {
            try? board.stopStream()
            try? board.releaseSession() }
        
        self.headset.board = nil
        
        do {
            try? BoardShim.logMessage(.LEVEL_INFO, "connecting to board ID: \(self.boardId)")
            self.headset = try Headset(boardId: self.boardId)
            try? BoardShim.logMessage(.LEVEL_INFO, "connected")
            self.isMainMenuActive = false }
        catch {
            try? BoardShim.logMessage(.LEVEL_INFO, "failed to connect")
            self.buttonLabel = "Try Again" }
    }
    
    var body: some View {
        ZStack {
            Color.white
            VStack {
                Spacer()
                HStack {
                    Button(action: {
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
        }
    }
}

//struct RetryView_Previews: PreviewProvider {
//    static var previews: some UIView {
//        Group {
//            RetryView("The headset is not ready.")
//        }
//    }
//}
    
    
