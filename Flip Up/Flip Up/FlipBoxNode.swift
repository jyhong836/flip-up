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
    let box: SCNBox!
    let rootNode: SCNNode? // the node where the box flip over. You can set as the scene.rootNode
    
    var boxDir: SCNVector3? // relative to the FlipBoxNode
    var targetDir: SCNVector3? // relative to the rootNode
    
    /* The rootNode define the coordinate system where the box will flip over. */
    /* If the rootNode is nil, the box will not flip */
    init(width w: CGFloat, height h: CGFloat, length l: CGFloat, chamferRadius c: CGFloat, rootNode r: SCNNode) {
        super.init()
        
        box = SCNBox(width: w, height: h, length: l, chamferRadius: c)
        self.geometry = box
        
        self.rootNode = r
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func flip() {
        if rootNode != nil && boxDir != nil && targetDir != nil && self.physicsBody != nil {
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
                torq.w = 0.01*asin(torq.w) * 180/CGFloat(M_PI)
                torq.w *= torq.w
                torq.w *= ((v_max.x*targetDir!.x + v_max.y*targetDir!.y + v_max.z*targetDir!.z) >= 0) ? 1 : -1
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
        }
    }
}
