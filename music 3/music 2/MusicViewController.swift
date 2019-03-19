//
//  MusicViewController.swift
//  music 2
//
//  Created by Ayman Zaher on 2019-03-13.
//  Copyright © 2019 Ayman Zaher. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

struct SongTable {
    var songTitle: String
    var songArtist: String
    var songURL : String
    var songArtwork : String
    var songAlbum : String
}

class MusicViewController: UIViewController, XMLParserDelegate {
    
    var songs: [SongTable] = []
    var filtered: [SongTable] = []
    var elementName: String = String()
    var songTitle = String()
    var songArtist = String()
    var songURL = String()
    var songArtwork = String()
    var songAlbum = String()
    var currentRow = Int()
    var searchActive : Bool = false
    var connection:Bool = true
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        
        setupRemoteTransportControls()
        
        
        filtered = songs
        // Create destination URL
        let documentsUrl:URL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first as URL!
        let documentString = NSSearchPathForDirectoriesInDomains(.documentDirectory,  .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: documentString)
        let destinationFileUrl = documentsUrl.appendingPathComponent("songs.xml")
        
        //Create URL to the source file you want to download
        let fileURL = URL(string: "https://azaherrepo.github.io/music/songs.xml")
        
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        
        let request = URLRequest(url:fileURL!)
        
