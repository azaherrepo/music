//
//  MusicCell.swift
//  music 2
//
//  Created by Ayman Zaher on 2019-03-13.
//  Copyright © 2019 Ayman Zaher. All rights reserved.
//

import UIKit
protocol musicDownload {
    func tappedDownloadButton(musicitem: SongTable)
}

class MusicCell: UITableViewCell {

    @IBOutlet weak var musicTitle: UILabel!    
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var downBttn: UIButton!
    
    var delegate: musicDownload?
    var musicItem: SongTable!
    func setMusic(song: SongTable) {
        musicItem = song
        musicTitle.text = song.songTitle
        infoLabel.text = song.songArtist
    }
    @IBAction func downloadBttn(_ sender: Any) {
        delegate?.tappedDownloadButton(musicitem: musicItem)
        downBttn.isEnabled = false
    }
    
}
