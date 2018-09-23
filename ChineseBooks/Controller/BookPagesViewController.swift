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
import CoreData

class BookPagesViewController: UIViewController {

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let saveChapterMark = SaveChapterMark()
    let savePageMark = SavePageMark()
    
    var body = ""
    var chapterIndex = 0
    var pageBookMark = 0
    
    var settingMode = false
    
    var CDChapterArray = [CDChapter]()
    var chapterArray = [Chapter]()
    //var chapterMarkArray = [CDChapterMark]()
    var selectedBook = CDBook()
    var selectedChapterMark = CDChapterMark()
    var splitedContentArray = [String]()
    
    var pageController: UIPageViewController?
    
    // setting variables
    var pageBackgroundColor = UIColor.white
    var fontSize : CGFloat = 22
    
    
    
    //@IBOutlet weak var contentTextView: UITextView!
    
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var settingView: UIView!
    
    
    @IBOutlet weak var currentPageLabel: UILabel!
    @IBOutlet weak var maxPageLabel: UILabel!
    @IBOutlet weak var pageSlider: UISlider!
    
    
    @IBOutlet weak var bgColor1Button: UIButton!
    @IBOutlet weak var bgColor2Button: UIButton!
    @IBOutlet weak var bgColor3Button: UIButton!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load Data
        
        // Load pageBookMarks
        pageBookMark = savePageMark.loadPageMarks(inChapter: Int16(chapterIndex), ofBook: selectedBook.id!)
        // Load preference
        loadPreference()
        // Load page
        loadPages(at: pageBookMark)
        
        // Style
        
        // set font
        contentLabel.font = UIFont(name: contentLabel.font.fontName, size: fontSize)
        // setting view rounded corners
        settingView.layer.cornerRadius = 10
        // nav bar hidden
        self.navigationController?.isNavigationBarHidden = true
        // bgColorButtons rounded
        bgColor1Button.layer.cornerRadius = 0.5 * bgColor1Button.bounds.size.width
        bgColor2Button.layer.cornerRadius = 0.5 * bgColor2Button.bounds.size.width
        bgColor3Button.layer.cornerRadius = 0.5 * bgColor3Button.bounds.size.width
        
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

    
    // MARK: - Functions
    
    // Load page
    func loadPages(at index: Int) {
        if chapterIndex >= CDChapterArray.count {
            let url = "http://chapter2.zhuishushenqi.com/chapter/\(chapterArray[chapterIndex].chapterLink.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)"
            
            getBodyData(from: url, completionHandler: {
                data in
                
                
                self.splitedContentArray = self.pageSplit(with: data)
                
                self.initializeView(at: index)
                
                self.updateSlider(with: index)
            })
        }
        else {
            
            splitedContentArray = pageSplit(with: CDChapterArray[chapterIndex].chapterBody!)
            initializeView(at: index)
            updateSlider(with: index)
        }
        
    }
    
    
    // Split body text into pages
    func pageSplit(with text: String) -> [String] {
        let font = UIFont(name: contentLabel.font.fontName, size: fontSize)
        let charactersPerLine = Int(contentLabel.bounds.width / (font?.pointSize)!)
        let numberOfLines = Int(contentLabel.bounds.height / (font?.lineHeight)!)
        
        var lines = [String]()
        var pagesArray = [String]()
        
        contentLabel.numberOfLines = numberOfLines
        
        let sentencesArray = text.components(separatedBy: "\n")
        for sentence in sentencesArray {
            let frontPadded = String(repeating: "", count: 1) + sentence
            
            //            let attributed = NSMutableAttributedString(string: frontPadded)
            //            attributed.addAttribute(.foregroundColor, value: contentLabel.backgroundColor, range: NSRange.init(location: 0, length: 0))
            var linesArray = frontPadded.split(by: charactersPerLine)
            
            for index in 0..<linesArray.count {
                //                if linesArray[index].count < charactersPerLine {
                //                    linesArray[index] = linesArray[index] + "\n"
                //                }
                linesArray[index] = linesArray[index] + "\n"
                lines.append(linesArray[index])
            }
        }
        
        var newPageText = ""
        let pages = lines.chunked(by: numberOfLines)
        
        for index in 0..<pages.count {
            for i in 0..<pages[index].count {
                newPageText = newPageText + pages[index][i]
            }
            pagesArray.append(newPageText)
            newPageText = ""
        }
        
        return pagesArray
    }
    
    
    // Initialize page view
    func initializeView(at index: Int) {
        // Initialize UIPageViewController
        pageController = UIPageViewController(
            transitionStyle: .pageCurl,
            navigationOrientation: .horizontal,
            options: nil)
        
        pageController?.delegate = self
        pageController?.dataSource = self
        
        let startingViewController: ContentViewController =
            viewControllerAtIndex(index: index)!
        
        let viewControllers: NSArray = [startingViewController]
        pageController!.setViewControllers(viewControllers
            as? [UIViewController],
                                           direction: .forward,
                                           animated: false,
                                           completion: nil)
        
        self.addChildViewController(pageController!)
        self.contentView.addSubview(self.pageController!.view)
        
        let pageViewRect = self.contentView.bounds
        pageController!.view.frame = pageViewRect
        pageController!.didMove(toParentViewController: self)
        
    }
    
    
    func updateSlider(with index: Int) {
        currentPageLabel.text = "\(index + 1)"
        maxPageLabel.text = "\(splitedContentArray.count)"
        pageSlider.minimumValue = 0
        pageSlider.maximumValue = Float(splitedContentArray.count - 1)
        pageSlider.value = Float(index)
        
        updatePageMark(with: index)
    }
    
    
    func updatePageMark(with index: Int) {
        let newPageMark = CDPageMark(context: context)
        newPageMark.pageMark = Int16(index)
        newPageMark.parentBookID = selectedBook.id
        newPageMark.chapterMark = Int16(chapterIndex)
        //newPageMark.parentChapterMark = chapterMarkArray[chapterMarkArray.endIndex - 1]
        savePageMark.savePageMarks()
        savePageMark.clearPageMarks(inBook: selectedBook.id!)
        pageBookMark = savePageMark.loadPageMarks(inChapter: Int16(chapterIndex), ofBook: selectedBook.id!)
    }
    
    
    
