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
    
    private let flickrKey       = "1ad60cb73a4eba6311c161ecad292a0b"
    private let flickrSecret    = "20b65be7d58394e9"
    
    private var lastLoadedData  = -1
    private let chunkSize       = 100
    private var lastPage        = 0
    
    var imagesInfo      : [[NSURL : NSData]] = []
    var searchOptions   : [String : String]

    // MARK - initializers
    
    init( options: [String : String] ){
        
        var finalOptions = options
        finalOptions[ "api_key" ] = flickrKey
        finalOptions[ "page" ] = String( lastPage + 1 )
        finalOptions[ "per_page"] = String( chunkSize )
        
        searchOptions = finalOptions
        
        let fk = FlickrKit.sharedFlickrKit()
        if fk.apiKey == nil{
            fk.initializeWithAPIKey( flickrKey, sharedSecret: flickrSecret )
        }
    }
    
    // MARK - methods
    func uploadInfo( completion: (NSError!) -> Void) {
        
        let fk = FlickrKit.sharedFlickrKit()
        
        NSLog( searchOptions.description )
        
        fk.call(    "flickr.photos.search",
                    args: searchOptions
                    , maxCacheAge: FKDUMaxAgeOneHour ) {
                    (response, error) -> Void in
                    
                    if error == nil
                    {
                        if (response != nil) {
                            // Pull out the photo urls from the results
                            let topPhotos = response["photos"] as! [NSObject: AnyObject]
                            
                            if let page = topPhotos["page"] {
                                self.lastPage = page as! Int
                            }
                            
                            let photoArray = topPhotos["photo"] as! [[NSObject: AnyObject]]
                            for photoDictionary in photoArray {
                                let photoURL = FlickrKit.sharedFlickrKit().photoURLForSize(FKPhotoSizeSmall240, fromPhotoDictionary: photoDictionary)
                                
                                self.imagesInfo.append([ photoURL : NSData() ])
                            }
                            
                            self.uploadData();
                        }
                    }
                        
                    completion( error )
        }
    }
    
    func uploadData() {
        
        let maxIndex = imagesInfo.count - lastLoadedData > 30 ? lastLoadedData + 30 : imagesInfo.count - 1
        
        if lastLoadedData < maxIndex {
            for index in (lastLoadedData + 1) ... maxIndex {
                let pair = imagesInfo[ index ]
                let URL = pair.keys.first
                imagesInfo[ index ].removeAll()
                imagesInfo[ index ][ URL! ] = NSData(contentsOfURL: (pair.keys.first)! )!
                
                NSLog( "%ld -> %ld", index, maxIndex )
            }
            
            lastLoadedData = maxIndex
        } else {
            // Wait until new urls will be loaded
            NSLog( "%ld", maxIndex )
        }
    }
    
    func needUploadData( currentIndex : Int ) -> Bool {
        return lastLoadedData - currentIndex < 50
    }
    
    func dataAtIndex( index : Int ) -> NSData? {
        if index < imagesInfo.count {
            let pair = imagesInfo[ index ]
            return pair.values.first
        }
        
        return nil
    }
    
}

