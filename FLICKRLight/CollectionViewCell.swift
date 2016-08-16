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
    
    var indicator   : UIActivityIndicatorView?
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        imageView = UIImageView(frame: self.contentView.bounds)
        
        contentView.addSubview(imageView)
        
        indicator = UIActivityIndicatorView( frame: contentView.frame )
        indicator?.activityIndicatorViewStyle = .Gray
        indicator?.hidesWhenStopped = true
        contentView.addSubview( indicator! )
        
        indicator?.startAnimating()
        
        clipsToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - internal methods
    
    func showWaitingIndicator() {
        self.imageView.image = nil
        
        indicator?.hidden = false;
        indicator?.startAnimating()
    }
    
    func setImage( image: UIImage, contentMode: UIViewContentMode ){
        self.imageView.contentMode = contentMode
        self.imageView.image = image
        
        indicator?.stopAnimating()
    }
}
