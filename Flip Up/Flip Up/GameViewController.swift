//
//  GameViewController.swift
//  Flip Up
//
//  Created by Junyuan Hong on 15/2/1.
//  Copyright (c) 2015年 Junyuan Hong. All rights reserved.
//

import SceneKit
import QuartzCore

class GameViewController: NSViewController, SCNSceneRendererDelegate {
    
    @IBOutlet weak var gameView: GameView!
    
    var scene: SCNScene!
    
    var boxNode: SCNNode!
    
    override func awakeFromNib(){
        // create a new scene
        scene = SCNScene()
        
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        
        // place the camera
        cameraNode.position = SCNVector3(x: 0, y: 20, z: 35)
        cameraNode.rotation = SCNVector4(x: 1, y: 0, z: 0, w: -CGFloat(M_PI)/6)
        
        // create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = SCNLightTypeOmni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        scene.rootNode.addChildNode(lightNode)
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = SCNLightTypeAmbient
        ambientLightNode.light!.color = NSColor.darkGrayColor()
        scene.rootNode.addChildNode(ambientLightNode)
        
        // create and add floor
        let floor = SCNFloor()
        let floorNode = SCNNode(geometry: floor)
        floor.firstMaterial?.diffuse.contents = NSColor(calibratedHue: 0.5, saturation: 1.0, brightness: 1.0, alpha: 1.0)
        // add physics body to floor
        floorNode.physicsBody = SCNPhysicsBody(type: SCNPhysicsBodyType.Kinematic, shape: nil)
        scene.rootNode.addChildNode(floorNode)
        
        // create and add box
        let box = SCNBox(width: 2, height: 2, length: 5, chamferRadius: 0)
        boxNode = SCNNode(geometry: box)
        boxNode.position = SCNVector3(x: 0, y: box.height/2, z: 0)
        boxNode.rotation = SCNVector4Make(0, 1, 0, CGFloat(M_PI)*0.2)
        // add physics body to box
        boxNode.physicsBody = SCNPhysicsBody(type: SCNPhysicsBodyType.Dynamic, shape: nil)
        scene.rootNode.addChildNode(boxNode)

        // set the scene to the view
        self.gameView!.scene = scene
        
        // allows the user to manipulate the camera
        self.gameView!.allowsCameraControl = true
        
        // show statistics such as fps and timing information
        self.gameView!.showsStatistics = true
        
        // configure the view
        self.gameView!.backgroundColor = NSColor.blackColor()
        
        // delgate
        self.gameView!.delegate = self
    }
    
    // implement SCNSceneRendererDelegate
    var vup = SCNVector3Make(0, 1, 0) // the vector directed upward
    
    func renderer(aRenderer: SCNSceneRenderer, didSimulatePhysicsAtTime time: NSTimeInterval) {
        flipBox()
    }
    
    func flipBox() {
        let nod = boxNode.presentationNode()
        let v_max = SCNVector3Minus(nod.convertPosition(SCNVector3Make(0, 0, 1), toNode: scene.rootNode), nod.position)
        var torq = SCNVector4Zero
        
        torq.x = v_max.y*vup.z - v_max.z*vup.y
        torq.y = v_max.z*vup.x - v_max.x*vup.z
        torq.z = v_max.x*vup.y - v_max.y*vup.x
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
            torq.w *= ((v_max.x*vup.x + v_max.y*vup.y + v_max.z*vup.z) >= 0) ? 1 : -1
        }
        // if the angular velocity is out of the range of torque, should be slowed down
        let av: SCNVector4 = boxNode.physicsBody!.angularVelocity
        if (av.w>10 && abs(av.x*torq.x + av.y*torq.y + av.z*torq.z)<0.7)
            //            || abs(av.x*torq.x + av.y*torq.y + av.z*torq.z)<0.6
        {
            torq.x = av.x
            torq.y = av.y
            torq.z = av.z
            torq.w = -av.w*0.5
            //            NSLog("angular v is too large")
        }
        boxNode.physicsBody?.applyTorque(torq, impulse: true)
    }
}
