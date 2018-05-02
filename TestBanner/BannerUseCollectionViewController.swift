//
//  BannerUseCollectionViewController.swift
//  TestBanner
//
//  Created by tiantengfei on 2016/12/22.
//  Copyright © 2016年 田腾飞. All rights reserved.
//

import UIKit

class BannerUseCollectionViewController: UIViewController {

    let images = ["0.png", "1.png", "2.png", "3.png"]
    var collectionView: UICollectionView!
    var pageView: UIPageControl!
    var timer: Timer?
    var currentIndexPath: IndexPath?
    var oldOffset: CGFloat = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    func setupViews() {
        automaticallyAdjustsScrollViewInsets = false
        
        do {
            let flowLayout = UICollectionViewFlowLayout()
            flowLayout.minimumLineSpacing = 0
            flowLayout.minimumInteritemSpacing = 0
            flowLayout.scrollDirection = .horizontal
            flowLayout.itemSize = CGSize(width: kScreenWidth, height: kScreenHeight)
            flowLayout.estimatedItemSize = CGSize(width: kScreenWidth, height: kScreenHeight)
            
            collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight), collectionViewLayout: flowLayout)
            collectionView.register(BannerCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
            view.addSubview(collectionView)
            collectionView.delegate = self
            collectionView.dataSource = self
            collectionView.isPagingEnabled = true
            collectionView.showsHorizontalScrollIndicator = false
            
            //从中间显示
            let indexPath = IndexPath(item: images.count, section: 0)
            currentIndexPath = indexPath
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
        
        do {
            pageView = UIPageControl(frame: CGRect(x: 0, y: kScreenHeight - 30, width: kScreenWidth, height: 30))
            view.addSubview(pageView)
            pageView.numberOfPages = images.count
            pageView.currentPage = 0
            pageView.pageIndicatorTintColor = UIColor.white
            pageView.currentPageIndicatorTintColor = UIColor.blue
        }
    }
    
    /// 添加timer
    func addTimer() {
        timer = Timer(timeInterval: 2, repeats: true, block: { [weak self] _ in
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
        if pageView.currentPage == images.count - 1 {
            pageView.currentPage = 0
        } else {
            pageView.currentPage += 1
        }
        
        guard let currentIndexPath = currentIndexPath else {
            return
        }
        let newIndexPath = IndexPath(item: currentIndexPath.item + 1, section: 0)
        self.currentIndexPath = newIndexPath
        collectionView.scrollToItem(at: newIndexPath, at: .centeredHorizontally, animated: true)
    }
    
    func preImage() {
        if pageView.currentPage == 0 {
            pageView.currentPage = images.count - 1
        } else {
            pageView.currentPage -= 1
        }
        
        guard let currentIndexPath = currentIndexPath else {
            return
        }
        let newIndexPath = IndexPath(item: currentIndexPath.item - 1, section: 0)
        self.currentIndexPath = newIndexPath
        collectionView.scrollToItem(at: newIndexPath, at: .centeredHorizontally, animated: true)
    }
    
    func reloadImage() {
        guard let currentIndexPath = currentIndexPath else {
            return
        }
        if currentIndexPath.item == images.count * 2 - 1 {  //如果是最后一个图片，回到第一部分的最后一张图片
            let newIndexPath = IndexPath(item: images.count - 1, section: 0)
            self.currentIndexPath = newIndexPath
            collectionView.scrollToItem(at: newIndexPath, at: .centeredHorizontally, animated: false)
        } else if currentIndexPath.item == 0 {  //如果是第一个图片，就回到第二部分的第一张图片
            let newIndexPath = IndexPath(item: images.count, section: 0)
            self.currentIndexPath = newIndexPath
            collectionView.scrollToItem(at: newIndexPath, at: .centeredHorizontally, animated: false)
        }
    }
}

extension BannerUseCollectionViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count * 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? BannerCollectionViewCell
        
        if let cell = cell {
            cell.imageName = images[indexPath.item % 4]
            return cell
        }
        
        return cell!
    }
}

extension BannerUseCollectionViewController: UICollectionViewDelegate {
    
}

extension BannerUseCollectionViewController: UIScrollViewDelegate {
    
    /// 开始滑动的时候，停止timer，设置为niltimer才会销毁
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        removeTimer()
        oldOffset = scrollView.contentOffset.x
    }
    
    /// 当停止滚动的时候重新设置三个ImageView的内容，然后悄悄滴显示中间那个imageView
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        reloadImage()
    }
    
    /// 停止拖拽，开始timer, 并且判断是显示上一个图片还是下一个图片
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        addTimer()
        
        if scrollView.contentOffset.x < oldOffset {
            preImage()
        } else {
            nextImage()
        }
    }
    
}
