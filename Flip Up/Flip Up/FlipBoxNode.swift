//
//  FlipBoxNode.swift
//  Flip Up
//
//  Created by Junyuan Hong on 15/2/1.
//  Copyright (c) 2015年 Junyuan Hong. All rights reserved.
//

import SceneKit

class FlipBoxNode: SCNNode {
    /* You have to add boxDir, targetDir and physicsbody before the node can flip */
    let rootNode: SCNNode? // the node where the box flip over. You MUST set as the scene.rootNode
    
    var boxDir: SCNVector3? // relative to the FlipBoxNode
    var boxRight: SCNVector3? // the box right direction relative to the FlipBoxNode
    var targetDir: SCNVector3? // relative to the rootNode
    
    // MARK: flip neccessary
    var c: CGFloat = 0.1
    var function: (CGFloat)->CGFloat = {(x: CGFloat) -> CGFloat in 0.1*x}
    
    // MARK: robot learning data
    var isResting = false
    var stepCount = 0 // 0 => not start
    var stableCount = 0 // the count of stable steps
    var score = 0.0
    var average = 0.0
    var totalScore = 0.0
    func resetLearningData() {
        isResting = false
        stepCount = 0
        stableCount = 0
        score = 0.0
        average = 0.0
        totalScore = 0.0
        if let physics = self.physicsBody {
            physics.resetTransform()
            physics.velocity = SCNVector3Zero
            physics.angularVelocity = SCNVector4Zero
        }
    }
    
    var forceAxisArrow: Arrow?
    var angularVecAxisArrow: Arrow?
    var showForceAxis: Bool {
        get {
            if forceAxisArrow != nil {
                return !forceAxisArrow!.hidden
            } else {
                return false
            }
        }
        set {
            forceAxisArrow?.hidden = !newValue
        }
    }
    var showAngularVecAxis: Bool {
        get {
            if angularVecAxisArrow != nil {
                return !angularVecAxisArrow!.hidden
            } else {
                return false
            }
        }
        set {
            angularVecAxisArrow?.hidden = !newValue
        }
    }
    
    var parallel: Bool = false // set to ture, if you just require the targetDir and boxDir parallel
    
    init(geometry: SCNGeometry, rootNode r: SCNNode) {
        super.init()
        
        self.geometry = geometry
        
        self.rootNode = r
    }
    
    /* The rootNode define the coordinate system where the box will flip over. */
    /* If the rootNode is nil, the box will not flip */
    init(width w: CGFloat, height h: CGFloat, length l: CGFloat, chamferRadius c: CGFloat, rootNode r: SCNNode) {
        super.init()
        
        self.geometry = SCNBox(width: w, height: h, length: l, chamferRadius: c)
        
        self.rootNode = r
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func flip() -> CGFloat? {
        return self.flip(self.function)
    }
    
    /* return the angle between boxDir and targetDir */
    func flip(wfunc: (CGFloat)->CGFloat) -> CGFloat? {
        if self.physicsBody != nil && rootNode != nil && boxDir != nil && targetDir != nil {
            let nod = self.presentationNode()
            let v_max = SCNVector3Minus(nod.convertPosition(boxDir!, toNode: rootNode), nod.position)
//            NSLog("\(v_max.x),\(v_max.y),\(v_max.z)")
            var torq = SCNVector4Zero
            var theta: CGFloat = 0.0
            
            torq.x = v_max.y*targetDir!.z - v_max.z*targetDir!.y
            torq.y = v_max.z*targetDir!.x - v_max.x*targetDir!.z
            torq.z = v_max.x*targetDir!.y - v_max.y*targetDir!.x
            theta = sqrt(pow(torq.x,2)+pow(torq.y,2)+pow(torq.z,2))
            if theta > 1.0 { // avoid: asin -> nan
                theta = 1.0
            }
            if theta < 1e-12 {
                if parallel || (v_max.x*targetDir!.x + v_max.y*targetDir!.y + v_max.z*targetDir!.z) > 0 {
                    torq.x = 0
                    torq.y = 0
                    torq.z = 0
                    theta = 0
                    torq.w = 0
                } else if let right = self.boxRight {
                    let vr = SCNVector3Minus(nod.convertPosition(right, toNode: rootNode), nod.position)
                    torq.x = vr.x
                    torq.y = vr.y
                    torq.z = vr.z
                    theta = CGFloat(M_PI)
                    torq.w = theta
                } else {
                    NSLog("WARN: the right dir of box is not set")
                }
            } else {
                torq.x /= theta
                torq.y /= theta
                torq.z /= theta
                theta = asin(theta)
                if parallel {
                    theta *= ((v_max.x*targetDir!.x + v_max.y*targetDir!.y + v_max.z*targetDir!.z) >= 0) ? 1 : -1
                } else if (v_max.x*targetDir!.x + v_max.y*targetDir!.y + v_max.z*targetDir!.z) < 0 {
                    theta = CGFloat(M_PI) - theta
                }
//                NSLog("theta: \(torq.w)")
//                torq.w *= 1
                torq.w = wfunc(theta)
            }
            // if the angular velocity is out of the range of torque, should be slowed down
            let av: SCNVector4 = self.physicsBody!.angularVelocity
            if (av.w>10 && abs(av.x*torq.x + av.y*torq.y + av.z*torq.z)<0.7)
                //            || abs(av.x*torq.x + av.y*torq.y + av.z*torq.z)<0.6
            {
                torq.x = av.x
                torq.y = av.y
                torq.z = av.z
                torq.w = -av.w*0.5
                //            NSLog("angular v is too large")
            }
            self.physicsBody!.applyTorque(torq, impulse: true)
            
            if showForceAxis {
                if let axis = forceAxisArrow {
                    axis.startPosition = nod.position
                    axis.endPosition = SCNVector3Add(nod.position, SCNVector3Make(torq.x*abs(torq.w)*4, torq.y*abs(torq.w)*4, torq.z*abs(torq.w)*4))
                }
            }
            
            if showAngularVecAxis {
                if let axis = angularVecAxisArrow {
                    axis.startPosition = nod.position
                    axis.endPosition = SCNVector3Add(nod.position, SCNVector3Make(av.x*abs(av.w)*4, av.y*abs(av.w)*4, av.z*abs(av.w)*4))
                }
            }
            return theta
        }
        return nil
    }
    
    func setDefaultForceAxis() {
        forceAxisArrow = Arrow(startPosition: SCNVector3Zero, endPosition:  SCNVector3Make(0, 1, 0))
        forceAxisArrow!.setDiffuseColor(NSColor.redColor())
        rootNode!.addChildNode(forceAxisArrow!)
        showForceAxis = true
    }
    
    func setDefaultAngularVecAxis() {
        angularVecAxisArrow = Arrow(startPosition: SCNVector3Zero, endPosition: SCNVector3Make(0, 1, 0))
        angularVecAxisArrow!.setDiffuseColor(NSColor.yellowColor())
        rootNode!.addChildNode(angularVecAxisArrow!)
        showAngularVecAxis = true
    }
    
    func makeCopy() -> FlipBoxNode {
        var nod = FlipBoxNode(geometry: self.geometry!, rootNode: self.rootNode!)
        nod.boxDir = self.boxDir!
        nod.boxRight = self.boxRight!
        nod.targetDir = self.targetDir!
        nod.forceAxisArrow = self.forceAxisArrow!
        nod.angularVecAxisArrow = self.angularVecAxisArrow!
        nod.position = self.position
        nod.rotation = self.rotation
        return nod
    }
    
}
