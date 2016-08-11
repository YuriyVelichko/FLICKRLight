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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        
        registerCell()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func collectionView( collectionView: UICollectionView,
                                   didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        performSegueWithIdentifier( "showDetail", sender:self )
    }
    
    // MARK: - UIScrollViewDelegate
    
    override func scrollViewDidScroll( _: UIScrollView) {
        
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

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        
        if  let detailView = segue.destinationViewController as? DetailViewController,
            let indexPath = collectionView?.indexPathsForSelectedItems()?.first {
            
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
        
        let screenSize  = UIScreen.mainScreen().bounds
        let cellSize    = ( screenSize.width - CGFloat( cellSpacing * 2 ) ) / 3
        
        return CGSize( width: cellSize, height: cellSize )
    }
    
    // MARK: Internal Methods
    
    func registerCell() {
        collectionView!.registerClass( CollectionViewCell.self,
                                       forCellWithReuseIdentifier: reuseIdentifier)
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
