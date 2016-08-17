//
//  PhotoLoader.swift
//  FLICKRLight
//
//  Created by Yuriy Velichko on 8/10/16.
//  Copyright © 2016 Yuriy Velichko. All rights reserved.
//

import Foundation
import FlickrKit

class PhotoListLoader {
    
    private struct State : OptionSetType {
        let rawValue: Int
        
        static let Complete = State(rawValue: 0)
        static let Updating = State(rawValue: 1 << 0)
    }
    
    // MARK: - properties
    
    private let flickrKey           = "1ad60cb73a4eba6311c161ecad292a0b"
    private let flickrSecret        = "20b65be7d58394e9"
    
    private var lastPage            = 0
    private let photosPerPage       = 400

    private var state               : [State] = [];
    
    var photosInfo                  : [PhotoInfo] = []
    var searchOptions               : [String : String]

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
        
        if state.contains( .Complete ) || state.contains( .Updating ) {
            return
        }
        
        state.append( .Updating )
        
        searchOptions[ "page" ] = String( lastPage + 1 )
        // debugPrint( searchOptions.description )
        
        let fk = FlickrKit.sharedFlickrKit()
        fk.call( "flickr.photos.search", args: searchOptions, maxCacheAge: FKDUMaxAgeOneHour )
        { (response, error) -> Void in
                    
            if error == nil
            {
                if (response != nil) {
                    // Pull out the photo urls from the results
                    let topPhotos = response["photos"] as! [NSObject: AnyObject]
                    
                    if let page = topPhotos["page"] {
                        
                        // debugPrint( "TOTAL: \(topPhotos["total"] as! String) PAGES: \( topPhotos["pages"] as? Int ?? 0 )")

                        let pageValue = page as! Int;
                        let pages = topPhotos["pages"] as? Int ?? 0
                        
                        if pageValue == pages {
                            dispatch_async( dispatch_get_main_queue() ) {
                                self.state.append( .Complete )
                            }
                        } else {
                            self.lastPage = pageValue
                        }
                    }
                    
                    let photoArray = topPhotos["photo"] as! [[NSObject: AnyObject]]
                    for photoDictionary in photoArray {
                        
                        var searchResult = PhotoInfo()
                        searchResult.urlCollection  = FlickrKit.sharedFlickrKit().photoURLForSize(FKPhotoSizeSmall240, fromPhotoDictionary: photoDictionary)
                        searchResult.urlOrigin      = FlickrKit.sharedFlickrKit().photoURLForSize(FKPhotoSizeMedium800, fromPhotoDictionary: photoDictionary)
                        
                        self.photosInfo.append( searchResult )
                    }
                }
            }
            
            dispatch_async( dispatch_get_main_queue() ) {
                if let index = self.state.indexOf( .Updating ) {
                    self.state.removeAtIndex( index )
                }
            }
            
            completion( nil )
        }
    }
    
    func needDownloadInfo( currentIndex : Int ) -> Bool {
        return !state.contains( .Complete ) && photosInfo.count - currentIndex < ( photosPerPage / 2 )
    }
}

