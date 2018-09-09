//
//  ContentViewController.swift
//  ChineseBooks
//
//  Created by Jason Li on 2018-08-30.
//  Copyright © 2018 Jason Li. All rights reserved.
//

import UIKit

class ContentViewController: UIViewController {

    var chapterTitle = ""
    var body = ""
    var pageCounte = ""
    
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var pageCounterLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        titleLabel.text = chapterTitle
        contentTextView.text = body
        pageCounterLabel.text = pageCounte
    }

}

