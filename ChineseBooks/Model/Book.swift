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
    let bookCover : String
    let bookIntro : String
    let bookCategory : String
    
    init(title: String, id: String, author: String, cover: String, intro: String, category: String) {
        bookTitle = title
        bookID = id
        bookAuthor = author
        bookCover = cover
        bookIntro = intro
        bookCategory = category
        
    }
}
