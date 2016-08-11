//
//  SearchViewController.swift
//  FLICKRLight
//
//  Created by Yuriy Velichko on 8/10/16.
//  Copyright © 2016 Yuriy Velichko. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UISearchBarDelegate {
    
     var searchResult : FlickrSearchHandler?

    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - UISearchBarDelegate
    
    
    func searchBarSearchButtonClicked( theSearchBar : UISearchBar ) {
        theSearchBar.resignFirstResponder()
        
        let options = [ "text" : theSearchBar.text! ]
        searchResult = FlickrSearchHandler( options: options )
        searchResult?.uploadInfo(){ error in
            
            dispatch_async( dispatch_get_main_queue() ) {
                if error != nil {
                    NSLog( error.localizedDescription )
                }
                
                self.collectionView?.reloadData()
            }
        }

    }
}
