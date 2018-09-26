//
//  Style.swift
//  ChineseBooks
//
//  Created by Jason Li on 2018-09-25.
//  Copyright © 2018 Jason Li. All rights reserved.
//

import UIKit

class Style {
    
    func cellStyle(view: UIView, widthDecrease: CGFloat, spacing: CGFloat, inset: UIEdgeInsets, heightMultiplier: CGFloat) -> UICollectionViewFlowLayout {
        let cellSize = view.frame.size.width/3 - widthDecrease
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = inset
        layout.itemSize = CGSize(width: cellSize, height: cellSize * heightMultiplier)
        layout.minimumInteritemSpacing = spacing
        layout.minimumLineSpacing = spacing
        
        return layout
    }
}

//    func cellStyle() -> UICollectionViewFlowLayout {
//        let cellSize = storeStackView.frame.size.width/3 - 12
//        let layout = UICollectionViewFlowLayout()
//        layout.sectionInset = UIEdgeInsetsMake(8, 8, 8, 8)
//        layout.itemSize = CGSize(width: cellSize, height: cellSize)
//        layout.minimumInteritemSpacing = 8
//        layout.minimumLineSpacing = 8
//
//        return layout
//    }

//    func cellStyle() -> UICollectionViewFlowLayout {
//        let cellSize = listStackView.frame.size.width/3 - 24
//        let layout = UICollectionViewFlowLayout()
//        layout.sectionInset = UIEdgeInsetsMake(8, 16, 8, 16)
//        layout.itemSize = CGSize(width: cellSize, height: cellSize * 2)
//        layout.minimumInteritemSpacing = 0
//        layout.minimumLineSpacing = 0
//
//        return layout
//    }
