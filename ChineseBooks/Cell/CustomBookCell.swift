//
//  CustomBookCell.swift
//  ChineseBooks
//
//  Created by Jason Li on 2018-08-18.
//  Copyright © 2018 Jason Li. All rights reserved.
//

import UIKit

protocol CollectionViewNew {
    func deleteCell(withIndex index: Int)
}


class CustomBookCell: UICollectionViewCell {
    
    var cellDelegate : CollectionViewNew?
    var index = 0

    @IBOutlet weak var bookCoverImage: UIImageView!
    
    @IBOutlet weak var bookTitleLabel: UILabel!
    
    @IBOutlet weak var bookAuthorLabel: UILabel!
    
    @IBOutlet weak var deleteButton: UIButton!
    
    
    //    override func awakeFromNib() {
//        super.awakeFromNib()
//        // Initialization code
//    }

    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        cellDelegate?.deleteCell(withIndex: index)
    }
    
    
    var shakeEnabled: Bool!
    func shakeIcons() {
        let shakeAnimation = CABasicAnimation(keyPath: "transform.rotation")
        shakeAnimation.duration = 0.05
        shakeAnimation.repeatCount = 2
        shakeAnimation.autoreverses = true
        let startAngle: Float = (-2) * 3.14159/180
        let stopAngle = -startAngle
        shakeAnimation.fromValue = NSNumber(value: startAngle as Float)
        shakeAnimation.toValue = NSNumber(value: 3 * stopAngle as Float)
        shakeAnimation.autoreverses = true
        shakeAnimation.duration = 0.2
        shakeAnimation.repeatCount = 10000
        shakeAnimation.timeOffset = 290 * drand48()
        
        let layer: CALayer = self.layer
        layer.add(shakeAnimation, forKey:"shaking")
        shakeEnabled = true
    }
    
    func stopShakingIcons() {
        let layer: CALayer = self.layer
        layer.removeAnimation(forKey: "shaking")
        self.deleteButton.isHidden = true
        shakeEnabled = false
    }
    
    
    
}
