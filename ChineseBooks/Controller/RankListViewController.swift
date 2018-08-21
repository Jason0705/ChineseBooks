//
//  RankListViewController.swift
//  ChineseBooks
//
//  Created by Jason Li on 2018-08-20.
//  Copyright © 2018 Jason Li. All rights reserved.
//

import UIKit

class RankListViewController: UIViewController {
    
    let baseURL = "http://api.zhuishushenqi.com/ranking/"
    var rankID = ""

    @IBOutlet weak var rankCollectionView: UICollectionView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let url = "\(baseURL)\(rankID)"
        print(url)
        
    }


}