    // Mark: - Core Data CRUD
    func savePreference() {
        do {
            try context.save()
        } catch {
            print("Error Saving Context: \(error)")
        }
    }
    
    func loadPreference() {
        let request : NSFetchRequest<CDPreference> = CDPreference.fetchRequest()
        do {
            let preferenceArray = try context.fetch(request)
            if preferenceArray.count > 0 {
                pageBackgroundColor = preferenceArray[preferenceArray.endIndex - 1].backgroundColor as! UIColor
                fontSize = CGFloat(preferenceArray[preferenceArray.endIndex - 1].fontSize)
            }
        } catch {
            print("Error fetching data from context: \(error)")
        }
    }
    
    func clearPreference() {
        let request : NSFetchRequest<CDPreference> = CDPreference.fetchRequest()
        do {
            let preferenceArray = try context.fetch(request)
            if preferenceArray.count >= 2 {
                for index in 0..<(preferenceArray.count - 1) {
                    context.delete(preferenceArray[index])
                }
                savePreference()
            }
        } catch {
            print("Error fetching data from context: \(error)")
        }
    }
    
    
    
    // MARK: - Enable/Disable Setting Menu
    
    // Tap gesture in the middle of the screen to bring up setting menu
    @IBAction func tapViewTapped(_ sender: UITapGestureRecognizer) {
        if settingMode == true {
            settingMode = false
            
        }
        else if settingMode == false {
            settingMode = true
            
        }
        settingView.isHidden = !settingMode
        self.navigationController?.isNavigationBarHidden = !settingMode
    }
    
    // Page slider to change page
    @IBAction func pageSliderMoved(_ sender: UISlider) {
        let value = Int(sender.value)
        currentPageLabel.text = "\(value + 1)"
        loadPages(at: value)
    }
    
    // Font buttons pressed to change font and re-split body string
    @IBAction func fontSizeButtonPressed(_ sender: UIButton) {
        if sender.tag == 0 {
            contentLabel.font = UIFont(name: contentLabel.font.fontName, size: contentLabel.font.pointSize - 2)
            fontSize = contentLabel.font.pointSize - 2
        }
        else if sender.tag == 1 {
            contentLabel.font = UIFont(name: contentLabel.font.fontName, size: contentLabel.font.pointSize + 2)
            fontSize = contentLabel.font.pointSize - 2
        }
        loadPages(at: 0)
        let newPrefernece = CDPreference(context: context)
        newPrefernece.backgroundColor = pageBackgroundColor
        newPrefernece.fontSize = Float(fontSize)
        savePreference()
        clearPreference()
    }
    
    // Color buttons pressed to change background color
    @IBAction func bgColorButtonPressed(_ sender: UIButton) {
        if sender.tag == 0 {
            pageBackgroundColor = bgColor1Button.backgroundColor!
        }
        else if sender.tag == 1 {
            pageBackgroundColor = bgColor2Button.backgroundColor!
        }
        else if sender.tag == 2 {
            pageBackgroundColor = bgColor3Button.backgroundColor!
        }
        loadPages(at: pageBookMark)
        let newPrefernece = CDPreference(context: context)
        newPrefernece.backgroundColor = pageBackgroundColor
        newPrefernece.fontSize = Float(fontSize)
        savePreference()
        clearPreference()
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
        dataVC.backgroundColor = pageBackgroundColor
        dataVC.fontSize = fontSize
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

            loadPages(at: 0)
        }
        
        index = index - 1
        
        updateSlider(with: index)
        
        return viewControllerAtIndex(index: index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        var index = indexOfViewController(viewController: viewController
            as! ContentViewController)
        
        if index == NSNotFound {
            return nil
        }
        index = index + 1
        
        updateSlider(with: index)
        
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

            loadPages(at: 0)
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

extension Array {
    func chunked(by chunkSize: Int) -> [[Element]] {
        return stride(from: 0, to: self.count, by: chunkSize).map {
            Array(self[$0..<Swift.min($0 + chunkSize, self.count)])
        }
    }
}



