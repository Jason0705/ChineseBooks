//
//  CustomChapterCell.swift
//  ChineseBooks
//
//  Created by Jason Li on 2018-09-22.
//  Copyright © 2018 Jason Li. All rights reserved.
//

import UIKit

class CustomChapterCell: UITableViewCell {

    
    
    @IBOutlet weak var bookMarkImage: UIImageView!
    @IBOutlet weak var chapterTitleLabel: UILabel!
    @IBOutlet weak var downloadedLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
