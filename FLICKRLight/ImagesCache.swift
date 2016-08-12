//
//  ImagesCache.swift
//  FLICKRLight
//
//  Created by Yuriy Velichko on 8/12/16.
//  Copyright © 2016 Yuriy Velichko. All rights reserved.
//

import Foundation
import AlamofireImage


class ImagesCache {
    
    static let sharedCache = ImagesCache()
    
    let downloader = ImageDownloader()
    let imageCache : AutoPurgingImageCache

    
    // MARK: - initializer
    
    init()
    {
        imageCache = AutoPurgingImageCache(
            memoryCapacity: 100 * 1024 * 1024,
            preferredMemoryUsageAfterPurge: 60 * 1024 * 1024
        )
    }
    
    func updateImage( url : NSURL, completion: (image : UIImage?) -> Void )
    {
        let URLRequest = NSURLRequest( URL: url )
        
        if let cachedImage = imageCache.imageForRequest( URLRequest, withAdditionalIdentifier: "image" ) {
            NSLog( "FROM: CACHE")
            completion( image: cachedImage )
        } else {
            
            NSLog( "FROM: INET")
            downloader.downloadImage(URLRequest: URLRequest ) { response in
                
                if let image = response.result.value {
                    
                    self.imageCache.addImage(
                        image,
                        forRequest: URLRequest,
                        withAdditionalIdentifier: "image"
                    )
                    
                    completion( image: image )
                }
            }
        }
    }
}