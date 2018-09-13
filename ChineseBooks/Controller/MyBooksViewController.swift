//
//  MyBooksViewController.swift
//  ChineseBooks
//
//  Created by Jason Li on 2018-09-12.
//  Copyright © 2018 Jason Li. All rights reserved.
//

import UIKit
import Kingfisher
import CoreData

class MyBooksViewController: UIViewController {

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var myBookList = [CDBook]()
    
    
    @IBOutlet weak var defultLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var myBooksCollectionView: UICollectionView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        defultLabel.isHidden = true
        //loadBooks()
        //myBooksCollectionView.reloadData()
        
        // Register CustomBookCell.xib
        myBooksCollectionView.register(UINib(nibName: "CustomBookCell", bundle: nil), forCellWithReuseIdentifier: "customBookCell")
        
        // Style
        containerView.frame.size.width = UIScreen.main.bounds.width
        myBooksCollectionView.collectionViewLayout = cellStyle()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super .viewDidAppear(animated)
        
        loadBooks()
    }
    
    func loadBooks() {
        let request : NSFetchRequest<CDBook> = CDBook.fetchRequest()
        do {
            myBookList = try context.fetch(request)
        } catch {
            print("Error fetching data from context: \(error)")
        }
        if myBookList.count == 0 {
            defultLabel.isHidden = false
        }
        else {
            defultLabel.isHidden = true
        }
        myBooksCollectionView.reloadData()
    }
    
    
    // MARK: - Styling
    
    // CollectionView Cell Style
    func cellStyle() -> UICollectionViewFlowLayout {
        let cellSize = containerView.frame.size.width/3 - 24
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsetsMake(8, 16, 8, 16)
        layout.itemSize = CGSize(width: cellSize, height: cellSize * 2)
        layout.minimumInteritemSpacing = 16
        layout.minimumLineSpacing = 16
        
        return layout
    }


}



extension MyBooksViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    // Number of Cell
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return myBookList.count
    }
    
    // Populate Cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "customBookCell", for: indexPath) as! CustomBookCell
        let cellData = myBookList[indexPath.row]
        cell.bookTitleLabel.text = cellData.title
        cell.bookAuthorLabel.text = cellData.author
        let coverURL = URL(string: cellData.coverURL!)
        cell.bookCoverImage.kf.setImage(with: coverURL)
        
        return cell
    }
    
    // Select Cell
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToChapter", sender: myBooksCollectionView)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToChapter" {
            let destinationVC = segue.destination as! ChapterViewController
            if let indexPaths = myBooksCollectionView.indexPathsForSelectedItems {
                let indexPath = indexPaths[0] as NSIndexPath
                destinationVC.bookTitle = myBookList[indexPath.row].title!
                destinationVC.bookID = myBookList[indexPath.row].id!
                destinationVC.downloadButtonState = true
            }
        }
    }
    
    
}
