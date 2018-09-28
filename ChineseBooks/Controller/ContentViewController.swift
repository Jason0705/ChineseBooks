//
//  ContentViewController.swift
//  ChineseBooks
//
//  Created by Jason Li on 2018-08-30.
//  Copyright © 2018 Jason Li. All rights reserved.
//

import UIKit
import ChameleonFramework
import GoogleMobileAds

class ContentViewController: UIViewController {

    var chapterTitle = ""
    var body = ""
    var pageCounte = ""
    var backgroundColor = UIColor.white
    var fontSize : CGFloat = 22
    
    var bannerView: GADBannerView!

    
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var pageCounterLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var bannerAdsView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        
        //addBannerViewToView(bannerView)
        
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        
        bannerView.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        contentLabel.font = UIFont(name: contentLabel.font.fontName, size: fontSize)
        
        titleLabel.text = chapterTitle
        contentLabel.text = body
        contentLabel.numberOfLines = Int(contentLabel.bounds.height / contentLabel.font.lineHeight)
        pageCounterLabel.text = pageCounte
        containerView.backgroundColor = backgroundColor
        titleLabel.textColor = ContrastColorOf(containerView.backgroundColor!, returnFlat: true)
        contentLabel.textColor = ContrastColorOf(containerView.backgroundColor!, returnFlat: true)
        pageCounterLabel.textColor = ContrastColorOf(containerView.backgroundColor!, returnFlat: true)
    }
    
    func addBannerViewToView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        bannerAdsView.addSubview(bannerView)
        
        bannerAdsView.addConstraints(
            [NSLayoutConstraint(item: bannerView,
                                attribute: .bottom,
                                relatedBy: .equal,
                                toItem: bannerAdsView,
                                attribute: .bottom,
                                multiplier: 1,
                                constant: 0),
             NSLayoutConstraint(item: bannerView,
                                attribute: .centerX,
                                relatedBy: .equal,
                                toItem: bannerAdsView,
                                attribute: .centerX,
                                multiplier: 1,
                                constant: 0)
            ])
    }

}

extension ContentViewController: GADBannerViewDelegate {
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        // Add banner to view and add constraints as above.
        addBannerViewToView(bannerView)
    }
}

