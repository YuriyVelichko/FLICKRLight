//
//  DetailViewController.swift
//  FLICKRLight
//
//  Created by Yuriy Velichko on 8/10/16.
//  Copyright © 2016 Yuriy Velichko. All rights reserved.
//

import UIKit
import SVProgressHUD

class DetailViewController: UIViewController, UIGestureRecognizerDelegate {
    
    // MARK: - properties
    
    @IBOutlet weak var imageView: UIImageView!
    
    weak var cache  : PhotoCache?
    var url         : NSURL?
    
    // transform properties
    private var scale               = CGFloat(1)
    private var previousScale       = CGFloat(1)
    private var rotation            = CGFloat(0)
    private var previousRotation    = CGFloat(0)

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if let dataURL = self.url {
            
            SVProgressHUD.showWithStatus( "Fetching Image..." )
            
            cache?.updateImage( dataURL ) {
                self.imageView.image = self.cache?.photoForURL(dataURL)
            }
        } else {
            showAlertInMainQueue( "There datasource URL is empty" )
        }
        
        // Gesture recognizers
        
        imageView.userInteractionEnabled = true
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(doPinch) )
        pinchGesture.delegate = self
        imageView.addGestureRecognizer(pinchGesture)
        
        let rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(doRotate) )
        rotationGesture.delegate = self
        imageView.addGestureRecognizer(rotationGesture)
        
        let panGestureRecognizer = UIPanGestureRecognizer(target:self, action:#selector(panGestureDetected) )
        panGestureRecognizer.delegate = self
        imageView.addGestureRecognizer(panGestureRecognizer)
        
        let doubleTouchRecognizer = UITapGestureRecognizer( target:self, action:#selector(doubleTouchDetected))
        doubleTouchRecognizer.delegate = self
        doubleTouchRecognizer.numberOfTapsRequired = 2
        imageView.addGestureRecognizer( doubleTouchRecognizer )

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func gestureRecognizer( gestureRecognizer: UIGestureRecognizer,
                            shouldRecognizeSimultaneouslyWithGestureRecognizer
                            otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func transformImageView() {
        var transorm = CGAffineTransformMakeScale(scale * previousScale, scale * previousScale)
        transorm = CGAffineTransformRotate(transorm, rotation + previousRotation)
        imageView.transform = transorm
    }
    
    func doPinch(gesture:UIPinchGestureRecognizer) {
        
        scale = gesture.scale
        transformImageView()
        
        if gesture.state == .Ended {
            previousScale = scale * previousScale
            scale = 1
        }
    }
    
    func doRotate(gesture:UIRotationGestureRecognizer) {
        
        rotation = gesture.rotation
        transformImageView()
        
        if gesture.state == .Ended {
            previousRotation = rotation + previousRotation
            rotation = 0
        }
    }
    
    var originalCenter = CGPoint()

    func panGestureDetected( gesture : UIPanGestureRecognizer )
    {
        if previousScale <= 1 {
            return
        }
        
        if (gesture.state == .Began) {
            originalCenter = gesture.view!.center;
        } else if (gesture.state == .Changed) {
            let translate = gesture.translationInView(gesture.view)
            gesture.view!.center = CGPointMake(originalCenter.x + translate.x + 10, originalCenter.y + translate.y + 10 );
        }
    }

    func doubleTouchDetected( gesture : UIPanGestureRecognizer )
    {
        UIView.animateWithDuration(0.3, animations: {
            
            self.scale               = CGFloat(1)
            self.previousScale       = CGFloat(1)
            self.rotation            = CGFloat(0)
            self.previousRotation    = CGFloat(0)

            gesture.view!.center = self.view.center
            self.imageView.transform = CGAffineTransformIdentity
        })
    }
}
