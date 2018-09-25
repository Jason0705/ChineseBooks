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
import ProgressHUD
import ChameleonFramework

class MyBooksViewController: UIViewController {

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
//    let gradientColorsStrings = [["80d0c7", "13547a"],
//                                ["b7f8db", "50a7c2"],
//                                ["da4453", "89216b"],
//                                ["ad5389", "3c1053"],
//                                ["a8c0ff", "3f2b96"],
//                                ["8f94fb", "4e54c8"],
//                                ["c94b4b", "4b134f"]]
    let themeColors = [FlatSkyBlue(), FlatPurple(), FlatBlue(), FlatGreen(), FlatGray(), FlatOrange(), FlatRed(), FlatMint(), FlatPlum(), FlatTeal(), FlatBrown(), FlatCoffee(), FlatMaroon(), FlatMagenta()]
    
    var myBookList = [CDBook]()
    var editMode = false
    
    
    
    @IBOutlet weak var defultLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var editBarButton: UIBarButtonItem!
    @IBOutlet weak var shopBarButton: UIBarButtonItem!
    
    @IBOutlet weak var myBooksCollectionView: UICollectionView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        defultLabel.isHidden = true
        clearBooks()
        //loadBooks()
        //myBooksCollectionView.reloadData()
        
        // Register CustomBookCell.xib
        myBooksCollectionView.register(UINib(nibName: "CustomBookCell", bundle: nil), forCellWithReuseIdentifier: "customBookCell")
        
        // Style
        containerView.frame.size.width = UIScreen.main.bounds.width
        myBooksCollectionView.collectionViewLayout = cellStyle()
        
        guard let navBar = navigationController?.navigationBar else {fatalError("Navigation Controller does not exist!")}
//        let themeColorStrings = gradientColorsStrings[Int(arc4random_uniform(UInt32(gradientColorsStrings.count)))]
//        navBar.backgroundColor = GradientColor(UIGradientStyle.leftToRight, frame: (navigationController?.navigationBar.bounds)!, colors: [HexColor(themeColorStrings[0])!, HexColor(themeColorStrings[1])!])
//        navBar.tintColor = HexColor(themeColorStrings[1])!
//        navBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor : HexColor(themeColorStrings[1])!]
//        navBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : HexColor(themeColorStrings[1])!]

        let themeColor = themeColors[Int(arc4random_uniform(UInt32(themeColors.count)))]
        navBar.backgroundColor = GradientColor(UIGradientStyle.leftToRight, frame: navBar.bounds, colors: [ComplementaryFlatColorOf(themeColor), themeColor])
        navBar.tintColor = themeColor
        navBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor : themeColor]
        navBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : themeColor]
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super .viewDidAppear(animated)
        
        loadBooks()
    }
    
    func saveBooks() {
        do {
            try context.save()
        } catch {
            ProgressHUD.showError("储存错误！")
            print("Error Saving Context: \(error)")
        }
        myBooksCollectionView.reloadData()
    }
    
    func loadBooks() {
        let request : NSFetchRequest<CDBook> = CDBook.fetchRequest()
        let predicate = NSPredicate(format: "added == YES")
        request.predicate = predicate
        do {
            myBookList = try context.fetch(request)
        } catch {
            ProgressHUD.showError("加载错误！")
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
    
    func deleteBook(at index: Int) {
        let request : NSFetchRequest<CDBook> = CDBook.fetchRequest()
        let predicate = NSPredicate(format: "id MATCHES %@", myBookList[index].id!)
        request.predicate = predicate
        do {
            let willDelete = try context.fetch(request)
            if willDelete.count > 0 {
                for book in willDelete {
                    context.delete(book)
                }
                saveBooks()
                loadBooks()
            }
        } catch {
            print("Error fetching data from context: \(error)")
        }
    }
    
    func clearBooks() {
        let request : NSFetchRequest<CDBook> = CDBook.fetchRequest()
        let predicate = NSPredicate(format: "added == NIL")
        request.predicate = predicate
        do {
            let willDelete = try context.fetch(request)
            if willDelete.count > 0 {
                for index in 0..<willDelete.count {
                    context.delete(willDelete[index])
                }
                saveBooks()
            }

        } catch {
            print("Error fetching data from context: \(error)")
        }
    }
    
    
    // MARK: - Styling
    
    // CollectionView Cell Style
    func cellStyle() -> UICollectionViewFlowLayout {
        let cellSize = containerView.frame.size.width/3 - 24
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsetsMake(8, 16, 8, 16)
        layout.itemSize = CGSize(width: cellSize, height: cellSize * 2)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        return layout
    }
    
    
    // MARK: - Edit Mode
    
    // Enter edit mode
    func enterEditMode() {
        editMode = true
        editBarButton.title = "完成"
        shopBarButton.isEnabled = false
    }
    
    // Exit edit mode
    func exitEditMode() {
        editMode = false
        editBarButton.title = "编辑"
        shopBarButton.isEnabled = true
    }

    

    @IBAction func editBarButtonPressed(_ sender: UIBarButtonItem) {
        // Press 完成
        if editMode == true {
            exitEditMode()
        }
        // Press 编辑
        else if editMode == false {
            enterEditMode()
        }
        myBooksCollectionView.reloadData()
    }
    

    @IBAction func longPressed(_ sender: UILongPressGestureRecognizer) {
        enterEditMode()
        myBooksCollectionView.reloadData()
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
        cell.cellDelegate = self
        cell.deleteButton.isHidden = !editMode
        cell.deleteButton.layer.cornerRadius = 0.5 * cell.deleteButton.bounds.size.width
        cell.index = indexPath.row
        if editMode == true {
            cell.shakeIcons()
        }
        else if editMode == false {
            cell.stopShakingIcons()
        }
        let coverURL = URL(string: cellData.coverURL!)
        cell.bookCoverImage.kf.setImage(with: coverURL)
        
        return cell
    }
    
    // Select Cell
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        exitEditMode()
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
                destinationVC.selectedBook = myBookList[indexPath.row]
                //destinationVC.selectedBookID = myBookList[indexPath.row].id!
            }
        }
    }
    
    
}


extension MyBooksViewController: CollectionViewNew {
    func deleteCell(withIndex index: Int) {
        deleteBook(at: index)
    }
    
    
}
