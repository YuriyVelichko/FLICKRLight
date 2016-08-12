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
}

class SearchHandler {
    
    // MARK: - properties
    
    private let flickrKey           = "1ad60cb73a4eba6311c161ecad292a0b"
    private let flickrSecret        = "20b65be7d58394e9"
    
    private var lastPage            = 0
    private let photosPerPage       = 100

    private var loadingComplete     = false
    private var updatingInfo        = false
    
    var imagesInfo      : [SearchResult] = []
    var searchOptions   : [String : String]

    // MARK - initializers
    
    init( options: [String : String] ){
        
        searchOptions = options
        searchOptions[ "api_key" ] = flickrKey
        searchOptions[ "per_page"] = String( photosPerPage )
        
        let fk = FlickrKit.sharedFlickrKit()
        if fk.apiKey == nil{
            fk.initializeWithAPIKey( flickrKey, sharedSecret: flickrSecret )
        }
    }
    
    // MARK - methods
    
    func downloadInfo( completion: (NSError!) -> Void ) {
        
        if loadingComplete || updatingInfo {
            return
        }
        
        updatingInfo = true;
        
        searchOptions[ "page" ] = String( lastPage + 1 )
        // NSLog( searchOptions.description )
        
        let fk = FlickrKit.sharedFlickrKit()
        fk.call( "flickr.photos.search", args: searchOptions, maxCacheAge: FKDUMaxAgeOneHour )
        { (response, error) -> Void in
                    
            if error == nil
            {
                if (response != nil) {
                    // Pull out the photo urls from the results
                    let topPhotos = response["photos"] as! [NSObject: AnyObject]
                    
                    if let page = topPhotos["page"] {
                        
                        // NSLog( "TOTAL: %@ PAGES: %ld", topPhotos["total"] as! String, topPhotos["pages"] as? Int ?? 0)
                        
                        let pageValue = page as! Int;
                        let pages = topPhotos["pages"] as? Int ?? 0
                        
                        if pageValue == pages {
                            self.loadingComplete = true
                        } else {
                            self.lastPage = pageValue
                        }
                    }
                    
                    let photoArray = topPhotos["photo"] as! [[NSObject: AnyObject]]
                    for photoDictionary in photoArray {
                        
                        var searchResult = SearchResult()
                        searchResult.urlCollection  = FlickrKit.sharedFlickrKit().photoURLForSize(FKPhotoSizeSmall240, fromPhotoDictionary: photoDictionary)
                        searchResult.urlOrigin      = FlickrKit.sharedFlickrKit().photoURLForSize(FKPhotoSizeMedium800, fromPhotoDictionary: photoDictionary)
                        
                        self.imagesInfo.append( searchResult )
                    }
                    
                    completion( nil )
                    
                    dispatch_async( dispatch_get_main_queue() ) {
                        self.updatingInfo = false
                    }
                }
            } else {
                completion( error )
            }
        }
    }
    
    func needdownloadInfo( currentIndex : Int ) -> Bool {
        
        return !loadingComplete && imagesInfo.count - currentIndex < ( photosPerPage / 2 )
    }
}

