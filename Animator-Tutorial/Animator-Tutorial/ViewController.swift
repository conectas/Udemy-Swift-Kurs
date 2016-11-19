//
//  ViewController.swift
//  Animator-Tutorial
//
//  Created by Benjamin Herzog on 30.07.14.
//  Copyright (c) 2014 Benjamin Herzog. All rights reserved.
//
// [GERMAN] Swift Tutorial #12 - iOS- Animation und CoreMotion
// https://www.youtube.com/watch?v=tC_Kf4Goj9k

import UIKit
import CoreMotion

var MAX_X: CGFloat = 0.0
var MAX_Y: CGFloat = 0.0
let BOX_SIZE: CGFloat = 10.0
let NUMBER_OF_BOXES = 60

class ViewController: UIViewController {
    
    var boxes = [UIView]()
    
    var animator: UIDynamicAnimator?
    let gravity = UIGravityBehavior()
    let collider = UICollisionBehavior()
    let itemBehavior = UIDynamicItemBehavior()
    
    let motionQueue = OperationQueue()
    let motionManager = CMMotionManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        MAX_X = view.bounds.size.width - BOX_SIZE
        MAX_Y = view.bounds.size.height - BOX_SIZE
        
        createAnimator()
        generateBoxes(number: NUMBER_OF_BOXES)
    }
    
    func createAnimator() {
        
        animator = UIDynamicAnimator(referenceView: view)
        gravity.gravityDirection = CGVector(dx: 0, dy: 0.8)
        animator?.addBehavior(gravity)
        
        collider.translatesReferenceBoundsIntoBoundary = true
        animator?.addBehavior(collider)
        
        itemBehavior.friction = 0.4 	// itemBehavior.friction = 0.3		// Widerstand der einzelnen Boxen
        itemBehavior.elasticity = 1.1	// itemBehavior.elasticity = 0.6	// Intensität wie die Boxen wieder auseinander springen
        animator?.addBehavior(itemBehavior)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        motionManager.startDeviceMotionUpdates(to: motionQueue, withHandler: {
            motion,error in
            
            if error != nil {
                print("Error: \(error!.localizedDescription)")
                return
            }
            guard let grav = motion?.gravity else {
                return
            }
            let x = CGFloat(grav.x)
            let y = CGFloat(grav.y)
            var p = CGPoint(x: x, y: y)
            
            let orientation = UIApplication.shared.statusBarOrientation
            
            switch orientation {
            case .landscapeLeft:
                let t = p.x
                p.x = 0 - p.y
                p.y = t
            case .landscapeRight:
                let t = p.x
                p.x = p.y
                p.y = 0 - t
            case .portraitUpsideDown:
                p.x = p.x * -1
            default: break
            }
            
            self.gravity.gravityDirection = CGVector(dx: p.x, dy: 0 - p.y)
        })
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        motionManager.stopDeviceMotionUpdates()
    }
    
    func generateBoxes(number: Int) {
        for _ in 0..<number {
            let newBox = UIView(frame: randomRect())
            newBox.backgroundColor = UIColor.randomColor()
            view.addSubview(newBox)
            gravity.addItem(newBox)
            collider.addItem(newBox)
            itemBehavior.addItem(newBox)
            boxes.append(newBox)
        }
    }
    
    func randomRect() -> CGRect {
        var ret = CGRect(x: 0, y: 0, width: BOX_SIZE, height: BOX_SIZE)
        
        repeat {
            let x = Int(arc4random()) % Int(MAX_X)
            let y = Int(arc4random()) % Int(MAX_Y)
            ret = CGRect(x: CGFloat(x), y: CGFloat(y), width: BOX_SIZE, height: BOX_SIZE)
        } while(!doesNotCollide(rect: ret))
        
        return ret
    }
    
    func doesNotCollide(rect: CGRect) -> Bool {
        for box in boxes {
            if(box.frame.intersects(rect)) {
                return false
            }
        }
        return true
    }
}


extension UIColor {
    
    class func randomColor() -> UIColor {
        let redValue = Float(arc4random() % 255) / 255
        let greenValue = Float(arc4random() % 255) / 255
        let blueValue = Float(arc4random() % 255) / 255
        
        return UIColor(red: CGFloat(redValue), green: CGFloat(greenValue), blue: CGFloat(blueValue), alpha: 1)
    }
}
















