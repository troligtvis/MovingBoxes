//
//  ViewController.swift
//  MovingBoxes
//
//  Created by Kj Drougge on 2014-12-07.
//  Copyright (c) 2014 kj. All rights reserved.
//

import UIKit
import CoreMotion

class ViewController: UIViewController {
    
    var box: UIView?
    let boxSize: CGFloat = 30.0
    var boxes: [UIView]! = []
    
    var maxY: CGFloat = 320
    var maxX: CGFloat = 320

    var animator: UIDynamicAnimator? = nil
    let gravity = UIGravityBehavior()
    let collider = UICollisionBehavior()
    let itemBehavior = UIDynamicItemBehavior()
    
    let startPoint = CGPointMake(50, 50)
    var prevBox = UIView()
    
    // For getting devide motion updates
    let motionQueue = NSOperationQueue()
    let motionManager = CMMotionManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        maxY = super.view.bounds.size.width - boxSize
        maxX = super.view.bounds.size.width - boxSize
        
        createAnimatorStuff()
        generateBoxes()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        println("Starting gravity")
        motionManager.startDeviceMotionUpdatesToQueue(motionQueue, withHandler: gravityUpdated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewDidAppear(animated)
        println("Stopping gravity")
        motionManager.stopDeviceMotionUpdates()
    }
    
    func randomColor() -> UIColor{
        let red = CGFloat(CGFloat(arc4random()%100000)/100000)
        let green = CGFloat(CGFloat(arc4random()%100000)/100000)
        let blue = CGFloat(CGFloat(arc4random()%1000000)/100000)
        
        return UIColor(red: red, green: green, blue: blue, alpha: 0.85)
    }
    
    func doesNotCollide(testRect: CGRect) -> Bool{
        for box: UIView in boxes{
            var viewRect = box.frame
            if CGRectIntersectsRect(testRect, viewRect){
                return false
            }
        }
        return true
    }
    
    func randomFrame() -> CGRect{
        var guess = CGRectMake(9, 9, 9, 9)
        
        do{
            let guessX = CGFloat(arc4random()) % maxX
            let guessY = CGFloat(arc4random()) % maxY
            guess = CGRectMake(guessX, guessY, boxSize, boxSize)
        } while !doesNotCollide(guess)
        
        return guess
    }
    
    func addBox(location: CGRect, color: UIColor) -> UIView{
        let newBox = UIView(frame: location)
        newBox.backgroundColor = color
        
        view.addSubview(newBox)
        addBoxToBehavior(newBox)
        boxes.append(newBox)
        return newBox
    }
    
    func generateBoxes(){
        for i in 0...9{
            var frame = randomFrame()
            var color = randomColor()
            var newBox = addBox(frame, color: color)
            chainBoxes(newBox)
        }
    }
    
    func chainBoxes(box: UIView){
        if prevBox.frame.origin.x == 0{
            let attach = UIAttachmentBehavior(item: box, attachedToAnchor: startPoint)
            attach.length = 61
            attach.damping = 0.5
            animator?.addBehavior(attach)
            prevBox = box
        }
    }
    
    func createAnimatorStuff(){
        animator = UIDynamicAnimator(referenceView: self.view)
        
        gravity.gravityDirection = CGVectorMake(0, 0.8)
        animator?.addBehavior(gravity)
        
        // Bouncing off the walls
        collider.translatesReferenceBoundsIntoBoundary = true
        animator?.addBehavior(collider)
        
        itemBehavior.friction = 0.2
        itemBehavior.elasticity = 0.6
        
        animator?.addBehavior(itemBehavior)
    }
    
    func addBoxToBehavior(box: UIView){
        gravity.addItem(box)
        collider.addItem(box)
        itemBehavior.addItem(box)
    }
    
    func gravityUpdated(motion: CMDeviceMotion!, error: NSError!){
        let grav: CMAcceleration = motion.gravity
        
        let x = CGFloat(grav.x)
        let y = CGFloat(grav.y)
        var p = CGPointMake(x, y)
        
        if (error != nil) {
            println("\(error)")
        }
        
        var orientation = UIApplication.sharedApplication().statusBarOrientation
        
        if orientation == UIInterfaceOrientation.LandscapeLeft{
            var t = p.x
            p.x = 0 - p.y
            p.y = t
        } else if orientation == UIInterfaceOrientation.LandscapeRight{
            var t = p.x
            p.x = p.y
            p.y = 0 - t
        } else if orientation == UIInterfaceOrientation.PortraitUpsideDown{
            p.x *= -1
            p.y *= -1
        }
        
        var v = CGVectorMake(p.x, 0 - p.y)
        gravity.gravityDirection = v
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

