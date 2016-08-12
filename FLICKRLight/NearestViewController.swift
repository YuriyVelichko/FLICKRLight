//
//  NearestViewController.swift
//  FLICKRLight
//
//  Created by Yuriy Velichko on 8/10/16.
//  Copyright © 2016 Yuriy Velichko. All rights reserved.
//

import UIKit
import CoreLocation
import SVProgressHUD

private let reuseIdentifier = "photoCell"
private let cellSpacing : CGFloat = CGFloat( 5 )

class NearestViewController: CollectionViewController, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Ask for Authorisation from the User.
        locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.distanceFilter = 100.0;
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: Internal Methods
    
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        let lat = String( locValue.latitude )
        let lon = String( locValue.longitude )
        
        let options = [ "lat"       : lat,
                        "lon"       : lon,
                        "radius"    : "1" ];
        
        if self.navigationController?.tabBarController?.selectedIndex == 0 {
            SVProgressHUD.showWithStatus( String( format: "Fetching data for location [Latitude: %@ Longitude: %@]", lat, lon ) )
        }

        searchResult = SearchHandler( options: options )
        
        dispatch_after( dispatch_time(DISPATCH_TIME_NOW,
                        Int64(1.5 * Double(NSEC_PER_SEC))),
                        dispatch_get_main_queue()) {
            self.uploadInfo( self.collectionView! )
        }
    }

}
