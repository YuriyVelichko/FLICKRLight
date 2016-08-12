//
//  SearchViewController.swift
//  FLICKRLight
//
//  Created by Yuriy Velichko on 8/10/16.
//  Copyright © 2016 Yuriy Velichko. All rights reserved.
//

import UIKit
import SVProgressHUD

class SearchViewController: UIViewController, UISearchBarDelegate {
    
    // MARK: - properties

    @IBOutlet weak var collectionView: UICollectionView!
    
    var collectionController = CollectionViewController()
    
    private var lastSearchedText = ""
    
    // MARK: - initializer
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionController.topController = self
        
        collectionView.delegate = collectionController
        collectionView.dataSource = collectionController
        
        CollectionViewController.registerCell( collectionView )
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UIViewController (proxy for internal controller)
    
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        
        collectionController.willRotateToInterfaceOrientation(toInterfaceOrientation, duration: duration)
    }
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        
        collectionController.didRotateFromInterfaceOrientation(fromInterfaceOrientation)
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
        
        collectionController.searchResult = SearchHandler( options: options )
        collectionController.uploadInfo( collectionView )
    }
    
    // MARK: - Naviagion (proxy for internal controller)
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        collectionController.prepareForSegue(segue, sender: collectionView)
    }
    
    func performSegue() {
        
        performSegueWithIdentifier( "showDetail", sender:self )
    }
}
