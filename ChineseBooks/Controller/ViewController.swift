//
//  ViewController.swift
//  ChineseBooks
//
//  Created by Jason Li on 2018-08-10.
//  Copyright © 2018 Jason Li. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIScrollViewDelegate {

   
    @IBOutlet weak var testSegmentedControl: UISegmentedControl!
    @IBOutlet weak var testScrollView: UIScrollView!
    
    var lastContentOffset: CGFloat = 0
    
    var v1 : View1 = View1(nibName: "View1", bundle: nil)
    var v2 : View2 = View2(nibName: "View2", bundle: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        testScrollView.delegate = self
        
        
        createScrollView()
        
    }
    

    func createScrollView() {
        addChildViewController(v1)
        testScrollView.addSubview(v1.view)
        v1.didMove(toParentViewController: self)
        
        addChildViewController(v2)
        testScrollView.addSubview(v2.view)
        v2.didMove(toParentViewController: self)
        
        var v2Frame : CGRect = v2.view.frame
        v2Frame.origin.x = self.view.frame.width
        v2.view.frame = v2Frame
        
        testScrollView.contentSize = CGSize(width: self.view.frame.width * 2, height: testScrollView.frame.height)
    }
    
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        lastContentOffset = testScrollView.contentOffset.x
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if (self.lastContentOffset < scrollView.contentOffset.x) {
            print("left")
            testSegmentedControl.selectedSegmentIndex += 1
        } else if (self.lastContentOffset > scrollView.contentOffset.x) {
            print("right")
            if testSegmentedControl.selectedSegmentIndex >= 0 {
                testSegmentedControl.selectedSegmentIndex -= 1
            }
            
            
        }
    }

    
    
    
    
    
    @IBAction func testSegmentedControlPressed(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            testScrollView.scrollRectToVisible(v1.view.frame, animated: true)
        }
        else if sender.selectedSegmentIndex == 1 {
            testScrollView.scrollRectToVisible(v2.view.frame, animated: true)
        }
    }
    
    
    
    

}
