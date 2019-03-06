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
        if let filePath = Bundle.main.path(forResource: "imageName", ofType: "jpg"), let image = UIImage(contentsOfFile: filePath) {
            artwork.contentMode = .scaleAspectFit
            artwork.image = image
        }
        print("Begin of code")
        let url = URL(string: MusicPlayerManager.shared.artwork)!
        downloadImage(from: url)
        print("End of code. The image will continue downloading in the background and it will be loaded when it ends.")
    }
    @IBOutlet weak var playbttn: UIButton!
    @IBOutlet weak var artwork: UIImageView!
    @IBOutlet weak var songTitle: UILabel!
    @IBAction func playbttn(_ sender: Any) {
        //print(MusicPlayerManager.shared.Player!.rate)
        print(MusicPlayerManager.shared.playerItem)
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

