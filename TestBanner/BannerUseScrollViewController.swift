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
    
    var imageCount: Int?
    var scrollView: UIScrollView!
    var pageView: UIPageControl!
    var timer: Timer?
    var dbDelegate = DatabaseController()
    var getPathArray = [String]()
    var linkPlayer = [Int : AVPlayer]()
    var passPageView: Int?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        dbDelegate.viewDidLoad()
        
        dbDelegate.insertInitialData(auth: "01:00:00", address: dbDelegate.getWiFiAddress()!, console: "huawei", cycle_time: 10)
        getPathArray = dbDelegate.getDBValue_address(ip_address: dbDelegate.getWiFiAddress()!)
        showToast(message: "成功連線")
        
        print("Time interval: \(parseDuration(timeString: "01:00:00"))")
        print(dbDelegate.getWiFiAddress()!)
        print(dbDelegate.getDirectoryPath())
        
        setupViews()
        addTimer()
    }
    
    func setupViews() {
        
        do {
            scrollView = UIScrollView(frame: CGRect(x: 0, y: 200, width: kScreenWidth, height: 250))
            scrollView.delegate = self
            view.addSubview(scrollView)
        }
        
        do {
            pageView = UIPageControl(frame: CGRect(x: 0, y: kScreenHeight - 30, width: kScreenWidth, height: 30))
            view.addSubview(pageView)
            pageView.numberOfPages = getPathArray.count
            pageView.currentPage = 0
            //pageView.pageIndicatorTintColor = UIColor.white
            //pageView.currentPageIndicatorTintColor = UIColor.blue
        }
        
        do {
            /// 只使用3个UIImageView，依次设置好最后一个，第一个，第二个图片，这里面使用取模运算。
            
            
            for index in 0..<getPathArray.count {
                
                if getFileExt(path: getPathArray[index]) == "mp4"{
                    var player: AVPlayer?
                    let playerLayer = AVPlayerViewController()
                    player = AVPlayer(url: URL(string: getPathArray[index])!))
                    playerLayer.player = player
                    playerLayer.view.frame = CGRect(x: CGFloat(index) * kScreenWidth, y: 0, width: kScreenWidth, height: 250)
                    player?.pause()
                    linkPlayer[index] = player
                    
                    scrollView.addSubview(playerLayer.view)
                    playerLayer.didMove(toParentViewController: self)
                }else{
                    
                    let imageView = UIImageView(frame: CGRect(x: CGFloat(index) * kScreenWidth, y: 0, width: kScreenWidth, height: 250))
                    
                    let url = URL(string: getPathArray[index])
                    if let data = try? Data(contentsOf: url!)
                    {
                        let image: UIImage = UIImage(data: data)!
                        
                        imageView.image = image
                        
                        scrollView.addSubview(imageView)
                    }
                    
                }
            }
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
        if pageView.currentPage == getPathArray.count - 1 {
            pageView.currentPage = 0
            
            let contentOffset = CGPoint(x: 0, y: 0)
            scrollView.setContentOffset(contentOffset, animated: true)
            
            if type(of: scrollView.subviews[pageView.currentPage]) != type(of: UIImageView()){
                
                linkPlayer[pageView.currentPage]?.play()
                removeTimer()
                
                //NotificationCenter.default.addObserver(self, selector: Selector(("playerDidFinishPlaying:")),name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: linkPlayer[pageView.currentPage]?.currentItem)
                
                NotificationCenter.default.addObserver(self, selector:#selector(playerDidFinishPlaying(note:)),name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: linkPlayer[pageView.currentPage]?.currentItem)
                
                linkPlayer[pageView.currentPage]?.seek(to: kCMTimeZero)
            } else {
                addTimer()
            }
            
            
        } else {
            pageView.currentPage += 1
            
            let getPage = CGFloat(pageView.currentPage)
            
            let contentOffset = CGPoint(x: kScreenWidth * getPage, y: 0)
            scrollView.setContentOffset(contentOffset, animated: true)
            
            if type(of: scrollView.subviews[pageView.currentPage]) != type(of: UIImageView()){
                
                linkPlayer[pageView.currentPage]?.play()
                removeTimer()
                
                NotificationCenter.default.addObserver(self, selector:#selector(playerDidFinishPlaying(note:)),name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: linkPlayer[pageView.currentPage]?.currentItem)
            }else {
                addTimer()
                
                
            }
        }
    }
    
    @objc func playerDidFinishPlaying(note: NSNotification) {
        print("Video Finished")
        
        NotificationCenter.default.removeObserver(self)
        
        linkPlayer[pageView.currentPage]?.seek(to: kCMTimeZero)
        linkPlayer[pageView.currentPage]?.pause()
        nextImage()
    }
    /// 上一个图片
    /*
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
     */
}

//時間轉秒器
func parseDuration(timeString: String) -> TimeInterval {
    guard !timeString.isEmpty else {
        return 0
    }
    
    var interval:Double = 0
    
    let parts = timeString.components(separatedBy: ":")
    for (index, part) in parts.reversed().enumerated() {
        interval += (Double(part) ?? 0) * pow(Double(60), Double(index))
    }
    
    return interval
}

func getFileExt(path: String) -> String{
    
    let filename: NSString = path as NSString
    let pathExtention = filename.pathExtension
    //let pathPrefix = filename.deletingPathExtension
    
    return pathExtention
}

extension BannerUseScrollViewController: UIScrollViewDelegate {
    
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
