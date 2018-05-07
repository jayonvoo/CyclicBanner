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
    
    var fixedTimer: Int?
    var getTimeCountDown: Int?
    var scrollView: UIScrollView!
    var pageView: UIPageControl!
    var timer: Timer?
    var countDown: Timer?
    var dbDelegate = DatabaseController()
    var getPathArray = [String]()
    var getTimeAuth: String?
    var linkPlayer = [Int : AVPlayer]()
    
    override func viewDidLoad() {
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.resigningActive),
            name: NSNotification.Name.UIApplicationWillResignActive,
            object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.becomeActive),
            name: NSNotification.Name.UIApplicationDidBecomeActive,
            object: nil)
        
        super.viewDidLoad()
        
        dbDelegate.viewDidLoad()
        
        dbDelegate.insertInitialData(auth: "01:00:00", address: dbDelegate.getWiFiAddress()!, console: "huawei", cycle_time: 10)
        getPathArray = dbDelegate.getDBValue_address(ip_address: dbDelegate.getWiFiAddress()!)
        getTimeAuth = dbDelegate.getDBValue_auth(ip_address: dbDelegate.getWiFiAddress()!)
        showToast(message: "成功連線")
        fixedTimer = parseDuration(timeString: dbDelegate.getDBValue_auth(ip_address: dbDelegate.getWiFiAddress()!))
        getTimeCountDown = fixedTimer
        
        print(dbDelegate.getWiFiAddress()!)
        print(dbDelegate.getDirectoryPath())
        
        setupViews()
        addTimer()
        countDownTimerInit()
        
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
                    player = AVPlayer(url: URL(string: getPathArray[index])!)
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
    
    func countDownTimerInit(){
        countDown = Timer(timeInterval: 1, repeats: true, block: { [weak self] _ in
            self?.countDownTimer()
        })
        
        guard let timer = countDown else {
            return
        }
        RunLoop.current.add(timer, forMode: .commonModes)
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
    
    func countDownTimer(){
        
        getTimeCountDown = getTimeCountDown! - 1
        
        if getTimeCountDown == 0 {
            
            alertAuthTimeIfEnd()
        }
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
    
    
    //時間轉秒器
    func parseDuration(timeString: String) -> Int {
        guard !timeString.isEmpty else {
            return 0
        }
        
        var interval:Double = 0
        
        let parts = timeString.components(separatedBy: ":")
        for (index, part) in parts.reversed().enumerated() {
            interval += (Double(part) ?? 0) * pow(Double(60), Double(index))
        }
        
        print("Interval: \(interval)")
        
        return Int(interval)
    }
    
    //秒轉時間
    func hmsFrom(seconds: Int, completion: @escaping (_ hours: Int, _ minutes: Int, _ seconds: Int)->()) {
        
        completion(seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
        
    }
    func getStringFrom(seconds: Int) -> String {
        
        return seconds < 10 ? "0\(seconds)" : "\(seconds)"
    }
    
    func getFileExt(path: String) -> String{
        
        let filename: NSString = path as NSString
        let pathExtention = filename.pathExtension
        //let pathPrefix = filename.deletingPathExtension
        
        return pathExtention
    }
    
    func alertAuthTimeIfEnd(){
        
        let alertController = UIAlertController(title: "期限提醒", message: "請問是否想續約, 否則關閉程式", preferredStyle: UIAlertControllerStyle.alert)
        
        let OkAction = UIAlertAction(title: "是", style: .default) { (action: UIAlertAction!) in
            
            self.getTimeCountDown = self.fixedTimer
        }
        alertController.addAction(OkAction)
        
        let cancelAction = UIAlertAction(title: "否", style: .cancel) { (action:UIAlertAction!) in
            
            exit(0)
        }
        alertController.addAction(cancelAction)
        
        // Present Dialog message
        present(alertController, animated: true, completion:nil)
        
    }
    
    
    @objc fileprivate func resigningActive() {
        print("== resigningActive ==")
        
        hmsFrom(seconds: getTimeCountDown!) { hours, minutes, seconds in
            
            let hours = self.getStringFrom(seconds: hours)
            let minutes = self.getStringFrom(seconds: minutes)
            let seconds = self.getStringFrom(seconds: seconds)
            
            self.dbDelegate.updateDBTable(timeFormat: "\(hours):\(minutes):\(seconds)", address: self.dbDelegate.getWiFiAddress()!)
        }
    }
    
    @objc fileprivate func becomeActive() {
        print("== becomeActive ==")
        linkPlayer[pageView.currentPage]?.play()
    }
    
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
        UIView.animate(withDuration: 1, delay: 5, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
}
