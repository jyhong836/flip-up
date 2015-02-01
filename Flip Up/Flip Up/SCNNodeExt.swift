//
//  SCNNodeExt.swift
//  HumanB
//
//  Created by Junyuan Hong on 15/1/31.
//  Copyright (c) 2015年 Junyuan Hong. All rights reserved.
//

import SceneKit

/* a+b */
func SCNVector3Add(a: SCNVector3, b: SCNVector3) -> SCNVector3 {
    return SCNVector3(x: a.x+b.x, y: a.y+b.y, z: a.z+b.z)
}

/* a-b */
func SCNVector3Minus(a: SCNVector3, b: SCNVector3) -> SCNVector3 {
    return SCNVector3(x: a.x-b.x, y: a.y-b.y, z: a.z-b.z)
}

/* sqrt((a-b)^2) */
func SCNVector3Distance(a: SCNVector3, b: SCNVector3) -> CGFloat {
    return sqrt(pow(a.x-b.x, 2.0) + pow(a.y-b.y, 2.0) + pow(a.z-b.z, 2.0))
}

/* a.dot(b) */
func SCNVector3Multiply(a: SCNVector3, b: SCNVector3) -> CGFloat {
    return a.x*b.x + a.y*b.y + a.z*b.z
}

/* a.cross(b) */
func SCNVector3Product(a: SCNVector3, b: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(a.y*b.z-a.z*b.y, a.z*b.x-a.x*b.z, a.x*b.y-a.y*b.x)
}

/* a.cross(b) */
func SCNVector3Product(a: SCNVector3, b: SCNVector3) -> SCNVector4 {
    var r = SCNVector4Make(a.y*b.z-a.z*b.y, a.z*b.x-a.x*b.z, a.x*b.y-a.y*b.x, 1)
    let aa = SCNVector3Abs(a)
    let bb = SCNVector3Abs(b)
    r.w = sqrt(pow(r.x, 2.0) + pow(r.y, 2.0) + pow(r.z, 2.0))
//    r.x /= r.w
//    r.y /= r.w
//    r.z /= r.w
    r.w = asin(r.w/aa/bb)
    return r
}

/* abs(a) */
func SCNVector3Abs(a: SCNVector3) -> CGFloat {
    return sqrt(pow(a.x, 2.0) + pow(a.y, 2.0) + pow(a.z, 2.0))
}

/* a+d */
func SCNVector3Move(a: SCNVector3, direction: SCNVector3) -> SCNVector3 {
    return SCNVector3(x: a.x+direction.x, y: a.y+direction.y, z: a.z+direction.z)
}
