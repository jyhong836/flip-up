//
//  Arrow.swift
//  HumanB
//
//  Created by Junyuan Hong on 15/1/31.
//  Copyright (c) 2015年 Junyuan Hong. All rights reserved.
//

import SceneKit

class Arrow: SCNNode {
    // Arrow is a 3D structure including a cylinder and a cone.
    
    var Line: SCNCylinder!
    var LineNode: SCNNode!
    var Head: SCNCone = SCNCone(topRadius: 0, bottomRadius: 0.5, height: 1.5)
    var HeadNode: SCNNode!
    var length: CGFloat = 0.0
    
    // the startPosition and endPosition is relative to the parentNode
    var startPosition: SCNVector3 {
        get {
            return self.position
        }
        set {
            self.position = newValue
            self.rotation = SCNVector3Product(SCNVector3Make(0, 0, -1), SCNVector3Minus(self.endp, newValue))
            length = SCNVector3Distance(newValue, endp)
            Line.height = length
            LineNode.position = SCNVector3(x: 0, y: 0, z: -length*0.5)
            HeadNode.position = SCNVector3(x: 0, y: 0, z: -length)
        }
    }
    var endp: SCNVector3!
    var endPosition: SCNVector3 {
        get {
            return endp
        }
        set {
            self.endp = newValue
            self.rotation = SCNVector3Product(SCNVector3Make(0, 0, -1), SCNVector3Minus(newValue, startPosition))
            length = SCNVector3Distance(startPosition, newValue)
            Line.height = length
            LineNode.position = SCNVector3(x: 0, y: 0, z: -length*0.5)
            HeadNode.position = SCNVector3(x: 0, y: 0, z: -length)
        }
    }
    
    init(startPosition startp: SCNVector3, endPosition endp: SCNVector3) {
        super.init()
        self.endp = endp
        
        length = SCNVector3Distance(startp, endp)
        Line = SCNCylinder(radius: 0.1, height: length)
        LineNode = SCNNode(geometry: Line)
        LineNode.position = SCNVector3(x: 0, y: 0, z: -length*0.5)
        LineNode.rotation = SCNVector4(x: -1, y: 0, z: 0, w: CGFloat(M_PI)/2)
        HeadNode = SCNNode(geometry: Head)
        HeadNode.position = SCNVector3(x: 0, y: 0, z: -length)
        HeadNode.rotation = SCNVector4(x: -1, y: 0, z: 0, w: CGFloat(M_PI)/2)

        self.addChildNode(LineNode)
        self.addChildNode(HeadNode)
        
        self.position = startp//.position
        self.rotation = SCNVector3Product(SCNVector3Make(0, 0, -1), SCNVector3Minus(endp, startp))
    }
    
    func setDiffuseColor(c: NSColor) {
        Line.firstMaterial?.diffuse.contents = c
        Head.firstMaterial?.diffuse.contents = c
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
