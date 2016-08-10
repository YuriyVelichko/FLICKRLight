//
//  NearestViewController.swift
//  FLICKRLight
//
//  Created by Yuriy Velichko on 8/10/16.
//  Copyright © 2016 Yuriy Velichko. All rights reserved.
//

import UIKit

private let reuseIdentifier = "photoCell"
private let cellSpacing : CGFloat = CGFloat( 5 )

class NearestViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var searchResult : FlickrSearchHandler?
    
    convenience init(){
        self.init()
        
        initSearchResult()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init( coder: aDecoder )
        
        initSearchResult()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        
        collectionView!.registerClass(CollectionViewCell.self,
                                      forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
        
        uploadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func collectionView( collectionView: UICollectionView,
                                   didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        performSegueWithIdentifier( "showDetail", sender:self )
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

        return searchResult?.imagesURLS?.count ?? 0
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! CollectionViewCell
    
        // Configure the cell
  
        let imageData =  NSData(contentsOfURL: (searchResult?.imagesURLS?[indexPath.row])!)
        cell.imageView.image = UIImage( data: imageData!);
        
        NSLog( "%ld", indexPath.row );
    
        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */
    
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
    
    func initSearchResult() {
        let options = createRequestParams()
        searchResult = FlickrSearchHandler( options: options )
    }
    
    func uploadData(){
        searchResult?.updateData() { error in
            
            dispatch_async( dispatch_get_main_queue() ) {
                if error != nil {
                    NSLog( error.localizedDescription )
                }
                
                self.collectionView?.reloadData()
            }
        }
    }
    
    func createRequestParams() -> [String : String]! {
        var res : [String : String] = [:]
        
        res[ "lat" ] = "46.6354";
        res[ "lon" ] = "32.6169";
        res[ "radius" ] = "5";
        
        return res;
    }

}
