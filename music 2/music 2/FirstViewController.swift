//
//  FirstViewController.swift
//  music 2
//
//  Created by Ayman Zaher on 2019-03-03.
//  Copyright © 2019 Ayman Zaher. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {
let player = MusicPlayerManager.shared.Player
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
    }
    override func viewDidAppear(_ animated: Bool) {
        songTitle.text = MusicPlayerManager.shared.songTitle
        songArtist.text = MusicPlayerManager.shared.songArtist
        if let filePath = Bundle.main.path(forResource: "imageName", ofType: "jpg"), let image = UIImage(contentsOfFile: filePath) {
            artwork.contentMode = .scaleAspectFit
            artwork.image = image
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
    }
    var playimage: UIImage = UIImage(named: "play")!
    var pauseimage: UIImage = UIImage(named: "pause")!
    @IBOutlet weak var playbttn: UIButton!
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
            }
        }
    }
    

}

