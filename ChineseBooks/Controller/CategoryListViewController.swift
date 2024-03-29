//
//  CategoryListViewController.swift
//  ChineseBooks
//
//  Created by Jason Li on 2018-08-15.
//  Copyright © 2018 Jason Li. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Kingfisher
import ProgressHUD

class CategoryListViewController: UIViewController {

    
    
    let baseURL = "http://api.zhuishushenqi.com/book/by-categories?"
    var major = ""
    var gender = ""
    
    var hotBookList = [Book]()
    var newBookList = [Book]()
    var reputationBookList = [Book]()
    var overBookList = [Book]()
    
    
    @IBOutlet weak var listStackView: UIStackView!
    @IBOutlet weak var hotCollectionView: UICollectionView!
    @IBOutlet weak var newCollectionView: UICollectionView!
    @IBOutlet weak var reputationCollectionView: UICollectionView!
    @IBOutlet weak var overCollectionView: UICollectionView!
    
    @IBOutlet weak var hotViewWidth: NSLayoutConstraint!
    @IBOutlet weak var newViewWidth: NSLayoutConstraint!
    @IBOutlet weak var reputationViewWidth: NSLayoutConstraint!
    @IBOutlet weak var overViewWidth: NSLayoutConstraint!
    
    @IBOutlet weak var listSegmentedControl: UISegmentedControl!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let hotURL = "\(baseURL)major=\(major.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)&gender=\(gender)&type=hot"
        let newURL = "\(baseURL)major=\(major.addingPercentEncoding( withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)&gender=\(gender)&type=new"
        let reputationURL = "\(baseURL)major=\(major.addingPercentEncoding( withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)&gender=\(gender)&type=reputation"
        let overURL = "\(baseURL)major=\(major.addingPercentEncoding( withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)&gender=\(gender)&type=over"
        
        getHotData(from: hotURL)
        getNewData(from: newURL)
        getReputationData(from: reputationURL)
        getOverData(from: overURL)
        
        // Register CustomBookCell.xib
        hotCollectionView.register(UINib(nibName: "CustomBookCell", bundle: nil), forCellWithReuseIdentifier: "customBookCell")
        newCollectionView.register(UINib(nibName: "CustomBookCell", bundle: nil), forCellWithReuseIdentifier: "customBookCell")
        reputationCollectionView.register(UINib(nibName: "CustomBookCell", bundle: nil), forCellWithReuseIdentifier: "customBookCell")
        overCollectionView.register(UINib(nibName: "CustomBookCell", bundle: nil), forCellWithReuseIdentifier: "customBookCell")

        // Style
        listStackView.frame.size.width = UIScreen.main.bounds.width
        hotViewWidth.constant = listStackView.frame.size.width
        newViewWidth.constant = 0
        reputationViewWidth.constant = 0
        overViewWidth.constant = 0
        hotCollectionView.collectionViewLayout = Style().cellStyle(view: listStackView, widthDecrease: 24, spacing: 0, inset: UIEdgeInsetsMake(8, 16, 8, 16), heightMultiplier: 2)
        
