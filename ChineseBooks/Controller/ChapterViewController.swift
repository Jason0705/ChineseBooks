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
import CoreData

class ChapterViewController: UIViewController {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var bookTitle = ""
    var bookID = ""
    var chapterArray = [Chapter]()
    //var bodyArray = [String]()
    //var downloadedChapterArray = [CDChapter]()
    var downloadButtonState = true
    
    
    @IBOutlet weak var chapterTableView: UITableView!
    @IBOutlet weak var downloadButton: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = "http://api.zhuishushenqi.com/mix-atoc/\(bookID)?view=chapters"
        //loadChapters()
        getChapterData(from: url) { (data) in
            //self.createBodyArray(with: data)
            self.mergeArray(with: data)
        }
        
        self.navigationItem.title = bookTitle
        downloadButton.isEnabled = downloadButtonState
    }
    
    
    // MARK: - Networking
    
    // getResultData Method
//    func getChapterData(from url: String) {
//        Alamofire.request(url).responseJSON {
//            response in
//            if response.result.isSuccess{
//                let chapterJSON : JSON = JSON(response.result.value!)
//                self.createChapterArray(with: chapterJSON)
//            } else {
//                print("Couldnt process 1 JSON response, Error: \(response.result.error)")
//            }
//        }
//    }
    func getChapterData(from url: String, completionHandler: @escaping ([Chapter]) -> Void) {
        Alamofire.request(url).responseJSON {
            response in
            if response.result.isSuccess{
                let chapterJSON : JSON = JSON(response.result.value!)
                let chapterData = self.createChapterArray(with: chapterJSON)
                completionHandler(chapterData)
            } else {
                print("Couldnt process 1 JSON response, Error: \(response.result.error)")
            }
        }
    }

    func getBodyData(from url: String, completionHandler: @escaping (String) -> Void) {
        Alamofire.request(url).responseJSON {
            response in
            if response.result.isSuccess{
                let bodyJSON : JSON = JSON(response.result.value!)
                let bodyData = self.createBodyData(with: bodyJSON)
                completionHandler(bodyData)
            } else {
                print("Couldnt process 2 JSON response, Error: \(response.result.error)")
            }
        }
    }
    
//    func getBodyData(from url: String) {
//        Alamofire.request(url).responseJSON {
//            response in
//            if response.result.isSuccess{
//                let bodyJSON : JSON = JSON(response.result.value!)
//                self.createBodyData(with: bodyJSON)
//            } else {
//                print("Couldnt 2 process JSON response, Error: \(response.result.error)")
//            }
//        }
//    }
    
    
    // MARK: - JSON Parsing
    
    // Parse JSON data
    func createChapterArray(with json: JSON) -> [Chapter] {
        guard !json.isEmpty else {fatalError("json unavailible!")}
        for chapter in json["mixToc"]["chapters"].arrayValue {
            let title = chapter["title"].stringValue
            let link = chapter["link"].stringValue
            let body = ""
            
            let newElement = Chapter(title: title, link: link, body: body)

            chapterArray.append(newElement)
        }
        chapterTableView.reloadData()
        return chapterArray
    }
    
    func createBodyData(with json: JSON) -> String {
        guard !json.isEmpty else {fatalError("json unavailible!")}

        let bodyData = json["chapter"]["body"].stringValue
        return bodyData
    }
//    func createBodyData(with json: JSON) {
//        guard !json.isEmpty else {fatalError("json unavailible!")}
//
//        let body = json["chapter"]["body"].stringValue
//        bodyArray.append(body)
//    }
    
    func mergeArray(with array: [Chapter]) {
//        let url = "http://api.zhuishushenqi.com/mix-atoc/\(bookID)?view=chapters"
//        getChapterData(from: url)
        for element in array {
            let bodyURL = "http://chapter2.zhuishushenqi.com/chapter/\(element.chapterLink.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)"
            getBodyData(from: bodyURL, completionHandler: {
                data in
                element.chapterBody = data
            })

        }
        
    }
    
//    func createBodyArray(with array: [Chapter]) {
//        for element in array {
//            let bodyURL = "http://chapter2.zhuishushenqi.com/chapter/\(element.chapterLink.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)"
//            getBodyData(from: bodyURL)
//        }
//    }
    
    
    
    
    
    
    
//    func saveChapters() {
//        do {
//            try context.save()
//        } catch {
//            print("Error Saving Context: \(error)")
//        }
//        chapterTableView.reloadData()
//    }
//
//    func loadChapters() {
//        let request : NSFetchRequest<CDChapter> = CDChapter.fetchRequest()
//        do {
//            downloadedChapterArray = try context.fetch(request)
//        } catch {
//            print("Error fetching data from context: \(error)")
//        }
//    }
//
//
//
//    @IBAction func downloadButtonPressed(_ sender: UIBarButtonItem) {
//        let url = "http://api.zhuishushenqi.com/mix-atoc/\(bookID)?view=chapters"
//        downloadChapterData(from: url)
//    }
   
    
    
}




extension ChapterViewController: UITableViewDataSource, UITableViewDelegate {

    // Number of cell
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chapterArray.count
    }

    // Populate cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = chapterTableView.dequeueReusableCell(withIdentifier: "chapterCell", for: indexPath)
//        if indexPath.row >= 0 && indexPath.row < downloadedChapterArray.count {
//            let cellData = downloadedChapterArray[indexPath.row]
//            cell.textLabel?.text = "下--\(cellData.chapterTitle)"
//        }
//        else if indexPath.row >= downloadedChapterArray.count && indexPath.row < chapterArray.count {
//            let cellData = chapterArray[indexPath.row]
//            cell.textLabel?.text = cellData.chapterTitle
//        }
        let cellData = chapterArray[indexPath.row]
        cell.textLabel?.text = cellData.chapterTitle
        return cell
    }

    // Select cell
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToPages", sender: self)
        //print(bodyArray[indexPath.row])
//        print(chapterArray[indexPath.row].chapterBody)
//        print(chapterArray[indexPath.row].chapterTitle)
//        print(indexPath.row)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToPages" {
            let destinationVC = segue.destination as! BookPagesViewController
            if let indexPath = chapterTableView.indexPathForSelectedRow {
                destinationVC.chapterArray = chapterArray
                destinationVC.chapterIndex = indexPath.row
            }
        }
    }

}
