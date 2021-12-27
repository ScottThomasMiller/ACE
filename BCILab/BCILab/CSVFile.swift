//
//  CSVFile.swift
//  BCILab
//
//  Created by Scott Miller on 8/13/21.
//
import Foundation

class CSVFile: FileHandle {
    var fileName: String = ""
    convenience init(fileName: String) {
        self.init()
        self.fileName = fileName
    }
    
    static func uniqueID() -> String {
        let now = Date().timeIntervalSinceReferenceDate
        return String(Int(now))
    }
    
    // create the csv file in Documents unless overridden by saveFolder:
    func create(id: String, saveFolder: URL? = nil) -> FileHandle {
        var docDir: URL

        if let saveURL = saveFolder {
            docDir = saveURL
            let savePath = saveURL.path
            do {
                try FileManager.default.createDirectory(atPath: savePath, withIntermediateDirectories: true) }
            catch {
                print("create directory error: \(error.localizedDescription)")
            }
        }
        else {
            docDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first! }
        
        let csvURL = docDir.appendingPathComponent(self.fileName+"_"+id).appendingPathExtension("csv")
        var fileHandle: FileHandle
        
        do {
            FileManager.default.createFile(atPath: csvURL.path, contents: nil, attributes: nil)
            fileHandle = try FileHandle(forWritingTo: csvURL)
            print("opened file: \(csvURL.path)") }
        catch {
            print("Cannot open \(csvURL)\nError: \(error)")
            exit(1) }
        
        return fileHandle
    }
}

extension FileHandle {
    func writeEEGsamples(pkgIDs: [Double], timestamps: [Double], markers: [Double], samples: [[Double]]) {
        for iSample in 0..<timestamps.count {
            let pkgID = String(format: "%d", Int(pkgIDs[iSample]))
            let tStamp = String(format: "%.6f", timestamps[iSample])
            let marker = String(format: "%d", Int(markers[iSample]))
            var sampleString = pkgID + "," + tStamp + "," + marker
            for iChannel in 0..<samples.count {
                sampleString += "," + String(format: "%.5f", samples[iChannel][iSample]) }
            sampleString += "\n"
            self.write(Data(sampleString.utf8)) }
    }
    
}
