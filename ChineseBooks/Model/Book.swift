//
//  Book.swift
//  ChineseBooks
//
//  Created by Jason Li on 2018-08-18.
//  Copyright © 2018 Jason Li. All rights reserved.
//

import Foundation

class Book {
    
    let bookTitle : String
    let bookID : String
    let bookAuthor : String
    let bookCoverURL : String
    let bookIntro : String
    let bookCategory : String
    let lastChapter : String
    
    init(title: String, id: String, author: String, coverURL: String, intro: String, category: String, last: String) {
        bookTitle = title
        bookID = id
        bookAuthor = author
        bookCoverURL = coverURL
        bookIntro = intro
        bookCategory = category
        lastChapter = last
        
    }
}
