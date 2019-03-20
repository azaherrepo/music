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
import GoogleMobileAds

class FirstViewController: UIViewController {
    let player = MusicPlayerManager.shared.Player
    
    @IBOutlet weak var banerView: GADBannerView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        print("Google Mobile Ads SDK version: \(GADRequest.sdkVersion())")
        banerView.adUnitID = "ca-app-pub-6780980839977049/4459922671"
        banerView.rootViewController = self
        banerView.load(GADRequest())
    }
    override func viewDidAppear(_ animated: Bool) {

        songTitle.text = MusicPlayerManager.shared.songTitle
        if MusicPlayerManager.shared.playerItem != nil {
        var songInfo: String = "\(MusicPlayerManager.shared.songArtist) -- \(MusicPlayerManager.shared.songAlbum)"
            songArtist.text = songInfo
            print("\(Int(MusicPlayerManager.shared.playerItem.asset.duration.seconds)/60):\(Int(MusicPlayerManager.shared.playerItem.asset.duration.seconds)%60)")
            seekBar.minimumValue = 0
            seekBar.maximumValue = Float(MusicPlayerManager.shared.playerItem.asset.duration.seconds)
            seekBar.value = Float(MusicPlayerManager.shared.Player.currentTime().seconds)
            let currentTimeString: String
            if Int(MusicPlayerManager.shared.Player.currentTime().seconds)%60 > 9 {
                currentTimeString = "\(Int(MusicPlayerManager.shared.Player.currentTime().seconds)/60):\(Int(MusicPlayerManager.shared.Player.currentTime().seconds)%60)"
            } else {
                currentTimeString = "\(Int(MusicPlayerManager.shared.Player.currentTime().seconds)/60):0\(Int(MusicPlayerManager.shared.Player.currentTime().seconds)%60)"
            }
            let totalTimeString: String
            if Int(MusicPlayerManager.shared.playerItem.asset.duration.seconds)%60 > 9 {
                totalTimeString = "\(Int(MusicPlayerManager.shared.playerItem.asset.duration.seconds)/60):\(Int(MusicPlayerManager.shared.playerItem.asset.duration.seconds)%60)"
            } else {
                totalTimeString = "\(Int(MusicPlayerManager.shared.playerItem.asset.duration.seconds)/60):0\(Int(MusicPlayerManager.shared.playerItem.asset.duration.seconds)%60)"
            }
            totalTime.text = totalTimeString
            currentTime.text = currentTimeString
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
        if MusicPlayerManager.shared.downloaded == false {
        downloadImage(from: url)
        } else {
            artwork.image = MusicPlayerManager.shared.artworkImage
        }
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
        let currentTimeString: String
        if Int(MusicPlayerManager.shared.Player.currentTime().seconds)%60 > 9 {
            currentTimeString = "\(Int(MusicPlayerManager.shared.Player.currentTime().seconds)/60):\(Int(MusicPlayerManager.shared.Player.currentTime().seconds)%60)"
        } else {
            currentTimeString = "\(Int(MusicPlayerManager.shared.Player.currentTime().seconds)/60):0\(Int(MusicPlayerManager.shared.Player.currentTime().seconds)%60)"
        }
        currentTime.text = currentTimeString
    }
    @IBAction func seekBarAction(_ sender: Any) {
        let newTime = CMTime(seconds: Double(seekBar.value), preferredTimescale: 2)
        MusicPlayerManager.shared.Player.seek(to: newTime)
        if MusicPlayerManager.shared.downloaded == false {
            downloadArtwork()
        } else {
            setupMetaDataDownloaded(image: MusicPlayerManager.shared.artworkImage)
        }
    }
    func streamNext() {
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
        songTitle.text = MusicPlayerManager.shared.songTitle
        
        var songInfo: String = "\(MusicPlayerManager.shared.songArtist) -- \(MusicPlayerManager.shared.songAlbum)"
        songArtist.text = songInfo
        let currentTimeString: String
        if Int(MusicPlayerManager.shared.Player.currentTime().seconds)%60 > 9 {
            currentTimeString = "\(Int(MusicPlayerManager.shared.Player.currentTime().seconds)/60):\(Int(MusicPlayerManager.shared.Player.currentTime().seconds)%60)"
        } else {
            currentTimeString = "\(Int(MusicPlayerManager.shared.Player.currentTime().seconds)/60):0\(Int(MusicPlayerManager.shared.Player.currentTime().seconds)%60)"
        }
        seekBar.minimumValue = 0
        seekBar.maximumValue = Float(MusicPlayerManager.shared.playerItem.asset.duration.seconds)
        seekBar.value = Float(MusicPlayerManager.shared.Player.currentTime().seconds)
        let totalTimeString: String
        if Int(MusicPlayerManager.shared.playerItem.asset.duration.seconds)%60 > 9 {
            totalTimeString = "\(Int(MusicPlayerManager.shared.playerItem.asset.duration.seconds)/60):\(Int(MusicPlayerManager.shared.playerItem.asset.duration.seconds)%60)"
        } else {
            totalTimeString = "\(Int(MusicPlayerManager.shared.playerItem.asset.duration.seconds)/60):0\(Int(MusicPlayerManager.shared.playerItem.asset.duration.seconds)%60)"
        }
        totalTime.text = totalTimeString
        currentTime.text = currentTimeString
        print(Float(MusicPlayerManager.shared.playerItem.asset.duration.seconds))
        
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default)
            MusicPlayerManager.shared.Player = AVPlayer(url: url!)
            MusicPlayerManager.shared.Player?.play()
            downloadArtwork()
        } catch {
            print(error)
        }
    }
    func createNewPath(lastPath: String) -> URL {
        let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        
        let destination = URL(fileURLWithPath: String(format: "%@/%@", documentsDirectory,lastPath))
        return destination
    }
    
    func downloadedNext() {
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
        setupMetaDataDownloaded(image: MusicPlayerManager.shared.artworkImage)
        songTitle.text = MusicPlayerManager.shared.songTitle
        
        var songInfo: String = "\(MusicPlayerManager.shared.songArtist) -- \(MusicPlayerManager.shared.songAlbum)"
        songArtist.text = songInfo
        seekBar.minimumValue = 0
        seekBar.maximumValue = Float(MusicPlayerManager.shared.playerItem.asset.duration.seconds)
        seekBar.value = Float(MusicPlayerManager.shared.Player.currentTime().seconds)
        let currentTimeString: String
        if Int(MusicPlayerManager.shared.Player.currentTime().seconds)%60 > 9 {
            currentTimeString = "\(Int(MusicPlayerManager.shared.Player.currentTime().seconds)/60):\(Int(MusicPlayerManager.shared.Player.currentTime().seconds)%60)"
        } else {
            currentTimeString = "\(Int(MusicPlayerManager.shared.Player.currentTime().seconds)/60):0\(Int(MusicPlayerManager.shared.Player.currentTime().seconds)%60)"
        }
        let totalTimeString: String
        if Int(MusicPlayerManager.shared.playerItem.asset.duration.seconds)%60 > 9 {
            totalTimeString = "\(Int(MusicPlayerManager.shared.playerItem.asset.duration.seconds)/60):\(Int(MusicPlayerManager.shared.playerItem.asset.duration.seconds)%60)"
        } else {
            totalTimeString = "\(Int(MusicPlayerManager.shared.playerItem.asset.duration.seconds)/60):0\(Int(MusicPlayerManager.shared.playerItem.asset.duration.seconds)%60)"
        }
        totalTime.text = totalTimeString
        currentTime.text = currentTimeString
        print(Float(MusicPlayerManager.shared.playerItem.asset.duration.seconds))
        
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default)
            MusicPlayerManager.shared.Player = AVPlayer(url: url)
            MusicPlayerManager.shared.Player?.play()
            artwork.image = MusicPlayerManager.shared.artworkImage
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
        songTitle.text = MusicPlayerManager.shared.songTitle
        
        var songInfo: String = "\(MusicPlayerManager.shared.songArtist) -- \(MusicPlayerManager.shared.songAlbum)"
        songArtist.text = songInfo
        seekBar.minimumValue = 0
        seekBar.maximumValue = Float(MusicPlayerManager.shared.playerItem.asset.duration.seconds)
        seekBar.value = Float(MusicPlayerManager.shared.Player.currentTime().seconds)
        let currentTimeString: String
        if Int(MusicPlayerManager.shared.Player.currentTime().seconds)%60 > 9 {
            currentTimeString = "\(Int(MusicPlayerManager.shared.Player.currentTime().seconds)/60):\(Int(MusicPlayerManager.shared.Player.currentTime().seconds)%60)"
        } else {
            currentTimeString = "\(Int(MusicPlayerManager.shared.Player.currentTime().seconds)/60):0\(Int(MusicPlayerManager.shared.Player.currentTime().seconds)%60)"
        }
        let totalTimeString: String
        if Int(MusicPlayerManager.shared.playerItem.asset.duration.seconds)%60 > 9 {
            totalTimeString = "\(Int(MusicPlayerManager.shared.playerItem.asset.duration.seconds)/60):\(Int(MusicPlayerManager.shared.playerItem.asset.duration.seconds)%60)"
        } else {
            totalTimeString = "\(Int(MusicPlayerManager.shared.playerItem.asset.duration.seconds)/60):0\(Int(MusicPlayerManager.shared.playerItem.asset.duration.seconds)%60)"
        }
        totalTime.text = totalTimeString
        currentTime.text = currentTimeString
        print(Float(MusicPlayerManager.shared.playerItem.asset.duration.seconds))
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default)
            MusicPlayerManager.shared.Player = AVPlayer(url: url!)
            MusicPlayerManager.shared.Player?.play()
            downloadArtwork()
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
        print(songT.artwork)
        MusicPlayerManager.shared.artworkImage = songT.artwork
        MusicPlayerManager.shared.songTitle = songT.songTitle
        MusicPlayerManager.shared.songArtist = songT.songArtist
        MusicPlayerManager.shared.songAlbum = songT.songAlbum
        MusicPlayerManager.shared.playerItem = AVPlayerItem(asset: asset)
        setupMetaDataDownloaded(image: MusicPlayerManager.shared.artworkImage)
        songTitle.text = MusicPlayerManager.shared.songTitle
        
        var songInfo: String = "\(MusicPlayerManager.shared.songArtist) -- \(MusicPlayerManager.shared.songAlbum)"
        songArtist.text = songInfo
        seekBar.minimumValue = 0
        seekBar.maximumValue = Float(MusicPlayerManager.shared.playerItem.asset.duration.seconds)
        seekBar.value = Float(MusicPlayerManager.shared.Player.currentTime().seconds)
        let currentTimeString: String
        if Int(MusicPlayerManager.shared.Player.currentTime().seconds)%60 > 9 {
            currentTimeString = "\(Int(MusicPlayerManager.shared.Player.currentTime().seconds)/60):\(Int(MusicPlayerManager.shared.Player.currentTime().seconds)%60)"
        } else {
            currentTimeString = "\(Int(MusicPlayerManager.shared.Player.currentTime().seconds)/60):0\(Int(MusicPlayerManager.shared.Player.currentTime().seconds)%60)"
        }
        let totalTimeString: String
        if Int(MusicPlayerManager.shared.playerItem.asset.duration.seconds)%60 > 9 {
            totalTimeString = "\(Int(MusicPlayerManager.shared.playerItem.asset.duration.seconds)/60):\(Int(MusicPlayerManager.shared.playerItem.asset.duration.seconds)%60)"
        } else {
            totalTimeString = "\(Int(MusicPlayerManager.shared.playerItem.asset.duration.seconds)/60):0\(Int(MusicPlayerManager.shared.playerItem.asset.duration.seconds)%60)"
        }
        totalTime.text = totalTimeString
        currentTime.text = currentTimeString
        print(Float(MusicPlayerManager.shared.playerItem.asset.duration.seconds))
        
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default)
            MusicPlayerManager.shared.Player = AVPlayer(url: url)
            MusicPlayerManager.shared.Player?.play()
            artwork.image = MusicPlayerManager.shared.artworkImage
        } catch {
            print(error)
        }
    }
    
    @IBAction func nextBttn(_ sender: Any) {
        if MusicPlayerManager.shared.playerItem != nil {
            if MusicPlayerManager.shared.downloaded == false {
                streamNext()
            } else {
                downloadedNext()
            }
        }
    }
    @IBAction func previousBttn(_ sender: Any) {
        if MusicPlayerManager.shared.playerItem != nil {
            if MusicPlayerManager.shared.downloaded == false {
                streamPrev()
            } else {
                downloadedPrev()
            }
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
    func setupMetaDataDownloaded(image: UIImage?) {
        var songT = MusicPlayerManager.shared.downloadedFiltered[MusicPlayerManager.shared.currentRow]
        var url = URL(string: songT.songFile)
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


