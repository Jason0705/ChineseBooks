//
//  StoreViewController.swift
//  ChineseBooks
//
//  Created by Jason Li on 2018-08-08.
//  Copyright © 2018 Jason Li. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class StoreViewController: UIViewController {
    
    let url = "http://api.zhuishushenqi.com/cats"
    
    var categoryArray = [Category]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getCategoryData(from: url)
    }


    // MARK: - Networking
    
    // getCategoryData Method
    func getCategoryData(from url: String) {
        Alamofire.request(url).responseJSON {
            response in
            if response.result.isSuccess{
                let categoryJSON : JSON = JSON(response.result.value!)
                self.createCategoryDict(with: categoryJSON)
                //print(categoryJSON["male"].arrayValue)
            } else {
                print("Couldnt process JSON response, Error: \(response.result.error)")
            }
        }
    }
    
    
    // MARK: - JSON Parsing
    
    // Parse JSON data
    func createCategoryDict(with json: JSON) {
        guard !json.isEmpty else {fatalError("json unavailible!")}
        
        for category in json["male"].arrayValue {
            let name = category["name"].stringValue
            let bookCount = category["bookCount"].intValue
            let newElement = Category(name: name, count: bookCount)
            
            //print(newElement)
            categoryArray.append(newElement)
        }
        //print(categoryArray[0].categoryName)
    }

    
    
    
}

