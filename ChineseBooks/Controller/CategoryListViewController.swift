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
        let newURL = "\(baseURL)major=\(major.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)&gender=\(gender)&type=new"
        let reputationURL = "\(baseURL)major=\(major.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)&gender=\(gender)&type=reputation"
        let overURL = "\(baseURL)major=\(major.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)&gender=\(gender)&type=over"
        
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
        hotCollectionView.collectionViewLayout = cellStyle()
    }
    
    
    // MARK: - Networking
    
    // getData Methods
    func getHotData(from url: String) {
        Alamofire.request(url).responseJSON {
            response in
            if response.result.isSuccess{
                let bookListJSON : JSON = JSON(response.result.value!)
                self.createHotList(with: bookListJSON)
            } else {
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
            } else {
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
            } else {
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
            } else {
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
            let cover = book["cover"].stringValue
            let intro = book["shortIntro"].stringValue
            let category = book["minorCate"].stringValue
            let last = book["lastChapter"].stringValue
            
            let newElement = Book(title: title, id: id, author: author, cover: cover, intro: intro, category: category, last: last)
            
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
            let cover = book["cover"].stringValue
            let intro = book["shortIntro"].stringValue
            let category = book["minorCate"].stringValue
            let last = book["lastChapter"].stringValue
            
            let newElement = Book(title: title, id: id, author: author, cover: cover, intro: intro, category: category, last: last)
            
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
            let cover = book["cover"].stringValue
            let intro = book["shortIntro"].stringValue
            let category = book["minorCate"].stringValue
            let last = book["lastChapter"].stringValue
            
            let newElement = Book(title: title, id: id, author: author, cover: cover, intro: intro, category: category, last: last)
            
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
            let cover = book["cover"].stringValue
            let intro = book["shortIntro"].stringValue
            let category = book["minorCate"].stringValue
            let last = book["lastChapter"].stringValue
            
            let newElement = Book(title: title, id: id, author: author, cover: cover, intro: intro, category: category, last: last)
            
            overBookList.append(newElement)
        }
        overCollectionView.reloadData()
    }

    
    
    // MARK: - Styling
    
    // CollectionView Cell Style
    func cellStyle() -> UICollectionViewFlowLayout {
        let cellSize = listStackView.frame.size.width/3 - 24
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsetsMake(8, 16, 8, 16)
        layout.itemSize = CGSize(width: cellSize, height: cellSize * 2)
        layout.minimumInteritemSpacing = 16
        layout.minimumLineSpacing = 16
        
        return layout
    }
    
    
    
    // MARK: - Action
    
    @IBAction func listSegmentedControlPressed(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            hotCollectionView.collectionViewLayout = cellStyle()
            UIView.animate(withDuration: 0.3) {
                self.hotViewWidth.constant = self.listStackView.frame.size.width
                self.newViewWidth.constant = 0
                self.reputationViewWidth.constant = 0
                self.overViewWidth.constant = 0
                self.view.layoutIfNeeded()
            }
        }
        else if sender.selectedSegmentIndex == 1 {
            newCollectionView.collectionViewLayout = cellStyle()
            UIView.animate(withDuration: 0.3) {
                self.hotViewWidth.constant = 0
                self.newViewWidth.constant = self.listStackView.frame.size.width
                self.reputationViewWidth.constant = 0
                self.overViewWidth.constant = 0
                self.view.layoutIfNeeded()
            }
        }
        else if sender.selectedSegmentIndex == 2 {
            reputationCollectionView.collectionViewLayout = cellStyle()
            UIView.animate(withDuration: 0.3) {
                self.hotViewWidth.constant = 0
                self.newViewWidth.constant = 0
                self.reputationViewWidth.constant = self.listStackView.frame.size.width
                self.overViewWidth.constant = 0
                self.view.layoutIfNeeded()
            }
        }
        else if sender.selectedSegmentIndex == 3 {
            overCollectionView.collectionViewLayout = cellStyle()
            UIView.animate(withDuration: 0.3) {
                self.hotViewWidth.constant = 0
                self.newViewWidth.constant = 0
                self.reputationViewWidth.constant = 0
                self.overViewWidth.constant = self.listStackView.frame.size.width
                self.view.layoutIfNeeded()
            }
        }
    }
    
    
    
    
}






// MARK: - CollectionView Datasource Method

extension CategoryListViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    // Number of Cell
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == hotCollectionView {
            return hotBookList.count
        }
        else if collectionView == newCollectionView {
            return newBookList.count
        }
        else if collectionView == reputationCollectionView {
            return reputationBookList.count
        }
        else if collectionView == overCollectionView {
            return overBookList.count
        }
        return 0
    }
    
    // Populate Cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "customBookCell", for: indexPath) as! CustomBookCell
        
        if collectionView == hotCollectionView {
            let cellData = hotBookList[indexPath.row]
            cell.bookTitleLabel.text = cellData.bookTitle
            cell.bookAuthorLabel.text = cellData.bookAuthor
        }
        else if collectionView == newCollectionView {
            let cellData = newBookList[indexPath.row]
            cell.bookTitleLabel.text = cellData.bookTitle
            cell.bookAuthorLabel.text = cellData.bookAuthor
        }
        else if collectionView == reputationCollectionView {
            let cellData = reputationBookList[indexPath.row]
            cell.bookTitleLabel.text = cellData.bookTitle
            cell.bookAuthorLabel.text = cellData.bookAuthor
        }
        else if collectionView == overCollectionView {
            let cellData = overBookList[indexPath.row]
            cell.bookTitleLabel.text = cellData.bookTitle
            cell.bookAuthorLabel.text = cellData.bookAuthor
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
                //destinationVC.bookCoverImage =
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
                //destinationVC.bookCoverImage =
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
                //destinationVC.bookCoverImage =
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
                //destinationVC.bookCoverImage =
            }
        }
    }
    
    
    
    
}



