//
//  SaveChapterMark.swift
//  ChineseBooks
//
//  Created by Jason Li on 2018-09-16.
//  Copyright © 2018 Jason Li. All rights reserved.
//

import UIKit
import CoreData

class SaveChapterMark {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    //var mark = 0
    var array = [CDChapterMark]()
    
    func saveChapterMarks() {
        do {
            try context.save()
        } catch {
            print("Error Saving Context: \(error)")
        }
    }
    func loadChapterMarks(with id: String) -> Int {
        let request : NSFetchRequest <CDChapterMark> = CDChapterMark.fetchRequest()
        let predicate = NSPredicate(format: "parentBook.id MATCHES %@", id)
        var mark = 0
        
        request.predicate = predicate
        do {
            array = try context.fetch(request)
            if array.count > 0 {
                mark = Int(array[array.endIndex - 1].chapterMark)
//                for index in 0..<array.count - 1 {
//                    if array[index].parentBook == nil {
//                        context.delete(array[index])
//                        saveChapterMarks()
//                    }
//
//                }
//                if array.count > 1 {
//                    for index in 0..<array.count - 1 {
//                        context.delete(array[index])
//                        array.remove(at: index)
//                        saveChapterMarks()
//                    }
//                    //saveChapterMarks()
//                }

            }
//            mark = Int(array.last!.chapterMark)
//            if array.count > 1 {
//                for index in 0..<array.count - 1 {
//                    context.delete(array[index])
//                    array.remove(at: index)
//                }
//                saveChapterMarks()
//            }
            //print(array)
            //print(id)
            //return mark
        } catch {
            print("Error fetching data from context: \(error)")
        }
        return mark
    }

}
