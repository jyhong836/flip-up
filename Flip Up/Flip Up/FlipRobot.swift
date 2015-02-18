//
//  FlipRobot.swift
//  Flip Up
//
//  Created by Junyuan Hong on 15/2/3.
//  Copyright (c) 2015年 Junyuan Hong. All rights reserved.
//

import SceneKit

class FlipRobot {
    
    var funcGenerator: (CGFloat) -> (CGFloat)->CGFloat = {(c:CGFloat) in {(x: CGFloat) -> CGFloat in
        c*x}} // TODO: Do we really need the generator?
    var box: FlipBoxNode
    var initPosition: SCNVector3
    var initRotation: SCNVector4
    
    var maxSteps = 2000
    var genCount = 0  // 0 => not start
    var maxGens = 10
    var indNum = 10 // TODO: init the var and indgap in init, must be even
    var inds = [CGFloat]()
    var indscore = [CGFloat: Double]()
    var indgap: CGFloat = 2.0/10
    var indBox = [FlipBoxNode]()
    var maxStableCount = 120
    var stableAngle = CGFloat(M_PI)*5/180
    
    
    init(flipbox: FlipBoxNode, position: SCNVector3, rotation: SCNVector4) {
        box = flipbox
        box.function = funcGenerator(box.c)
        initPosition = position
        initRotation = rotation
        initGene()
    }
    
    init(funcGenerator: (CGFloat) -> (CGFloat)->CGFloat, flipbox: FlipBoxNode, position: SCNVector3, rotation: SCNVector4) {
        self.funcGenerator = funcGenerator
        box = flipbox
        box.function = funcGenerator(box.c)
        initPosition = position
        initRotation = rotation
        initGene()
    }
    
    func initGene() {
        inds = [CGFloat](count: indNum, repeatedValue: 0.0)
        indscore[inds[0]] = 0.0
        indBox.append(box)
        box.physicsBody = SCNPhysicsBody(type: SCNPhysicsBodyType.Dynamic, shape: nil)
        box.physicsBody?.collisionBitMask = 1<<(0+1)
        for i in 1..<indNum {
            inds[i] = inds[i-1] + indgap
            indscore[inds[i]] = 0.0
            
            // clone box
            var b = box.makeCopy()
            b.physicsBody = SCNPhysicsBody(type: SCNPhysicsBodyType.Dynamic, shape: nil)
            indBox.append(b)
            box.rootNode?.addChildNode(b)
            b.physicsBody?.collisionBitMask = 1<<(i+1)
            
            b.c = inds[i]
            b.function = funcGenerator(b.c)
        }
    }
    
    func updateIndivdual(boxIndex: Int) {
        
        indscore[inds[boxIndex]] = indBox[boxIndex].totalScore
        // MARK: clear
        indBox[boxIndex].resetLearningData()
        
        indBox[boxIndex].c = inds[boxIndex]
        indBox[boxIndex].function = funcGenerator(indBox[boxIndex].c)
    }
    
    func nextGeneration() -> Bool {
        for i in 0..<inds.count {
            indscore[inds[i]] = indBox[i].totalScore
        }
        
        genCount++
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
            updateIndivdual(i*2  )
            updateIndivdual(i*2+1)
        }
        return true
    }
    
    func stepOnce() -> Bool {
        var existActive = false
        for box in indBox {
            if !box.isResting && stepOnce(box) {
                existActive = true
            }
        }
        if !existActive { // no individual is active
            return nextGeneration()
        }
        return true
    }
    
    // make one step. If box is not active, return false.
    func stepOnce(box: FlipBoxNode) -> Bool {
        box.stepCount++
        
        var theta = box.flip(box.function) // flip once
        
        // calculate score
        box.score += pow(Double(theta!/stableAngle), 2.0)
        box.average += Double(theta!/stableAngle)
        if theta < stableAngle {
            box.stableCount++
            // the box has been stable
            if box.stableCount > maxStableCount {
                box.average /= Double(box.stepCount)
                box.totalScore = 1.0+1/Double(box.stepCount) //sqrt(score)
                println("[\(genCount):\(box.c)] \(box.stepCount) steps: stable count > max\n\tscore \(box.totalScore)")
                box.isResting = true
                return false
            }
        } else {
            box.stableCount = 0
        }
        
        // out of step range
        if box.stepCount >= maxSteps {
            box.average /= Double(box.stepCount)
            box.totalScore = 1/(box.average)/sqrt(box.score/Double(box.stepCount))
            println("[\(genCount):\(box.c)] \(box.stepCount)steps\n\tscore \(box.totalScore)")
            box.isResting = true
            return false
        }
        return true
    }
    
}
