//
//  SearchViewController.swift
//  FLICKRLight
//
//  Created by Yuriy Velichko on 8/10/16.
//  Copyright © 2016 Yuriy Velichko. All rights reserved.
//

import UIKit

private let reuseIdentifier = "photoCell"
private let cellSpacing : CGFloat = CGFloat( 5 )

class SearchViewController: UIViewController, UISearchBarDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
    
     var searchResult : FlickrSearchHandler?

    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Register cell classes
        
        collectionView!.registerClass( CollectionViewCell.self,
                                       forCellWithReuseIdentifier: reuseIdentifier)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: UICollectionViewDataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return searchResult?.imagesInfo.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! CollectionViewCell
        
        // Configure the cell
        
        if let data = searchResult?.dataAtIndex( indexPath.row ) {
            cell.imageView.image = UIImage( data: data )
        }
        
        return cell
    }
    
    // MARK: - UIScrollViewDelegate
    
    func scrollViewDidScroll( _: UIScrollView) {
        
        if let lastVisiableCell = collectionView?.visibleCells().last {
            let indexPath = collectionView?.indexPathForCell( lastVisiableCell )
            
            if searchResult?.needUploadInfo( (indexPath?.row)! ) ?? false {
                uploadInfo()
            } else {
                if searchResult?.needUploadData((indexPath?.row)!) ?? false {
                    uploadData()
                }
            }
        }
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
    
    // MARK: UICollectionViewDelegateFlowLayout API
    
    func collectionView( collectionView: UICollectionView,
                         layout collectionViewLayout: UICollectionViewLayout,
                                minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return cellSpacing
    }
    
    func collectionView( collectionView: UICollectionView,
                         layout collectionViewLayout: UICollectionViewLayout,
                                minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return cellSpacing
    }
    
    func collectionView(collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        // Show 3 cells in the portrait orientation
        
        let screenSize  = UIScreen.mainScreen().bounds
        let cellSize    = ( screenSize.width - CGFloat( cellSpacing * 2 ) ) / 3
        
        return CGSize( width: cellSize, height: cellSize )
    }
    
    func uploadInfo(){
        searchResult?.uploadInfo() { error in
            
            dispatch_async( dispatch_get_main_queue() ) {
                if error != nil {
                    NSLog( error.localizedDescription )
                }
                
                self.collectionView?.reloadData()
            }
        }
    }
    
    func uploadData(){
        
        dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) ) {
            
            self.searchResult?.uploadData()
            
            dispatch_async( dispatch_get_main_queue() ) {
                self.collectionView?.reloadData()
            }
        }
    }
}
