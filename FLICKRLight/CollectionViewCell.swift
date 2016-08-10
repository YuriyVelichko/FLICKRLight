//
//  CollectionViewCell.swift
//  FLICKRLight
//
//  Created by Yuriy Velichko on 8/10/16.
//  Copyright © 2016 Yuriy Velichko. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    
    var imageView: UIImageView!
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        imageView = UIImageView(frame: self.contentView.bounds)
        imageView.opaque = false
        
        contentView.addSubview(imageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
