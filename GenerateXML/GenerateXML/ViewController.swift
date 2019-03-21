//
//  ViewController.swift
//  GenerateXML
//
//  Created by Ayman Zaher on 2019-03-20.
//  Copyright © 2019 Ayman Zaher. All rights reserved.
//

import Cocoa
import Foundation
import AVFoundation

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let root = XMLElement(name: "catalog")
        let xml = XMLDocument(rootElement: root)
        let completePath = "/Users/aymanzaher/Documents/GitHub/music/files"
        let completeURL = URL(fileURLWithPath: completePath)
        print(completeURL)
        let fileManager = FileManager.default
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: completeURL, includingPropertiesForKeys: nil)
            print(fileURLs)
            let mp3Files = fileURLs.filter{ $0.pathExtension == "m4a" }
            let mp3FileNames = mp3Files.map{ $0.deletingPathExtension().lastPathComponent }
            print(mp3Files)
            for i in 0 ... mp3Files.count - 1{
                let currentFile = mp3Files[i]
                var asset = AVAsset(url: currentFile as URL) as AVAsset
                let song = XMLElement(name: "song")
                root.addChild(song)

                for metaDataItems in asset.commonMetadata {
                    //getting the title of the song
                    if metaDataItems.commonKey!.rawValue == "title" {
                        let titleData = metaDataItems.value as! NSString
                        print("title = \(titleData)")
                        song.addChild(XMLElement(name: "title", stringValue: titleData as String))
                    }
                    //getting the "Artist of the mp3 file"
                    if metaDataItems.commonKey!.rawValue == "artist" {
                        let artistData = metaDataItems.value as! NSString
                        print("artist = \(artistData)")
                        song.addChild(XMLElement(name: "artist", stringValue: artistData as String))
                        let aString = "\(mp3FileNames[i]).m4a"
                        let newString = aString.replacingOccurrences(of: " ", with: "%20", options: .literal, range: nil)
                        print(newString)
                        song.addChild(XMLElement(name: "url", stringValue: "https://azaherrepo.github.io/music/files/\(newString)"))
                    }
                    //getting the "Album of the mp3 file"
                    if metaDataItems.commonKey!.rawValue == "albumName" {
                        let albumNameData = metaDataItems.value as! NSString
                        print("albumName = \(albumNameData)")
                        song.addChild(XMLElement(name: "album", stringValue: albumNameData as String))
                        let string = "\(albumNameData).jpg"
                        let newString = string.replacingOccurrences(of: " ", with: "%20", options: .literal, range: nil)
                        song.addChild(XMLElement(name: "artwork", stringValue: "https://azaherrepo.github.io/music/art/\(newString)"))
                    }
                }
                
            }

            print(xml.stringValue)
            print(xml.xmlData(options: .nodePrettyPrint))
            var path2 = "/Users/aymanzaher/Documents/GitHub/music/test.xml"
            var url = URL(fileURLWithPath: path2)
            do {
                try xml.xmlData(options: .nodePrettyPrint).write(to: url)
            } catch {
                print("failed")
            }
        } catch {
            
        }
        // Do any additional setup after loading the view.
        
        
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

final class LogDestination: TextOutputStream {
    private let path: String
    init() {
        path = ""
    }
    
    func write(_ string: String) {
        if let data = string.data(using: .utf8), let fileHandle = FileHandle(forWritingAtPath: path) {
            defer {
                fileHandle.closeFile()
            }
            fileHandle.seekToEndOfFile()
            fileHandle.write(data)
        }
    }
}

