//
//  RankListViewController.swift
//  ChineseBooks
//
//  Created by Jason Li on 2018-08-20.
//  Copyright © 2018 Jason Li. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class RankListViewController: UIViewController {
    
    let baseURL = "http://api.zhuishushenqi.com/ranking/"
    var rankID = ""
    
    var rankBookList = [Book]()

    @IBOutlet weak var rankView: UIView!
    @IBOutlet weak var rankCollectionView: UICollectionView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let url = "\(baseURL)\(rankID)"
        
        getRankData(from: url)
        
        // Register CustomBookCell.xib
        rankCollectionView.register(UINib(nibName: "CustomBookCell", bundle: nil), forCellWithReuseIdentifier: "customBookCell")
        
        // Style
        rankView.frame.size.width = UIScreen.main.bounds.width
        rankCollectionView.collectionViewLayout = cellStyle()
    }

    // MARK: - Networking
    
    // getRankData Method
    func getRankData(from url: String) {
        Alamofire.request(url).responseJSON {
            response in
            if response.result.isSuccess{
                let bookListJSON : JSON = JSON(response.result.value!)
                self.createRankList(with: bookListJSON)
            } else {
                print("Couldnt process JSON response, Error: \(response.result.error)")
            }
        }
    }
    
    
    // MARK: - JSON Parsing
    
    // Parse JSON data
    func createRankList(with json: JSON) {
        guard !json.isEmpty else {fatalError("json unavailible!")}
        for book in json["ranking"]["books"].arrayValue {
            let title = book["title"].stringValue
            let id = book["_id"].stringValue
            let author = book["author"].stringValue
            let cover = book["cover"].stringValue
            let intro = book["shortIntro"].stringValue
            let category = book["minorCate"].stringValue
            let last = ""
            
            let newElement = Book(title: title, id: id, author: author, cover: cover, intro: intro, category: category, last: last)
            
            rankBookList.append(newElement)
        }
        rankCollectionView.reloadData()
    }
    
    
    // MARK: - Styling
    
    // CollectionView Cell Style
    func cellStyle() -> UICollectionViewFlowLayout {
        let cellSize = rankView.frame.size.width/3 - 24
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsetsMake(8, 16, 8, 16)
        layout.itemSize = CGSize(width: cellSize, height: cellSize * 2)
        layout.minimumInteritemSpacing = 16
        layout.minimumLineSpacing = 16
        
        return layout
    }
    
}


extension RankListViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    // Number of Cell
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return rankBookList.count
    }
    
    // Populate Cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "customBookCell", for: indexPath) as! CustomBookCell
        let cellData = rankBookList[indexPath.row]
        cell.bookTitleLabel.text = cellData.bookTitle
        cell.bookAuthorLabel.text = cellData.bookAuthor
        
        return cell
    }
    
    // Select Cell
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToDetail", sender: rankCollectionView)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToDetail" {
            let destinationVC = segue.destination as! BookDetailViewController
            if let indexPaths = rankCollectionView.indexPathsForSelectedItems {
                let indexPath = indexPaths[0] as NSIndexPath
                destinationVC.bookTitle = rankBookList[indexPath.row].bookTitle
                destinationVC.author = rankBookList[indexPath.row].bookAuthor
                destinationVC.category = rankBookList[indexPath.row].bookCategory
                destinationVC.last = rankBookList[indexPath.row].lastChapter
                destinationVC.intro = rankBookList[indexPath.row].bookIntro
                //destinationVC.bookCoverImage =
            }
        }
        
    }
    
    
}