        // navBar
        guard let navBar = navigationController?.navigationBar else {fatalError("Navigation Controller does not exist!")}
        listSegmentedControl.tintColor = navBar.tintColor
    }
    
    
    // MARK: - Networking
    
    // getData Methods
    func getHotData(from url: String) {
        Alamofire.request(url).responseJSON {
            response in
            if response.result.isSuccess{
                let bookListJSON : JSON = JSON(response.result.value!)
                self.createHotList(with: bookListJSON)
                //ProgressHUD.showSuccess()
            } else {
                ProgressHUD.showError("网络连接有问题！\n请检查网络！")
                print("Couldnt process JSON response, Error: \(response.result.error)")
            }
        }
    }
    
    func getNewData(from url: String) {
        Alamofire.request(url).responseJSON {
            response in
            if response.result.isSuccess{
                let bookListJSON : JSON = JSON(response.result.value!)
                self.createNewList(with: bookListJSON)
                //ProgressHUD.showSuccess()
            } else {
                ProgressHUD.showError("网络连接有问题！\n请检查网络！")
                print("Couldnt process JSON response, Error: \(response.result.error)")
            }
        }
    }
    
    func getReputationData(from url: String) {
        Alamofire.request(url).responseJSON {
            response in
            if response.result.isSuccess{
                let bookListJSON : JSON = JSON(response.result.value!)
                self.createReputationList(with: bookListJSON)
                //ProgressHUD.showSuccess()
            } else {
                ProgressHUD.showError("网络连接有问题！\n请检查网络！")
                print("Couldnt process JSON response, Error: \(response.result.error)")
            }
        }
    }
    
    func getOverData(from url: String) {
        Alamofire.request(url).responseJSON {
            response in
            if response.result.isSuccess{
                let bookListJSON : JSON = JSON(response.result.value!)
                self.createOverList(with: bookListJSON)
                //ProgressHUD.showSuccess()
            } else {
                ProgressHUD.showError("网络连接有问题！\n请检查网络！")
                print("Couldnt process JSON response, Error: \(response.result.error)")
            }
        }
    }
    

    
    
    // MARK: - JSON Parsing
    
    // Parse JSON data
    func createHotList(with json: JSON) {
        guard !json.isEmpty else {fatalError("json unavailible!")}
        for book in json["books"].arrayValue {
            let title = book["title"].stringValue
            let id = book["_id"].stringValue
            let author = book["author"].stringValue
            let coverURL = book["cover"].stringValue.dropFirst("/agent/".count).removingPercentEncoding!
            let intro = book["shortIntro"].stringValue
            let category = book["minorCate"].stringValue
            let last = book["lastChapter"].stringValue
            
            let newElement = Book(title: title, id: id, author: author, coverURL: coverURL, intro: intro, category: category, last: last)
            
            hotBookList.append(newElement)
        }
        hotCollectionView.reloadData()
    }
    
    func createNewList(with json: JSON) {
        guard !json.isEmpty else {fatalError("json unavailible!")}
        for book in json["books"].arrayValue {
            let title = book["title"].stringValue
            let id = book["_id"].stringValue
            let author = book["author"].stringValue
            let coverURL = book["cover"].stringValue.dropFirst("/agent/".count).removingPercentEncoding!
            let intro = book["shortIntro"].stringValue
            let category = book["minorCate"].stringValue
            let last = book["lastChapter"].stringValue
            
            let newElement = Book(title: title, id: id, author: author, coverURL: coverURL, intro: intro, category: category, last: last)
            
            newBookList.append(newElement)
        }
        newCollectionView.reloadData()
    }
    
    func createReputationList(with json: JSON) {
        guard !json.isEmpty else {fatalError("json unavailible!")}
        for book in json["books"].arrayValue {
            let title = book["title"].stringValue
            let id = book["_id"].stringValue
            let author = book["author"].stringValue
            let coverURL = book["cover"].stringValue.dropFirst("/agent/".count).removingPercentEncoding!
            let intro = book["shortIntro"].stringValue
            let category = book["minorCate"].stringValue
            let last = book["lastChapter"].stringValue
            
            let newElement = Book(title: title, id: id, author: author, coverURL: coverURL, intro: intro, category: category, last: last)
            
            reputationBookList.append(newElement)
        }
        reputationCollectionView.reloadData()
    }
    
    func createOverList(with json: JSON) {
        guard !json.isEmpty else {fatalError("json unavailible!")}
        for book in json["books"].arrayValue {
            let title = book["title"].stringValue
            let id = book["_id"].stringValue
            let author = book["author"].stringValue
            let coverURL = book["cover"].stringValue.dropFirst("/agent/".count).removingPercentEncoding!
            let intro = book["shortIntro"].stringValue
            let category = book["minorCate"].stringValue
            let last = book["lastChapter"].stringValue
            
            let newElement = Book(title: title, id: id, author: author, coverURL: coverURL, intro: intro, category: category, last: last)
            
            overBookList.append(newElement)
        }
        overCollectionView.reloadData()
    }
    
    func segmentAnimation(hotW: CGFloat, newW: CGFloat, reputationW: CGFloat, overW:CGFloat) {
        UIView.animate(withDuration: 0.3) {
            self.hotViewWidth.constant = hotW
            self.newViewWidth.constant = newW
            self.reputationViewWidth.constant = reputationW
            self.overViewWidth.constant = overW
            self.view.layoutIfNeeded()
        }
    }
    
    
    // MARK: - Action
    
    @IBAction func listSegmentedControlPressed(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            hotCollectionView.collectionViewLayout = Style().cellStyle(view: listStackView, widthDecrease: 24, spacing: 0, inset: UIEdgeInsetsMake(8, 16, 8, 16), heightMultiplier: 2)
            
            segmentAnimation(hotW: self.listStackView.frame.size.width, newW: 0, reputationW: 0, overW: 0)
        }
        else if sender.selectedSegmentIndex == 1 {
            newCollectionView.collectionViewLayout = Style().cellStyle(view: listStackView, widthDecrease: 24, spacing: 0, inset: UIEdgeInsetsMake(8, 16, 8, 16), heightMultiplier: 2)
            
            segmentAnimation(hotW: 0, newW: self.listStackView.frame.size.width, reputationW: 0, overW: 0)
        }
        else if sender.selectedSegmentIndex == 2 {
            reputationCollectionView.collectionViewLayout = Style().cellStyle(view: listStackView, widthDecrease: 24, spacing: 0, inset: UIEdgeInsetsMake(8, 16, 8, 16), heightMultiplier: 2)
            
            segmentAnimation(hotW: 0, newW: 0, reputationW: self.listStackView.frame.size.width, overW: 0)
        }
        else if sender.selectedSegmentIndex == 3 {
            overCollectionView.collectionViewLayout = Style().cellStyle(view: listStackView, widthDecrease: 24, spacing: 0, inset: UIEdgeInsetsMake(8, 16, 8, 16), heightMultiplier: 2)
            
            segmentAnimation(hotW: 0, newW: 0, reputationW: 0, overW: self.listStackView.frame.size.width)
        }
    }
    
    
    
    
}






