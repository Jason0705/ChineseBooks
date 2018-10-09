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
import ProgressHUD
import ChameleonFramework
import CoreData

class SearchViewController: UIViewController {

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let baseURL = "http://api.zhuishushenqi.com/book/fuzzy-search?query="
    var searchInput = ""
    var resultBookList = [Book]()
    var searchHistoryList = [CDSearchHistory]()
    var searched = false
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var resultView: UIView!
    @IBOutlet weak var resultCollectionView: UICollectionView!
    @IBOutlet weak var historyView: UIView!
    @IBOutlet weak var historyTableView: UITableView!
    @IBOutlet weak var clearHistoryButton: UIButton!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load search history
        loadHistory()
        
        // Register CustomBookCell.xib
        resultCollectionView.register(UINib(nibName: "CustomBookCell", bundle: nil), forCellWithReuseIdentifier: "customBookCell")
        
        // Style
        resultCollectionView.collectionViewLayout = Style().cellStyle(view: resultView, widthDecrease: 24, spacing: 0, inset: UIEdgeInsetsMake(8, 16, 8, 16), heightMultiplier: 2)
        
        guard let navBar = navigationController?.navigationBar else {fatalError("Navigation Controller does not exist!")}
        searchBar.tintColor = navBar.tintColor
        
        historyTableView.separatorStyle = .none
        
        clearHistoryButton.layer.cornerRadius = 10
        clearHistoryButton.backgroundColor = GradientColor(UIGradientStyle.leftToRight, frame: navBar.bounds, colors: [ComplementaryFlatColorOf(navBar.tintColor), navBar.tintColor])
        clearHistoryButton.setTitleColor(ContrastColorOf((navBar.backgroundColor)!, returnFlat: true), for: .normal)
        
    }

    
    // MARK: - Networking
    
    // getResultData Method
    func getResultData(from url: String) {
        Alamofire.request(url).responseJSON {
            response in
            if response.result.isSuccess{
                let bookListJSON : JSON = JSON(response.result.value!)
                self.createResultList(with: bookListJSON)
                //ProgressHUD.showSuccess()
            } else {
                ProgressHUD.showError("网络连接有问题！\n请检查网络！")
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
    
    func saveHistory() {
        do {
            try context.save()
        } catch {
            print("Error Saving Context: \(error)")
        }
        historyTableView.reloadData()
    }
    
    func loadHistory() {
        let request : NSFetchRequest <CDSearchHistory> = CDSearchHistory.fetchRequest()
        
        do {
            searchHistoryList = try context.fetch(request)
        } catch {
            print("Error fetching data from context: \(error)")
        }
        historyTableView.reloadData()
    }
    
    func clearHistory() {
        for searchWord in searchHistoryList {
            context.delete(searchWord)
        }
        saveHistory()
    }
    
    
    
    @IBAction func clearHistoryBottonPressed(_ sender: UIButton) {
        clearHistory()
    }
    

}



extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searched = true
        historyView.isHidden = true
        ProgressHUD.show()
        resultBookList = [Book]()
        if searchBar.text?.count != 0 {
            searchInput = searchBar.text!
            let url = "\(baseURL)\(searchInput.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)"
            
            getResultData(from: url)
            
            let newSearch = CDSearchHistory(context: context)
            newSearch.searchWord = searchBar.text!
            
            searchHistoryList.append(newSearch)
            saveHistory()
        }
        ProgressHUD.dismiss()
        self.view.endEditing(true)
        //searched = false
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        resultBookList = [Book]()
        resultCollectionView.reloadData()
        searched = false
        historyView.isHidden = false
        self.view.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            resultBookList = [Book]()
            resultCollectionView.reloadData()
            historyView.isHidden = false
            searched = false
        }
    }
    
}



extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    // Number of Cell
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchHistoryList.count == 0 {
            clearHistoryButton.isHidden = true
        }
        else {
            clearHistoryButton.isHidden = false
        }
        return searchHistoryList.count
    }
    
    // Populate Cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "historyCell", for: indexPath)
        let cellData = searchHistoryList[searchHistoryList.endIndex - 1 - indexPath.row]
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.text = cellData.searchWord
        cell.textLabel?.textColor = navigationController?.navigationBar.tintColor
        
        return cell
    }
    
    // Select Cell
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchBar.text = searchHistoryList[searchHistoryList.endIndex - 1 - indexPath.row].searchWord
        self.searchBarSearchButtonClicked(searchBar)
        historyTableView.deselectRow(at: indexPath, animated: true)
    }
    
    
}

extension SearchViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    // Number of Cell
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if searched == true && resultBookList.count == 0 {
            ProgressHUD.showError("对不起...\n没有找到您所搜索的小说...")
        }
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

