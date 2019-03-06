//
//  TableViewController.swift
//  music 2
//
//  Created by Ayman Zaher on 2019-03-03.
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
}
class TableViewController: UITableViewController, XMLParserDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var searchBarS: UISearchBar!
    var songs: [SongTable] = []
    var filtered: [SongTable] = []
    var elementName: String = String()
    var songTitle = String()
    var songArtist = String()
    var songURL = String()
    var songArtwork = String()
    var currentRow = Int()
    var searchActive : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBarS.delegate = self
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
            
        }
        
        self.elementName = elementName
        
    }
    
    // 2
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "song" {
            let song = SongTable(songTitle: songTitle, songArtist: songArtist, songURL: songURL, songArtwork: songArtwork)
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
            }
        }
        filtered = songs
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // return the number of rows
        return filtered.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let songT = filtered[indexPath.row]
        
        cell.textLabel?.text = songT.songTitle
        cell.detailTextLabel?.text = songT.songArtist
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("row: \(indexPath.row)")
        currentRow = indexPath.row
        let songT = filtered[indexPath.row]
        var url = URL(string: songT.songURL)
        let asset = AVAsset(url: url!)
        print(songT.songArtwork)
        MusicPlayerManager.shared.artwork = songT.songArtwork
        MusicPlayerManager.shared.songTitle = songT.songTitle
        MusicPlayerManager.shared.songArtist = songT.songArtist
        MusicPlayerManager.shared.playerItem = AVPlayerItem(asset: asset)
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default)
            MusicPlayerManager.shared.Player = AVPlayer(url: url!)
            MusicPlayerManager.shared.Player?.play()
            setupRemoteTransportControls()
            // Define Now Playing Info
            var nowPlayingInfo = [String : Any]()
            nowPlayingInfo[MPMediaItemPropertyTitle] = songT.songTitle
            nowPlayingInfo[MPMediaItemPropertyArtist] = songT.songArtist
            
            if let image = UIImage(named: "lockscreen") {
                nowPlayingInfo[MPMediaItemPropertyArtwork] =
                    MPMediaItemArtwork(boundsSize: image.size) { size in
                        return image
                }
            }
            print(MusicPlayerManager.shared.Player.currentItem!.asset.duration)
            nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = MusicPlayerManager.shared.Player.currentTime().seconds
            nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = MusicPlayerManager.shared.playerItem.asset.duration.seconds
            nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = MusicPlayerManager.shared.Player.rate
            
            // Set the metadata
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
        } catch {
            print(error)
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBarS.text != "" {
        filtered = songs.filter({ (text) -> Bool in
            return text.songTitle.range(of: searchText, options: .caseInsensitive) != nil
        })
        } else {
            filtered = songs
        }
        
        tableView.reloadData()
    }
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBarS.showsCancelButton = true
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBarS.showsCancelButton = false
        searchBarS.text = ""
        searchBarS.resignFirstResponder()
        filtered = songs
        tableView.reloadData()
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBarS.showsCancelButton = false
        searchBarS.resignFirstResponder()
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
         
            
    }
    
    
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
final class MusicPlayerManager {
    static let shared = MusicPlayerManager()
    private init() { }
    
    var Player: AVPlayer!
    var iPlayer: AVPlayerLayer!
    var playerItem: AVPlayerItem!
    var paused: Bool = false
    var songTitle: String = "Nothing Playing"
    var artwork: String = "link"
    var songArtist: String = ""
}

