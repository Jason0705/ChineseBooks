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
import ProgressHUD

class ChapterViewController: UIViewController {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let saveChapterMark = SaveChapterMark()
    
    
    var chapterBookMark = 0
    var bookTitle = ""
    var bookID = ""

    var chapterArray = [Chapter]()
    var CDChapterArray = [CDChapter]()
    var downloadedChapterArray = [CDChapter]()
    var chapterMarkArray = [CDChapterMark]()
    var downloadButtonState = true
   
    
    var selectedBook : CDBook? {
        didSet {
            loadChapters()
            chapterBookMark = saveChapterMark.loadChapterMarks(with: selectedBook!.id!)
        }
    }
    
    var downloadedCount = 0
    var willDownloadCount = 0
    var percentage = 0
    
    
    @IBOutlet weak var chapterTableView: UITableView!
    @IBOutlet weak var downloadButton: UIBarButtonItem!
    @IBOutlet weak var percentageView: UIView!
    @IBOutlet weak var percentageLabel: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let url = "http://api.zhuishushenqi.com/mix-atoc/\(bookID)?view=chapters"
        getChapterData(from: url)
        
        // Register CustomCategoryCell.xib
        chapterTableView.register(UINib(nibName: "CustomChapterCell", bundle: nil), forCellReuseIdentifier: "customChapterCell")
        
        // Style
        self.navigationItem.title = bookTitle
        downloadButton.isEnabled = downloadButtonState
        chapterTableView.separatorStyle = .none
        percentageView.layer.cornerRadius = 10
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let temp = selectedBook
        selectedBook = temp
        chapterTableView.reloadData()
        let chapterBookMarkIndexPath = IndexPath(row: chapterBookMark, section: 0)
        if chapterBookMark != 0 {
            chapterTableView.scrollToRow(at: chapterBookMarkIndexPath, at: UITableViewScrollPosition.top, animated: true)
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
                if self.CDChapterArray.count == 0 {
                    ProgressHUD.showError("网络连接有问题！\n请检查网络！")
                }
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
                ProgressHUD.showError("网络连接有问题！\n请检查网络！")
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
                ProgressHUD.showError("网络连接有问题！\n请检查网络！")
                print("Couldnt process 2 JSON response, Error: \(response.result.error)")
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
    
    func createCDChapterArray(with json: JSON) -> [CDChapter] {
        guard !json.isEmpty else {fatalError("json unavailible!")}
        loadChapters()
        downloadedCount = CDChapterArray.count
        for chapter in json["mixToc"]["chapters"].arrayValue[CDChapterArray.count...] {
            let newChapter = CDChapter(context: context)
            newChapter.chapterTitle = chapter["title"].stringValue
            newChapter.chapterLink = chapter["link"].stringValue
            newChapter.chapterBody = ""
            newChapter.downloaded = false
            newChapter.parentBook = selectedBook

            CDChapterArray.append(newChapter)
            saveChapters()
        }
        return CDChapterArray
    }
    
    func createBodyData(with json: JSON) -> String {
        guard !json.isEmpty else {fatalError("json unavailible!")}

        let bodyData = json["chapter"]["body"].stringValue
        return bodyData
    }
    
    
    func mergeArray(with array: [CDChapter]) {
        for element in array {
            if element.chapterBody == "" {
                let bodyURL = "http://chapter2.zhuishushenqi.com/chapter/\(element.chapterLink!.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)"
                getBodyData(from: bodyURL, completionHandler: {
                    data in
                    //element.setValue(data, forKey: "chapterBody")
                    element.chapterBody = data
                    element.downloaded = true
                    self.saveChapters()
                    self.chapterTableView.reloadData()
                })
                willDownloadCount += 1
            }
            percentage = Int(Float((downloadedCount + willDownloadCount) / CDChapterArray.count) * 100)
            percentageLabel.text = "\(percentage)%"
        }
        if percentage == 100 {
            ProgressHUD.dismiss()
            //percentageView.isHidden = true
        }

    }
    
    
    
    // Mark: - Save and Load Chapter
    func saveChapters() {
        do {
            try context.save()
        } catch {
            print("Error Saving Context: \(error)")
        }
    }

    func loadChapters() {
        let request : NSFetchRequest<CDChapter> = CDChapter.fetchRequest()
        let predicate = NSPredicate(format: "parentBook.id MATCHES %@", selectedBook!.id!)
        //let predicate = NSPredicate(format: "parentBook.id MATCHES %@", bookID!)
        request.predicate = predicate
        do {
            CDChapterArray = try context.fetch(request)
        } catch {
            ProgressHUD.showError("数据提取错误！")
            print("Error fetching data from context: \(error)")
        }
    }



    @IBAction func downloadButtonPressed(_ sender: UIBarButtonItem) {
        //percentageView.isHidden = false
        ProgressHUD.show()
        let url = "http://api.zhuishushenqi.com/mix-atoc/\(bookID)?view=chapters"
        downloadChapterData(from: url) { (data) in
            self.mergeArray(with: data)
        }
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
        if numberOfRow == 0 {
            ProgressHUD.show()
        }
        else {
            ProgressHUD.dismiss()
        }
        return numberOfRow
    }

    // Populate cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell = chapterTableView.dequeueReusableCell(withIdentifier: "chapterCell", for: indexPath)
        let cell = chapterTableView.dequeueReusableCell(withIdentifier: "customChapterCell", for: indexPath) as! CustomChapterCell
        cell.bookMarkImage.backgroundColor = navigationController?.navigationBar.tintColor
        cell.bookMarkImage.layer.cornerRadius = 5
        
        
        if indexPath.row >= 0 && indexPath.row < CDChapterArray.count {
            let cellData = CDChapterArray[indexPath.row]
            cell.chapterTitleLabel.text = cellData.chapterTitle
            if cellData.downloaded == true {
                cell.downloadedLabel.isHidden = false
            }
            else {
                cell.downloadedLabel.isHidden = true
            }
            
            if indexPath.row == chapterBookMark {
                cell.bookMarkImage.isHidden = false
            }
            else {
                cell.bookMarkImage.isHidden = true
            }
        }
        else if indexPath.row >= CDChapterArray.count && indexPath.row < chapterArray.count {
            let cellData = chapterArray[indexPath.row]
            cell.chapterTitleLabel.text = cellData.chapterTitle
            if indexPath.row == chapterBookMark {
                cell.bookMarkImage.isHidden = false
            }
            else {
                cell.bookMarkImage.isHidden = true
            }
        }
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
        performSegue(withIdentifier: "goToPages", sender: self)
    
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
