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
    var type = "hot"
    var major = ""
    var gender = ""
    
    var hotBookList = [Book]()
    
    
    @IBOutlet weak var listStackView: UIStackView!
    @IBOutlet weak var hotCollectionView: UICollectionView!
    
    @IBOutlet weak var hotViewWidth: NSLayoutConstraint!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = "\(baseURL)major=\(major.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)&gender=\(gender)&type=\(type)"
        
        getBookData(from: url)
        
        // Register CustomBookCell.xib
        hotCollectionView.register(UINib(nibName: "CustomBookCell", bundle: nil), forCellWithReuseIdentifier: "customBookCell")

        // Style
        listStackView.frame.size.width = UIScreen.main.bounds.width
        hotCollectionView.collectionViewLayout = cellStyle()
    }
    
    
    // MARK: - Networking
    
    // getBookData Method
    func getBookData(from url: String) {
        Alamofire.request(url).responseJSON {
            response in
            if response.result.isSuccess{
                let bookListJSON : JSON = JSON(response.result.value!)
                self.createBookList(with: bookListJSON)
            } else {
                print("Couldnt process JSON response, Error: \(response.result.error)")
            }
        }
    }

    
    func createBookList(with json: JSON) {
        guard !json.isEmpty else {fatalError("json unavailible!")}
        // Create rankArray
        for book in json["books"].arrayValue {
            let title = book["title"].stringValue
            let id = book["_id"].stringValue
            let author = book["author"].stringValue
            let intro = book["shortIntro"].stringValue
            let cover = book["cover"].stringValue
            
            let newElement = Book(title: title, id: id, author: author, intro: intro, cover: cover)
            
            hotBookList.append(newElement)
        }
        hotCollectionView.reloadData()
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
    
    
    
    
    
    
    
    
}






// MARK: - CollectionView Datasource Method

extension CategoryListViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    // Number of Cell
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == hotCollectionView {
            return hotBookList.count
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
        return cell
    }
    
    
}



