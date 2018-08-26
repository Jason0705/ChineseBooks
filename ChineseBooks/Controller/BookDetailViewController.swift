//
//  BookDetailViewController.swift
//  ChineseBooks
//
//  Created by Jason Li on 2018-08-21.
//  Copyright © 2018 Jason Li. All rights reserved.
//

import UIKit

class BookDetailViewController: UIViewController {

    var bookTitle = ""
    var author = ""
    var category = ""
    var last = ""
    var intro = ""
    var bookID = ""
    
    
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

    }

    
    @IBAction func addButtonPressed(_ sender: UIButton) {
    }
    
    @IBAction func readButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "goToChapter", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToChapter" {
            let destinationVC = segue.destination as! ChapterViewController
            destinationVC.bookTitle = self.bookTitle
            destinationVC.bookID = self.bookID
        }
    }
    

}
