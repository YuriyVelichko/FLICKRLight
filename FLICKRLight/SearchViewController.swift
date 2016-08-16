//
//  SearchViewController.swift
//  FLICKRLight
//
//  Created by Yuriy Velichko on 8/10/16.
//  Copyright © 2016 Yuriy Velichko. All rights reserved.
//

import UIKit
import SVProgressHUD

class SearchViewController: CollectionViewController, UISearchBarDelegate {
    
    // MARK: - properties
    
    private var searchBar           : UISearchBar?
    private var lastSearchedText    = ""
    
    // MARK: - initializer
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        addSearchBar()
        navigationItem.titleView = searchBar
    }
    
    // MARK: - UISearchBarDelegate
    
    func searchBarSearchButtonClicked( theSearchBar : UISearchBar ) {
        
        theSearchBar.resignFirstResponder()

        let text = theSearchBar.text ?? ""
        
        if text == lastSearchedText {
            return
        }
        
        lastSearchedText = text
        
        SVProgressHUD.showWithStatus( "Searching..." )
        
        let options = [ "text" : text ]
        
        photoListLoader = PhotoListLoader( options: options )
        
        dispatch_after( dispatch_time(DISPATCH_TIME_NOW,
            Int64(1.5 * Double(NSEC_PER_SEC))),
                        dispatch_get_main_queue()) {
                            
            self.downloadInfo()
        }        
    }
    
    // MARK: - internal methods
    
    private func addSearchBar(){
        if searchBar == nil{
            
            searchBar = UISearchBar()
            searchBar!.sizeToFit()
            searchBar!.searchBarStyle       = UISearchBarStyle.Minimal
            searchBar!.tintColor            = UIColor.whiteColor()
            searchBar!.barTintColor         = UIColor.whiteColor()
            searchBar!.delegate             = self;
            searchBar!.placeholder          = "Type text to start searching";
        }
    }
}
