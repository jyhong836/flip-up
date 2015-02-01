//
//  GameView.swift
//  Flip Up
//
//  Created by Junyuan Hong on 15/2/1.
//  Copyright (c) 2015年 Junyuan Hong. All rights reserved.
//

import SceneKit

class GameView: SCNView {
    
    override func mouseDown(theEvent: NSEvent) {
        /* Called when a mouse click occurs */
        
        // check what nodes are clicked
        let p = self.convertPoint(theEvent.locationInWindow, fromView: nil)
        if let hitResults = self.hitTest(p, options: nil) {
            // check that we clicked on at least one object
            if hitResults.count > 0 {
                // retrieved the first clicked object
                let result: AnyObject = hitResults[0]
                
                // get its material
                let material = result.node!.geometry!.firstMaterial!
                
                // highlight it
                SCNTransaction.begin()
                SCNTransaction.setAnimationDuration(0.5)
                
                // on completion - unhighlight
                SCNTransaction.setCompletionBlock() {
                    SCNTransaction.begin()
                    SCNTransaction.setAnimationDuration(0.5)
                    
                    material.emission.contents = NSColor.blackColor()
                    
                    SCNTransaction.commit()
                }
                
                material.emission.contents = NSColor.redColor()
                
                SCNTransaction.commit()
                
                selectedObj = result.node
            }
        }
        
        super.mouseDown(theEvent)
    }
    
    var selectedObj: SCNNode? = nil
    
    override func keyDown(theEvent: NSEvent) {
        if let theArrow: NSString = theEvent.charactersIgnoringModifiers {
            if theArrow.length == 0 {
                return
            }
            if theArrow.length==1 {
                switch Int(theArrow.characterAtIndex(0)) {
                case NSLeftArrowFunctionKey: // left
                    selectedObj?.physicsBody?.applyForce(SCNVector3Make(-5, 0, 0), atPosition: SCNVector3Zero, impulse: true)
                    break
                case NSRightArrowFunctionKey: // right
                    selectedObj?.physicsBody?.applyForce(SCNVector3Make(5, 0, 0), atPosition: SCNVector3Zero, impulse: true)
                    break
                case NSUpArrowFunctionKey: // up
                    selectedObj?.physicsBody?.applyForce(SCNVector3Make(0, 0, -5), atPosition: SCNVector3Zero, impulse: true)
                    break
                case NSDownArrowFunctionKey: // down
                    selectedObj?.physicsBody?.applyForce(SCNVector3Make(0, 0, 5), atPosition: SCNVector3Zero, impulse: true)
                    break
                case Int(NSString(string: "w").characterAtIndex(0)): // w
                    rotate(SCNVector3Make(1, 0, 0), w: 5)
                    break
                case Int(NSString(string: "a").characterAtIndex(0)): // a
                    rotate(SCNVector3Make(0, 0, 1), w: 5)
                    break
                case Int(NSString(string: "s").characterAtIndex(0)): // s
                    rotate(SCNVector3Make(1, 0, 0), w: -5)
                    break
                case Int(NSString(string: "d").characterAtIndex(0)): // d
                    rotate(SCNVector3Make(0, 0, 1), w: -5)
                    break
                case Int(NSString(string: " ").characterAtIndex(0)):
                    selectedObj?.physicsBody?.applyForce(SCNVector3Make(0, 5, 0), atPosition: SCNVector3Zero, impulse: true)
                    break
                default:break
                }
            }
        }
    }

    func rotate(axis: SCNVector3, w: CGFloat) {
        if let so = selectedObj {
            var v1 = so.presentationNode().convertPosition(axis, toNode: self.scene?.rootNode)
            v1 = SCNVector3Minus(v1, so.presentationNode().position)
            selectedObj?.physicsBody?.angularVelocity = SCNVector4Make(v1.x,v1.y,v1.z, w)
        }
    }

}
