//
//  CollectionViewCell.swift
//  FLICKRLight
//
//  Created by Yuriy Velichko on 8/10/16.
//  Copyright © 2016 Yuriy Velichko. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    
    var imageView   : UIImageView!
    weak var cache  : ImagesCache?

    var url: NSURL? {
        
        didSet {
            cache?.updateImage( url! ) { image in
                dispatch_async( dispatch_get_main_queue() ) {
                    self.imageView.image = image
                }
            }
        }
    }
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        imageView = UIImageView(frame: self.contentView.bounds)
        imageView.contentMode = .ScaleAspectFill
        
        contentView.addSubview(imageView)
        
        clipsToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - internal methods

}
