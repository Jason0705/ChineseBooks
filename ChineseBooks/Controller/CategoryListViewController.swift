//
//  CategoryListViewController.swift
//  ChineseBooks
//
//  Created by Jason Li on 2018-08-15.
//  Copyright © 2018 Jason Li. All rights reserved.
//

import UIKit

class CategoryListViewController: UIViewController {

    @IBOutlet weak var label: UILabel!
    
    let baseURL = "http://api.zhuishushenqi.com/book/by-categories?"
    var type = ""
    var major = ""
    var gender = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("\(baseURL) + \(gender) + \(major)")

    }


}
