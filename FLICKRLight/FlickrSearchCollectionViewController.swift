//
//  FlickrSearchCollectionViewController.swift
//  FLICKRLight
//
//  Created by Yuriy Velichko on 8/11/16.
//  Copyright © 2016 Yuriy Velichko. All rights reserved.
//

import UIKit

private let reuseIdentifier = "photoCell"
private let cellSpacing : CGFloat = CGFloat( 5 )

class FlickrSearchCollectionViewController: UICollectionViewController {

    var searchResult : FlickrSearchHandler?
    
    weak var topCotroller : SearchViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        
        FlickrSearchCollectionViewController.registerCell( collectionView! )
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func collectionView(   collectionView: UICollectionView,
                                    didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        if let ctr = topCotroller {
            ctr.performSegue()
        } else {
            performSegueWithIdentifier( "showDetail", sender:collectionView )
        }
    }
    
    // MARK: - UIScrollViewDelegate
    
    override func scrollViewDidScroll( scrollView : UIScrollView) {
        
        if  let collectionView = scrollView as? UICollectionView,
            let lastVisiableCell = collectionView.visibleCells().last {
            let indexPath = collectionView.indexPathForCell( lastVisiableCell )
            
            if searchResult?.needUploadInfo( (indexPath?.row)! ) ?? false {
                uploadInfo( collectionView )
            } else {
                if searchResult?.needUploadData((indexPath?.row)!) ?? false {
                    uploadData( collectionView )
                }
            }            
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        
        if  let detailView = segue.destinationViewController as? DetailViewController,
            let collectionView = sender as? UICollectionView {
            
            if let indexPath = collectionView.indexPathsForSelectedItems()?.first{
                detailView.data = searchResult?.dataAtIndex(indexPath.row) ?? NSData()
            }
        }
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return searchResult?.imagesInfo.count ?? 0
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! CollectionViewCell
    
        // Configure the cell
  
        if let data = searchResult?.dataAtIndex( indexPath.row ) {
            cell.imageView.image = UIImage( data: data )
        }
    
        return cell
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
        
        let screenSize      = UIScreen.mainScreen().bounds
        let portraitWidth   = min( screenSize.width, screenSize.height )
        let cellSize        = ( portraitWidth - CGFloat( cellSpacing * 2 ) ) / 3
        
        return CGSize( width: cellSize, height: cellSize )
    }
    
    // MARK: Internal Methods
    
    static func registerCell( collectionView : UICollectionView! ) {
        collectionView.registerClass(  CollectionViewCell.self,
                                       forCellWithReuseIdentifier: reuseIdentifier)
    }
    
    func uploadInfo( collectionView : UICollectionView ){
        searchResult?.uploadInfo() { error in
            
            dispatch_async( dispatch_get_main_queue() ) {
                if error != nil {
                    NSLog( error.localizedDescription )
                }                
                
                collectionView.reloadData()
            }
        }
    }
    
    func uploadData( collectionView : UICollectionView ){
        
        self.searchResult?.uploadData() {
        
            dispatch_async( dispatch_get_main_queue() ) {
                collectionView.reloadData()
            }
            
        }
    }
}
