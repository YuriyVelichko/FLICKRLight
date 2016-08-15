//
//  PhotoCache.swift
//  FLICKRLight
//
//  Created by Yuriy Velichko on 8/12/16.
//  Copyright © 2016 Yuriy Velichko. All rights reserved.
//

import Foundation
import AlamofireImage

class DownloadPhotoOperation : NSOperation {
    
    let url                 : NSURL
    weak var downloader     : ImageDownloader?
    let completion          : (() -> Void)?
    
    init( url: NSURL,
          downloader: ImageDownloader,
          completion: () -> Void ) {
    
        self.url = url
        self.downloader = downloader
        self.completion = completion
    }
    
    override func main() {
        
        if cancelled {
            return
        }
        
        let URLRequest = NSURLRequest( URL: url )
        
        downloader?.downloadImage(URLRequest: URLRequest ) { response in
            self.completion?()
        }
    }
}
