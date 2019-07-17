//
//  abcTools.swift
//  JYMT-StructureFinder
//
//  Created by Jerry Yan on 7/15/19.
//  Copyright © 2019 Jerry Yan. All rights reserved.
//

import Foundation

/**
 The structure contains the information of rotational constants and single isotopic substitutions (SIS).
 */
struct ABCTuple {
    var A: Double = 0
    var B: Double = 0
    var C: Double = 0
    
    /**
     The type of the tuple.
     */
    enum ABCType {
        case original
        case singleSubstituted
    }
    
    /**
     The type of the tuple to determine if the molecule was original or after single isotopic substitution.
     */
    var type: ABCType
    
    /**
     The element that has been substituted in the SIS.
     */
    var substitutedElement: ChemElement? = nil
    
    /**
     The atomic mass of the substituted element, unit in `amu`.
     */
    var substitutedAtomicMass: Double? = nil
    
    /**
     The total atomic mass of the molecule, unit in `amu`.
     */
    var totalAtomicMass: Double = 0
    
    /**
     The change of atomic mass, calculated from the substituted element. Unit in `amu`.
     */
    var deltaAtomicMass: Double? {
        guard type == .singleSubstituted, let mass = substitutedAtomicMass, let element = substitutedElement else {
            return nil
        }
        return mass - element.atomicMass
    }
    
    /**
     The change of mass, unit in `kg`.
     */
    var deltaMass: Double? {
        if deltaAtomicMass == nil {
            return nil
        } else {
            return deltaAtomicMass! * PhysConst.amu
        }
    }
    
    /**
     The total mass of the molcule, unit in `kg`.
     */
    var totalMass: Double {
        totalAtomicMass * PhysConst.amu
    }
    
    /**
     The inertia tensor calculated from the rotational constants A, B, and C.
     */
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

/**
 Generate the tensor of inertia from the rotational constants along the principal axes.
 */
func tensorIFromABC(_ A: Double, _ B: Double, _ C: Double) -> Matrix {
    var tensorI = Matrix(3,3)
    let abc = [A, B, C]
    for (i, value) in abc.enumerated() {
        tensorI[i, i] = PhysConst.h / (8.0 * Double.pi * Double.pi * value)
    }
    return tensorI
}

/**
 Returns the reduced mass given the original mass and the mass change.
 */
func reducedMass(M: Double, deltaM: Double) -> Double {
    return M * deltaM / (M + deltaM)
}

/**
 Generate the tensor Delta P from the change of inertia tensor Delta I.
 */
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

/**
 Calculate the position vector (all absolute valued) <|x|, |y|, |z|> from the reduced mass, delta P tensor, and the original inertia tensor.
 */
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

/**
 Calculate from a given original ABC and an array of substituted ABC to an array of atoms.
 */
func fromSISToAtoms(original oABC: ABCTuple, substituted sABCs: [ABCTuple]) -> [Atom] {
    var results = [Atom]()
    
    let iInitial = oABC.inertiaTensor
    
    for sABC in sABCs {
        guard sABC.type == .singleSubstituted, let sElement = sABC.substitutedElement, let deltaM = sABC.deltaMass else {
            continue
        }
        let iSub = sABC.inertiaTensor
        let deltaI = iSub - iInitial
        
        let mu = reducedMass(M: oABC.totalMass, deltaM: deltaM)
        guard let deltaP = tensorDeltaP(fromDeltaI: deltaI), let rVec = rVecFromSIS(mu: mu, deltaP: deltaP, I: iInitial) else {
            continue
        }
        results.append(Atom(sElement, rVec * 1e10))
    }
    
    return results
}
