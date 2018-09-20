//
//  BookPagesViewController.swift
//  ChineseBooks
//
//  Created by Jason Li on 2018-09-01.
//  Copyright © 2018 Jason Li. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class BookPagesViewController: UIViewController {

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let saveChapterMark = SaveChapterMark()
    let savePageMark = SavePageMark()
    
    var body = ""
    
    var chapterIndex = 0
    var pageBookMark = 0
    
    var CDChapterArray = [CDChapter]()
    var chapterArray = [Chapter]()
    //var chapterMarkArray = [CDChapterMark]()
    var selectedBook = CDBook()
    var selectedChapterMark = CDChapterMark()
    
    
    var splitedContentArray = [String]()
    
    var pageController: UIPageViewController?
    
    
    
    //@IBOutlet weak var contentTextView: UITextView!
    
    @IBOutlet weak var contentLabel: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if chapterIndex >= CDChapterArray.count {
            let url = "http://chapter2.zhuishushenqi.com/chapter/\(chapterArray[chapterIndex].chapterLink.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)"
            
            getBodyData(from: url, completionHandler: {
                data in

                
                self.splitedContentArray = self.pageSplit(with: data)
                
                self.initializeView()
                
            })
        }
        else {

            splitedContentArray = pageSplit(with: CDChapterArray[chapterIndex].chapterBody!)
            initializeView()
        }
        
        //chapterMarkArray.append(selectedChapterMark)
        pageBookMark = savePageMark.loadPageMarks(inChapter: Int16(chapterIndex), ofBook: selectedBook.id!)
        
        
    }
  
    
    func initializeView() {
        // Initialize UIPageViewController
        pageController = UIPageViewController(
            transitionStyle: .pageCurl,
            navigationOrientation: .horizontal,
            options: nil)
        
        pageController?.delegate = self
        pageController?.dataSource = self
        
        let startingViewController: ContentViewController =
            viewControllerAtIndex(index: pageBookMark)!
        
        let viewControllers: NSArray = [startingViewController]
        pageController!.setViewControllers(viewControllers
            as? [UIViewController],
                                           direction: .forward,
                                           animated: false,
                                           completion: nil)
        
        self.addChildViewController(pageController!)
        self.view.addSubview(self.pageController!.view)
        
        let pageViewRect = self.view.bounds
        pageController!.view.frame = pageViewRect
        pageController!.didMove(toParentViewController: self)
        
    }
    
    func pageSplit(with text: String) -> [String] {
        var lines = [String]()
        var pagesArray = [String]()
        
        let charactersPerLine = Int(contentLabel.bounds.width / (contentLabel.font.pointSize))
        let numberOfLines = Int(contentLabel.bounds.height / contentLabel.font.lineHeight)

        contentLabel.numberOfLines = numberOfLines
        
        let sentencesArray = text.components(separatedBy: "\n")
        for sentence in sentencesArray {
            let frontPadded = String(repeating: "", count: 1) + sentence
            
//            let attributed = NSMutableAttributedString(string: frontPadded)
//            attributed.addAttribute(.foregroundColor, value: contentLabel.backgroundColor, range: NSRange.init(location: 0, length: 0))
            var linesArray = frontPadded.split(by: charactersPerLine)
            //print(linesArray)
            for index in 0..<linesArray.count {
                if linesArray[index].count < charactersPerLine {
                    linesArray[index] = linesArray[index] + "\n"
                }
                lines.append(linesArray[index])
            }
        }
        
//        var i = numberOfLines
        var newPageText = ""
//        var remainder = 0
//        for index in 1..<lines.count + 1{
//            if (i / (index)) >= 1 {
//                newPageText = newPageText + lines[index - 1]
//            }
//            else {
//                pagesArray.append(newPageText)
//                i = i + numberOfLines
//                newPageText = lines[index - 1]
//            }
//        }
        let pages = lines.chunked(by: numberOfLines)
        
        for index in 0..<pages.count {
            for i in 0..<pages[index].count {
                newPageText = newPageText + pages[index][i]
            }
            pagesArray.append(newPageText)
            newPageText = ""
        }
        
        print(pagesArray)
        return pagesArray

    }
    
    
    
    // MARK: - Networking
    
    // getRankData Method
    func getBodyData(from url: String, completionHandler: @escaping (String) -> Void) {
        Alamofire.request(url).responseJSON {
            response in
            if response.result.isSuccess{
                let bodyJSON : JSON = JSON(response.result.value!)
                let bodyData = self.createBodyData(with: bodyJSON)
                completionHandler(bodyData)
            } else {
                print("Couldnt process JSON response, Error: \(response.result.error)")
            }
        }
    }


    // MARK: - JSON Parsing

    // Parse JSON data
    func createBodyData(with json: JSON) -> String {
        guard !json.isEmpty else {fatalError("json unavailible!")}

        let bodyData = json["chapter"]["body"].stringValue
        return bodyData
    }

    

}



extension BookPagesViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    func viewControllerAtIndex(index: Int) -> ContentViewController? {
        
        if (splitedContentArray.count == 0) || (index >= splitedContentArray.count) {
            return nil
        }
        
        let storyBoard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let dataVC = storyBoard.instantiateViewController(withIdentifier: "contentView") as! ContentViewController
        
