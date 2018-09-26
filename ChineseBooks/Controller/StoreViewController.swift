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
import ProgressHUD
import ChameleonFramework

class StoreViewController: UIViewController {
    
    let categoryURL = "http://api.zhuishushenqi.com/cats/lv2/statistics"
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
        maleCategoryCollectionView.collectionViewLayout = Style().cellStyle(view: storeStackView, widthDecrease: 12, spacing: 8, inset: UIEdgeInsetsMake(8, 8, 8, 8), heightMultiplier: 1)
        
        // navBar
        guard let navBar = navigationController?.navigationBar else {fatalError("Navigation Controller does not exist!")}
        switchViewSegmentedControl.tintColor = navBar.tintColor
    }


    // MARK: - Networking
    
    // getCategoryData Method
    func getCategoryData(from url: String) {
        Alamofire.request(url).responseJSON {
            response in
            if response.result.isSuccess{
                let categoryJSON : JSON = JSON(response.result.value!)
                self.createCategoryArray(with: categoryJSON)
                //ProgressHUD.showSuccess()
            } else {
                print("Couldnt process JSON response, Error: \(String(describing: response.result.error))")
                ProgressHUD.showError("网络连接有问题！\n请检查网络！")
            }
        }
    }
    
    func getRankData(from url: String) {
        Alamofire.request(url).responseJSON {
            response in
            if response.result.isSuccess{
                let rankJSON : JSON = JSON(response.result.value!)
                self.createRankArray(with: rankJSON)
                //ProgressHUD.showSuccess()
            } else {
                print("Couldnt process JSON response, Error: \(String(describing: response.result.error))")
                ProgressHUD.showError("网络连接有问题！\n请检查网络！")
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
    
    
    // MARK: - Action
    
    @IBAction func switchViewSegmentedControlPressed(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            maleCategoryCollectionView.collectionViewLayout = Style().cellStyle(view: storeStackView, widthDecrease: 12, spacing: 8, inset: UIEdgeInsetsMake(8, 8, 8, 8), heightMultiplier: 1)
            UIView.animate(withDuration: 0.3) {
                self.maleViewWidth.constant = self.storeStackView.frame.size.width
                self.femaleViewWidth.constant = 0
                self.rankViewWidth.constant = 0
                self.view.layoutIfNeeded()
            }
            
        }
        else if sender.selectedSegmentIndex == 1 {
            femaleCategoryCollectionView.collectionViewLayout = Style().cellStyle(view: storeStackView, widthDecrease: 12, spacing: 8, inset: UIEdgeInsetsMake(8, 8, 8, 8), heightMultiplier: 1)
            UIView.animate(withDuration: 0.3) {
                self.maleViewWidth.constant = 0
                self.femaleViewWidth.constant = self.storeStackView.frame.size.width
                self.rankViewWidth.constant = 0
                self.view.layoutIfNeeded()
            }
        }
        else if sender.selectedSegmentIndex == 2 {
            rankCollectionView.collectionViewLayout = Style().cellStyle(view: storeStackView, widthDecrease: 12, spacing: 8, inset: UIEdgeInsetsMake(8, 8, 8, 8), heightMultiplier: 1)
            UIView.animate(withDuration: 0.3) {
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
        var count = 0
        if collectionView == maleCategoryCollectionView {
            count = maleCategoryArray.count
        }
        else if collectionView == femaleCategoryCollectionView {
            count = femaleCategoryArray.count
        }
        else if collectionView == rankCollectionView {
            count = rankArray.count
        }
        if count == 0 {
            ProgressHUD.show()
        }
        else {
            ProgressHUD.dismiss()
        }
        return count
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
    
    // Select cell
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == maleCategoryCollectionView {
            performSegue(withIdentifier: "goToCategoryList", sender: maleCategoryCollectionView)
        }
        else if collectionView == femaleCategoryCollectionView {
            performSegue(withIdentifier: "goToCategoryList", sender: femaleCategoryCollectionView)
        }
        else if collectionView == rankCollectionView {
            performSegue(withIdentifier: "goToRankList", sender: rankCollectionView)
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
        else if segue.identifier == "goToRankList" {
            let destinationVC = segue.destination as! RankListViewController
            if let indexPaths = rankCollectionView.indexPathsForSelectedItems {
                let indexPath = indexPaths[0] as NSIndexPath
                destinationVC.rankID = rankArray[indexPath.row].rankID
            }
        }
    }
    
    
    
}

