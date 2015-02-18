//
//  FlipRobot.swift
//  Flip Up
//
//  Created by Junyuan Hong on 15/2/3.
//  Copyright (c) 2015年 Junyuan Hong. All rights reserved.
//

import SceneKit

class FlipRobot {
    
    var c: CGFloat = 0.1
    var funcGenerator: (CGFloat) -> (CGFloat)->CGFloat = {(c:CGFloat) in {(x: CGFloat) -> CGFloat in
        c*x}}
    var function: (CGFloat)->CGFloat
    var box: FlipBoxNode
    var initPosition: SCNVector3
    var initRotation: SCNVector4
    
    var stepCount = 0 // 0 => not start
    var maxSteps = 2000
    var genCount = 0  // 0 => not start
    var maxGens = 10
    var indCount = 0
    var indNum = 10 // TODO: init the var and indgap in init, must be even
    var inds = [CGFloat]()
    var indscore = [CGFloat: Double]()
    var indgap: CGFloat = 2.0/10
    var indBox = [FlipBoxNode]()
    var stableCount = 0 // the count of stable steps
    var maxStableCount = 120
    var stableAngle = CGFloat(M_PI)*5/180
    
    var score = 0.0
    var average = 0.0
    var totalScore = 0.0
    
    init(flipbox: FlipBoxNode, position: SCNVector3, rotation: SCNVector4) {
        self.function = funcGenerator(self.c)
        box = flipbox
        initPosition = position
        initRotation = rotation
        initGene()
    }
    
    init(funcGenerator: (CGFloat) -> (CGFloat)->CGFloat, flipbox: FlipBoxNode, position: SCNVector3, rotation: SCNVector4) {
        self.funcGenerator = funcGenerator
        self.function = funcGenerator(self.c)
        box = flipbox
        initPosition = position
        initRotation = rotation
        initGene()
    }
    
    func initGene() {
        inds = [CGFloat](count: indNum, repeatedValue: 0.0)
        indscore[inds[0]] = 0.0
        indBox.append(box)
        box.physicsBody?.collisionBitMask = 1<<(0+1)
        for i in 1..<indNum {
            inds[i] = inds[i-1] + indgap
            indscore[inds[i]] = 0.0
            
            var b = box.makeCopy()
            b.physicsBody = SCNPhysicsBody(type: SCNPhysicsBodyType.Dynamic, shape: nil)
            indBox.append(b)
            box.rootNode?.addChildNode(b)
            b.physicsBody?.collisionBitMask = 1<<(i+1)
        }
        
        stepCount = 0
        stableCount = 0
        score = 0
        totalScore = 0
        average = 0
        c = inds[indCount]
    }
    
    func nextIndividual() -> Bool {
        indscore[inds[indCount]] = totalScore
        // MARK: clear
        stepCount = 0
        stableCount = 0
        score = 0
        totalScore = 0
        average = 0
        
        indCount++
        if indCount >= inds.count {
            if !nextGeneration() {
                return false
            }
        }
        c = inds[indCount]
        function = funcGenerator(c)
        
        if let physics = box.physicsBody {
            physics.resetTransform()
            physics.velocity = SCNVector3Zero
            physics.angularVelocity = SCNVector4Zero
        }
        return true
    }
    
    func nextGeneration() -> Bool {
        
        genCount++
        indCount = 0;
        // MARK: update inds for new generation
        let _inds = inds.sorted({(a,b)->Bool in self.indscore[a]>self.indscore[b]})
        NSLog("end of the \(genCount) generation\n\tindgap: \(indgap)")
        println("\tind\tvalue")
        for i in _inds {
            println("\t\(i)\t\(indscore[i]!)")
        }
        if genCount > maxGens || indgap < 1e-4 {
            NSLog("END at the \(genCount) generation, indgap: \(indgap)")
            return false
        }
        indgap /= 4.0
        for i in 0..<inds.count/2 {
            inds[i*2  ] = _inds[i] + indgap
            inds[i*2+1] = _inds[i] - indgap
        }
        return true
    }
    
    // make one step
    func stepOnce() -> Bool {
        stepCount++
        
        var theta = box.flip(function)
        score += pow(Double(theta!/stableAngle), 2.0)
        average += Double(theta!/stableAngle)
        if theta < stableAngle {
            stableCount++
            if stableCount > maxStableCount {
                average /= Double(stepCount)
                totalScore = 1.0+1/Double(stepCount) //sqrt(score)
                println("[\(genCount):\(indCount)] \(stepCount) steps: stable count > max\n\tscore \(totalScore)\n\tvalue \(c)")
                return self.nextIndividual()
            }
        } else {
            stableCount = 0
        }
        
        if stepCount >= maxSteps {
            average /= Double(stepCount)
            totalScore = 1/(average)/sqrt(score/Double(stepCount))
            println("[\(genCount):\(indCount)] \(stepCount)steps\n\tscore \(totalScore)\n\tvalue \(c)")
            return self.nextIndividual()
        }
        return true
    }
    
}
