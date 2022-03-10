//
//  SlideShow.swift
//  BCILab
//
//  Created by Scott Miller on 8/7/21.
//

import Foundation
import SwiftUI

struct SlideShow: View {
    @Binding var isMainMenuActive: Bool
    var appState: AppState
    private let maxImages: Int = 10000
    var images = [LabeledImage]()
    var labels = [String]()
    var totalImages: Int { return self.images.count }
    
    @State private var selection: Int = 0
    @State private var isPaused = true
    @State private var animationTimer = Timer.publish(every: 0.6, on: .main, in: .common).autoconnect()

    private func writeLabelFile() {
        let uqID = CSVFile.uniqueID()
        let labelFile = CSVFile(fileName: "BCILabels").create(id: uqID, saveFolder: self.appState.saveFolder)
        for label in self.labels {
            labelFile.write(Data("\(label)\n".utf8))
        }
    }
    
    init(isMainMenuActive: Binding<Bool>, appState: AppState) {
        self._isMainMenuActive = isMainMenuActive
        self.appState = appState
        let results = self.prepareImages(from: appState.loadFolder)
        self.images = results.0
        self.labels = results.1
        self.writeLabelFile()
        try? BoardShim.logMessage(.LEVEL_INFO, "SlideShow.init()")
    }
    
    private func loadURL(_ url: URL) throws -> Image? {
        let data = try Data(contentsOf: url)
        #if os(macOS)
            guard let nsImage = NSImage(data: data) else {
                try? BoardShim.logMessage(.LEVEL_ERROR, "cannot load image URL: \(url)")
                return nil
            }
            return Image(nsImage: nsImage)
        #else
            guard let uiImage = UIImage(data: data) else {
                try? BoardShim.logMessage(.LEVEL_ERROR, "cannot load image URL: \(url)")
                return nil
            }
            return Image(uiImage: uiImage)
        #endif
    }

    private func loadAllFromURL(from: URL, marker: Double) -> [LabeledImage]  {
        var count = 0
        var labeledImages = [LabeledImage]()
        
        if let urls = FileManager.default.imageURLs(of: from) {
            for url in urls {
                guard let image = try? loadURL(url) else {
                    try? BoardShim.logMessage(.LEVEL_ERROR, "Error loading image: \(url)")
                    continue }
                
                let labeledImage = LabeledImage(image: image, marker: marker)
                labeledImages.append(labeledImage)
                count += 1

                guard count < maxImages else {
                    try? BoardShim.logMessage(.LEVEL_INFO, "reached limit of \(maxImages) images")
                    break }
            }
        }
        
        return labeledImages
    }

    private func loadAllFromSubdir(subdir: String, marker: Double) -> [LabeledImage]  {
        var count = 0
        var labeledImages = [LabeledImage]()
        
        if let urls = Bundle.main.urls(forResourcesWithExtension: ".jpg", subdirectory: subdir) {
            for url in urls {
                guard let image = try? loadURL(url) else {
                    try? BoardShim.logMessage(.LEVEL_ERROR, "Error loading image: \(url)")
                    continue }
                
                let labeledImage = LabeledImage(image: image, marker: marker)
                labeledImages.append(labeledImage)
                count += 1

                guard count < maxImages else {
                    try? BoardShim.logMessage(.LEVEL_INFO, "reached limit of \(maxImages) images")
                    break }
            }
        }
        
        print("loaded \(count) images from \(subdir) with marker \(marker)")
        return labeledImages
    }

    private func getImage(_ assetName: String) -> Image? {
        guard let blankURL = Bundle.main.url(forResource: assetName, withExtension: nil) else {
            try? BoardShim.logMessage(.LEVEL_INFO, "Error: cannot locate URL for asset: \(assetName)")
            return nil
        }
        guard let assetImage = try? loadURL(blankURL) else {
            try? BoardShim.logMessage(.LEVEL_INFO, "Error: cannot load image \(assetName)")
            return nil
        }
        
        return assetImage
    }
    
