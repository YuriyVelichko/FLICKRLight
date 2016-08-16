//
//  FlickrSearchCollectionViewController.swift
//  FLICKRLight
//
//  Created by Yuriy Velichko on 8/11/16.
//  Copyright © 2016 Yuriy Velichko. All rights reserved.
//

import UIKit
import SVProgressHUD
import AlamofireImage

private let reuseIdentifier = "photoCell"
private let cellSpacing     = CGFloat( 5 )

class CollectionViewController: UICollectionViewController {
    
    // MARK: - properties

    var photoListLoader : PhotoListLoader? {
        didSet {
            photoCache?.removeAllImages()
        }
    }
    
    private var visibleCells    : [NSIndexPath] = []
    
    private var photoCache      : AutoPurgingImageCache?
    private var downloader      : ImageDownloader?
    
    // MARK: - UIView
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView?.registerClass(  CollectionViewCell.self,
                                        forCellWithReuseIdentifier: reuseIdentifier)
        
        
        photoCache = AutoPurgingImageCache(
            memoryCapacity: 100 * 1024 * 1024,
            preferredMemoryUsageAfterPurge: 60 * 1024 * 1024
        )
        
        downloader = ImageDownloader(
            configuration: ImageDownloader.defaultURLSessionConfiguration(),
            downloadPrioritization: .FIFO,
            maximumActiveDownloads: 4,
            imageCache: photoCache
        )
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
        
        if  let detailView      = segue.destinationViewController as? DetailViewController,
            let collectionView  = sender as? UICollectionView,
            let indexPath       = collectionView.indexPathsForSelectedItems()?.first,
            let url             = photoListLoader?.photosInfo[ indexPath.row ].urlOrigin,
            let cache           = photoCache {
            
            if let cachedImage = cache.imageForRequest( NSURLRequest( URL: url ) ) {
                detailView.image = cachedImage
            } else {
                downloadPhoto( url ) { image in
                    dispatch_async( dispatch_get_main_queue() ) {
                        if let readyImage = image  {
                            detailView.image = readyImage
                        }
                    }
                }
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
        
        if  let url     = photoListLoader?.photosInfo[ indexPath.row ].urlCollection,
            let cache   = photoCache {
            
            if let cachedImage = cache.imageForRequest( NSURLRequest( URL: url ) ) {
                cell.setImage( cachedImage, contentMode: .ScaleAspectFill )
            } else {
                
                if let placeholder = UIImage( named: "reload_placeholder_24" ) {
                    cell.setImage( placeholder, contentMode: .Center )
                }
                
                downloadPhoto( url ) { image in
                    dispatch_async( dispatch_get_main_queue() ) {
                        if let readyImage = image  {
                            if collectionView.indexPathsForVisibleItems().contains( indexPath ) {
                                cell.setImage( readyImage, contentMode: .ScaleAspectFill )
                            }
                        }
                    }
                }
            }
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
    
    private func downloadPhoto( url: NSURL, completion: (image : UIImage?) -> Void )
    {
        let URLRequest = NSURLRequest( URL: url )
        
        downloader?.downloadImage(URLRequest: URLRequest ) { response in
            if let image = response.result.value {
                completion( image: image )
            }
        }
    }
}
