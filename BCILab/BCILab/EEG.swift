////
////  EEG.swift
////  BCILab
////
////  Created by Scott Miller on 8/12/21 for Aeris Rising, LLC.
////
//
//import Foundation
//
//public let MAXSAMPLES: UInt = 1250
//public let NUMCHANNELS: Int = 8
//struct EEG {
//    private let csvFile = CSVFile(fileName: "BrainLabEEG").openFile()
//
//    func writeSample(timestamp: Double, sample: [Float32], offset: Double) {
//        let cTime = timestamp + offset
//        var sampleString = "\(cTime)"
//        for i in 0..<sample.count {
//            sampleString += ",\(sample[i])"
//        }
//        sampleString += "\n"
//        csvFile.write(Data(sampleString.utf8))
//    }
//    
//    func writeChunk(buffers: [Float32],
//                    timestamps: [Double],
//                    offset: Double) {
//        for n in 0..<timestamps.count {
//            let sliceStart = n * NUMCHANNELS
//            let sliceEnd = sliceStart + NUMCHANNELS
//            let bSlice = buffers[sliceStart..<sliceEnd]
//            writeSample(timestamp: timestamps[n], sample: Array(bSlice), offset: offset)
//        }
//    }
//    
//    func streamToFile() {
//        print("resolving EEG stream")
//        let eegStreamInfo = resolve(property: "type", value: "EEG")
//        let inlet = Inlet(streamInfo: eegStreamInfo[0])
//        var clockOffset: Double = 0.0
//        var active = 0
//        let buffer1 = Array<Float32>(repeating: 0, count: NUMCHANNELS * Int(MAXSAMPLES))
//        let buffer2 = Array<Float32>(repeating: 0, count: NUMCHANNELS * Int(MAXSAMPLES))
//        let timestamps1 = Array<Double>(repeating: 0, count: Int(MAXSAMPLES))
//        let timestamps2 = Array<Double>(repeating: 0, count: Int(MAXSAMPLES))
//        var buffers = [buffer1, buffer2]
//        var timestamps = [timestamps1, timestamps2]
//        var numSamples: Int  = 0
//
//        defer {
//            print("closing EEG file")
//            csvFile.closeFile()
//        }
//        
//        do {
//            print("opening inlet")
//            try inlet.openStream(timeout: 60) }
//        catch {
//            print("Cannot open stream.  Error: \(error)")
//            return
//        }
//        
//        do {
//            print("inlet is open. getting time correction")
//            try clockOffset = inlet.timeCorrection() }
//        catch {
//            print("Cannot get clock offset.  Error: \(error)")
//            return
//        }
//        print("initial clock offset = \(clockOffset)")
//        
//        while true {
//            do {
//                try numSamples = inlet.pullChunk(&buffers[active], &timestamps[active]) }
//            catch {
//                print("Sample error: \(error)")
//                continue
//            }
//
//            // Write the active buffer to the csv file asynchronously:
//            let bSlice = buffers[active][..<(numSamples*NUMCHANNELS)]
//            let tSlice = timestamps[active][..<numSamples]
//            DispatchQueue.global(qos: .background).async {
//                self.writeChunk(buffers: Array(bSlice),
//                                timestamps: Array(tSlice),
//                                offset: clockOffset)
//            }
//
//            // swap buffers:
//            active = (active == 0 ? 1 : 0)
//
//            try? clockOffset = inlet.timeCorrection()
//            print("now: \(lsl_local_clock()) offset: \(clockOffset)")
//        }
//    }
//}