    // Load a randomized array of all subfolders, with blanks inserted between each image.
    // Use the subfolder names for the image labels.
    private func prepareImages (from folder: URL) -> ([LabeledImage], [String]) {
        try? BoardShim.logMessage(.LEVEL_INFO, "prepareImages(). load folder:\n\(folder)")
        var marker: Double = 0
        var newImages = [LabeledImage]()
        var labels = [String]()

        guard let blankImage = getImage("black_crosshair.jpeg") else {
            try? BoardShim.logMessage(.LEVEL_INFO, "Error: cannot load crosshair image")
            return (newImages, labels)
        }
        guard let endImage = getImage("end.png") else {
            try? BoardShim.logMessage(.LEVEL_INFO, "Error: cannot load end image")
            return (newImages, labels)
        }
        guard let subFolders = FileManager.default.subFolders(of: folder) else {
            try? BoardShim.logMessage(.LEVEL_INFO, "Error: cannot get subfolders for folder: \(folder)")
            return (newImages, labels)
        }

        let unsortedLabelURLs = Dictionary(uniqueKeysWithValues: subFolders.map { ($0.lastPathComponent, $0) })
        labels = subFolders.map {$0.lastPathComponent}
        labels.sort()
        let labelURLs = unsortedLabelURLs.sorted( by: { $0.0 < $1.0 })

        for (label, subfolder) in labelURLs {
            guard let offset = labels.firstIndex(of: label) else {
                try? BoardShim.logMessage(.LEVEL_ERROR, "Invalid label: \(label)")
                break }
            marker = MarkerType.image.rawValue + Double(offset)
            newImages += loadAllFromURL(from: subfolder, marker: marker)
        }

        var finalImages = [LabeledImage]()
        for image in newImages.shuffled() {
            let blank = LabeledImage(image: blankImage, marker: MarkerType.blank.rawValue)
            finalImages.append(blank)
            finalImages.append(image)
        }

        finalImages.append(LabeledImage(image: endImage, marker: MarkerType.end.rawValue))
        try? BoardShim.logMessage(.LEVEL_INFO, "loaded \(newImages.count) images total " +
                                               "across \(self.labels.count) labels")

        self.appState.totalImages = finalImages.count
        self.appState.labels = labels
        self.appState.saveIndex = 0
        return (finalImages, labels)
    }

    private func insertAppears(_ image: LabeledImage) {
        guard !self.isPaused else {
            try? BoardShim.logMessage(.LEVEL_INFO, "insertAppears(): paused.")
            return
        }
        guard !image.appeared else {
            return
        }
        let nmarker = image.marker + 100.0
        if let board = self.appState.headset.board {
            do { try board.insertMarker(value: nmarker) }
            catch { try? BoardShim.logMessage(.LEVEL_ERROR, "cannot insert marker \(nmarker)") }
        }
        image.appeared = true
        try? BoardShim.logMessage(.LEVEL_INFO, "insertAppears(). marker: \(nmarker) selection: \(self.selection)")
    }
    
    private func stopTimer() {
        try? BoardShim.logMessage(.LEVEL_INFO, "stopTimer()")
        self.animationTimer.upstream.connect().cancel()
        if let board = self.appState.headset.board {
            try? board.insertMarker(value: MarkerType.stop.rawValue)}
        self.appState.headset.isStreaming = false
        self.isPaused = true
        self.appState.saveIndex = self.selection
        if self.images[selection].appeared { self.appState.saveIndex! += 1 }
    }
    
    private func startTimer() {
        try? BoardShim.logMessage(.LEVEL_INFO, "startTimer()")
        self.appState.headset.saveURL = self.appState.saveFolder
        self.appState.headset.isStreaming = true
        if let board = self.appState.headset.board {
            try? board.insertMarker(value: MarkerType.start.rawValue) }
        let interval = Double(self.appState.intervalSeconds)
        self.animationTimer = Timer.publish(every: interval, on: .main, in: .common).autoconnect()
        self.isPaused = false
    }
    
    private func toggleTimer() {
        if self.isPaused {
            startTimer() }
        else {
            stopTimer()}
    }
    
    private func longPress() {
        try? BoardShim.logMessage(.LEVEL_INFO, "longPress()")
        self.stopTimer()
        self.isMainMenuActive = true
    }
    
    private func animate() {
        if let startIndex = self.appState.saveIndex {
            let _ = restoreSelection(to: startIndex) }

        guard self.selection < (self.images.count - 1) else {
            try? BoardShim.logMessage(.LEVEL_INFO, "experiment complete")
            if let board = self.appState.headset.board {
                try? board.insertMarker(value: MarkerType.stop.rawValue) }
            self.stopTimer()
            return }
        

        if self.isPaused {
            try? BoardShim.logMessage(.LEVEL_INFO, "experiment is ready and paused")
            self.stopTimer()  }
        else {
            self.selection += 1
        }
    }
    
    private func restoreSelection(to: Int) {
        try? BoardShim.logMessage(.LEVEL_INFO, "restoreSelection(to: \(to))")
        self.selection = to
        self.appState.saveIndex = nil
    }

    var body: some View {
        if self.selection < self.images.count {
            let _ = insertAppears(self.images[self.selection]) }
        GeometryReader { geometry in
            ZStack(alignment: .center) {
                Color.white
                if self.selection < self.images.count {
                    self.images[self.selection].image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                }
            }
            .onChange(of: self.isMainMenuActive, perform: { _ in self.stopTimer() })
            .onChange(of: self.appState.loadFolder, perform: { _ in self.selection = 0})
            .onReceive(self.animationTimer, perform: { _ in self.animate() })
            .onTapGesture { self.toggleTimer() }
            .onLongPressGesture { self.longPress() }
//            .sheet(isPresented: self.$isMainMenuActive) {
//                MainMenu(isMainMenuActive: self.$isMainMenuActive,
//                         appState: self.appState,
//                         appGeometry: geometry) }
        }
    }
}
