//
//  PhotoCache.swift
//  FLICKRLight
//
//  Created by Yuriy Velichko on 8/12/16.
//  Copyright © 2016 Yuriy Velichko. All rights reserved.
//

import Foundation
import AlamofireImage

class PhotoCache {
    
    private let downloader  : ImageDownloader
    private let cache       : AutoPurgingImageCache

    
    // MARK: - initializer
    
    init()
    {
        cache = AutoPurgingImageCache(
            memoryCapacity: 100 * 1024 * 1024,
            preferredMemoryUsageAfterPurge: 60 * 1024 * 1024
        )
        
        downloader = ImageDownloader(
            configuration: ImageDownloader.defaultURLSessionConfiguration(),
            downloadPrioritization: .FIFO,
            maximumActiveDownloads: 4,
            imageCache: cache
        )
    }
    
    // MARK: - methods
    
    func updateImage( url: NSURL, completion: (image : UIImage?) -> Void )
    {
        let URLRequest = NSURLRequest( URL: url )
        
        if let cachedImage = imageForURL( url ) {
            completion( image: cachedImage )
        } else {
            
            downloader.downloadImage(URLRequest: URLRequest ) { response in
                
                if let image = response.result.value {
                    completion( image: image )
                }
            }
        }
    }
    
    func imageForURL( url: NSURL ) -> UIImage? {
        
        let URLRequest = NSURLRequest( URL: url )
        return cache.imageForRequest( URLRequest, withAdditionalIdentifier: "image" )
    }
    
    func clearCache() {
        cache.removeAllImages()
    }
}