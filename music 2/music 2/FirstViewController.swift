//
//  FirstViewController.swift
//  music 2
//
//  Created by Ayman Zaher on 2019-03-03.
//  Copyright © 2019 Ayman Zaher. All rights reserved.
//

import UIKit
import CoreMedia
import MediaPlayer
import AVFoundation

class FirstViewController: UIViewController {
let player = MusicPlayerManager.shared.Player
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
    }
    override func viewDidAppear(_ animated: Bool) {
        songTitle.text = MusicPlayerManager.shared.songTitle
        if MusicPlayerManager.shared.playerItem != nil {
        var songInfo: String = "\(MusicPlayerManager.shared.songArtist) -- \(MusicPlayerManager.shared.songAlbum)"
            songArtist.text = songInfo
            seekBar.minimumValue = 0
            seekBar.maximumValue = Float(MusicPlayerManager.shared.playerItem.asset.duration.seconds)
            seekBar.value = Float(MusicPlayerManager.shared.Player.currentTime().seconds)
            totalTime.text = String(MusicPlayerManager.shared.playerItem.asset.duration.seconds)
            currentTime.text = String(MusicPlayerManager.shared.Player.currentTime().seconds)
            print(Float(MusicPlayerManager.shared.playerItem.asset.duration.seconds))
        } else {
            songArtist.text = ""
        }
        if let filePath = Bundle.main.path(forResource: "imageName", ofType: "jpg"), let image = UIImage(contentsOfFile: filePath) {
            artwork.contentMode = .scaleAspectFit
            artwork.image = image
            var nowPlayingInfo = [String : Any]()
            var artworkImage = UIImage(contentsOfFile: filePath)
        }
        print("Begin of code")
        let url = URL(string: MusicPlayerManager.shared.artwork)!
        downloadImage(from: url)
        print("End of code. The image will continue downloading in the background and it will be loaded when it ends.")
        
        if MusicPlayerManager.shared.playerItem != nil {
            print(MusicPlayerManager.shared.Player!.rate)
            if MusicPlayerManager.shared.Player!.rate == 0 {
                playbttn.setTitle("Play", for: .normal)
                playbttn.setImage(playimage, for: .normal)
            } else {
                playbttn.setTitle("Pause", for: .normal)
                playbttn.setImage(pauseimage, for: .normal)
            }
        }
        if MusicPlayerManager.shared.playerItem != nil {
        Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateTime), userInfo: nil, repeats: true)
        }
    }
    var playimage: UIImage = UIImage(named: "play")!
    var pauseimage: UIImage = UIImage(named: "pause")!
    @IBOutlet weak var currentTime: UILabel!
    @IBOutlet weak var totalTime: UILabel!
    @IBOutlet weak var playbttn: UIButton!
    @IBOutlet weak var seekBar: UISlider!
    @IBOutlet weak var artwork: UIImageView!
    @IBOutlet weak var songTitle: UILabel!
    @IBOutlet weak var songArtist: UILabel!
    @IBAction func playbttn(_ sender: Any) {
        print(MusicPlayerManager.shared.playerItem)
        if MusicPlayerManager.shared.playerItem != nil {
            print(MusicPlayerManager.shared.Player!.rate)
            if MusicPlayerManager.shared.Player!.rate == 0 {
                MusicPlayerManager.shared.Player!.play()
                playbttn.setTitle("Pause", for: .normal)
                playbttn.setImage(pauseimage, for: .normal)
            } else {
                MusicPlayerManager.shared.Player!.pause()
                playbttn.setTitle("Play", for: .normal)
                playbttn.setImage(playimage, for: .normal)
            }
        }
    }
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
                self.artwork.image = UIImage(data: data)
                self.setupMetaData(image: data)
            }
        }
    }
    @objc func updateTime(_ timer:Timer) {
        seekBar.value = Float(MusicPlayerManager.shared.Player.currentTime().seconds)
    }
    @IBAction func seekBarAction(_ sender: Any) {
        let newTime = CMTime(seconds: Double(seekBar.value), preferredTimescale: 2)
        MusicPlayerManager.shared.Player.seek(to: newTime)
    }
    @IBAction func nextBttn(_ sender: Any) {
        MusicPlayerManager.shared.currentRow += 1
        var songT = MusicPlayerManager.shared.songArray[MusicPlayerManager.shared.currentRow]
        var url = URL(string: songT.songURL)
        let asset = AVAsset(url: url!)
        print(songT.songArtwork)
        MusicPlayerManager.shared.artwork = songT.songArtwork
        MusicPlayerManager.shared.songTitle = songT.songTitle
        MusicPlayerManager.shared.songArtist = songT.songArtist
        MusicPlayerManager.shared.songAlbum = songT.songAlbum
        MusicPlayerManager.shared.playerItem = AVPlayerItem(asset: asset)
        songTitle.text = MusicPlayerManager.shared.songTitle
        if MusicPlayerManager.shared.playerItem != nil {
            var songInfo: String = "\(MusicPlayerManager.shared.songArtist) -- \(MusicPlayerManager.shared.songAlbum)"
            songArtist.text = songInfo
            seekBar.minimumValue = 0
            seekBar.maximumValue = Float(MusicPlayerManager.shared.playerItem.asset.duration.seconds)
            seekBar.value = Float(MusicPlayerManager.shared.Player.currentTime().seconds)
            totalTime.text = String(MusicPlayerManager.shared.playerItem.asset.duration.seconds)
            currentTime.text = String(MusicPlayerManager.shared.Player.currentTime().seconds)
            print(Float(MusicPlayerManager.shared.playerItem.asset.duration.seconds))
        } else {
            songArtist.text = ""
        }
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default)
            MusicPlayerManager.shared.Player = AVPlayer(url: url!)
            MusicPlayerManager.shared.Player?.play()
            setupRemoteTransportControls()
            downloadArtwork()
        } catch {
            print(error)
        }
    }
    @IBAction func previousBttn(_ sender: Any) {
        MusicPlayerManager.shared.currentRow -= 1
        var songT = MusicPlayerManager.shared.songArray[MusicPlayerManager.shared.currentRow]
        var url = URL(string: songT.songURL)
        let asset = AVAsset(url: url!)
        print(songT.songArtwork)
        MusicPlayerManager.shared.artwork = songT.songArtwork
        MusicPlayerManager.shared.songTitle = songT.songTitle
        MusicPlayerManager.shared.songArtist = songT.songArtist
        MusicPlayerManager.shared.songAlbum = songT.songAlbum
        MusicPlayerManager.shared.playerItem = AVPlayerItem(asset: asset)
        songTitle.text = MusicPlayerManager.shared.songTitle
        if MusicPlayerManager.shared.playerItem != nil {
            var songInfo: String = "\(MusicPlayerManager.shared.songArtist) -- \(MusicPlayerManager.shared.songAlbum)"
            songArtist.text = songInfo
            seekBar.minimumValue = 0
            seekBar.maximumValue = Float(MusicPlayerManager.shared.playerItem.asset.duration.seconds)
            seekBar.value = Float(MusicPlayerManager.shared.Player.currentTime().seconds)
            totalTime.text = String(MusicPlayerManager.shared.playerItem.asset.duration.seconds)
            currentTime.text = String(MusicPlayerManager.shared.Player.currentTime().seconds)
            print(Float(MusicPlayerManager.shared.playerItem.asset.duration.seconds))
        } else {
            songArtist.text = ""
        }
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default)
            MusicPlayerManager.shared.Player = AVPlayer(url: url!)
            MusicPlayerManager.shared.Player?.play()
            setupRemoteTransportControls()
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
        
        
    }
    func setupMetaData(image: Data) {
        var songT = MusicPlayerManager.shared.songArray[MusicPlayerManager.shared.currentRow]
        var url = URL(string: songT.songURL)
        do {
            setupRemoteTransportControls()
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
                    self.artwork.image = UIImage(data: data)
                    self.setupMetaData(image: data)
                }
            }
        }
        print("Begin of code")
        let url = URL(string: MusicPlayerManager.shared.artwork)!
        downloadImage(from: url)
        print("End of code. The image will continue downloading in the background and it will be loaded when it ends.")
    }
}

