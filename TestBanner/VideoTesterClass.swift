//
//  VideoTesterClass.swift
//  TestBanner
//
//  Created by 創意遊玩 on 2018/5/2.
//  Copyright © 2018年 田腾飞. All rights reserved.
//

import UIKit

class VideoTesterClass: UIViewController{
    @IBOutlet weak var myWebView: UIWebView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = URL(string: "https://www.youtube.com/embed/JlGkuFI-lj0")
        myWebView.loadRequest(URLRequest(url: url!))
    }
}
