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
    
    var boxNode: FlipBoxNode!
    
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
        
//        // create and add a light to the scene
//        let lightNode = SCNNode()
//        lightNode.light = SCNLight()
//        lightNode.light!.type = SCNLightTypeOmni
//        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
//        scene.rootNode.addChildNode(lightNode)
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = SCNLightTypeAmbient
        ambientLightNode.light!.color = NSColor.darkGrayColor()
        scene.rootNode.addChildNode(ambientLightNode)
        
        // create and add floor
        let floor = SCNFloor()
        let floorNode = SCNNode(geometry: floor)
        floor.firstMaterial?.diffuse.contents = NSColor(calibratedRed: 88/255, green: 165/255, blue: 240/255, alpha: 1.0)
        // add physics body to floor
        floorNode.physicsBody = SCNPhysicsBody(type: SCNPhysicsBodyType.Kinematic, shape: nil)
        
        scene.rootNode.addChildNode(floorNode)
        
        // create and add box
        let boxGeo = SCNCapsule(capRadius: 2, height: 10)
        boxNode = FlipBoxNode(geometry: boxGeo, rootNode: scene.rootNode)
        boxNode.position = SCNVector3(x: 0, y: boxGeo.height/2, z: 0)
        boxNode.rotation = SCNVector4Make(0, 1, 0, CGFloat(M_PI)*0.2)
        // add physics body to box
        boxNode.physicsBody = SCNPhysicsBody(type: SCNPhysicsBodyType.Dynamic, shape: nil)
        boxNode.boxDir = SCNVector3Make(0, 1, 0)
        boxNode.targetDir = SCNVector3Make(0, 1, 0)
        boxNode.setDefaultAngularVecAxis()
        boxNode.setDefaultForceAxis()
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
    func renderer(aRenderer: SCNSceneRenderer, didSimulatePhysicsAtTime time: NSTimeInterval) {
        boxNode.flip()
    }
    
}
