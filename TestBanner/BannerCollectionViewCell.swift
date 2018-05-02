//
//  BannerCollectionViewCell.swift
//  TestBanner
//
//  Created by 田腾飞 on 2016/12/22.
//  Copyright © 2016年 田腾飞. All rights reserved.
//

import UIKit

class BannerCollectionViewCell: UICollectionViewCell {
    var imageName: String? {
        didSet {
            guard let imageName = imageName else {
                return
            }
            let image = UIImage(named: imageName)
            imageView.image = image
        }
    }
    var imageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView = UIImageView(frame: self.bounds)
        contentView.addSubview(imageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
