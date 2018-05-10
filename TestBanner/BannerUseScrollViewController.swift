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
    
    var databaseIsReject = false
    var getGlobalToast: UILabel?
    var fixedTimer: Int?
    var getTimeCountDown: Int?
    var scrollView: UIScrollView!
    var pageView: UIPageControl!
    var timer: Timer?
    var countDown: Timer?
    var toastTimerCount = 0
    var dbDelegate = DatabaseController()
    var getPathArray = [String]()
    var getTimeAuth: String?
    var linkPlayer = [Int : AVPlayer]()
    var visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
    var blockView = BlockViewController()
    
    @IBOutlet var popUpBoxView: UIView!
    
    override func viewDidLoad() {
        
        visualEffectView.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight)
        popUpBoxView.layer.cornerRadius = 5
        
        ///參數傳遞
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.resigningActive),
            name: NSNotification.Name.UIApplicationWillResignActive,
            object: nil)
        
        ///如⇡
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.becomeActive),
            name: NSNotification.Name.UIApplicationDidBecomeActive,
            object: nil)
        
        ///初始化資料庫
        dbDelegate.viewDidLoad()
        
        ///預設空Table時，插入資料
        dbDelegate.insertInitialData(auth: "01:00:00", address: dbDelegate.getWiFiAddress()!, console: "huawei", cycle_time: 10)
        getPathArray = dbDelegate.getDBValue_address(ip_address: dbDelegate.getWiFiAddress()!)
        getTimeAuth = dbDelegate.getDBValue_auth(ip_address: dbDelegate.getWiFiAddress()!)
        
        fixedTimer = parseDuration(timeString: dbDelegate.getDBValue_auth(ip_address: dbDelegate.getWiFiAddress()!))
        
        
        if fixedTimer != 0{
            
            showToast(message: "成功連線")
            toastTimer()
            databaseIsReject = false
            getTimeCountDown = fixedTimer
            
            print(dbDelegate.getWiFiAddress()!)
            print(dbDelegate.getDirectoryPath())
            
            setupViews()
            addTimer()  ///計時錶開始
            countDownTimerInit()  ///倒數計時
        }else{
            
            //self.navigationController!.pushViewController(blockView, animated: true)
            //showToast(message: "拒絕連線，期限已到")
            //toastTimer()
            databaseIsReject = true
        }
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if fixedTimer == 0{
            performSegue(withIdentifier: "toBlockView", sender: nil)
        }
    }
    
    ///初始化scrollView框架
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
        //scrollView.contentOffset = contentOffset
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
    
    ///暫停累加計時器
    func removeTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    ///暫停倒數計時器
    func removeCountDownTimer() {
        countDown?.invalidate()
        countDown = nil
    }
    
    ///計時器每秒更新
    func countDownTimerInit(){
        countDown = Timer(timeInterval: 1, repeats: true, block: { [weak self] _ in
            self?.countDownTimer()
        })
        
        guard let timer = countDown else {
            return
        }
        RunLoop.current.add(timer, forMode: .commonModes)
    }
    
    func toastTimer(){
        countDown = Timer(timeInterval: 1, repeats: true, block: { [weak self] _ in
            self?.toastTimerCount += 1
            
            if self?.toastTimerCount == 5{
                if self?.getGlobalToast != nil{
                    self?.getGlobalToast?.removeFromSuperview()
                }
            }
            
        })
        
        guard let timer = countDown else {
            return
        }
        RunLoop.current.add(timer, forMode: .commonModes)
    }
    
    /// 下一个图片
    func nextImage() {
        
        if pageView.currentPage == getPathArray.count - 1 {
            pageView.currentPage = 0
            
            let contentOffset = CGPoint(x: 0, y: 0)
            scrollView.setContentOffset(contentOffset, animated: true)
            if type(of: scrollView.subviews[pageView.currentPage]) != type(of: UIImageView()){
                
                linkPlayer[pageView.currentPage]?.play()
                removeTimer()
                
                NotificationCenter.default.addObserver(self, selector:#selector(playerDidFinishPlaying(note:)),name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: linkPlayer[pageView.currentPage]?.currentItem)
                
                linkPlayer[pageView.currentPage]?.seek(to: kCMTimeZero)
            } else if timer == nil{
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
            }else if timer == nil{
                addTimer()
            }
        }
    }
    
    ///偵測影片播放結束
    @objc func playerDidFinishPlaying(note: NSNotification) {
        
        NotificationCenter.default.removeObserver(self)
        
        linkPlayer[pageView.currentPage]?.seek(to: kCMTimeZero)
        linkPlayer[pageView.currentPage]?.pause()
        nextImage()
    }
    
    ///倒數計時
    func countDownTimer(){
        
        if getTimeCountDown! == 0 {
            alertPopEffectView()
            removeCountDownTimer()
        }else {
            getTimeCountDown = getTimeCountDown! - 1
        }
    }
    
    ///時間轉秒器
    func parseDuration(timeString: String) -> Int {
        guard !timeString.isEmpty else {
            return 0
        }
        
        var interval:Double = 0
        
        let parts = timeString.components(separatedBy: ":")
        for (index, part) in parts.reversed().enumerated() {
            interval += (Double(part) ?? 0) * pow(Double(60), Double(index))
        }
        
        return Int(interval)
    }
    
    ///秒轉時間
    func hmsFrom(seconds: Int, completion: @escaping (_ hours: Int, _ minutes: Int, _ seconds: Int)->()) {
        
        completion(seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
        
    }
    func getStringFrom(seconds: Int) -> String {
        
        return seconds < 10 ? "0\(seconds)" : "\(seconds)"
    }
    
    ///取得文件擴展名
    func getFileExt(path: String) -> String{
        
        let filename: NSString = path as NSString
        let pathExtention = filename.pathExtension
        
        return pathExtention
    }
    
    ///ip存取權限警示
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
    
    //模糊和小版面顯示
    func alertPopEffectView(){
        
        view.addSubview(visualEffectView)
        view.addSubview(popUpBoxView)
        popUpBoxView.frame.origin.x += 30
        popUpBoxView.frame.origin.y += 240
        popUpBoxView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        popUpBoxView.alpha = 0
        
        UIView.animate(withDuration: 0.4) {
            self.popUpBoxView.alpha = 1
            self.popUpBoxView.transform = CGAffineTransform.identity
        }
    }
    
    ///程式暫停時存取資料庫
    @objc fileprivate func resigningActive() {
        
        if !databaseIsReject{
            hmsFrom(seconds: getTimeCountDown!) { hours, minutes, seconds in
                
                let hours = self.getStringFrom(seconds: hours)
                let minutes = self.getStringFrom(seconds: minutes)
                let seconds = self.getStringFrom(seconds: seconds)
                
                self.dbDelegate.updateDBTable(timeFormat: "\(hours):\(minutes):\(seconds)", address: self.dbDelegate.getWiFiAddress()!)
            }
        }
    }
    
    ///程式回復，繼續播放影片
    @objc fileprivate func becomeActive() {
        
        if !databaseIsReject{
            linkPlayer[pageView.currentPage]?.play()
        }
        
    }
}

///初始化小訊息
extension BannerUseScrollViewController: UIScrollViewDelegate {
    
    func showToast(message : String) {
        
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height-100, width: 200, height: 35))
        toastLabel.center = view.center
        toastLabel.center.y = 650
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont(name: "Montserrat-Light", size: 12.0)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        
        getGlobalToast = toastLabel
        
    }
}
