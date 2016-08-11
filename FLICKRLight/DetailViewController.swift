//
//  DetailViewController.swift
//  FLICKRLight
//
//  Created by Yuriy Velichko on 8/10/16.
//  Copyright © 2016 Yuriy Velichko. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    
    private var scale               = CGFloat(1)
    private var previousScale       = CGFloat(1)
    private var rotation            = CGFloat(0)
    private var previousRotation    = CGFloat(0)
    
    var data : NSData?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if let internalData = data {
            imageView.image = UIImage( data: internalData )
        }
        
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
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
