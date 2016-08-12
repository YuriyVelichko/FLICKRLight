//
//  SearchViewController.swift
//  FLICKRLight
//
//  Created by Yuriy Velichko on 8/10/16.
//  Copyright © 2016 Yuriy Velichko. All rights reserved.
//

import UIKit
import SVProgressHUD

private let reuseIdentifier = "photoCell"
private let cellSpacing : CGFloat = CGFloat( 5 )

class SearchViewController: UIViewController, UISearchBarDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var collectionController = FlickrSearchCollectionViewController()
    
    private var lastSearchedText = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionController.topController = self
        
        collectionView.delegate = collectionController
        collectionView.dataSource = collectionController
        
        FlickrSearchCollectionViewController.registerCell( collectionView )
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UIViewController
    
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
        
        collectionController.searchResult = FlickrSearchHandler( options: options )
        collectionController.uploadInfo( collectionView )
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        
        collectionController.prepareForSegue(segue, sender: collectionView)
    }
    
    func performSegue() {
        
        performSegueWithIdentifier( "showDetail", sender:self )
    }


    
}
