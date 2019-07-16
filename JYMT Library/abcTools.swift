//
//  abcTools.swift
//  JYMT-StructureFinder
//
//  Created by Jerry Yan on 7/15/19.
//  Copyright © 2019 Jerry Yan. All rights reserved.
//

import Foundation

struct ABCTuple {
    var A: Double = 0
    var B: Double = 0
    var C: Double = 0
    
    enum ABCType {
        case original
        case singleSubstituted
    }
    
    var type: ABCType
    var substitutedElement: ChemElement? = nil
    var substitutedAtomicMass: Double? = nil
    var totalAtomicMass: Double = 0
    
    var deltaAtomicMass: Double? {
        guard type == .singleSubstituted, let mass = substitutedAtomicMass, let element = substitutedElement else {
            return nil
        }
        return mass - element.atomicMass
    }
    
    var deltaMass: Double? {
        if deltaAtomicMass == nil {
            return nil
        } else {
            return deltaAtomicMass! * PhysConst.amu
        }
    }
    
    var totalMass: Double {
        totalAtomicMass * PhysConst.amu
    }
    
    var inertiaTensor: Matrix {
        return tensorIFromABC(A, B, C)
    }
    
    subscript(index: Int) -> Double {
        get {
            switch index {
            case 0:
                return A
            case 1:
                return B
            case 2:
                return C
            default:
                fatalError("Index out of range")
            }
        }
        
        set {
            switch index {
            case 0:
                A = newValue
            case 1:
                B = newValue
            case 2:
                C = newValue
            default:
                fatalError("Index out of range")
            }
        }
    }
    
    init(_ type: ABCType = .original){
        self.type = type
    }
    
    init(_ A: Double, _ B: Double, _ C: Double, totalMass: Double, type: ABCType = .original, substitutedElement sElement: ChemElement? = nil, substitutedMass sMass: Double? = nil) {
        self.A = A
        self.B = B
        self.C = C
        self.totalAtomicMass = totalMass
        self.type = type
        self.substitutedElement = sElement
        self.substitutedAtomicMass = sMass
    }
}

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

func rVecFromSIS(mu: Double, deltaP: Matrix, I: Matrix, errLevel: Double = 0.5) -> Vector3D? {
    guard deltaP.size == (3,3) && I.size == (3,3) else {
        return nil
    }
    
    var vec = Vector3D()
    
    for ix in [0,1,2].cyclicTransformed() {
        let i = ix[0]
        let j = ix[1]
        let k = ix[2]
        var result = (deltaP[i, i] / mu) * (1.0 + (deltaP[j, j] / (I[i, i] - I[j, j]))) * (1.0 + (deltaP[k, k] / (I[i, i] - I[k, k])))
        if result < 0 && abs(result) <= errLevel {
            result = 0.0
        } else if result >= 0 {
            result = result.squareRoot()
        } else {
            result = 0.0
            print("WARNING: The negative number to be square rooted is over-deviated. Rounded to zero.")
        }
        vec.dictVec[i] = result
    }
    
    return vec
}