// MARK: - CollectionView Datasource Method

extension CategoryListViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    // Number of Cell
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var count = 0
        if collectionView == hotCollectionView {
            count = hotBookList.count
        }
        else if collectionView == newCollectionView {
            count = newBookList.count
        }
        else if collectionView == reputationCollectionView {
            count = reputationBookList.count
        }
        else if collectionView == overCollectionView {
            count = overBookList.count
        }
        if count == 0 {
            ProgressHUD.show()
        }
        else {
            ProgressHUD.dismiss()
        }
        return count
    }
    
    // Populate Cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "customBookCell", for: indexPath) as! CustomBookCell
        
        if collectionView == hotCollectionView {
            let cellData = hotBookList[indexPath.row]
            cell.bookTitleLabel.text = cellData.bookTitle
            cell.bookAuthorLabel.text = cellData.bookAuthor
            let coverURL = URL(string: cellData.bookCoverURL)
            cell.bookCoverImage.kf.setImage(with: coverURL)
        }
        else if collectionView == newCollectionView {
            let cellData = newBookList[indexPath.row]
            cell.bookTitleLabel.text = cellData.bookTitle
            cell.bookAuthorLabel.text = cellData.bookAuthor
            let coverURL = URL(string: cellData.bookCoverURL)
            cell.bookCoverImage.kf.setImage(with: coverURL)
        }
        else if collectionView == reputationCollectionView {
            let cellData = reputationBookList[indexPath.row]
            cell.bookTitleLabel.text = cellData.bookTitle
            cell.bookAuthorLabel.text = cellData.bookAuthor
            let coverURL = URL(string: cellData.bookCoverURL)
            cell.bookCoverImage.kf.setImage(with: coverURL)
        }
        else if collectionView == overCollectionView {
            let cellData = overBookList[indexPath.row]
            cell.bookTitleLabel.text = cellData.bookTitle
            cell.bookAuthorLabel.text = cellData.bookAuthor
            let coverURL = URL(string: cellData.bookCoverURL)
            cell.bookCoverImage.kf.setImage(with: coverURL)
        }
        return cell
    }
    
    // Select Cell
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == hotCollectionView {
            performSegue(withIdentifier: "goToDetail", sender: hotCollectionView)
        }
        else if collectionView == newCollectionView {
            performSegue(withIdentifier: "goToDetail", sender: newCollectionView)
        }
        else if collectionView == reputationCollectionView {
            performSegue(withIdentifier: "goToDetail", sender: reputationCollectionView)
        }
        else if collectionView == overCollectionView {
            performSegue(withIdentifier: "goToDetail", sender: overCollectionView)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToDetail" {
            let destinationVC = segue.destination as! BookDetailViewController
            let senderView = sender as! UICollectionView
            if senderView.tag == 0 {
                if let indexPaths = hotCollectionView.indexPathsForSelectedItems {
                    let indexPath = indexPaths[0] as NSIndexPath
                    destinationVC.bookTitle = hotBookList[indexPath.row].bookTitle
                    destinationVC.author = hotBookList[indexPath.row].bookAuthor
                    destinationVC.category = hotBookList[indexPath.row].bookCategory
                    destinationVC.last = hotBookList[indexPath.row].lastChapter
                    destinationVC.intro = hotBookList[indexPath.row].bookIntro
                    destinationVC.bookID = hotBookList[indexPath.row].bookID
                    destinationVC.bookCoverURL = hotBookList[indexPath.row].bookCoverURL
                }
            }
            else if senderView.tag == 1 {
                if let indexPaths = newCollectionView.indexPathsForSelectedItems {
                    let indexPath = indexPaths[0] as NSIndexPath
                    destinationVC.bookTitle = newBookList[indexPath.row].bookTitle
                    destinationVC.author = newBookList[indexPath.row].bookAuthor
                    destinationVC.category = newBookList[indexPath.row].bookCategory
                    destinationVC.last = newBookList[indexPath.row].lastChapter
                    destinationVC.intro = newBookList[indexPath.row].bookIntro
                    destinationVC.bookID = newBookList[indexPath.row].bookID
                    destinationVC.bookCoverURL = newBookList[indexPath.row].bookCoverURL
                }
            }
            else if senderView.tag == 2 {
                if let indexPaths = reputationCollectionView.indexPathsForSelectedItems {
                    let indexPath = indexPaths[0] as NSIndexPath
                    destinationVC.bookTitle = reputationBookList[indexPath.row].bookTitle
                    destinationVC.author = reputationBookList[indexPath.row].bookAuthor
                    destinationVC.category = reputationBookList[indexPath.row].bookCategory
                    destinationVC.last = reputationBookList[indexPath.row].lastChapter
                    destinationVC.intro = reputationBookList[indexPath.row].bookIntro
                    destinationVC.bookID = reputationBookList[indexPath.row].bookID
                    destinationVC.bookCoverURL = reputationBookList[indexPath.row].bookCoverURL
                }
            }
            else if senderView.tag == 3 {
                if let indexPaths = overCollectionView.indexPathsForSelectedItems {
                    let indexPath = indexPaths[0] as NSIndexPath
                    destinationVC.bookTitle = overBookList[indexPath.row].bookTitle
                    destinationVC.author = overBookList[indexPath.row].bookAuthor
                    destinationVC.category = overBookList[indexPath.row].bookCategory
                    destinationVC.last = overBookList[indexPath.row].lastChapter
                    destinationVC.intro = overBookList[indexPath.row].bookIntro
                    destinationVC.bookID = overBookList[indexPath.row].bookID
                    destinationVC.bookCoverURL = overBookList[indexPath.row].bookCoverURL
                }
            }
        }
    }
    
    
    
    
}




