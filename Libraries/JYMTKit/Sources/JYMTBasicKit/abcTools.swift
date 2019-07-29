//
//  abcTools.swift
//  JYMT-StructureFinder
//
//  Created by Jerry Yan on 7/15/19.
//  Copyright © 2019 Jerry Yan. All rights reserved.
//

import Foundation

/**
 The structure contains the information of rotational constants and isotopic substitutions.
 */
public struct ABCTuple {
    public var A: Double = 0
    public var B: Double = 0
    public var C: Double = 0
    
    /**
     The type of the tuple to determine if the molecule was original or after single isotopic substitution.
     */
    public var substituted: Int {
        substitutedElements.count
    }
    
    /**
     The element that has been substituted in the SIS.
     */
    public var substitutedElements: [ChemElement] = []
    
    /**
     The atomic mass of the substituted element, unit in `amu`.
     */
    public var substitutedAtomicMasses: [Double] = []
    
    /**
     The total atomic mass of the molecule, unit in `amu`.
     */
    public var totalAtomicMass: Double = 0
    
    public var isValid: Bool {
        substitutedElements.count == substitutedAtomicMasses.count
    }
    
    public var isSIS: Bool {
        substituted == 1 && isValid
    }
    
    public var isParent: Bool {
        substituted == 0 && isValid
    }
    
    /**
     The change of atomic mass, calculated from the substituted element. Unit in `amu`.
     */
    public var deltaAtomicMasses: [Double] {
        guard isValid else {
            return []
        }
        return (0..<substituted).map { substitutedAtomicMasses[$0] - substitutedElements[$0].mostCommonIsotopeAtomicMass }
    }
    
    /**
     The change of mass, unit in `kg`.
     */
    public var deltaMass: [Double] {
        deltaAtomicMasses.map { $0 * PhysConst.amu }
    }
    
    /**
     The total mass of the molcule, unit in `kg`.
     */
    public var totalMass: Double {
        totalAtomicMass * PhysConst.amu
    }
    
    /**
     The inertia tensor calculated from the rotational constants A, B, and C.
     */
    var inertiaTensor: Matrix {
        return tensorIFromABC(A, B, C)
    }
    
    public subscript(index: Int) -> Double {
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
    
    public init(){
        
    }
    
    public init(_ A: Double, _ B: Double, _ C: Double, totalAtomicMass: Double, substitutedElements sElements: [ChemElement] = [], substitutedMasses sMasses: [Double] = []) {
        self.A = A
        self.B = B
        self.C = C
        self.totalAtomicMass = totalAtomicMass
        self.substitutedElements = sElements
        self.substitutedAtomicMasses = sMasses
    }
}

/**
 Generate the tensor of inertia from the rotational constants along the principal axes.
 */
public func tensorIFromABC(_ A: Double, _ B: Double, _ C: Double) -> Matrix {
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
public func reducedMass(M: Double, deltaM: Double) -> Double {
    return M * deltaM / (M + deltaM)
}

/**
 Generate the tensor Delta P from the change of inertia tensor Delta I.
 */
public func tensorDeltaP(fromDeltaI deltaI: Matrix) -> Matrix? {
    guard deltaI.size == (3,3) else {
        return nil
    }
    var deltaP = Matrix(3,3)
    for ix in [0,1,2].cyclicTransformed() {
        let (i, j, k) = (ix[0], ix[1], ix[2])
        deltaP[i, i] = 0.5 * (-deltaI[i, i] + deltaI[j, j] + deltaI[k, k])
    }
    return deltaP
}

/**
 Calculate the position vector (all absolute valued) <|x|, |y|, |z|> from the reduced mass, delta P tensor, and the original inertia tensor.
 */
public func rVecFromSIS(mu: Double, deltaP: Matrix, I: Matrix, errLevel: Double = 0.5) -> Vector3D? {
    guard deltaP.size == (3,3) && I.size == (3,3) else {
        return nil
    }
    
    var vec = Vector3D()
    
    for ix in [0,1,2].cyclicTransformed() {
        let (i, j, k) = (ix[0], ix[1], ix[2])
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
public func fromSISToAtoms(original oABC: ABCTuple, substituted sABCs: [ABCTuple]) -> [Atom] {
    var results = [Atom]()
    
    let iInitial = oABC.inertiaTensor
    
    for sABC in sABCs {
        guard sABC.substituted == 1 && sABC.isValid else {
            continue
        }
        let iSub = sABC.inertiaTensor
        let deltaI = iSub - iInitial
        
        let mu = reducedMass(M: oABC.totalMass, deltaM: sABC.deltaMass[0])
        guard let deltaP = tensorDeltaP(fromDeltaI: deltaI), let rVec = rVecFromSIS(mu: mu, deltaP: deltaP, I: iInitial) else {
            continue
        }
        results.append(Atom(sABC.substitutedElements[0], rVec * 1e10))
    }
    
    return results
}

/**
 Calculate the tensor I in SI unit from an array of atoms *(with position vector unit in angstrom)* with an optional origin. The default origin is the center of mass.
 */
public func tensorIFromAtoms(_ atoms: [Atom], origin: Vector3D? = nil) -> Matrix {
    var tensorI = Matrix(3,3)
    if !atoms.isEmpty {
        var center = Vector3D()
        if origin == nil {
            center = atoms.centerOfMass
        } else {
            center = origin!
        }
        for ix in [0, 1, 2].cyclicTransformed() {
            let (i, j, k) = (ix[0], ix[1], ix[2])
            var atomDiagMap = [Double]()
            var atomOffDiagMap = [Double]()
            for atom in atoms {
                guard let mass = atom.mass, let rvec = atom.rvec else {
                    atomDiagMap.append(0.0)
                    atomOffDiagMap.append(0.0)
                    continue
                }
                let pVec = (rvec - center) * 1e-10
                atomDiagMap.append(mass * ((pVec[j] * pVec[j]) + (pVec[k] * pVec[k])))
                atomOffDiagMap.append(mass * pVec[i] * pVec[j])
            }
            let resultDiag = atomDiagMap.reduce(0, +)
            let resultOffDiag = atomOffDiagMap.reduce(0, +)
            
            tensorI[i, i] = resultDiag
            tensorI[i, j] = resultOffDiag
            tensorI[j, i] = resultOffDiag
        }
    }
    return tensorI
}
