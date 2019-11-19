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
        substitutedIsotopes.count
    }
    
    /**
     The element that has been substituted in the SIS.
     */
    public var substitutedIsotopes: [(ChemElement, Int)] = []
    
    /**
     The atomic mass of the substituted element, unit in `amu`.
     */
    public var substitutedAtomicMasses: [Double] {
        substitutedIsotopes.map { $0.0.isotopeAtomicMasses[$0.1] ?? $0.0.mostCommonIsotopeAtomicMass }
    }
    
    /**
     The total atomic mass of the molecule, unit in `amu`.
     */
    public var totalAtomicMass: Double = 0
    
    public var isValid: Bool {
        substitutedIsotopes.count == substitutedAtomicMasses.count
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
        return (0..<substituted).map { substitutedAtomicMasses[$0] - substitutedIsotopes[$0].0.mostCommonIsotopeAtomicMass }
    }
    
    /**
     The change of mass, unit in `kg`.
     */
    public var deltaMasses: [Double] {
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
    public var inertiaTensor: Matrix {
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
    
    public var arrayForm: [Double] {
        return [A, B, C]
    }
    
    public init(){
        
    }
    
    public init(_ A: Double, _ B: Double, _ C: Double, totalAtomicMass: Double, substitutedIsotopes sIsotpes: [(ChemElement, Int)] = [], substitutedMassNumbers sMassNumbers: [Double] = []) {
        self.A = A
        self.B = B
        self.C = C
        self.totalAtomicMass = totalAtomicMass
        self.substitutedIsotopes = sIsotpes
    }
    
    public func megaHertzForm(roundDigits: Int? = nil) -> [Double] {
        var aForm = arrayForm
        aForm = aForm.map({ $0 * 1e-6 })
        if roundDigits != nil {
            aForm.round(digitsAfterDecimal: roundDigits!)
        }
        return aForm
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
 Calculate the squares of the position vectors from the reduced mass, delta P tensor, and the original I tensor. **The squares might be negative.**
 */
public func rSquaresFromSIS(mu: Double, deltaP: Matrix, I: Matrix, errLevel: Double = 0.5) -> [Double]?{
    guard deltaP.size == (3,3) && I.size == (3,3) else {
        return nil
    }
    
    var rSqaures:[Double] = [0,0,0]
    
    for ix in [0,1,2].cyclicTransformed() {
        let (i, j, k) = (ix[0], ix[1], ix[2])
        let result = (deltaP[i, i] / mu) * (1.0 + (deltaP[j, j] / (I[i, i] - I[j, j]))) * (1.0 + (deltaP[k, k] / (I[i, i] - I[k, k])))
        rSqaures[i] = result
    }
    
    return rSqaures
}

/**
 Calcualte the postion vector (all absolute valued) <|x|, |y|, |z|> from the reduced mass, delta P tensor, and the original inertia tensor. Real components and Imaginary components are returned as a tuple.
 */
public func rComplexFromSIS(mu: Double, deltaP: Matrix, I: Matrix, errLevel: Double = 0.5) -> (re: [Double?], im: [Double?])? {
    guard let rS = rSquaresFromSIS(mu: mu, deltaP: deltaP, I: I, errLevel: errLevel) else {
        return nil
    }
    
    var rRe = [Double?](repeating: nil, count: 3)
    var rIm = [Double?](repeating: nil, count: 3)
    
    for i in [0,1,2] {
        let result = rS[i]
        if result < 0 {
            rIm[i] = (-result).squareRoot()
        } else {
            rRe[i] = result.squareRoot()
        }
    }
    
    return (re: rRe, im: rIm)
}

/**
 Calculate the position vector (all absolute valued) <|x|, |y|, |z|> from the reduced mass, delta P tensor, and the original inertia tensor.
 */
public func rVecFromSIS(mu: Double, deltaP: Matrix, I: Matrix, errLevel: Double = 0.5) -> Vector3D? {
    guard let (rRe, rIm) = rComplexFromSIS(mu: mu, deltaP: deltaP, I: I, errLevel: errLevel) else {
        return nil
    }
    
    var vec = Vector3D()
    
    for i in [0,1,2] {
        if rRe[i] != nil {
            vec.dictVec[i] = rRe[i]!
            continue
        }
        if rIm[i] != nil {
            let dev = rIm[i]!
            let abcDev = PhysConst.h * (-deltaP[i, i]) / (4 * Double.pi * Double.pi * I[i, i] * I[i, i])
            print("WARNING: Imaginary coordinate \(String(format: "%.4f", dev * 1e10))i appeared. Rounded to zero. (ABC dev: \(String(format: "%.2f", abcDev * 1e-3))kHz)")
        }
        
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
        
        let mu = reducedMass(M: oABC.totalMass, deltaM: sABC.deltaMasses[0])
        guard let deltaP = tensorDeltaP(fromDeltaI: deltaI), let rVec = rVecFromSIS(mu: mu, deltaP: deltaP, I: iInitial) else {
            continue
        }
        let newAtom = Atom(sABC.substitutedIsotopes[0].0, rVec * 1e10)
        newAtom.setIdentifier()
        results.append(newAtom)
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
                atomOffDiagMap.append(-mass * pVec[i] * pVec[j])
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

/**
 Calculate the new inertia tensor given the total mass, the new origin, and the center of mass. If not specified, the center of mass will be `(0,0,0)`.
 
 - **Reference**: Abdulghany, A. R. (2017). Generalization of parallel axis theorem for rotational inertia. *American Journal of Physics, 85*(10), 791-795. doi:10.1119/1.4994835
 */
public func translateTensorI(_ tensorI: Matrix, totalMass mtot: Double, newOrigin no: Vector3D, centerOfMass cm: Vector3D = Vector3D(0,0,0)) -> Matrix {
    var newTensorI = Matrix(3,3)
    
    for ix in [0, 1, 2].cyclicTransformed() {
        let (i, j, k) = (ix[0], ix[1], ix[2])
        
        let resultDiag = tensorI[i, i] + mtot * (no[j] * no[j] + no[k] * no[k] - 2 * (no[j] * cm[j] + no[k] * cm[k]))
        let resultOffDiag = tensorI[i, j] + mtot * (no[i] * cm[j] + no[j] * cm[i] - no[i] * no[j])
        
        newTensorI[i, i] = resultDiag
        newTensorI[i, j] = resultOffDiag
        newTensorI[j, i] = resultOffDiag
    }
    
    return newTensorI
}
