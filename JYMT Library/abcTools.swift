//
//  abcTools.swift
//  JYMT-StructureFinder
//
//  Created by Jerry Yan on 7/15/19.
//  Copyright © 2019 Jerry Yan. All rights reserved.
//

import Foundation

func tensorIFromABC(_ A: Double, _ B: Double, _ C: Double) -> Matrix {
    var tensorI = Matrix(3,3)
    let abc = [A, B, C]
    for (i, value) in abc.enumerated() {
        tensorI[i, i] = PhysConst.h / (8.0 * Double.pi * Double.pi * value)
    }
    return tensorI
}

func reducedMass(M: Double, deltaM: Double) -> Double {
    return M * deltaM / (M + deltaM)
}

func tensorDeltaP(fromDeltaI deltaI: Matrix) -> Matrix? {
    guard deltaI.size == (3,3) else {
        return nil
    }
    var deltaP = Matrix(3,3)
    for ix in [0,1,2].cyclicTransformed() {
        let i = ix[0]
        let j = ix[1]
        let k = ix[2]
        deltaP[i, i] = 0.5 * (-deltaI[i, i] + deltaI[j, j] + deltaI[k, k])
    }
    return deltaP
}

func rVecFromSIS(mu: Double, deltaP: Matrix, I: Matrix) -> Vector3D? {
    guard deltaP.size == (3,3) && I.size == (3,3) else {
        return nil
    }
    
    var vec = Vector3D()
    
    for ix in [0,1,2].cyclicTransformed() {
        let i = ix[0]
        let j = ix[1]
        let k = ix[2]
        print(deltaP[i,i], (1.0 + (deltaP[j, j] / (I[i, i] - I[j, j]))), (1.0 + (deltaP[k, k] / (I[i, i] - I[k, k]))))
        vec.dictVec[i] = ((deltaP[i, i] / mu) * (1.0 + (deltaP[j, j] / (I[i, i] - I[j, j]))) * (1.0 + (deltaP[k, k] / (I[i, i] - I[k, k])))).squareRoot()
    }
    
    return vec
}
