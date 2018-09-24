//
//  ViewController.swift
//  ChineseBooks
//
//  Created by Jason Li on 2018-09-24.
//  Copyright © 2018 Jason Li. All rights reserved.
//

import UIKit
import ChameleonFramework

class ViewController: UIViewController {

    
    
    @IBOutlet weak var view1: UIView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view1.backgroundColor = GradientColor(UIGradientStyle.leftToRight, frame: view1.bounds, colors: [HexColor("13547a")!, HexColor("80d0c7")!])
//        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
//        let blurEffectView = UIVisualEffectView(effect: blurEffect)
//        blurEffectView.frame = view1.bounds
//        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        view1.addSubview(blurEffectView)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
