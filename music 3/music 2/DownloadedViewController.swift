//
//  DownloadedViewController.swift
//  music 2
//
//  Created by Ayman Zaher on 2019-03-13.
//  Copyright © 2019 Ayman Zaher. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

struct downloadedTable {
    var songTitle: String
    var songArtist: String
    var songFile : String
    var songAlbum : String
    var artwork: UIImage
}

class DownloadedViewController: UIViewController, XMLParserDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var songs: [downloadedTable] = []
    var filtered: [downloadedTable] = []
    var elementName: String = String()
    var songTitle = String()
    var songArtist = String()
    var songURL = String()
    var songArtwork = String()
    var songAlbum = String()
    var currentRow: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        
        filtered = songs
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
            print(fileURLs)
            let mp3Files = fileURLs.filter{ $0.pathExtension == "m4a" }
            let mp3FileNames = mp3Files.map{ $0.deletingPathExtension().lastPathComponent }
            if mp3Files != [] {
            for i in 0...mp3Files.count - 1{
                let url = mp3Files[i]
                let avasset = AVAsset(url: url)
                let metadataList = avasset.metadata as! [AVMetadataItem]
                let titleID = AVMetadataIdentifier.commonIdentifierTitle
                let albumID = AVMetadataIdentifier.commonIdentifierAlbumName
                let artistID = AVMetadataIdentifier.commonIdentifierArtist
                let titleItems = AVMetadataItem.metadataItems(from: metadataList, filteredByIdentifier: titleID)
                
                let albumItems = AVMetadataItem.metadataItems(from: metadataList, filteredByIdentifier: albumID)
                
                let artistItems = AVMetadataItem.metadataItems(from: metadataList, filteredByIdentifier: artistID)
                let artworkItems = AVMetadataItem.metadataItems(from: metadataList, filteredByIdentifier: AVMetadataIdentifier.commonIdentifierArtwork)
                var artimage: UIImage
                if let artworkItem = artworkItems.first {
                    // Coerce the value to an NSData using its dataValue property
                    if let imageData = artworkItem.dataValue {
                        artimage = UIImage(data: imageData)!
                        let song = downloadedTable(songTitle: titleItems.first!.value as! String, songArtist:  artistItems.first!.value as! String, songFile: "\(mp3FileNames[i]).m4a", songAlbum: albumItems.first!.value as! String, artwork: artimage)
                        songs.append(song)
                        filtered = songs
                        // process image
                    } else {
                        // No image data found
                    }
                }
                
                print(songs)
            }
            }
        } catch {
            print("Error while enumerating files \(documentsURL.path): \(error.localizedDescription)")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    @IBAction func refreshBttn(_ sender: Any) {
        songs = []
        filtered = []
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
            print(fileURLs)
            let mp3Files = fileURLs.filter{ $0.pathExtension == "m4a" }
            let mp3FileNames = mp3Files.map{ $0.deletingPathExtension().lastPathComponent }
            if mp3Files != [] {
            for i in 0...mp3Files.count - 1{
                let url = mp3Files[i]
                let avasset = AVAsset(url: url)
                let metadataList = avasset.metadata as! [AVMetadataItem]
                let titleID = AVMetadataIdentifier.commonIdentifierTitle
                let albumID = AVMetadataIdentifier.commonIdentifierAlbumName
                let artistID = AVMetadataIdentifier.commonIdentifierArtist
                let titleItems = AVMetadataItem.metadataItems(from: metadataList, filteredByIdentifier: titleID)
                
                let albumItems = AVMetadataItem.metadataItems(from: metadataList, filteredByIdentifier: albumID)
                
                let artistItems = AVMetadataItem.metadataItems(from: metadataList, filteredByIdentifier: artistID)
                let artworkItems = AVMetadataItem.metadataItems(from: metadataList, filteredByIdentifier: AVMetadataIdentifier.commonIdentifierArtwork)
                var artimage: UIImage
                if let artworkItem = artworkItems.first {
                    // Coerce the value to an NSData using its dataValue property
                    if let imageData = artworkItem.dataValue {
                        artimage = UIImage(data: imageData)!
                        let song = downloadedTable(songTitle: titleItems.first!.value as! String, songArtist:  artistItems.first!.value as! String, songFile: "\(mp3FileNames[i]).m4a", songAlbum: albumItems.first!.value as! String, artwork: artimage)
                        songs.append(song)
                        filtered = songs
                        // process image
                    } else {
                        // No image data found
                    }
                }
                
                print(songs)
                
            }
            }
            tableView.reloadData()
        } catch {
            print("Error while enumerating files \(documentsURL.path): \(error.localizedDescription)")
        }
    }
    
    @objc func hitEnd() {
        print("Hit end")
        if MusicPlayerManager.shared.currentRow != MusicPlayerManager.shared.downloadedFiltered.count - 1 {
            MusicPlayerManager.shared.currentRow += 1
        }
        var songT = MusicPlayerManager.shared.downloadedFiltered[MusicPlayerManager.shared.currentRow]
        var url = self.createNewPath(lastPath: songT.songFile)
        let asset = AVAsset(url: url)
        print(songT.artwork)
        MusicPlayerManager.shared.artworkImage = songT.artwork
        MusicPlayerManager.shared.songTitle = songT.songTitle
        MusicPlayerManager.shared.songArtist = songT.songArtist
        MusicPlayerManager.shared.songAlbum = songT.songAlbum
        MusicPlayerManager.shared.playerItem = AVPlayerItem(asset: asset)
        
        
        print(Float(MusicPlayerManager.shared.playerItem.asset.duration.seconds))
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default)
            MusicPlayerManager.shared.Player = AVPlayer(url: url)
            MusicPlayerManager.shared.Player?.play()
            setupMetaData(image: MusicPlayerManager.shared.artworkImage)
             NotificationCenter.default.addObserver(self, selector: #selector(hitEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: MusicPlayerManager.shared.Player.currentItem)
        } catch {
            print(error)
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
}

