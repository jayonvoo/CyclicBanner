//
//  ToasterView.swift
//  TestBanner
//
//  Created by 創意遊玩 on 2018/5/7.
//  Copyright © 2018年 田腾飞. All rights reserved.
//

import UIKit

class ToasterView: UIViewController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showToast(message: "PopUp...please")
    }
    
    
}
extension ToasterView: UIScrollViewDelegate {
    
    func showToast(message : String) {
        
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height-100, width: 150, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont(name: "Montserrat-Light", size: 12.0)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 1, delay: 5, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
}
