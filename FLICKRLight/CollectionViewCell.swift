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
    weak var cache  : PhotoCache?

    var url: NSURL? {
        
        didSet {
            
            if let cachedImage = cache?.imageForURL( url! ) {
                setImage( cachedImage, contentMode: .ScaleAspectFill )
            } else {
                
                if let placeholder = UIImage( named: "reload_placeholder_24" ) {
                    setImage( placeholder, contentMode: .Center )
                }
            
                cache?.updateImage( url! ) { image in
                    dispatch_async( dispatch_get_main_queue() ) {
                        if let readyImage = image  {
                            self.setImage( readyImage, contentMode: .ScaleAspectFill )
                        }
                    }
                }
            }
        }
    }
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        imageView = UIImageView(frame: self.contentView.bounds)
        
        contentView.addSubview(imageView)
        
        clipsToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - internal methods
    
    private func setImage( image: UIImage, contentMode: UIViewContentMode ){
        self.imageView.contentMode = contentMode
        self.imageView.image = image
    }
    

}
