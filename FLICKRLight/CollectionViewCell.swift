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
    
    var url: NSURL? {
        
        didSet {
            
            let cache = ImagesCache.sharedCache
            
            cache.updateImage( url! ) { image in
                dispatch_async( dispatch_get_main_queue() ) {
                    self.imageView.image = image
                }
            }
        }
    }
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        imageView = UIImageView(frame: self.contentView.bounds)
        imageView.opaque = false
        
        contentView.addSubview(imageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - internal methods

}