        let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
            if let tempLocalUrl = tempLocalUrl, error == nil {
                // Success
                if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                    print("Successfully downloaded. Status code: \(statusCode)")
                    
                    if let pathComponent = url.appendingPathComponent("songs.xml") {
                        let filePath = pathComponent.path
                        if FileManager.default.fileExists(atPath: filePath) {
                            do{
                                try FileManager.default.replaceItemAt(destinationFileUrl, withItemAt: tempLocalUrl)
                            } catch (let errors) {
                                print("Error creating a file \(destinationFileUrl) : \(errors)")
                            }
                        } else {
                            do {
                                try FileManager.default.copyItem(at: tempLocalUrl, to: destinationFileUrl)
                            } catch (let writeError) {
                                print("Error creating a file \(destinationFileUrl) : \(writeError)")
                            }
                        }
                    }
                }
                
            } else {
                print("Error took place while downloading a file. Error description: %@", error?.localizedDescription);
            }
        }
        task.resume()
        
        if let parser = XMLParser(contentsOf: destinationFileUrl) {
            parser.delegate = self
            parser.parse()
        }
        
    }
    
    
    // 1
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        
        if elementName == "song" {
            songTitle = String()
            songArtist = String()
            songURL = String()
            songArtwork = String()
            songAlbum = String()
            
        }
        
        self.elementName = elementName
        
    }
    
    // 2
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "song" {
            let song = SongTable(songTitle: songTitle, songArtist: songArtist, songURL: songURL, songArtwork: songArtwork, songAlbum: songAlbum)
            songs.append(song)
        }
    }
    
    // 3
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let data = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        if (!data.isEmpty) {
            if self.elementName == "title" {
                songTitle += data
            } else if self.elementName == "artist" {
                songArtist += data
            } else if self.elementName == "url" {
                songURL += data
            } else if self.elementName == "artwork" {
                songArtwork += data
            } else if self.elementName == "album" {
                songAlbum += data
            }
        }
        filtered = songs
        
    }
    
    func checkaConnection() -> Bool {
        print("Reachability Summary")
        print("Status:", Network.reachability.status)
        print("HostName:", Network.reachability.hostname ?? "nil")
        print("Reachable:", Network.reachability.isReachable)
        print("Wifi:", Network.reachability.isReachableViaWiFi)
        switch Network.reachability.status {
        case .unreachable:
            return false
        case .wwan:
            return true
        case .wifi:
            return true
        }
        
    }
    
    func createNewPath(lastPath: String) -> URL {
        let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        
        let destination = URL(fileURLWithPath: String(format: "%@/%@", documentsDirectory,lastPath))
        return destination
    }
    func setupMetaData(image: UIImage?) {
        let songT = MusicPlayerManager.shared.downloadedFiltered[MusicPlayerManager.shared.currentRow]
        var url = self.createNewPath(lastPath: songT.songFile)
        do {
            // Define Now Playing Info
            var nowPlayingInfo = [String : Any]()
            nowPlayingInfo[MPMediaItemPropertyTitle] = songT.songTitle
            nowPlayingInfo[MPMediaItemPropertyArtist] = songT.songArtist
            
            print(MusicPlayerManager.shared.Player.currentItem!.asset.duration)
            nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = MusicPlayerManager.shared.Player.currentTime().seconds
            nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = MusicPlayerManager.shared.playerItem.asset.duration.seconds
            nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = MusicPlayerManager.shared.Player.rate
            
            if let artimage = image{
                nowPlayingInfo[MPMediaItemPropertyArtwork] =
                    MPMediaItemArtwork(boundsSize: artimage.size) { size in
                        return artimage
                }
            }
            
            // Set the metadata
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
        } catch {
            print(error)
        }
    }
    func downloadedNext() {
        if MusicPlayerManager.shared.currentRow != MusicPlayerManager.shared.downloadedFiltered.count - 1 {
            MusicPlayerManager.shared.currentRow += 1
        }
        var songT = MusicPlayerManager.shared.downloadedFiltered[MusicPlayerManager.shared.currentRow]
        var url = self.createNewPath(lastPath: songT.songFile)
        let asset = AVAsset(url: url)
        MusicPlayerManager.shared.artworkImage = songT.artwork
        print(MusicPlayerManager.shared.currentRow)
        MusicPlayerManager.shared.songTitle = songT.songTitle
        MusicPlayerManager.shared.songArtist = songT.songArtist
        MusicPlayerManager.shared.songAlbum = songT.songAlbum
        MusicPlayerManager.shared.playerItem = AVPlayerItem(asset: asset)
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default)
            MusicPlayerManager.shared.Player = AVPlayer(url: url)
            MusicPlayerManager.shared.Player?.play()
            self.setupMetaData(image: MusicPlayerManager.shared.artworkImage)
        } catch {
            print(error)
        }
    }
    
    func downloadedPrev() {
        if MusicPlayerManager.shared.currentRow != 0 {
            MusicPlayerManager.shared.currentRow -= 1
        }
        var songT = MusicPlayerManager.shared.downloadedFiltered[MusicPlayerManager.shared.currentRow]
        var url = self.createNewPath(lastPath: songT.songFile)
        let asset = AVAsset(url: url)
        MusicPlayerManager.shared.artworkImage = songT.artwork
        print(songT.artwork)
        print(MusicPlayerManager.shared.currentRow)
        MusicPlayerManager.shared.songTitle = songT.songTitle
        MusicPlayerManager.shared.songArtist = songT.songArtist
        MusicPlayerManager.shared.songAlbum = songT.songAlbum
        MusicPlayerManager.shared.playerItem = AVPlayerItem(asset: asset)
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default)
            MusicPlayerManager.shared.Player = AVPlayer(url: url)
            MusicPlayerManager.shared.Player?.play()
            self.setupMetaData(image: MusicPlayerManager.shared.artworkImage)
        } catch {
            print(error)
        }
    }
    
    func streamNext() {
        if MusicPlayerManager.shared.currentRow != MusicPlayerManager.shared.filteredArray.count - 1 {
        MusicPlayerManager.shared.currentRow += 1
        }
        print(MusicPlayerManager.shared.currentRow)
        
        var songT = MusicPlayerManager.shared.filteredArray[MusicPlayerManager.shared.currentRow]
        var url = URL(string: songT.songURL)
        let asset = AVAsset(url: url!)
        print(songT.songArtwork)
        MusicPlayerManager.shared.artwork = songT.songArtwork
        MusicPlayerManager.shared.songTitle = songT.songTitle
        MusicPlayerManager.shared.songArtist = songT.songArtist
        MusicPlayerManager.shared.songAlbum = songT.songAlbum
        MusicPlayerManager.shared.playerItem = AVPlayerItem(asset: asset)
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default)
            MusicPlayerManager.shared.Player = AVPlayer(url: url!)
            MusicPlayerManager.shared.Player?.play()
            self.downloadArtwork()
        } catch {
            print(error)
        }
    }
    
    func streamPrev() {
        if MusicPlayerManager.shared.currentRow != 0 {
        MusicPlayerManager.shared.currentRow -= 1
        }
        var songT = MusicPlayerManager.shared.filteredArray[MusicPlayerManager.shared.currentRow]
        var url = URL(string: songT.songURL)
        let asset = AVAsset(url: url!)
        print(songT.songArtwork)
        MusicPlayerManager.shared.artwork = songT.songArtwork
        MusicPlayerManager.shared.songTitle = songT.songTitle
        MusicPlayerManager.shared.songArtist = songT.songArtist
        MusicPlayerManager.shared.songAlbum = songT.songAlbum
        MusicPlayerManager.shared.playerItem = AVPlayerItem(asset: asset)
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default)
            MusicPlayerManager.shared.Player = AVPlayer(url: url!)
            MusicPlayerManager.shared.Player?.play()
            self.downloadArtwork()
        } catch {
            print(error)
        }
    }
    
    @objc func hitEnd() {
        print("Hit end")
        if MusicPlayerManager.shared.currentRow != MusicPlayerManager.shared.filteredArray.count - 1 {
            MusicPlayerManager.shared.currentRow += 1
        }
        var songT = MusicPlayerManager.shared.filteredArray[MusicPlayerManager.shared.currentRow]
        var url = URL(string: songT.songURL)
        let asset = AVAsset(url: url!)
        print(songT.songArtwork)
        MusicPlayerManager.shared.artwork = songT.songArtwork
        MusicPlayerManager.shared.songTitle = songT.songTitle
        MusicPlayerManager.shared.songArtist = songT.songArtist
        MusicPlayerManager.shared.songAlbum = songT.songAlbum
        MusicPlayerManager.shared.playerItem = AVPlayerItem(asset: asset)
        
        print(Float(MusicPlayerManager.shared.playerItem.asset.duration.seconds))
        
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default)
            MusicPlayerManager.shared.Player = AVPlayer(url: url!)
            MusicPlayerManager.shared.Player?.play()
            NotificationCenter.default.addObserver(self, selector: #selector(hitEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: MusicPlayerManager.shared.Player.currentItem)
            downloadArtwork()
        } catch {
            print(error)
        }
    }
    
    func setupRemoteTransportControls() {
        // Get the shared MPRemoteCommandCenter
        let commandCenter = MPRemoteCommandCenter.shared()
        
        
        // Add handler for Play Command
        commandCenter.playCommand.addTarget { [unowned self] event in
            if MusicPlayerManager.shared.Player!.rate == 0.0 {
                MusicPlayerManager.shared.Player!.play()
                return .success
            }
            return .commandFailed
        }
        
        // Add handler for Pause Command
        commandCenter.pauseCommand.addTarget { [unowned self] event in
            if MusicPlayerManager.shared.Player!.rate == 1.0 {
                MusicPlayerManager.shared.Player!.pause()
                return .success
            }
            return .commandFailed
        }
        commandCenter.nextTrackCommand.addTarget { [unowned self] event in
            if MusicPlayerManager.shared.downloaded == false {
                self.streamNext()
            } else {
                self.downloadedNext()
            }
            return .success
        }
        commandCenter.previousTrackCommand.addTarget { [unowned self] event in
            if MusicPlayerManager.shared.downloaded == false {
                self.streamPrev()
            } else {
                self.downloadedPrev()
            }
            
            return .success
        }
        
    }
    func setupMetaData(image: Data) {
        var songT = MusicPlayerManager.shared.filteredArray[MusicPlayerManager.shared.currentRow]
        var url = URL(string: songT.songURL)
        do {
            // Define Now Playing Info
            var nowPlayingInfo = [String : Any]()
            nowPlayingInfo[MPMediaItemPropertyTitle] = songT.songTitle
            nowPlayingInfo[MPMediaItemPropertyArtist] = songT.songArtist
            
            print(MusicPlayerManager.shared.Player.currentItem!.asset.duration)
            nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = MusicPlayerManager.shared.Player.currentTime().seconds
            nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = MusicPlayerManager.shared.playerItem.asset.duration.seconds
            nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = MusicPlayerManager.shared.Player.rate
            
            if let artimage = UIImage(data: image){
                nowPlayingInfo[MPMediaItemPropertyArtwork] =
                    MPMediaItemArtwork(boundsSize: artimage.size) { size in
                        return artimage
                }
            }
            
            // Set the metadata
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
        } catch {
            print(error)
        }
    }
    func downloadArtwork() {
        func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
            URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
        }
        func downloadImage(from url: URL) {
            print("Download Started")
            getData(from: url) { data, response, error in
                guard let data = data, error == nil else { return }
                print(response?.suggestedFilename ?? url.lastPathComponent)
                print("Download Finished")
                DispatchQueue.main.async() {
                    self.setupMetaData(image: data)
                }
            }
        }
        print("Begin of code")
        let url = URL(string: MusicPlayerManager.shared.artwork)!
        downloadImage(from: url)
        print("End of code. The image will continue downloading in the background and it will be loaded when it ends.")
    }
    func downloadSong(songTitle: String, songArtist: String, songAlbum: String, songURL: String, songArtwork: String) {
        print("started download")
        let documentsUrl:URL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first as URL!
        let documentString = NSSearchPathForDirectoriesInDomains(.documentDirectory,  .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: documentString)
        let destinationFileUrl = documentsUrl.appendingPathComponent("\(songTitle).m4a")
        if FileManager.default.fileExists(atPath: destinationFileUrl.path) {
            let alert = UIAlertController(title: "\(songTitle) Downloaded", message: "\(songTitle) has Downloaded", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                switch action.style{
                case .default:
                    print("default")
                    
                case .cancel:
                    print("cancel")
                    
                case .destructive:
                    print("destructive")
                    
                    
                }}))
            self.present(alert, animated: true, completion: nil)
        } else {
        //Create URL to the source file you want to download
        let fileURL = URL(string: songURL)
        
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        
        let request = URLRequest(url:fileURL!)
        
        let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
            if let tempLocalUrl = tempLocalUrl, error == nil {
                // Success
                if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                    print("Successfully downloaded. Status code: \(statusCode)")
                    let alert = UIAlertController(title: "\(songTitle) Downloaded", message: "\(songTitle) has Downloaded", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                        switch action.style{
                        case .default:
                            print("default")
                            
                        case .cancel:
                            print("cancel")
                            
                        case .destructive:
                            print("destructive")
                            
                            
                        }}))
                    self.present(alert, animated: true, completion: nil)
                    if let pathComponent = url.appendingPathComponent("\(songTitle).m4a") {
                        let filePath = pathComponent.path
                        if FileManager.default.fileExists(atPath: filePath) {
                            do{
                                try FileManager.default.replaceItemAt(destinationFileUrl, withItemAt: tempLocalUrl)
                            } catch (let errors) {
                                print("Error creating a file \(destinationFileUrl) : \(errors)")
                            }
                        } else {
                            do {
                                try FileManager.default.copyItem(at: tempLocalUrl, to: destinationFileUrl)
                                
                            } catch (let writeError) {
                                print("Error creating a file \(destinationFileUrl) : \(writeError)")
                            }
                        }
                    }
                }
                
            } else {
                print("Error took place while downloading a file. Error description: %@", error?.localizedDescription);
            }
        }
        task.resume()
    }
    }
}

