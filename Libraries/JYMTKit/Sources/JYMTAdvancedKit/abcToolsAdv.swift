//
//  abcToolsAdv.swift
//  JYMTAdvancedKit
//
//  Created by Jerry Yan BA on 7/22/19.
//

import Foundation
import JYMTBasicKit

/**
 Calculate the principal moments (the eigenvalues) of an inertia tensor.
 */
public func principalMoments(_ tensorI: Matrix) -> [Double]? {
    let eigs = tensorI.eigenSystem()
    if eigs == nil {
        print("Can't compute eigenvalues")
        return nil
    }
    return eigs!.0
}

/**
 Calculate the rotational constants A, B, and C based on the information of the atoms of a molecule. It takes the atoms and an optional origin vector as parameters. If the `origin` is set to the default value `nil`, the function will take the center of mass as the origin by default.
 
 - TODO: Add single isotopic substitutions (SIS)
 */
public func ABCFromAtoms(_ atoms: [Atom], origin: Vector3D? = nil) -> ABCTuple? {
    let tensorI = tensorIFromAtoms(atoms, origin: origin)
    return ABCFromTensorI(tensorI, totalAtomicMass: atoms.totalAtomicMass)
}

public func ABCFromTensorI(_ tensorI: Matrix, totalAtomicMass: Double, substitutedIsotopes: [(ChemElement, Int)] = []) -> ABCTuple? {
    guard let pM = principalMoments(tensorI), pM.count == 3 else {
        return nil
    }
    let abc = pM.map({ (principalMoment) -> Double in
        PhysConst.h / (8 * Double.pi * Double.pi * principalMoment)
    }).sorted(by: >) // Unit in Hz
    let abcTuple = ABCTuple(abc[0], abc[1], abc[2], totalAtomicMass: totalAtomicMass, substitutedIsotopes: substitutedIsotopes)
    return abcTuple
}

public func MISFromSubstitutedAtoms(depth: Int, original: ABCTuple, substitutedAtoms: [Atom]) -> [([Atom], ABCTuple)] {
    guard depth >= 1 && depth <= substitutedAtoms.count else {
        return []
    }
    var result = [([Atom], ABCTuple)]()
    let originalInertia = original.inertiaTensor
    
    let combAtoms = combinations(substitutedAtoms, depth)
    
    for atoms in combAtoms {
        let atomArray = Array(atoms)
        let originalAtoms = atomArray.map({ Atom($0.element, $0.rvec, $0.identifier, massNumber: $0.element?.mostCommonMassNumber) })
        let masses = [(original.totalAtomicMass, Vector3D())] + atoms.map( {(($0.atomicMass! - $0.element!.mostCommonIsotopeAtomicMass), $0.rvec ?? Vector3D())} )
        let newCM = centerOfPointMasses(masses) * 1e-10 // In angstrom
        let tensorITBA = tensorIFromAtoms(atomArray, origin: Vector3D())
        let tensorITBS = tensorIFromAtoms(originalAtoms, origin: Vector3D())
        let newTotalMass = original.totalAtomicMass + atoms.reduce(0.0, { $0 + ($1.atomicMass! - $1.element!.mostCommonIsotopeAtomicMass) })
        var newTensorI = originalInertia + tensorITBA - tensorITBS
        newTensorI = translateTensorI(newTensorI, totalMass: newTotalMass * PhysConst.amu, newOrigin: newCM, centerOfMass: newCM)
        guard var abc = ABCFromTensorI(newTensorI, totalAtomicMass: newTotalMass) else {
            continue
        }
        abc.substitutedIsotopes = atomArray.map({ ($0.element!, $0.massNumber!) })
        result.append((atomArray, abc))
    }
    
    return result
}
