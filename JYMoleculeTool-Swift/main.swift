//
//  main.swift
//  JYMoleculeTool-Swift
//
//  Created by Jerry Yan on 6/20/19.
//  Copyright © 2019 Jerry Yan. All rights reserved.
//

import Foundation

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

let carbonAtoms: [Atom] = rawAtoms.select(byName: "C")
let oxygenAtoms: [Atom] = rawAtoms.select(byName: "O")

let combAtoms = carbonAtoms + oxygenAtoms

let tolerenceLevel = 0.1

let A1 = combAtoms[0]
print("The first atom has been fixed.")

let combrAtoms = combAtoms.filter({$0 != A1})

let initialSMol = StrcMolecule(Set([A1]))

var possibleList: [StrcMolecule] = []

let tInitial = Date()

rcsAction(rAtoms: combrAtoms, stMolList: [initialSMol], tolRange: tolerenceLevel, possibleList: &possibleList)

let tTaken = -(Double(tInitial.timeIntervalSinceNow))
let roundTTaken = String(format: "%.2f", tTaken)


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





