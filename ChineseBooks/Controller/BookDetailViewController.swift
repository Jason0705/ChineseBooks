//
//  BookDetailViewController.swift
//  ChineseBooks
//
//  Created by Jason Li on 2018-08-21.
//  Copyright © 2018 Jason Li. All rights reserved.
//

import UIKit
import Kingfisher
import CoreData

class BookDetailViewController: UIViewController {

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var addedBookArray = [CDBook]()
    //var addedBook = [CDBook]()
    
    //let thisBook = CDBook()
    
    var bookTitle = ""
    var author = ""
    var category = ""
    var last = ""
    var intro = ""
    var bookID = ""
    var bookCoverURL = ""
    
    
    @IBOutlet weak var bookCoverImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var lastLabel: UILabel!
    @IBOutlet weak var introTextView: UITextView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var readButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = bookTitle
        authorLabel.text = "作者: \(author)"
        categoryLabel.text = "分类: \(category)"
        lastLabel.text = last
        introTextView.text = intro
        let coverURL = URL(string: bookCoverURL)
        bookCoverImage.kf.setImage(with: coverURL)
        
        loadButton()
        //createCDBook()

    }
    
//    func createCDBook() {
//        thisBook.id = bookID
//        thisBook.title = bookTitle
//        thisBook.author = author
//        thisBook.category = category
//        thisBook.last = last
//        thisBook.intro = intro
//        thisBook.coverURL = bookCoverURL
//        thisBook.read = true
//    }
    
    func saveBooks() {
        do {
            try context.save()
        } catch {
            print("Error Saving Context: \(error)")
        }
    }
    
    func loadButton() {
        let request : NSFetchRequest <CDBook> = CDBook.fetchRequest()
        //let predicate = NSPredicate(format: "parentBook.id MATCHES %@", selectedBook!.id!)
        let predicate = NSPredicate(format: "added == YES")
        request.predicate = predicate
        do {
            let addedBook = try context.fetch(request)
//            if addedBook != [CDBook]() {
//                disableAddButton()
//            }
            for book in addedBook {
                if bookID == book.id {
                    disableAddButton()
                }
            }
        } catch {
            print("Error fetching data from context: \(error)")
        }
    }
    
    func disableAddButton() {
        addButton.isEnabled = false
        addButton.setTitle("已添加", for: .normal)
    }

    
    // MARK: - Actions
    
    @IBAction func addButtonPressed(_ sender: UIButton) {
        let newBook = CDBook(context: context)
        newBook.id = bookID
        newBook.title = bookTitle
        newBook.author = author
        newBook.category = category
        newBook.last = last
        newBook.intro = intro
        newBook.coverURL = bookCoverURL
        newBook.added = true
        
        addedBookArray.append(newBook)
        saveBooks()
        disableAddButton()
    }
    
    @IBAction func readButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "goToChapter", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToChapter" {
            let destinationVC = segue.destination as! ChapterViewController
            destinationVC.bookTitle = self.bookTitle
            destinationVC.bookID = self.bookID
            destinationVC.downloadButtonState = false
            //destinationVC.selectedBookID = self.bookID
            
            let thisBook = CDBook(context: context)
            thisBook.id = bookID
            thisBook.title = bookTitle
            thisBook.author = author
            thisBook.category = category
            thisBook.last = last
            thisBook.intro = intro
            thisBook.coverURL = bookCoverURL
            thisBook.read = true
            destinationVC.selectedBook = thisBook
        }
    }
    
    
    

}
