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
    @IBAction func playbttn(_ sender: Any) {
        print(MusicPlayerManager.shared.Player!.rate)
        if MusicPlayerManager.shared.Player!.rate == 0 {
            MusicPlayerManager.shared.Player!.play()
        } else {
            MusicPlayerManager.shared.Player!.pause()
        }
    }
    

}

