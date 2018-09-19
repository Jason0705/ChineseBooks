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
        var array = [CDChapterMark]()
        
        request.predicate = predicate
        do {
            array = try context.fetch(request)
            if array.count > 0 {
                mark = Int(array[array.endIndex - 1].chapterMark)
                //mark = Int(array[0].chapterMark)

            }

        } catch {
            print("Error fetching data from context: \(error)")
        }
        return mark
    }
    
    func clearChapterMarks() {
        let request : NSFetchRequest <CDChapterMark> = CDChapterMark.fetchRequest()
        do {
            var a = try context.fetch(request)
            if a.count > 0 {
                for index in 0..<a.count - 1 {
                    if a[index].parentBook == nil {
                        context.delete(a[index])
                    }
                }
                saveChapterMarks()
            }
        } catch {
            print("Error fetching data from context: \(error)")
        }
    }

}
