//
//  CanvasViewController.swift
//  
//
//  Created by Hassan Karaouni on 4/30/15.
//
//

import UIKit

class CanvasViewController: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var trayView: UIView!
    @IBOutlet weak var trayArrow: UIImageView!
    
    var trayOriginalCenter: CGPoint!    
    var openPosition: CGFloat!
    var closedPosition: CGFloat!
    var newlyCreatedFace: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        openPosition = trayView.center.y
        closedPosition = trayView.center.y + trayView.frame.size.height - 40
        println(closedPosition)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func dragFace(sender: UIPanGestureRecognizer) {
        if (sender.state == .Began) {
            var imageView = sender.view as! UIImageView
            newlyCreatedFace = UIImageView(image: imageView.image)
            view.addSubview(newlyCreatedFace)
            newlyCreatedFace.center = imageView.center
            newlyCreatedFace.center.y += trayView.frame.origin.y
            
            newlyCreatedFace.userInteractionEnabled = true
            
            // add pan gesture
            let panRecognizer = UIPanGestureRecognizer(target: self, action: "panFace:")
            newlyCreatedFace.addGestureRecognizer(panRecognizer)
            
            let pinchRecognizer = UIPinchGestureRecognizer(target: self, action: "pinchFace:")
            newlyCreatedFace.addGestureRecognizer(pinchRecognizer)
            
            pinchRecognizer.delegate = self
            
            let rotateRecognizer = UIRotationGestureRecognizer(target: self, action: "rotateFace:")
            newlyCreatedFace.addGestureRecognizer(rotateRecognizer)
            
            let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: "doubleTap:")
            doubleTapRecognizer.numberOfTapsRequired = 2
            newlyCreatedFace.addGestureRecognizer(doubleTapRecognizer)
            
            
        } else if (sender.state == .Changed) {
            
            newlyCreatedFace.center = CGPoint(x: newlyCreatedFace.center.x + sender.translationInView(self.view).x, y: newlyCreatedFace.center.y + sender.translationInView(self.view).y)
            
            sender.setTranslation(CGPointZero, inView: self.view)
        } else if (sender.state == .Ended) {
            if let senderView = sender.view {
                println("yo")
                // we were configuring bottom based off of "senderView" before but that is wrong because
                // senderView is the image of the smily in the tray, not the image which we just created
                // that's why we changed "senderView" to "newlyCreatedFace"
                // TLDR had the right logic but referenced by the wrong face
                var bottom = CGPoint(x: newlyCreatedFace.center.x, y: newlyCreatedFace.center.y + newlyCreatedFace.frame.height/2)
                if (trayView.frame.contains(bottom)){
                    println("entered")
                    newlyCreatedFace.hidden = true
                }
            }
        }
    }
    
    func doubleTap(sender: UITapGestureRecognizer) {
        if let view = sender.view {
            view.removeFromSuperview()
        }
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func rotateFace(sender: UIRotationGestureRecognizer) {
        if let view = sender.view {
            view.transform = CGAffineTransformRotate(view.transform, sender.rotation)
            sender.rotation = 0
        }
    }
    
    func panFace(sender: UIPanGestureRecognizer) {
        if (sender.state == .Began) {
            var faceView = sender.view as! UIImageView
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                faceView.transform = CGAffineTransformScale(faceView.transform, 1.25, 1.25)
            })
        } else if (sender.state == .Changed) {
            newlyCreatedFace.center = CGPoint(x: newlyCreatedFace.center.x + sender.translationInView(self.view).x, y: newlyCreatedFace.center.y + sender.translationInView(self.view).y)
            sender.setTranslation(CGPointZero, inView: self.view)
        } else if (sender.state == .Ended) {
            var faceView = sender.view as! UIImageView
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                faceView.transform = CGAffineTransformScale(faceView.transform, 0.8, 0.8)
            })
            if (faceView.center.y > (openPosition - trayView.frame.size.height/2.0)) {
                println("inside")
                faceView.removeFromSuperview()
            }
        }
    }
    
    func pinchFace(sender: UIPinchGestureRecognizer) {
        if let view = sender.view {
            view.transform = CGAffineTransformScale(view.transform, sender.scale, sender.scale)
            sender.scale = 1.0
        }
    }
    
    @IBAction func onTrayPanGesture(sender: UIPanGestureRecognizer) {
        //trayOriginalCenter = sender.locationInView(trayView)
        if (sender.state == .Ended) {
            var velocity = sender.velocityInView(view)
            if (velocity.y > 0) {
                // animate down
                UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: nil, animations: { () -> Void in
                    // write animation
                    self.trayView.center.y = self.closedPosition
                    self.trayArrow.transform = CGAffineTransformRotate(self.trayArrow.transform, CGFloat(M_PI))
                    
                    }, completion: { (success: Bool) -> Void in
                    println("finished animate down!")
                })
            } else if (velocity.y < 0){
                // animate up
                UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: nil, animations: { () -> Void in
                    // write animation
                    self.trayView.center.y = self.openPosition
                    self.trayArrow.transform = CGAffineTransformRotate(self.trayArrow.transform, CGFloat(M_PI))

                    }, completion: { (success: Bool) -> Void in
                        println("finished animation up")
                })
            }
        } else if(sender.state == .Changed) {
            if (trayView.center.y < openPosition || trayView.center.y > closedPosition) {
                // friction was ez.
                trayOriginalCenter = trayView.center
                trayView.center = CGPoint(x: trayOriginalCenter.x, y: trayOriginalCenter.y + sender.translationInView(trayView).y/10.0)
                sender.setTranslation(CGPointZero, inView: self.view)
            } else {
                trayOriginalCenter = trayView.center
                trayView.center = CGPoint(x: trayOriginalCenter.x, y: trayOriginalCenter.y + sender.translationInView(trayView).y)
                sender.setTranslation(CGPointZero, inView: self.view)
            }
        }
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
