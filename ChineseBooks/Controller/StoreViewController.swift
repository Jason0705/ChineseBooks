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
    
    var url = "http://api.zhuishushenqi.com/cats"
    //var segmentedControlIndex = 0
    
    var maleCategoryArray = [Category]()
    var femaleCategoryArray = [Category]()
    
    
    @IBOutlet weak var storeStackView: UIStackView!
    @IBOutlet weak var maleCategoryCollectionView: UICollectionView!
    @IBOutlet weak var femaleCategoryCollectionView: UICollectionView!
    
    @IBOutlet weak var maleViewWidth: NSLayoutConstraint!
    @IBOutlet weak var femaleViewWidth: NSLayoutConstraint!
    @IBOutlet weak var rankingViewWidth: NSLayoutConstraint!
    
    @IBOutlet weak var switchViewSegmentedControl: UISegmentedControl!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getCategoryData(from: url)
        
        // Register CustomCategoryCell.xib
        maleCategoryCollectionView.register(UINib(nibName: "CustomCategoryCell", bundle: nil), forCellWithReuseIdentifier: "customCategoryCell")
        femaleCategoryCollectionView.register(UINib(nibName: "CustomCategoryCell", bundle: nil), forCellWithReuseIdentifier: "customCategoryCell")
        
        // Style
        //cellStyle()
        
        //storeStackView.frame.size.width = UIScreen.main.bounds.width
        maleViewWidth.constant = UIScreen.main.bounds.width
        femaleViewWidth.constant = 0
        rankingViewWidth.constant = 0
        maleCategoryCollectionView.collectionViewLayout = cellStyle()
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
                //print(categoryJSON)
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
            
            //print(newElement.categoryName)
            maleCategoryArray.append(newElement)
        }
        
        for category in json["female"].arrayValue {
            let name = category["name"].stringValue
            let bookCount = category["bookCount"].intValue
            let newElement = Category(name: name, count: bookCount)
            
            //print(newElement.categoryName)
            femaleCategoryArray.append(newElement)
        }
        //print(categoryArray[0].categoryName)
        //print(femaleCategoryArray[0].categoryName)
        maleCategoryCollectionView.reloadData()
        femaleCategoryCollectionView.reloadData()
    }

    
    // CollectionView Cell Style
    func cellStyle() -> UICollectionViewFlowLayout {
        let itemSize = UIScreen.main.bounds.width/3 - 12
        //let cellSize = storeStackView.frame.size.width/3 - 12
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsetsMake(8, 8, 8, 8)
        layout.itemSize = CGSize(width: itemSize, height: itemSize)
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        
        //maleCategoryCollectionView.collectionViewLayout = layout
        
        return layout
        
    }
    
    
    // MARK: - Action
    
    @IBAction func switchViewSegmentedControlPressed(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            maleViewWidth.constant = UIScreen.main.bounds.width
            femaleViewWidth.constant = 0
            rankingViewWidth.constant = 0
//            segmentedControlIndex = 0
//            cellStyle(for: segmentedControlIndex)
            maleCategoryCollectionView.collectionViewLayout = cellStyle()
        }
        else if sender.selectedSegmentIndex == 1 {
            maleViewWidth.constant = 0
            femaleViewWidth.constant = UIScreen.main.bounds.width
            rankingViewWidth.constant = 0
//            segmentedControlIndex = 1
//            cellStyle(for: segmentedControlIndex)
            femaleCategoryCollectionView.collectionViewLayout = cellStyle()
        }
        else if sender.selectedSegmentIndex == 2 {
            //url = "http://api.zhuishushenqi.com/ranking"
            maleViewWidth.constant = 0
            femaleViewWidth.constant = 0
            rankingViewWidth.constant = UIScreen.main.bounds.width
            //getCategoryData(from: url)
        }
        
    }
    
    
    
    
    
    
}







// MARK: - CollectionView Datasource Method

extension StoreViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    // Number of cells
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == maleCategoryCollectionView {
            return maleCategoryArray.count
        }
        else if collectionView == femaleCategoryCollectionView {
            return femaleCategoryArray.count
        }
        return 0
    }
    
    // Populate cells
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "customCategoryCell", for: indexPath) as! CustomCategoryCell
        var cellData = maleCategoryArray[indexPath.row]
        
        if collectionView == maleCategoryCollectionView {
            cellData = maleCategoryArray[indexPath.row]
            cell.backgroundColor = UIColor.green
        }
        else if collectionView == femaleCategoryCollectionView {
            cellData = femaleCategoryArray[indexPath.row]
            cell.backgroundColor = UIColor.green
        }
        cell.categoryLabel.text = cellData.categoryName
        cell.bookCountLabel.text = "\(String(cellData.bookCount)) 本"
        return cell
    }
    
    
}

