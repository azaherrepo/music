//
//  DownloadCell.swift
//  music 2
//
//  Created by Ayman Zaher on 2019-03-15.
//  Copyright © 2019 Ayman Zaher. All rights reserved.
//

import UIKit

protocol musicDelete {
    func tappedDeleteButton(musicitem: downloadedTable)
}

class DownloadCell: UITableViewCell {

    @IBOutlet weak var songTitle: UILabel!
    @IBOutlet weak var songInfo: UILabel!
    
    var delegate: musicDelete?
    var songItem: downloadedTable!
    func setSongs(song: downloadedTable){
        songItem = song
        songTitle.text = song.songTitle
        songInfo.text = song.songArtist
    }
    @IBAction func deleteBttn(_ sender: Any) {
        print("clicked")
        delegate?.tappedDeleteButton(musicitem: songItem)
    }
    
}
