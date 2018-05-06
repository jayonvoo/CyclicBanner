//
//  BannerUseScrollViewController.swift
//  TestBanner
//
//  Created by tiantengfei on 2016/12/22.
//  Copyright © 2016年 田腾飞. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class BannerUseScrollViewController: UIViewController {
    
    let imageCount = 3
    var scrollView: UIScrollView!
    var pageView: UIPageControl!
    var timer: Timer?
    var dbDelegate = DatabaseController()
    var videoURL = URL(string: "https://jayonweb.000webhostapp.com/CycleBanner_video/%E6%98%A0%E7%94%BB%E3%80%8E%E3%83%8B%E3%83%B3%E3%82%B7%E3%82%99%E3%83%A3%E3%83%8F%E3%82%99%E3%83%83%E3%83%88%E3%83%9E%E3%83%B3%E3%80%8F%20%E6%97%A5%E6%9C%AC%E7%94%A8%E3%83%88%E3%83%AC%E3%83%BC%E3%83%A9%E3%83%BC%E3%80%902018%E5%B9%B46%E6%9C%8815%E6%97%A5%E5%8A%87%E5%A0%B4%E5%85%AC%E9%96%8B%E3%80%91.mp4")
    var player: AVPlayer?
    var playerLayer = AVPlayerViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        dbDelegate.viewDidLoad()
        print(dbDelegate.getWiFiAddress()!)
        print(dbDelegate.getDirectoryPath())
        dbDelegate.insertInitialData(auth: "01:00:00", address: dbDelegate.getWiFiAddress()!, console: "huawei", cycle_time: 10)
        addTimer()
        showToast(message: "成功連線")
        
        dbDelegate.getDBValue_id()
        
    }
    /*
     override func viewDidAppear(_ animated: Bool) {
     let alertController = UIAlertController(title: "Enter Ip", message: "", preferredStyle: .alert)
     
     alertController.addTextField(configurationHandler:{(textField) in
     textField.placeholder = "ip address"
     })
     
     let okAction = UIAlertAction(title: "確定", style: .default, handler:{
     (alert) -> Void in
     })
     
     alertController.addAction(okAction)
     
     present(alertController, animated: true, completion: nil)
     }
     */
    func setupViews() {
        
        do {
            scrollView = UIScrollView(frame: CGRect(x: 0, y: 200, width: kScreenWidth, height: 250))
            scrollView.delegate = self
            view.addSubview(scrollView)
        }
        
        do {
            pageView = UIPageControl(frame: CGRect(x: 0, y: kScreenHeight - 30, width: kScreenWidth, height: 30))
            //  view.addSubview(pageView)
            pageView.numberOfPages = imageCount
            pageView.currentPage = 0
            //pageView.pageIndicatorTintColor = UIColor.white
            //pageView.currentPageIndicatorTintColor = UIColor.blue
        }
        
        do {
            /// 只使用3个UIImageView，依次设置好最后一个，第一个，第二个图片，这里面使用取模运算。
            
            
            for index in 0..<2 {
                let imageView = UIImageView(frame: CGRect(x: CGFloat(index) * kScreenWidth, y: 0, width: kScreenWidth, height: 250))
                imageView.image = UIImage(named: "pic0\((index + 3) % 3).jpg")
                
                scrollView.addSubview(imageView)
                
                print(scrollView.subviews[index])
            }
            
            player = AVPlayer(url: videoURL!)
            playerLayer.player = player
            playerLayer.view.frame = CGRect(x: CGFloat(2) * kScreenWidth, y: 0, width: kScreenWidth, height: 250)
            player?.play()
            
            scrollView.addSubview(playerLayer.view)
            
            print(scrollView.subviews[2])
            print(type(of: playerLayer.view))
        }
        
        do {
            scrollView.contentSize = CGSize(width: kScreenWidth * 3, height: 0)
            scrollView.contentOffset = CGPoint(x: kScreenWidth, y: 0)
            scrollView.isPagingEnabled = true
            scrollView.showsHorizontalScrollIndicator = false
            scrollView.showsVerticalScrollIndicator = false
        }
        
        let contentOffset = CGPoint(x: 0, y: 0)
        scrollView.contentOffset = contentOffset
        scrollView.setContentOffset(contentOffset, animated: true)
    }
    
    /// 添加timer
    func addTimer() {
        /// 利用这种方式添加的timer 如果有列表滑动的话不会调用这个timer，因为当前runloop的mode更换了
        //        timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true, block: { [weak self] (timer) in
        //            self?.nextImage()
        //        })
        
        timer = Timer(timeInterval: 5, repeats: true, block: { [weak self] _ in
            self?.nextImage()
        })
        
        guard let timer = timer else {
            return
        }
        RunLoop.current.add(timer, forMode: .commonModes)
    }
    
    func removeTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    /// 下一个图片
    func nextImage() {
        print("next_image: \(pageView.currentPage)")
        if pageView.currentPage == imageCount - 1 {
            pageView.currentPage = 0
            
            let contentOffset = CGPoint(x: 0, y: 0)
            scrollView.setContentOffset(contentOffset, animated: true)
        } else {
            pageView.currentPage += 1
            
            let getPage = CGFloat(pageView.currentPage)
            
            let contentOffset = CGPoint(x: kScreenWidth * getPage, y: 0)
            scrollView.setContentOffset(contentOffset, animated: true)
        }
    }
    
    /// 上一个图片
    func preImage() {
        print("prev_image: \(pageView.currentPage)")
        if pageView.currentPage == 0 {
            pageView.currentPage = imageCount - 1
        } else {
            pageView.currentPage -= 1
        }
        
        let contentOffset = CGPoint(x: 0, y: 0)
        scrollView.contentOffset = contentOffset
        scrollView.setContentOffset(contentOffset, animated: true)
    }
    
    /// 重新加载图片，重新设置3个imageView
    func reloadImage() {
        let currentIndex = pageView.currentPage
        let nextIndex = (currentIndex + 1) % 3
        let preIndex = (currentIndex + 2) % 3
        
        (scrollView.subviews[0] as! UIImageView).image = UIImage(named: "pic0\(preIndex).jpg")
        (scrollView.subviews[1] as! UIImageView).image = UIImage(named: "pic0\(currentIndex).jpg")
        // (scrollView.subviews[2]).sub
        //(scrollView.subviews[2] as! UIImageView).image = UIImage(named: "pic0\(nextIndex).jpg")
        //(scrollView.subviews[2] as! UIView) = playerLayer.view
        
    }
}

extension BannerUseScrollViewController: UIScrollViewDelegate {
    
    /// 开始滑动的时候，停止timer，设置为niltimer才会销毁
    /*func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        removeTimer()
    }*/
    
    /// 当停止滚动的时候重新设置三个ImageView的内容，然后悄悄滴显示中间那个imageView
    /* func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
     reloadImage()
     scrollView.setContentOffset(CGPoint(x: kScreenWidth, y: 0), animated: false)
     } */
    
    /// 停止拖拽，开始timer, 并且判断是显示上一个图片还是下一个图片
    /*func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        addTimer()
        
        if scrollView.contentOffset.x < kScreenWidth {
            preImage()
        } else {
            nextImage()
        }
    }*/
    
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
        UIView.animate(withDuration: 1, delay: 3, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
}
