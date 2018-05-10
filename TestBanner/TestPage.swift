//
//  TestPage.swift
//  TestBanner
//
//  Created by 創意遊玩 on 2018/5/10.
//  Copyright © 2018年 田腾飞. All rights reserved.
//

import UIKit

class TestPage: UIViewController{
    
    @IBAction func totheAlert(_ sender: Any) {
        performSegue(withIdentifier: "toAlertViewPage", sender: self)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}
