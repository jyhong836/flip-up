//
//  FlipRobot.swift
//  Flip Up
//
//  Created by Junyuan Hong on 15/2/3.
//  Copyright (c) 2015年 Junyuan Hong. All rights reserved.
//

import SceneKit

class FlipRobot {
    
    var c: CGFloat = 2.0
    var funcGenerator: (CGFloat) -> (CGFloat)->CGFloat = {(c:CGFloat) in {(x: CGFloat) -> CGFloat in
        c*x}}
    var function: (CGFloat)->CGFloat
    var box: FlipBoxNode
    var initPosition: SCNVector3
    var initRotation: SCNVector4
    
    var stepCount = 0 // 0 => not start
    var maxSteps = 1000
    var genCount = 0  // 0 => not start
    var maxGens = 10
    var stableCount = 0 // the count of stable steps
    var maxStableCount = 10
    
    var score = 0.0
    var totalScore = 0.0
    
    init(flipbox: FlipBoxNode, position: SCNVector3, rotation: SCNVector4) {
        self.function = funcGenerator(self.c)
        box = flipbox
        initPosition = position
        initRotation = rotation
    }
    
    init(funcGenerator: (CGFloat) -> (CGFloat)->CGFloat, flipbox: FlipBoxNode, position: SCNVector3, rotation: SCNVector4) {
        self.funcGenerator = funcGenerator
        self.function = funcGenerator(self.c)
        box = flipbox
        initPosition = position
        initRotation = rotation
    }
    
    func nextGeneration() {
        genCount++
        stepCount = 0
        stableCount = 0
        if genCount > maxGens {
            // TODO: display the result
        }
        
        c = 1.0 // TODO: to calculate next gen value of c
        function = funcGenerator(c)
        
        if let physics = box.physicsBody {
            physics.resetTransform()
            physics.velocity = SCNVector3Zero
            physics.angularVelocity = SCNVector4Zero
        }
    }
    
    // make one step
    func stepOnce() {
        stepCount++
        
        var theta = box.flip(function)
        // TODO: calculate the score
        if theta < CGFloat(M_PI)*1/180 {
            stableCount++
            if stableCount > maxStableCount {
                // TODO: calculate the total score
                // TODO: display the result of this generation
                NSLog("[\(genCount)] \(stepCount)steps: stable count > max")
                self.nextGeneration()
                return
            }
        } else {
            stableCount = 0
        }
        
        if stepCount >= maxSteps {
            // TODO: calculate the total score
            // TODO: display the result of this generation
            NSLog("[\(genCount)] \(stepCount)steps")
            self.nextGeneration()
        }
    }
    
}
