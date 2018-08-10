//
//  ViewController.swift
//  ChineseBooks
//
//  Created by Jason Li on 2018-08-10.
//  Copyright © 2018 Jason Li. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var v1width: NSLayoutConstraint!
    @IBOutlet weak var v2width: NSLayoutConstraint!
    @IBOutlet weak var v3width: NSLayoutConstraint!
    @IBOutlet weak var containerView: UIView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func b1pressed(_ sender: UIButton) {
        v1width.constant = containerView.frame.size.width
        v2width.constant = 0
        v3width.constant = 0
    }
    @IBAction func b2pressed(_ sender: UIButton) {
        v1width.constant = 0
        v2width.constant = containerView.frame.size.width
        v3width.constant = 0
    }
    @IBAction func b3pressed(_ sender: UIButton) {
        v1width.constant = 0
        v2width.constant = 0
        v3width.constant = containerView.frame.size.width
    }
    
    
    

}
