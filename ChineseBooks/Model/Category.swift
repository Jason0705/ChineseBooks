//
//  Category.swift
//  ChineseBooks
//
//  Created by Jason Li on 2018-08-08.
//  Copyright © 2018 Jason Li. All rights reserved.
//

import Foundation

class Category {
    
    let categoryName : String
    let bookCount : Int
    
    init(name: String, count: Int) {
        categoryName = name
        bookCount = count
    }
}
