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

    var searchResult            : SearchHandler?
    weak var topController      : SearchViewController?
    private var visibleCells    : [NSIndexPath] = []
    
    // MARK: - UIView
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        
        CollectionViewController.registerCell( collectionView! )
    }

    // MARK: - UICollectionViewController
    
    override func viewWillTransitionToSize( size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator)
    {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        
        visibleCells = managedCollectionView()?.indexPathsForVisibleItems() ?? []
        
        coordinator.animateAlongsideTransition(nil) { _ in
            
            if !self.visibleCells.isEmpty {
                self.managedCollectionView()?.scrollToItemAtIndexPath( self.visibleCells[0], atScrollPosition: UICollectionViewScrollPosition.Top, animated: false)
            }
        }
    }
    
    override func collectionView(   collectionView: UICollectionView,
                                    didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        if let ctr = topController {
            ctr.performSegue()
        } else {
            performSegueWithIdentifier( "showDetail", sender:collectionView )
        }
    }
    
    // MARK: - UIScrollViewDelegate
    
    override func scrollViewDidScroll( scrollView : UIScrollView) {
        
        if  let collectionView = scrollView as? UICollectionView,
            let lastVisibleCell = collectionView.visibleCells().last {
            
            let indexPath = collectionView.indexPathForCell( lastVisibleCell )
            
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

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if  let detailView = segue.destinationViewController as? DetailViewController,
            let collectionView = sender as? UICollectionView {
            
            if let indexPath = collectionView.indexPathsForSelectedItems()?.first{
                detailView.url = searchResult?.imagesInfo[indexPath.row].urlOrigin
            }
        }
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {

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
    
    func uploadInfo( collectionView : UICollectionView ){
        searchResult?.uploadInfo() { error in
            
            dispatch_async( dispatch_get_main_queue() ) {
                
                if error != nil {
                    NSLog( error.localizedDescription )
                }                
                
                SVProgressHUD.dismiss()
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
    
    // MARK: - internal methods
    
    private func managedCollectionView() -> UICollectionView? {
        
        var res : UICollectionView?
        
        if let topCtr = topController{
            res = topCtr.collectionView
        } else {
            res = collectionView
        }
        
        return res
    }
}