        dataVC.chapterTitle = chapterArray[chapterIndex].chapterTitle
        dataVC.pageCounte = "\(index + 1)/\(splitedContentArray.count)"
        if index >= 0 {
            dataVC.body = splitedContentArray[index]
        }
        return dataVC
    }
    
    func indexOfViewController(viewController: ContentViewController) -> Int {
        
        if let dataObject: String = viewController.body {
            return splitedContentArray.index(of: dataObject)!
        } else {
            return NSNotFound
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        var index = indexOfViewController(viewController: viewController
            as! ContentViewController)
        
        if index == NSNotFound {
            return nil
        }
        if index == 0 {
            if chapterIndex <= 0 {
                return nil
            }
            chapterIndex -= 1
            
            let newChapterMark = CDChapterMark(context: context)
            newChapterMark.chapterMark = Int16(chapterIndex)
            newChapterMark.parentBook = selectedBook
            //chapterMarkArray.append(newChapterMark)
            saveChapterMark.saveChapterMarks()
//            let url = "http://chapter2.zhuishushenqi.com/chapter/\(chapterArray[chapterIndex].chapterLink.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)"
//
//            getBodyData(from: url, completionHandler: {
//                data in
//                self.body = data
//
//                self.contentTextView.text = self.body
//                let fitRange = self.contentTextView.numberOfCharactersThatFitTextView()
//                self.splitedContentArray = self.body.split(by: fitRange)
//
//                self.initializeView()
//
//            })
//            body = chapterArray[chapterIndex].chapterBody
//            contentTextView.text = body
//            let fitRange = contentTextView.numberOfCharactersThatFitTextView()
//            splitedContentArray = body.split(by: fitRange)
//            pageDevide()
//            initializeView()
            if chapterIndex >= CDChapterArray.count {
                let url = "http://chapter2.zhuishushenqi.com/chapter/\(chapterArray[chapterIndex].chapterLink.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)"
                
                getBodyData(from: url, completionHandler: {
                    data in

                    self.splitedContentArray = self.pageSplit(with: data)

                    self.initializeView()
                    
                })
            }
            else {

                splitedContentArray = pageSplit(with: CDChapterArray[chapterIndex].chapterBody!)
                initializeView()
            }
        }
        
        index = index - 1
        let newPageMark = CDPageMark(context: context)
        newPageMark.pageMark = Int16(index)
        newPageMark.parentBookID = selectedBook.id
        newPageMark.chapterMark = Int16(chapterIndex)
        //newPageMark.parentChapterMark = chapterMarkArray[chapterMarkArray.endIndex - 1]
        savePageMark.savePageMarks()
        
        savePageMark.clearPageMarks(inBook: selectedBook.id!)
        
        return viewControllerAtIndex(index: index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        var index = indexOfViewController(viewController: viewController
            as! ContentViewController)
        
        if index == NSNotFound {
            return nil
        }
        
        index = index + 1
        
        if index == splitedContentArray.count {
            if chapterIndex >= chapterArray.count - 1 {
                return nil
            }
            chapterIndex += 1
            
            let newChapterMark = CDChapterMark(context: context)
            newChapterMark.chapterMark = Int16(chapterIndex)
            newChapterMark.parentBook = selectedBook
            //chapterMarkArray.append(newChapterMark)
            saveChapterMark.saveChapterMarks()
//            let url = "http://chapter2.zhuishushenqi.com/chapter/\(chapterArray[chapterIndex].chapterLink.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)"
//
//            getBodyData(from: url, completionHandler: {
//                data in
//                self.body = data
//
//                self.contentTextView.text = self.body
//                let fitRange = self.contentTextView.numberOfCharactersThatFitTextView()
//                self.splitedContentArray = self.body.split(by: fitRange)
//
//                self.initializeView()
//
//            })
//            body = chapterArray[chapterIndex].chapterBody
//            contentTextView.text = body
//            let fitRange = contentTextView.numberOfCharactersThatFitTextView()
//            splitedContentArray = body.split(by: fitRange)
//            pageDevide()
//            initializeView()
            if chapterIndex >= CDChapterArray.count {
                let url = "http://chapter2.zhuishushenqi.com/chapter/\(chapterArray[chapterIndex].chapterLink.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)"
                
                getBodyData(from: url, completionHandler: {
                    data in

                    self.splitedContentArray = self.pageSplit(with: data)

                    self.initializeView()
                    
                })
            }
            else {

                splitedContentArray = pageSplit(with: CDChapterArray[chapterIndex].chapterBody!)
                initializeView()
            }
        }
        let newPageMark = CDPageMark(context: context)
        newPageMark.pageMark = Int16(index)
        newPageMark.parentBookID = selectedBook.id
        newPageMark.chapterMark = Int16(chapterIndex)
        //newPageMark.parentChapterMark = chapterMarkArray[chapterMarkArray.endIndex - 1]
        savePageMark.savePageMarks()
        
        savePageMark.clearPageMarks(inBook: selectedBook.id!)
        
        return viewControllerAtIndex(index: index)
    }
    
    
}




// MARK: - Split string by length
extension String {
    func split(by length: Int) -> [String] {
        var startIndex = self.startIndex
        var results = [Substring]()
        
        while startIndex < self.endIndex {
            let endIndex = self.index(startIndex, offsetBy: length, limitedBy: self.endIndex) ?? self.endIndex
            results.append(self[startIndex..<endIndex])
            startIndex = endIndex
        }
        
        return results.map { String($0) }
    }
}

extension Array {
    func chunked(by chunkSize: Int) -> [[Element]] {
        return stride(from: 0, to: self.count, by: chunkSize).map {
            Array(self[$0..<Swift.min($0 + chunkSize, self.count)])
        }
    }
}



