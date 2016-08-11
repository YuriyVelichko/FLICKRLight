//
//  NearestViewController.swift
//  FLICKRLight
//
//  Created by Yuriy Velichko on 8/10/16.
//  Copyright © 2016 Yuriy Velichko. All rights reserved.
//

import UIKit

private let reuseIdentifier = "photoCell"
private let cellSpacing : CGFloat = CGFloat( 5 )

class NearestViewController: FlickrSearchCollectionViewController {
    
    convenience init(){
        self.init()
        
        initSearchResult()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init( coder: aDecoder )
        
        initSearchResult()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        uploadInfo()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: Internal Methods
    
    func initSearchResult() {
        let options = createRequestParams()
        searchResult = FlickrSearchHandler( options: options )
    }
    
    func createRequestParams() -> [String : String]! {
        var res : [String : String] = [:]
        
        res[ "lat" ] = "46.6354";
        res[ "lon" ] = "32.6169";
        res[ "radius" ] = "5";
        
        return res;
    }

}
