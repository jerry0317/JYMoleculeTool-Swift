//
//  main.swift
//  JYMoleculeTool-Swift
//
//  Created by Jerry Yan on 6/20/19.
//  Copyright © 2019 Jerry Yan. All rights reserved.
//

import Foundation

/**
 Tolerence level used in bond length filter. Unit in angstrom.
 */
let tolerenceLevel = 0.1

/**
 Trim level used to trim down the component of the position vector of an atom to zero if the absolute value of that component is less than the trim level. Unit in angstrom. Suggested to be siginificantly smaller than the major component(s) of the position vector.
 */
let trimLevel = 0.01

var filePass = false
var xyzSet = XYZFile()

while !filePass {
    do {
        let filePath: String = String(describing: input(name: "XYZ file Path", type: "string"))
        xyzSet = try XYZFile(fromPath: filePath)
        filePass = true
        print("Successfully imported from XYZ file.")
    } catch let error {
        print("Error: \(error). Please try again.")
    }
}

guard let rawAtoms = xyzSet.atoms else {
    print("No Atoms. Fatal Error.")
    exit(-1)
}

var combAtoms: [Atom] = rawAtoms.select(byName: "C") + rawAtoms.select(byName: "O")
combAtoms.trimDownRVecs(level: trimLevel)

// Fix the first atom
let A1 = combAtoms[0]
print("The first atom has been fixed.")

let combrAtoms = combAtoms.filter({$0 != A1})
let initialSMol = StrcMolecule(Set([A1]))

var possibleList: [StrcMolecule] = []

let tInitial = Date()

rcsAction(rAtoms: combrAtoms, stMolList: [initialSMol], tolRange: tolerenceLevel, possibleList: &possibleList)

let timeTaken = -(Double(tInitial.timeIntervalSinceNow))
let roundTTaken = String(format: "%.4f", timeTaken)

var iCode = 0

// Printing results
for pMol in possibleList {
    iCode = iCode + 1
    print("**** Molecule No.\(iCode) ****")
    for atom in pMol.atoms {
        print("\(atom.name)     \(atom.rvec!.dictVec)")
    }
}

print("=================")
print("Duration of computation: \(roundTTaken) s.")
print("Number of combinations to work with: \(pow(8, combrAtoms.count)).")
print("Number of plausible results: \(possibleList.count).")
