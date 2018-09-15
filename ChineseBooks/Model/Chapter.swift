//
//  Chapter.swift
//  ChineseBooks
//
//  Created by Jason Li on 2018-08-26.
//  Copyright © 2018 Jason Li. All rights reserved.
//

import Foundation

class Chapter {
    
    let chapterTitle : String
    let chapterLink : String
    var chapterBody: String
    
    init(title: String, link: String, body: String) {
        chapterTitle = title
        chapterLink = link
        chapterBody = body
    }
}
