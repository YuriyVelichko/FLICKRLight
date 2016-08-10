//
//  FlickrSearchHandler.swift
//  FLICKRLight
//
//  Created by Yuriy Velichko on 8/10/16.
//  Copyright © 2016 Yuriy Velichko. All rights reserved.
//

import Foundation
import FlickrKit

class FlickrSearchHandler {
    
    // MARK: - properties
    
    private let flickrKey = "1ad60cb73a4eba6311c161ecad292a0b"
    private let flickrSecret = "20b65be7d58394e9"
    
    var imagesURLS      : [NSURL]?
    var searchOptions   : [String : String]
    
    let chunkSize       = 100
    private(set) var lastPage        = 0
    private(set) var totalPages      = 0
    
    let searchRadiusKM  = 1

    // MARK - initializers
    
    init( options: [String : String] ){
        
        var finalOptions = options
        finalOptions[ "api_key" ] = flickrKey
        
        searchOptions = finalOptions
        
        let fk = FlickrKit.sharedFlickrKit()
        if fk.apiKey == nil{
            fk.initializeWithAPIKey( flickrKey, sharedSecret: flickrSecret )
        }
    }
    
    // MARK - methods
    func updateData( completion: (NSError!) -> Void) {
        
        let fk = FlickrKit.sharedFlickrKit()
        
        NSLog( searchOptions.description )
        
        fk.call(    "flickr.photos.search",
                    args: searchOptions
                    , maxCacheAge: FKDUMaxAgeOneHour ) {
                    (response, error) -> Void in
                    
                    if( error != nil )
                    {
                        completion( error )
                        return;
                    }
                    
                    if (response != nil) {
                        // Pull out the photo urls from the results
                        let topPhotos = response["photos"] as! [NSObject: AnyObject]
                        let photoArray = topPhotos["photo"] as! [[NSObject: AnyObject]]
                        for photoDictionary in photoArray {
                            let photoURL = FlickrKit.sharedFlickrKit().photoURLForSize(FKPhotoSizeSmall240, fromPhotoDictionary: photoDictionary)
                            NSLog( photoURL.absoluteString )
                            
                            if self.imagesURLS == nil{
                                self.imagesURLS = []
                            }
                            
                            self.imagesURLS?.append( photoURL )
                        }
                    }
        }
    }
    
}

