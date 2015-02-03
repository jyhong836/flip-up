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
    
    var stepCount = 0 // 0 => not start
    var genCount = 0  // 0 => not start
    
    init(flipbox: FlipBoxNode) {
        self.function = funcGenerator(self.c)
        box = flipbox
    }
    
    init(funcGenerator: (CGFloat) -> (CGFloat)->CGFloat, flipbox: FlipBoxNode) {
        self.funcGenerator = funcGenerator
        self.function = funcGenerator(self.c)
        box = flipbox
    }
    
    func nextGeneration() {
        genCount++
        
        c = 1.0 // TODO: to calculate next gen value of c
        function = funcGenerator(c)
    }
    
    // make one step
    func stepOnce() {
        stepCount++
        
        box.flip(function)
    }
    
}
