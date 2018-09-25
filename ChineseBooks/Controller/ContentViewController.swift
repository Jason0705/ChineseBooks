//
//  ContentViewController.swift
//  ChineseBooks
//
//  Created by Jason Li on 2018-08-30.
//  Copyright © 2018 Jason Li. All rights reserved.
//

import UIKit
import ChameleonFramework

class ContentViewController: UIViewController {

    var chapterTitle = ""
    var body = ""
    var pageCounte = ""
    var backgroundColor = UIColor.white
    var fontSize : CGFloat = 22
    
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var pageCounterLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        contentLabel.font = UIFont(name: contentLabel.font.fontName, size: fontSize)
        
        titleLabel.text = chapterTitle
        contentLabel.text = body
        contentLabel.numberOfLines = Int(contentLabel.bounds.height / contentLabel.font.lineHeight)
        pageCounterLabel.text = pageCounte
        containerView.backgroundColor = backgroundColor
        titleLabel.textColor = ContrastColorOf(containerView.backgroundColor!, returnFlat: true)
        contentLabel.textColor = ContrastColorOf(containerView.backgroundColor!, returnFlat: true)
        pageCounterLabel.textColor = ContrastColorOf(containerView.backgroundColor!, returnFlat: true)
    }

}

