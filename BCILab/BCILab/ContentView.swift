import SwiftUI

// forked from: https://stackoverflow.com/questions/58896661/swiftui-create-image-slider-with-dots-as-indicators

struct ContentView: View {
    let interval = 1.0
    @State private var timer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
    @State private var selection = -1
    @State var isTimerRunning = false
    let images: [LabeledImage] = prepareImages()
    let headset = try! Headset(boardId: BoardIds.CYTON_BOARD)
    
    var body: some View {
        ZStack{
            Color.black
            TabView(selection : $selection){
                ForEach(0..<images.count){ i in
                    Image(uiImage: self.images[i].image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
            }
            .tabViewStyle(PageTabViewStyle())
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
            .onReceive(timer, perform: { _ in
                withAnimation{
                    guard self.selection < (self.images.count-1) else {
                        print("done")
                        self.stopTimer()
                        return
                    }
                    if self.selection < 0 {
                        print("pause")
                        try? self.headset.board.insertMarker(value: ImageLabels.blank.rawValue)
                        self.selection = 0
                        self.stopTimer()
                    } else {
                        let label = self.images[self.selection+1].label
                        try? self.headset.board.insertMarker(value: label.rawValue)
                        self.selection += 1
                    }
                }
            })
            .animation(nil)
            .onTapGesture {
                if self.isTimerRunning {
                    self.stopTimer()
                } else {
                    self.startTimer()
                }
                self.isTimerRunning.toggle()
            }
        }
    }

    init () {
        let headsetCopy = headset
        DispatchQueue.global(qos: .background).async {
            headsetCopy.streamEEG()
        }
    }
    
    func stopTimer() {
        print("stop timer")
        self.timer.upstream.connect().cancel()
    }
    
    func startTimer() {
        print("start timer")
        self.timer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
    }
}
