//
//  ChapterViewController.swift
//  ChineseBooks
//
//  Created by Jason Li on 2018-08-26.
//  Copyright © 2018 Jason Li. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ChapterViewController: UIViewController {
    
    var bookTitle = ""
    var bookID = ""
    var chapterArray = [Chapter]()
    
    
    @IBOutlet weak var chapterTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = "http://api.zhuishushenqi.com/mix-atoc/\(bookID)?view=chapters"
        
        getChapterData(from: url)
        
        self.navigationItem.title = bookTitle
    }
    
    
    // MARK: - Networking
    
    // getResultData Method
    func getChapterData(from url: String) {
        Alamofire.request(url).responseJSON {
            response in
            if response.result.isSuccess{
                let chapterJSON : JSON = JSON(response.result.value!)
                self.createChapterArray(with: chapterJSON)
            } else {
                print("Couldnt process JSON response, Error: \(response.result.error)")
            }
        }
    }
    
    
    // MARK: - JSON Parsing
    
    // Parse JSON data
    func createChapterArray(with json: JSON) {
        guard !json.isEmpty else {fatalError("json unavailible!")}
        for chapter in json["mixToc"]["chapters"].arrayValue {
            let title = chapter["title"].stringValue
            let link = chapter["link"].stringValue
            
            let newElement = Chapter(title: title, link: link)
            
            chapterArray.append(newElement)
        }
        chapterTableView.reloadData()
    }
    


}




extension ChapterViewController: UITableViewDataSource, UITableViewDelegate {
    
    // Number of cell
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chapterArray.count
    }
    
    // Populate cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = chapterTableView.dequeueReusableCell(withIdentifier: "chapterCell", for: indexPath)
        let cellData = chapterArray[indexPath.row]
        cell.textLabel?.text = cellData.chapterTitle
        return cell
    }
    
    // Select cell
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToPages", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToPages" {
            let destinationVC = segue.destination as! BookPagesViewController
            if let indexPath = chapterTableView.indexPathForSelectedRow {
                destinationVC.chapterTitle = chapterArray[indexPath.row].chapterTitle
                destinationVC.chapterLink = chapterArray[indexPath.row].chapterLink
            }
        }
    }
    
}
