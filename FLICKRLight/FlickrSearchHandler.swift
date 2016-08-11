//
//  FlickrSearchHandler.swift
//  FLICKRLight
//
//  Created by Yuriy Velichko on 8/10/16.
//  Copyright © 2016 Yuriy Velichko. All rights reserved.
//

import Foundation
import FlickrKit

struct SearchResult {
    
    var urlCollection   : NSURL?
    var urlOrigin       : NSURL?
    
    var dataCollection  : NSData?
}

class FlickrSearchHandler {
    
    // MARK: - properties
    
    private let flickrKey       = "1ad60cb73a4eba6311c161ecad292a0b"
    private let flickrSecret    = "20b65be7d58394e9"
    
    private var lastLoadedData  = -1
    private let chunkSize       = 100
    private var lastPage        = 0
    
    private var loadingCompleete = false
    private var updatingData    = false
    
    var imagesInfo      : [SearchResult] = []
    var searchOptions   : [String : String]

    // MARK - initializers
    
    init( options: [String : String] ){
        
        searchOptions = options
        searchOptions[ "api_key" ] = flickrKey
        searchOptions[ "per_page"] = String( chunkSize )
        
        let fk = FlickrKit.sharedFlickrKit()
        if fk.apiKey == nil{
            fk.initializeWithAPIKey( flickrKey, sharedSecret: flickrSecret )
        }
    }
    
    // MARK - methods
    func uploadInfo( completion: (NSError!) -> Void) {
        
        if loadingCompleete {
            return
        }
        
        objc_sync_enter( updatingData )
        
        let fk = FlickrKit.sharedFlickrKit()
        
        searchOptions[ "page" ] = String( lastPage + 1 )
        
        NSLog( searchOptions.description )
        
        fk.call( "flickr.photos.search", args: searchOptions, maxCacheAge: FKDUMaxAgeOneHour )
        { (response, error) -> Void in
                    
            if error == nil
            {
                if (response != nil) {
                    // Pull out the photo urls from the results
                    let topPhotos = response["photos"] as! [NSObject: AnyObject]
                    
                    if let page = topPhotos["page"] {
                        
                        let pageValue = page as! Int;
                        
                        let pages = topPhotos["pages"] as? Int ?? 0
                        if pageValue == pages {
                            self.loadingCompleete = true
                        } else {
                            self.lastPage = pageValue
                        }
                    }
                    
                    let photoArray = topPhotos["photo"] as! [[NSObject: AnyObject]]
                    for photoDictionary in photoArray {
                        
                        var searchResult = SearchResult()
                        searchResult.urlCollection  = FlickrKit.sharedFlickrKit().photoURLForSize(FKPhotoSizeSmall240, fromPhotoDictionary: photoDictionary)
                        searchResult.urlOrigin      = FlickrKit.sharedFlickrKit().photoURLForSize(FKPhotoSizeOriginal, fromPhotoDictionary: photoDictionary)
                        
                        self.imagesInfo.append( searchResult )
                    }
                    
                    self.uploadData();
                }
            }
                
            completion( error )
        }
        
        objc_sync_exit( updatingData )
    }
    
    func uploadData() {
        
        if updatingData {
            return
        }
        
        objc_sync_enter( updatingData )
        updatingData = true
        
        let maxIndex = imagesInfo.count - lastLoadedData > 30 ? lastLoadedData + 30 : imagesInfo.count - 1
        
        if lastLoadedData < maxIndex {
            for index in (lastLoadedData + 1) ... maxIndex {
                
                if let url = imagesInfo[ index ].urlCollection {
                    imagesInfo[ index ].dataCollection = NSData(contentsOfURL: url )
                }
                
                NSLog( "%ld -> %ld", index, maxIndex )
            }
            
            lastLoadedData = maxIndex
        } else {
            // Wait until new urls will be loaded
            NSLog( "%ld", maxIndex )
        }
        
        updatingData = false
        objc_sync_exit( updatingData )
    }
    
    func needUploadData( currentIndex : Int ) -> Bool {
        return !updatingData && lastLoadedData - currentIndex < 30
    }
    
    func needUploadInfo( currentIndex : Int ) -> Bool {
        return imagesInfo.count - currentIndex < 30
    }
    
    func dataAtIndex( index : Int ) -> NSData? {
        if index < imagesInfo.count {
            return imagesInfo[ index ].dataCollection
        }
        
        return nil
    }
    
}

