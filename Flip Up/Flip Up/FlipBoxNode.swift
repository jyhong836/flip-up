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
    var targetDir: SCNVector3? // relative to the rootNode
    
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
    
    func flip() {
        if self.physicsBody != nil && rootNode != nil && boxDir != nil && targetDir != nil {
            let nod = self.presentationNode()
            let v_max = SCNVector3Minus(nod.convertPosition(boxDir!, toNode: rootNode), nod.position)
            var torq = SCNVector4Zero
            
            torq.x = v_max.y*targetDir!.z - v_max.z*targetDir!.y
            torq.y = v_max.z*targetDir!.x - v_max.x*targetDir!.z
            torq.z = v_max.x*targetDir!.y - v_max.y*targetDir!.x
            torq.w = sqrt(pow(torq.x,2)+pow(torq.y,2)+pow(torq.z,2))
            if torq.w > 1.0 { // avoid: asin -> nan
                torq.w = 1.0
            }
            if torq.w < 1e-12 {
                torq.x = 0
                torq.y = 0
                torq.z = 0
                torq.w = 0
            } else {
                torq.x /= torq.w
                torq.y /= torq.w
                torq.z /= torq.w
                torq.w = asin(torq.w)
                if parallel {
                    torq.w *= ((v_max.x*targetDir!.x + v_max.y*targetDir!.y + v_max.z*targetDir!.z) >= 0) ? 1 : -1
                } else if (v_max.x*targetDir!.x + v_max.y*targetDir!.y + v_max.z*targetDir!.z) < 0 {
                    torq.w = CGFloat(M_PI) - torq.w
                }
                torq.w *= 1
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
        }
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
    
}
