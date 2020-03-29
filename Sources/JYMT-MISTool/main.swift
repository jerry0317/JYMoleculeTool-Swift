//
//  main.swift
//  JYMT-MISTool
//
//  Created by Jerry Yan on 11/18/19.
//

import Foundation
import JYMTBasicKit
import JYMTAdvancedKit

printWelcomeBanner("MIS Tool")

let abcPM = ABCTuple(6709.080887*1e6, 4121.532619*1e6, 3387.851702*1e6, totalAtomicMass: 76.0944)
let abcA = ABCTuple(5296.279016*1e6, 3642.216781*1e6, 3125.767619*1e6, totalAtomicMass: 76.0944, substitutedIsotopes: [(ChemElement.carbon, 13)])
let abcB = ABCTuple(4775.040608*1e6, 3569.764660*1e6, 2866.559174*1e6, totalAtomicMass: 76.0944, substitutedIsotopes: [(ChemElement.carbon, 13)])
let abcAB = ABCTuple(4305.255076*1e6, 3214.296089*1e6, 2574.740027*1e6, totalAtomicMass: 76.0944, substitutedIsotopes: [(ChemElement.carbon, 13), (ChemElement.carbon, 13)])

var atoms = fromSISToAtoms(original: abcPM, substituted: [abcA, abcB])

for atom in atoms {
    atom.massNumber = 13
}

var atomBs = atoms[1].possibles

var rABCs =  [([Atom], ABCTuple)]()

for atomB in atomBs {
    let rABC = MISFromSubstitutedAtoms(depth: 2, original: abcPM, substitutedAtoms: [atoms[0], atomB])
    rABCs.append(rABC[0])
}

let abcABRVec = Vector3D(abcAB.arrayForm)
rABCs.sort(by: { (Vector3D($0.1.arrayForm) - abcABRVec).magnitude < (Vector3D($1.1.arrayForm) - abcABRVec).magnitude })
print(rABCs[0].1.arrayForm)
//print(rABCs[0].0[0].rvec!)

