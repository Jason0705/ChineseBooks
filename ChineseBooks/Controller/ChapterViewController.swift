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
    let saveChapterMark = SaveChapterMark()
    
    
    var chapterBookMark = 0
    var bookTitle = ""
    var bookID = ""
    var chapterBookMarkIndexPath : IndexPath?

    var chapterArray = [Chapter]()
    var CDChapterArray = [CDChapter]()
    var downloadedChapterArray = [CDChapter]()
    var chapterMarkArray = [CDChapterMark]()
    var downloadButtonState = true
   
    
    var selectedBook : CDBook? {
        didSet {
            loadChapters()
            chapterBookMark = saveChapterMark.loadChapterMarks(with: selectedBook!.id!)
            print("SET")
        }
    }
    
    
    @IBOutlet weak var chapterTableView: UITableView!
    @IBOutlet weak var downloadButton: UIBarButtonItem!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let url = "http://api.zhuishushenqi.com/mix-atoc/\(bookID)?view=chapters"
        getChapterData(from: url)
        //loadChapters()
//        getChapterData(from: url) { (data) in
//            //self.createBodyArray(with: data)
//            self.mergeArray(with: data)
//        }
        
        //saveChapterMark.clearChapterMarks()
        
        self.navigationItem.title = bookTitle
        downloadButton.isEnabled = downloadButtonState
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let temp = selectedBook
        selectedBook = temp
        chapterTableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if chapterBookMarkIndexPath != nil {
            chapterTableView.scrollToRow(at: chapterBookMarkIndexPath!, at: UITableViewScrollPosition.top, animated: true)
        }
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
                print("Couldnt process 1 JSON response, Error: \(response.result.error)")
            }
        }
    }
    func downloadChapterData(from url: String, completionHandler: @escaping ([CDChapter]) -> Void) {
        Alamofire.request(url).responseJSON {
            response in
            if response.result.isSuccess{
                let chapterJSON : JSON = JSON(response.result.value!)
                let CDChapterData = self.createCDChapterArray(with: chapterJSON)
                completionHandler(CDChapterData)
            } else {
                print("Couldnt process 1 JSON response, Error: \(response.result.error)")
            }
        }
    }
//
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
    
    func createCDChapterArray(with json: JSON) -> [CDChapter] {
        guard !json.isEmpty else {fatalError("json unavailible!")}
        for chapter in json["mixToc"]["chapters"].arrayValue {
            let newChapter = CDChapter(context: context)
            newChapter.chapterTitle = chapter["title"].stringValue
            newChapter.chapterLink = chapter["link"].stringValue
            newChapter.chapterBody = ""
            newChapter.downloaded = false
            newChapter.parentBook = selectedBook

            //downloadedChapterArray.append(newChapter)
            CDChapterArray.append(newChapter)
            saveChapters()
        }
        //chapterTableView.reloadData()
        //return downloadedChapterArray
        return CDChapterArray
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
    
    func mergeArray(with array: [CDChapter]) {
        for element in array {
            let bodyURL = "http://chapter2.zhuishushenqi.com/chapter/\(element.chapterLink!.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)"
            getBodyData(from: bodyURL, completionHandler: {
                data in
                //element.setValue(data, forKey: "chapterBody")
                element.chapterBody = data
                element.downloaded = true
                self.saveChapters()
                self.chapterTableView.reloadData()
            })

        }

    }
    
//    func createBodyArray(with array: [Chapter]) {
//        for element in array {
//            let bodyURL = "http://chapter2.zhuishushenqi.com/chapter/\(element.chapterLink.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)"
//            getBodyData(from: bodyURL)
//        }
//    }
    
    
    
    
    
    
    // Mark: - Save and Load Chapter
    func saveChapters() {
        do {
            try context.save()
        } catch {
            print("Error Saving Context: \(error)")
        }
        //chapterTableView.reloadData()
    }

    func loadChapters() {
        let request : NSFetchRequest<CDChapter> = CDChapter.fetchRequest()
        let predicate = NSPredicate(format: "parentBook.id MATCHES %@", selectedBook!.id!)
        //let predicate = NSPredicate(format: "parentBook.id MATCHES %@", bookID!)
        request.predicate = predicate
        do {
            //downloadedChapterArray = try context.fetch(request)
            CDChapterArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context: \(error)")
        }
    }
    
    func deleteChapters() {
//        let request : NSFetchRequest<CDChapter> = CDChapter.fetchRequest()
//        let predicate = NSPredicate(format: "parentBook.id MATCHES %@", selectedBook!.id!)
//        //let predicate = NSPredicate(format: "parentBook.id MATCHES %@", bookID!)
//        request.predicate = predicate
//        do {
//            let willDelete = try context.fetch(request)
//            if willDelete.count > 0 {
//                for index in 0..<willDelete.count {
//                    context.delete(willDelete[index])
//                }
//                saveChapters()
//            }
//        } catch {
//            print("Error fetching data from context: \(error)")
//        }
        
//        if downloadedChapterArray.count > 0 {
//            for index in 0..<downloadedChapterArray.count {
//                context.delete(downloadedChapterArray[index])
//            }
//            saveChapters()
//        }
        
//        if CDChapterArray.count > 0 {
//            for index in 0..<CDChapterArray.count {
//                context.delete(CDChapterArray[index])
//            }
//            saveChapters()
//        }

    }
    
    
    // MARK: - Save and Load Chapter Book Mark
    
//    func saveChapterMarks() {
//        do {
//            try context.save()
//        } catch {
//            print("Error Saving Context: \(error)")
//        }
//        chapterTableView.reloadData()
//    }
//
//    func loadChapterMarks() {
//        let request : NSFetchRequest<CDChapterMark> = CDChapterMark.fetchRequest()
//        let predicate = NSPredicate(format: "parentBook.id MATCHES %@", selectedBook!.id!)
//        request.predicate = predicate
//        do {
//            chapterMarkArray = try context.fetch(request)
//        } catch {
//            print("Error fetching data from context: \(error)")
//        }
//    }



    @IBAction func downloadButtonPressed(_ sender: UIBarButtonItem) {
        
        let url = "http://api.zhuishushenqi.com/mix-atoc/\(bookID)?view=chapters"
        //deleteChapters()
        downloadChapterData(from: url) { (data) in
            self.mergeArray(with: data)
        }
        //loadChapters()
        //chapterTableView.reloadData()
    }
   
    
    
}




