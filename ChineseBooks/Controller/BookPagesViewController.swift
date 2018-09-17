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
    
    var CDChapterArray = [CDChapter]()
    var chapterArray = [Chapter]()
    var chapterIndex = 0
    
    var body = ""
    
    var splitedContentArray = [String]()
    
    var pageController: UIPageViewController?
    
    var selectedBook : CDBook? {
        didSet {
            
        }
    }
    
    
    @IBOutlet weak var contentTextView: UITextView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if chapterIndex >= CDChapterArray.count {
            let url = "http://chapter2.zhuishushenqi.com/chapter/\(chapterArray[chapterIndex].chapterLink.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)"
            
            getBodyData(from: url, completionHandler: {
                data in
                self.body = data
                
                self.pageDevide()
                
                self.initializeView()
                
            })
        }
        else {
            body = CDChapterArray[chapterIndex].chapterBody!
            pageDevide()
            initializeView()
        }
        
        
        //navigationController?.isNavigationBarHidden = true
//        pageDevide()
//        initializeView()
        
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
            viewControllerAtIndex(index: 0)!
        
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
    
    func pageDevide() {
        contentTextView.text = body //chapterArray[chapterIndex].chapterBody
        let fitRange = contentTextView.numberOfCharactersThatFitTextView()
        splitedContentArray = body.split(by: fitRange) //chapterArray[chapterIndex].chapterBody.split(by: fitRange)
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
                    self.body = data
                    
                    self.pageDevide()
                    
                    self.initializeView()
                    
                })
            }
            else {
                body = CDChapterArray[chapterIndex].chapterBody!
                pageDevide()
                initializeView()
            }
        }
        
        index = index - 1
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
                    self.body = data
                    
                    self.pageDevide()
                    
                    self.initializeView()
                    
                })
            }
            else {
                body = CDChapterArray[chapterIndex].chapterBody!
                pageDevide()
                initializeView()
            }
        }
        
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

// MARK: - Get textView fitRange
extension UITextView {
    func numberOfCharactersThatFitTextView() -> Int {
        let fontRef = CTFontCreateWithName(font!.fontName as CFString, font!.pointSize, nil)
        let attributes = [kCTFontAttributeName : fontRef]
        let attributedString = NSAttributedString(string: text!, attributes: attributes as [NSAttributedStringKey : Any])
        let frameSetterRef = CTFramesetterCreateWithAttributedString(attributedString as CFAttributedString)
        
        var characterFitRange: CFRange = CFRange()
        
        CTFramesetterSuggestFrameSizeWithConstraints(frameSetterRef, CFRangeMake(0, 0), nil, CGSize(width: bounds.size.width, height: bounds.size.height), &characterFitRange)
        
        return Int(characterFitRange.length)
    }
}
