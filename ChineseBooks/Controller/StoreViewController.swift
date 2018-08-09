//
//  StoreViewController.swift
//  ChineseBooks
//
//  Created by Jason Li on 2018-08-08.
//  Copyright © 2018 Jason Li. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class StoreViewController: UIViewController {
    
    let url = "http://api.zhuishushenqi.com/cats"
    
    var categoryArray = [Category]()
    
    
    @IBOutlet weak var maleCategoryCollectionView: UICollectionView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getCategoryData(from: url)
        
        // Register CustomCategoryCell.xib
        maleCategoryCollectionView.register(UINib(nibName: "CustomCategoryCell", bundle: nil), forCellWithReuseIdentifier: "customCategoryCell")
        
        // Style
        cellStyle()
    }


    // MARK: - Networking
    
    // getCategoryData Method
    func getCategoryData(from url: String) {
        Alamofire.request(url).responseJSON {
            response in
            if response.result.isSuccess{
                let categoryJSON : JSON = JSON(response.result.value!)
                self.createCategoryDict(with: categoryJSON)
                //print(categoryJSON["male"].arrayValue)
            } else {
                print("Couldnt process JSON response, Error: \(response.result.error)")
            }
        }
    }
    
    
    // MARK: - JSON Parsing
    
    // Parse JSON data
    func createCategoryDict(with json: JSON) {
        guard !json.isEmpty else {fatalError("json unavailible!")}
        
        for category in json["male"].arrayValue {
            let name = category["name"].stringValue
            let bookCount = category["bookCount"].intValue
            let newElement = Category(name: name, count: bookCount)
            
            //print(newElement)
            categoryArray.append(newElement)
        }
        //print(categoryArray[0].categoryName)
        maleCategoryCollectionView.reloadData()
    }

    
    // CollectionView Cell Style
    func cellStyle() {
        //let itemSize = UIScreen.main.bounds.width/3 - 3
        let cellSize = maleCategoryCollectionView.frame.size.width/3
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsetsMake(8, 8, 8, 8)
        layout.itemSize = CGSize(width: cellSize, height: cellSize)
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        
        maleCategoryCollectionView.collectionViewLayout = layout
    }
    
    
}


// MARK: - CollectionView Datasource Method

extension StoreViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    // Number of cells
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categoryArray.count
    }
    
    // Populate cells
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "customCategoryCell", for: indexPath) as! CustomCategoryCell
        let cellData = categoryArray[indexPath.row]
        cell.categoryLabel.text = cellData.categoryName
        cell.bookCountLabel.text = "\(String(cellData.bookCount)) 本"
        return cell
    }
    
    
}

