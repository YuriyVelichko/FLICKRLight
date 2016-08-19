//
//  App.swift
//  FLICKRLight
//
//  Created by Yuriy Velichko on 8/19/16.
//  Copyright © 2016 Yuriy Velichko. All rights reserved.
//

import Foundation
import UIKit

class App {
    
    private let storyboard              = UIStoryboard(name: "Main", bundle: nil)
    private let detailViewController    : DetailViewController
    
    init(window: UIWindow) {
    
        detailViewController = storyboard.instantiateViewControllerWithIdentifier("Detail") as! DetailViewController
        
        let tabController = window.rootViewController as! UITabBarController
        
        assignDidSelectForNaviagationController( tabController.viewControllers?[0] as! UINavigationController )
        assignDidSelectForNaviagationController( tabController.viewControllers?[1] as! UINavigationController )
    }
    
    private func assignDidSelectForNaviagationController( navigationController: UINavigationController ) {
        
        let collectionController = navigationController.viewControllers[0] as! CollectionViewController
        
        collectionController.didSelect = { imageUpdater in
            
            navigationController.pushViewController(self.detailViewController, animated: true)
            imageUpdater( self.detailViewController.showImage )
        }
    }
}