extension MusicViewController: musicDownload {
    func tappedDownloadButton(musicitem: SongTable) {
        print("I was tapped \(musicitem)")
        downloadSong(songTitle: musicitem.songTitle, songArtist: musicitem.songArtist, songAlbum: musicitem.songAlbum, songURL: musicitem.songURL, songArtwork: musicitem.songArtwork)
    }
}

extension MusicViewController: UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filtered.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! MusicCell
        let songT = filtered[indexPath.row]
        cell.setMusic(song: songT)
        cell.delegate = self
//        cell.textLabel?.text = songT.songTitle
//        cell.detailTextLabel?.text = songT.songArtist
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if checkaConnection() == true {
        print("row: \(indexPath.row)")
        currentRow = indexPath.row
        MusicPlayerManager.shared.downloaded = false
        MusicPlayerManager.shared.currentRow = indexPath.row
        MusicPlayerManager.shared.songArray = songs
        MusicPlayerManager.shared.filteredArray = filtered
        let songT = filtered[indexPath.row]
        var url = URL(string: songT.songURL)
        let asset = AVAsset(url: url!)
        print(songT.songArtwork)
        MusicPlayerManager.shared.artwork = songT.songArtwork
        MusicPlayerManager.shared.songTitle = songT.songTitle
        MusicPlayerManager.shared.songArtist = songT.songArtist
        MusicPlayerManager.shared.songAlbum = songT.songAlbum
        MusicPlayerManager.shared.playerItem = AVPlayerItem(asset: asset)
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default)
            MusicPlayerManager.shared.Player = AVPlayer(url: url!)
            MusicPlayerManager.shared.Player?.play()
            NotificationCenter.default.addObserver(self, selector: #selector(hitEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: MusicPlayerManager.shared.Player.currentItem)
//            setupRemoteTransportControls()
            downloadArtwork()
        } catch {
            print(error)
        }
        } else {
            let alert = UIAlertController(title: "No Connection", message: "Could not connect to the music server please check your internet connection", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                switch action.style{
                case .default:
                    print("default")
                    
                case .cancel:
                    print("cancel")
                    
                case .destructive:
                    print("destructive")
                    
                    
                }}))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text != "" {
            MusicPlayerManager.shared.filtering = true
            filtered = songs.filter({ (text) -> Bool in
                return text.songTitle.range(of: searchText, options: .caseInsensitive) != nil
            })
        } else {
            filtered = songs
        }
        
        tableView.reloadData()
    }
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
        MusicPlayerManager.shared.filtering = true
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        MusicPlayerManager.shared.filtering = false
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
        filtered = songs
        tableView.reloadData()
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
    }
}

final class MusicPlayerManager {
    static let shared = MusicPlayerManager()
    private init() { }
    
    var Player: AVPlayer!
    var iPlayer: AVPlayerLayer!
    var playerItem: AVPlayerItem!
    var songTitle: String = "Nothing Playing"
    var artwork: String = "link"
    var songArtist: String = ""
    var songAlbum: String = ""
    var songlink: String = "Link"
    var currentRow: Int = 0
    var songArray: [SongTable] = []
    var filteredArray: [SongTable] = []
    var filtering: Bool = false
    var artworkImage: UIImage!
    var downloadedArray: [downloadedTable] = []
    var downloadedFiltered: [downloadedTable] = []
    var downloaded: Bool = false
}