extension ChapterViewController: UITableViewDataSource, UITableViewDelegate {

    // Number of cell
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRow = 0
        if chapterArray.count == 0 {
            numberOfRow = CDChapterArray.count
        }
        else {
            numberOfRow = chapterArray.count
        }
        return numberOfRow
    }

    // Populate cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = chapterTableView.dequeueReusableCell(withIdentifier: "chapterCell", for: indexPath)
        
        
        if indexPath.row >= 0 && indexPath.row < CDChapterArray.count {
            let cellData = CDChapterArray[indexPath.row]
            if cellData.downloaded == true {
                cell.textLabel?.text = "下--\(cellData.chapterTitle!)"
            }
            else {
                cell.textLabel?.text = "\(cellData.chapterTitle!)"
            }
            
            if indexPath.row == chapterBookMark {
                cell.backgroundColor = UIColor.blue
                chapterBookMarkIndexPath = indexPath
            }
            else {
                cell.backgroundColor = UIColor.white
            }
        }
        else if indexPath.row >= CDChapterArray.count && indexPath.row < chapterArray.count {
            let cellData = chapterArray[indexPath.row]
            cell.textLabel?.text = cellData.chapterTitle
            if indexPath.row == chapterBookMark {
                cell.backgroundColor = UIColor.blue
                chapterBookMarkIndexPath = indexPath
            }
            else {
                cell.backgroundColor = UIColor.white
            }
        }
//        let cellData = chapterArray[indexPath.row]
//        cell.textLabel?.text = cellData.chapterTitle
        return cell
    }

    // Select cell
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let newChapterMark = CDChapterMark(context: context)
        newChapterMark.chapterMark = Int16(indexPath.row)
        newChapterMark.parentBook = selectedBook
        chapterMarkArray.append(newChapterMark)
        saveChapterMark.saveChapterMarks()
        
        saveChapterMark.clearChapterMarks()
        
        chapterTableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.top, animated: true)
        //print(bookID)
        performSegue(withIdentifier: "goToPages", sender: self)
        //print(bodyArray[indexPath.row])
//        print(chapterArray[indexPath.row].chapterBody)
//        print(chapterArray[indexPath.row].chapterTitle)
//        print(indexPath.row)
        //loadChapters()
//        print(downloadedChapterArray[indexPath.row].chapterBody!)
//        print(downloadedChapterArray[indexPath.row].chapterTitle!)
//        print(downloadedChapterArray[indexPath.row].chapterLink!)
        //tableView.deselectRow(at: indexPath, animated: true)
    
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToPages" {
            let destinationVC = segue.destination as! BookPagesViewController
            if let indexPath = chapterTableView.indexPathForSelectedRow {
                destinationVC.CDChapterArray = CDChapterArray
                destinationVC.chapterArray = chapterArray
                destinationVC.chapterIndex = indexPath.row
                destinationVC.selectedBook = selectedBook!
                destinationVC.selectedChapterMark = chapterMarkArray[chapterMarkArray.endIndex - 1]
            }
        }
    }

}
