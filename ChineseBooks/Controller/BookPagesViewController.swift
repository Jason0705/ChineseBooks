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

    var chapterTitle = ""
    var chapterLink = ""
    var body = ""
    
    var splitedContentArray = [String]()
    
    var pageController: UIPageViewController?
    
    
    @IBOutlet weak var contentTextView: UITextView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = "http://chapter2.zhuishushenqi.com/chapter/\(chapterLink.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)"

        getBodyData(from: url)
        
        //navigationController?.isNavigationBarHidden = true
        
    }
  
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        contentTextView.text = body
        let fitRange = contentTextView.numberOfCharactersThatFitTextView()
        splitedContentArray = body.split(by: fitRange)
        
        
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
    
    
    // MARK: - Networking
    
    // getRankData Method
    func getBodyData(from url: String) {
        Alamofire.request(url).responseJSON {
            response in
            if response.result.isSuccess{
                let bodyJSON : JSON = JSON(response.result.value!)
                self.createBodyData(with: bodyJSON)
            } else {
                print("Couldnt process JSON response, Error: \(response.result.error)")
            }
        }
    }
    
    
    // MARK: - JSON Parsing
    
    // Parse JSON data
    func createBodyData(with json: JSON) {
        guard !json.isEmpty else {fatalError("json unavailible!")}
        
        body = json["chapter"]["body"].stringValue
    }

    

}



extension BookPagesViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    func viewControllerAtIndex(index: Int) -> ContentViewController? {
        
        if (splitedContentArray.count == 0) || (index >= splitedContentArray.count) {
            return nil
        }
        
        let storyBoard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let dataVC = storyBoard.instantiateViewController(withIdentifier: "contentView") as! ContentViewController
        
        dataVC.chapterTitle = chapterTitle
        dataVC.body = splitedContentArray[index]
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
        
        if (index == 0) || (index == NSNotFound) {
            return nil
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
            return nil
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
