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
    
    let categoryURL = "http://api.zhuishushenqi.com/cats"
    let rankURL = "http://api.zhuishushenqi.com/ranking"
    
    var maleCategoryArray = [Category]()
    var femaleCategoryArray = [Category]()
    var rankArray = [Rank]()
    
    
    @IBOutlet weak var storeStackView: UIStackView!
    @IBOutlet weak var maleCategoryCollectionView: UICollectionView!
    @IBOutlet weak var femaleCategoryCollectionView: UICollectionView!
    @IBOutlet weak var rankCollectionView: UICollectionView!
    
    @IBOutlet weak var maleViewWidth: NSLayoutConstraint!
    @IBOutlet weak var femaleViewWidth: NSLayoutConstraint!
    @IBOutlet weak var rankViewWidth: NSLayoutConstraint!
    
    @IBOutlet weak var switchViewSegmentedControl: UISegmentedControl!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getCategoryData(from: categoryURL)
        getRankData(from: rankURL)
        
        // Register CustomCategoryCell.xib
        maleCategoryCollectionView.register(UINib(nibName: "CustomCategoryCell", bundle: nil), forCellWithReuseIdentifier: "customCategoryCell")
        femaleCategoryCollectionView.register(UINib(nibName: "CustomCategoryCell", bundle: nil), forCellWithReuseIdentifier: "customCategoryCell")
        rankCollectionView.register(UINib(nibName: "CustomCategoryCell", bundle: nil), forCellWithReuseIdentifier: "customCategoryCell")
        
        // Style
        storeStackView.frame.size.width = UIScreen.main.bounds.width
        maleViewWidth.constant = storeStackView.frame.size.width
        femaleViewWidth.constant = 0
        rankViewWidth.constant = 0
        maleCategoryCollectionView.collectionViewLayout = cellStyle()
    }


    // MARK: - Networking
    
    // getCategoryData Method
    func getCategoryData(from url: String) {
        Alamofire.request(url).responseJSON {
            response in
            if response.result.isSuccess{
                let categoryJSON : JSON = JSON(response.result.value!)
                self.createCategoryArray(with: categoryJSON)
            } else {
                print("Couldnt process JSON response, Error: \(String(describing: response.result.error))")
            }
        }
    }
    
    func getRankData(from url: String) {
        Alamofire.request(url).responseJSON {
            response in
            if response.result.isSuccess{
                let rankJSON : JSON = JSON(response.result.value!)
                self.createRankArray(with: rankJSON)
            } else {
                print("Couldnt process JSON response, Error: \(String(describing: response.result.error))")
            }
        }
    }
    
    
    // MARK: - JSON Parsing
    
    // Parse JSON data
    func createCategoryArray(with json: JSON) {
        guard !json.isEmpty else {fatalError("json unavailible!")}
        // Create  maleCatagoryArray
        for category in json["male"].arrayValue {
            let name = category["name"].stringValue
            let bookCount = category["bookCount"].intValue
            let newElement = Category(name: name, count: bookCount)
            
            maleCategoryArray.append(newElement)
        }
        // Create femaleCategoryArray
        for category in json["female"].arrayValue {
            let name = category["name"].stringValue
            let bookCount = category["bookCount"].intValue
            let newElement = Category(name: name, count: bookCount)
            
            femaleCategoryArray.append(newElement)
        }
        maleCategoryCollectionView.reloadData()
        femaleCategoryCollectionView.reloadData()
    }
    
    func createRankArray(with json: JSON) {
        guard !json.isEmpty else {fatalError("json unavailible!")}
        // Create rankArray
        for rank in json["rankings"].arrayValue {
            let title = rank["title"].stringValue
            let id = rank["_id"].stringValue
            let newElement = Rank(title: title, id: id)
            
            rankArray.append(newElement)
        }
        rankCollectionView.reloadData()
    }

    
    
    // MARK: - Styling
    
    // CollectionView Cell Style
    func cellStyle() -> UICollectionViewFlowLayout {
        //let itemSize = UIScreen.main.bounds.width/3 - 12
        let cellSize = storeStackView.frame.size.width/3 - 12
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsetsMake(8, 8, 8, 8)
        layout.itemSize = CGSize(width: cellSize, height: cellSize)
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        
        return layout
        
    }
    
    
    
    // MARK: - Action
    
    @IBAction func switchViewSegmentedControlPressed(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            maleCategoryCollectionView.collectionViewLayout = cellStyle()
            UIView.animate(withDuration: 0.5) {
                self.maleViewWidth.constant = self.storeStackView.frame.size.width
                self.femaleViewWidth.constant = 0
                self.rankViewWidth.constant = 0
                self.view.layoutIfNeeded()
            }
            
        }
        else if sender.selectedSegmentIndex == 1 {
            femaleCategoryCollectionView.collectionViewLayout = cellStyle()
            UIView.animate(withDuration: 0.5) {
                self.maleViewWidth.constant = 0
                self.femaleViewWidth.constant = self.storeStackView.frame.size.width
                self.rankViewWidth.constant = 0
                self.view.layoutIfNeeded()
            }
        }
        else if sender.selectedSegmentIndex == 2 {
            rankCollectionView.collectionViewLayout = cellStyle()
            UIView.animate(withDuration: 0.5) {
                self.maleViewWidth.constant = 0
                self.femaleViewWidth.constant = 0
                self.rankViewWidth.constant = self.storeStackView.frame.size.width
                self.view.layoutIfNeeded()
            }
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
        else if collectionView == rankCollectionView {
            return rankArray.count
        }
        return 0
    }
    
    // Populate cells
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "customCategoryCell", for: indexPath) as! CustomCategoryCell
        
        if collectionView == maleCategoryCollectionView {
            let cellData = maleCategoryArray[indexPath.row]
            cell.nameLabel.text = cellData.categoryName
        }
        else if collectionView == femaleCategoryCollectionView {
            let cellData = femaleCategoryArray[indexPath.row]
            cell.nameLabel.text = cellData.categoryName
        }
        else if collectionView == rankCollectionView {
            let cellData = rankArray[indexPath.row]
            cell.nameLabel.text = cellData.rankTitle
        }
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == maleCategoryCollectionView {
            performSegue(withIdentifier: "goToCategoryList", sender: maleCategoryCollectionView)
        }
        else if collectionView == femaleCategoryCollectionView {
            performSegue(withIdentifier: "goToCategoryList", sender: femaleCategoryCollectionView)
        }
    }
   
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToCategoryList" {
            
            let destinationVC = segue.destination as! CategoryListViewController
            let senderView = sender as! UICollectionView
            
            if senderView.tag == 0 {
                if let indexPaths = maleCategoryCollectionView.indexPathsForSelectedItems {
                    let indexPath = indexPaths[0] as NSIndexPath
                    destinationVC.major = maleCategoryArray[indexPath.row].categoryName
                    destinationVC.gender = "male"
                }
            }
            else if senderView.tag == 1 {
                if let indexPaths = femaleCategoryCollectionView.indexPathsForSelectedItems {
                    let indexPath = indexPaths[0] as NSIndexPath
                    destinationVC.major = femaleCategoryArray[indexPath.row].categoryName
                    destinationVC.gender = "female"
                }
            }
        }
    }
    
    
    
}

