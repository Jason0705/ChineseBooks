//
//  SearchViewController.swift
//  ChineseBooks
//
//  Created by Jason Li on 2018-08-24.
//  Copyright © 2018 Jason Li. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Kingfisher

class SearchViewController: UIViewController {

    let baseURL = "http://api.zhuishushenqi.com/book/fuzzy-search?query="
    var searchInput = ""
    var resultBookList = [Book]()
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var resultView: UIView!
    @IBOutlet weak var resultCollectionView: UICollectionView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register CustomBookCell.xib
        resultCollectionView.register(UINib(nibName: "CustomBookCell", bundle: nil), forCellWithReuseIdentifier: "customBookCell")
        
        // Style
        resultCollectionView.collectionViewLayout = cellStyle()
    }

    
    // MARK: - Networking
    
    // getResultData Method
    func getResultData(from url: String) {
        Alamofire.request(url).responseJSON {
            response in
            if response.result.isSuccess{
                let bookListJSON : JSON = JSON(response.result.value!)
                self.createResultList(with: bookListJSON)
            } else {
                print("Couldnt process JSON response, Error: \(response.result.error)")
            }
        }
    }
    
    
    // MARK: - JSON Parsing
    
    // Parse JSON data
    func createResultList(with json: JSON) {
        guard !json.isEmpty else {fatalError("json unavailible!")}
        for book in json["books"].arrayValue {
            let title = book["title"].stringValue
            let id = book["_id"].stringValue
            let author = book["author"].stringValue
            let coverURL = book["cover"].stringValue.dropFirst("/agent/".count).removingPercentEncoding!
            let intro = book["shortIntro"].stringValue
            let category = book["Cat"].stringValue
            let last = book["lastChapter"].stringValue
            
            let newElement = Book(title: title, id: id, author: author, coverURL: coverURL, intro: intro, category: category, last: last)
            
            resultBookList.append(newElement)
        }
        resultCollectionView.reloadData()
    }
    
    
    // MARK: - Styling
    
    // CollectionView Cell Style
    func cellStyle() -> UICollectionViewFlowLayout {
        let cellSize = resultView.frame.size.width/3 - 24
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsetsMake(8, 16, 8, 16)
        layout.itemSize = CGSize(width: cellSize, height: cellSize * 2)
        layout.minimumInteritemSpacing = 16
        layout.minimumLineSpacing = 16
        
        return layout
    }
    
    
    

}



extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        resultBookList = [Book]()
        if searchBar.text?.count != 0 {
            searchInput = searchBar.text!
            let url = "\(baseURL)\(searchInput.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)"
            
            getResultData(from: url)
        }
        
        
        self.view.endEditing(true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        resultBookList = [Book]()
        resultCollectionView.reloadData()
        self.view.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            resultBookList = [Book]()
            resultCollectionView.reloadData()
        }
    }
    
}



extension SearchViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    // Number of Cell
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return resultBookList.count
    }
    
    // Populate Cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "customBookCell", for: indexPath) as! CustomBookCell
        let cellData = resultBookList[indexPath.row]
        cell.bookTitleLabel.text = cellData.bookTitle
        cell.bookAuthorLabel.text = cellData.bookAuthor
        let coverURL = URL(string: cellData.bookCoverURL)
        cell.bookCoverImage.kf.setImage(with: coverURL)
        
        return cell
    }
    
    // Select Cell
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToDetail", sender: resultCollectionView)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToDetail" {
            let destinationVC = segue.destination as! BookDetailViewController
            if let indexPaths = resultCollectionView.indexPathsForSelectedItems {
                let indexPath = indexPaths[0] as NSIndexPath
                destinationVC.bookTitle = resultBookList[indexPath.row].bookTitle
                destinationVC.author = resultBookList[indexPath.row].bookAuthor
                destinationVC.category = resultBookList[indexPath.row].bookCategory
                destinationVC.last = resultBookList[indexPath.row].lastChapter
                destinationVC.intro = resultBookList[indexPath.row].bookIntro
                destinationVC.bookID = resultBookList[indexPath.row].bookID
                destinationVC.bookCoverURL = resultBookList[indexPath.row].bookCoverURL
            }
        }
    }
    
    
}

