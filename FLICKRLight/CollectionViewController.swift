//
//  FlickrSearchCollectionViewController.swift
//  FLICKRLight
//
//  Created by Yuriy Velichko on 8/11/16.
//  Copyright © 2016 Yuriy Velichko. All rights reserved.
//

import UIKit
import SVProgressHUD

private let reuseIdentifier = "photoCell"
private let cellSpacing     = CGFloat( 5 )

class CollectionViewController: UICollectionViewController {
    
    // MARK: - properties

    var photoListLoader : PhotoListLoader? {
        didSet {
            photoCache.clearCache()
        }
    }
    
    private var visibleCells    : [NSIndexPath] = []
    
    private let photoCache     = PhotoCache()

    
    // MARK: - UIView
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Register cell classes
        
        CollectionViewController.registerCell( collectionView! )
    }

    // MARK: - UICollectionViewController
    
    override func viewWillTransitionToSize( size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator)
    {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        
        visibleCells = collectionView?.indexPathsForVisibleItems() ?? []
        
        coordinator.animateAlongsideTransition(nil) { _ in
            
            if !self.visibleCells.isEmpty {
                self.collectionView?.scrollToItemAtIndexPath( self.visibleCells[0], atScrollPosition: UICollectionViewScrollPosition.Top, animated: false)
            }
        }
    }
    
    override func collectionView(   collectionView: UICollectionView,
                                    didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        performSegueWithIdentifier( "showDetail", sender:collectionView )
    }
    
    // MARK: - UIScrollViewDelegate
    
    override func scrollViewDidScroll( scrollView : UIScrollView) {
        
        if  let collectionView = scrollView as? UICollectionView,
            let lastVisibleCell = collectionView.visibleCells().last {
            
            let indexPath = collectionView.indexPathForCell( lastVisibleCell )
            
            if photoListLoader?.needDownloadInfo( (indexPath?.row)! ) ?? false {
                downloadInfo()
            }
        }
    }

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if  let detailView = segue.destinationViewController as? DetailViewController,
            let collectionView = sender as? UICollectionView {
            
            if let indexPath = collectionView.indexPathsForSelectedItems()?.first{
                
                if detailView.cache == nil {
                    detailView.cache = photoCache
                }
                
                detailView.url = photoListLoader?.photosInfo[indexPath.row].urlOrigin
            }
        }
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {

        return 1
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return photoListLoader?.photosInfo.count ?? 0
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! CollectionViewCell
    
        // Configure the cell
        
        if cell.cache == nil {
            cell.cache = photoCache
        }
        
        cell.url = photoListLoader?.photosInfo[ indexPath.row ].urlCollection

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
        
        // Show 3 cells for iPhone and 5 cells for iPad in the portrait orientation
        
        let screenSize      = UIScreen.mainScreen().bounds
        let portraitWidth   = min( screenSize.width, screenSize.height )
        
        var perRow : CGFloat = 3
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            perRow = 5
        }
        
        let cellSize = ( ( portraitWidth - CGFloat( cellSpacing * CGFloat( perRow - 1 ) ) ) / perRow )
        
        return CGSize( width: cellSize, height: cellSize )
    }
    
    // MARK: - methods
    
    static func registerCell( collectionView : UICollectionView! ) {
        collectionView.registerClass(  CollectionViewCell.self,
                                       forCellWithReuseIdentifier: reuseIdentifier)
    }
    
    func downloadInfo(){
        photoListLoader?.downloadInfo() { error in
            
            dispatch_async( dispatch_get_main_queue() ) {
                
                SVProgressHUD.dismiss()
                self.collectionView?.reloadData()
                
                if error != nil {
                    self.showAlertInMainQueue( error.localizedDescription )
                }
            }
        }
    }
}
