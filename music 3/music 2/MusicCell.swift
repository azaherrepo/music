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
        let titleString = song.songTitle
        let editedTitle = titleString.replacingOccurrences(of: "&", with: " & ", options: .literal, range: nil)
        let artistString = song.songArtist
        let editedArtist = artistString.replacingOccurrences(of: "&", with: " & ", options: .literal, range: nil)
        musicTitle.text = editedTitle
        infoLabel.text = editedArtist
    }
    @IBAction func downloadBttn(_ sender: Any) {
        delegate?.tappedDownloadButton(musicitem: musicItem)
    }
    
}
