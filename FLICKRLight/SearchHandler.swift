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

class SearchHandler {
    
    // MARK: - properties
    
    private let flickrKey           = "1ad60cb73a4eba6311c161ecad292a0b"
    private let flickrSecret        = "20b65be7d58394e9"
    
    private var lastLoadedData      = -1
    private var lastPage            = 0
    private let chunkSize           = 200

    private let updateImagesBound   : Int
    private var loadingComplete     = false
    private var updatingData        = false
    private var updatingInfo        = false
    
    var imagesInfo      : [SearchResult] = []
    var searchOptions   : [String : String]

    // MARK - initializers
    
    init( options: [String : String] ){
        
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            updateImagesBound = 60
        } else {
            updateImagesBound = 30
        }
        
        searchOptions = options
        searchOptions[ "api_key" ] = flickrKey
        searchOptions[ "per_page"] = String( chunkSize )
        
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
                    
                    dispatch_async( dispatch_get_main_queue() ) {
                        self.updatingInfo = false
                    }
                    
                    self.downloadData(){
                        completion( error )
                    };
                }
            } else {
                completion( error )
            }
        }
    }
    
    func downloadData( completion: (() -> Void)? ) {
        
        if updatingData {
            return
        }
        
        updatingData = true
        
        dispatch_async( dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0 ) ) {
        
            // Need to upload a little bunch of photos, not all required
            
            let maxIndex = (    self.imagesInfo.count - self.lastLoadedData > self.updateImagesBound ) ?
                                self.lastLoadedData + self.updateImagesBound :
                                self.imagesInfo.count - 1
            
            if self.lastLoadedData < maxIndex {
                for index in (self.lastLoadedData + 1) ... maxIndex {
                    
                    if let url = self.imagesInfo[ index ].urlCollection {
                        self.imagesInfo[ index ].dataCollection = NSData(contentsOfURL: url )
                    } else {
                        
                        self.imagesInfo[ index ].dataCollection = UIImagePNGRepresentation( UIImage(named: "green-square-Retina")! )
                    }
                    
                    // NSLog( "%ld -> %ld", index, maxIndex )
                }
                
                self.lastLoadedData = maxIndex
            } else {
                // Wait until new urls will be loaded
            }
            
            dispatch_async( dispatch_get_main_queue() ) {
                self.updatingData = false
            }

            if let callback = completion {
                callback()
            }
        }
    }
    
    func needdownloadData( currentIndex : Int ) -> Bool {
        return !updatingData && lastLoadedData - currentIndex < updateImagesBound
    }
    
    func needdownloadInfo( currentIndex : Int ) -> Bool {
        
        return !loadingComplete && imagesInfo.count - currentIndex < ( chunkSize / 2 )
    }
    
    func dataAtIndex( index : Int ) -> NSData? {
        if index < imagesInfo.count {
            return imagesInfo[ index ].dataCollection
        }
        
        return nil
    }
}