extension DownloadedViewController: musicDelete {
    func tappedDeleteButton(musicitem: downloadedTable) {
        print("clicked part 2")
        let outputMineURL = self.createNewPath(lastPath: musicitem.songFile)
        if FileManager.default.fileExists(atPath: outputMineURL.path) {
            do {
                try FileManager.default.removeItem(at: outputMineURL)
            } catch {
                
            }
            
        }
        songs = []
        filtered = []
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
            print(fileURLs)
            let mp3Files = fileURLs.filter{ $0.pathExtension == "m4a" }
            let mp3FileNames = mp3Files.map{ $0.deletingPathExtension().lastPathComponent }
            if mp3Files != [] {
            for i in 0...mp3Files.count - 1{
                let url = mp3Files[i]
                let avasset = AVAsset(url: url)
                let metadataList = avasset.metadata as! [AVMetadataItem]
                let titleID = AVMetadataIdentifier.commonIdentifierTitle
                let albumID = AVMetadataIdentifier.commonIdentifierAlbumName
                let artistID = AVMetadataIdentifier.commonIdentifierArtist
                let titleItems = AVMetadataItem.metadataItems(from: metadataList, filteredByIdentifier: titleID)
                
                let albumItems = AVMetadataItem.metadataItems(from: metadataList, filteredByIdentifier: albumID)
                
                let artistItems = AVMetadataItem.metadataItems(from: metadataList, filteredByIdentifier: artistID)
                let artworkItems = AVMetadataItem.metadataItems(from: metadataList, filteredByIdentifier: AVMetadataIdentifier.commonIdentifierArtwork)
                var artimage: UIImage
                if let artworkItem = artworkItems.first {
                    // Coerce the value to an NSData using its dataValue property
                    if let imageData = artworkItem.dataValue {
                        artimage = UIImage(data: imageData)!
                        let song = downloadedTable(songTitle: titleItems.first!.value as! String, songArtist:  artistItems.first!.value as! String, songFile: "\(mp3FileNames[i]).m4a", songAlbum: albumItems.first!.value as! String, artwork: artimage)
                        songs.append(song)
                        filtered = songs
                        // process image
                    } else {
                        // No image data found
                    }
                }
                
                print(songs)
                
            }
            }
            tableView.reloadData()
        } catch {
            print("Error while enumerating files \(documentsURL.path): \(error.localizedDescription)")
        }
        
        
    }
    
}

extension DownloadedViewController: UISearchBarDelegate {
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
        tableView.reloadData()
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
    }
}

extension DownloadedViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filtered.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let song = filtered[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "songCell") as! DownloadCell
        cell.setSongs(song: song)
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("row: \(indexPath.row)")
        currentRow = indexPath.row
        MusicPlayerManager.shared.currentRow = indexPath.row
        
        let songT = filtered[indexPath.row]
        let outputMineURL = self.createNewPath(lastPath: songT.songFile)
        print(outputMineURL)
        let asset = AVAsset(url: outputMineURL)
        print(songT.songAlbum)
        MusicPlayerManager.shared.downloadedArray = songs
        MusicPlayerManager.shared.downloadedFiltered = filtered
        MusicPlayerManager.shared.currentRow = indexPath.row
        MusicPlayerManager.shared.songTitle = songT.songTitle
        MusicPlayerManager.shared.songArtist = songT.songArtist
        MusicPlayerManager.shared.songAlbum = songT.songAlbum
        MusicPlayerManager.shared.artworkImage = songT.artwork
        MusicPlayerManager.shared.downloaded = true
        MusicPlayerManager.shared.playerItem = AVPlayerItem(asset: asset)
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default)
            MusicPlayerManager.shared.Player = AVPlayer(url: outputMineURL)
            MusicPlayerManager.shared.Player?.play()
            NotificationCenter.default.addObserver(self, selector: #selector(hitEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: MusicPlayerManager.shared.Player.currentItem)
            setupMetaData(image: songT.artwork)
        } catch {
            print(error)
        }
    }
    
}
