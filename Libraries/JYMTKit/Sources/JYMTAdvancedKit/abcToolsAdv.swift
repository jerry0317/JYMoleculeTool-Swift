//
//  abcToolsAdv.swift
//  JYMTAdvancedKit
//
//  Created by Jerry Yan BA on 7/22/19.
//

import Foundation
import JYMTBasicKit

public func principalMoments(_ tensorI: Matrix) -> [Double]? {
    let eigs = tensorI.eigenSystem()
    if eigs == nil {
        print("Can't compute eigenvalues")
        return nil
    }
    return eigs!.0
}

// TODO: Add single isotopic substitutions (SIS)
public func ABCFromAtoms(_ atoms: [Atom], origin: Vector3D? = nil) -> ABCTuple? {
    let tensorI = tensorIFromAtoms(atoms, origin: origin)
    guard let pM = principalMoments(tensorI), pM.count == 3 else {
        return nil
    }
    let abc = pM.map({ (principalMoment) -> Double in
        PhysConst.h / (8 * Double.pi * Double.pi * principalMoment) * 1e-6
    }).sorted(by: >) // Unit in MHz
    let abcTuple = ABCTuple(abc[0], abc[1], abc[2], totalAtomicMass: atoms.totalAtomicMass, type: .original)
    return abcTuple
}
