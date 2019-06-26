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
let trimLevel = 0.05

let saveXYZ = false
var writePass = false
var writePath = URL(fileURLWithPath: "")

var filePass = false
var xyzSet = XYZFile()
var fileName = ""

while !filePass {
    do {
        let filePath: String = String(describing: input(name: "XYZ file Path", type: "string"))
        xyzSet = try XYZFile(fromPath: filePath)
        fileName = URL(fileURLWithPath: filePath).lastPathComponentName
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

if saveXYZ {
    while !writePass {
        let writePathUrl = URL(fileURLWithPath: String(describing: input(name: "XYZ exporting Path", type: "string")))
        if writePathUrl.hasDirectoryPath {
            writePath = writePathUrl
            writePass = true
        } else {
            print("Not a directory. Please try again.")
        }
    }
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

rcsAction(rAtoms: combrAtoms, stMolList: [initialSMol], tolRange: tolerenceLevel, possibleList: &possibleList, trueMol: StrcMolecule(Set(combAtoms)))

let timeTaken = -(Double(tInitial.timeIntervalSinceNow))

var iCode = 0

// Sort the possible List by CM deviation
possibleList.sort(by: {
    ($0.centerOfMass - combAtoms.centerOfMass).magnitude < ($1.centerOfMass - combAtoms.centerOfMass).magnitude
})

// Printing results
for pMol in possibleList {
    iCode = iCode + 1
    print("**** Molecule No.\(iCode) ****")
    if pMol.atoms == Set(combAtoms) {
        print("<Correct Molecule>")
    }
    let atomList = Array(pMol.atoms).sorted(by: {
        guard $0.rvec != nil && $1.rvec != nil else {
            return false
        }
        return $0.rvec!.magnitude > $1.rvec!.magnitude
    })
    let bondGraph = Array(pMol.bondGraphs)[0]
    
    for atom in atomList {
        print("\(atom.name)     \(atom.rvec!.dictVec)", terminator: "")
        if bondGraph.degreeOfAtom(atom) == 3 {
            let (adjacentAtoms, _) = bondGraph.adjacenciesOfAtom(atom)
            print("     D3APD: \(degreeThreeAtomPlanarDistance(center: atom, attached: adjacentAtoms)!.rounded(digitsAfterDecimal: 5))")
        }else{
            print()
        }
    }
    
//    print("--Bond information--")
//    for bond in bondGraph.bonds {
//        print("Bond code: \(bond.type.bdCode)   Bond distance: \(bond.distance!)")
//    }
    
    let cmVec = pMol.centerOfMass
    let cmDevVec = cmVec - combAtoms.centerOfMass
    print("- Center of Mass: \(cmVec.dictVec.rounded(digitsAfterDecimal: 4))")
    print("- CM Deviation: \(cmDevVec.dictVec.rounded(digitsAfterDecimal: 4))")
    print("- CM Deviation Magnitude: \(cmDevVec.magnitude.rounded(digitsAfterDecimal: 5))")
    
    if saveXYZ {
        let xyzUrl = writePath.appendingPathComponent(fileName + "_" + String(Int(tInitial.timeIntervalSince1970)) + "_" + String(iCode) + ".xyz")
        let pMolXYZ = XYZFile(fromAtoms: atomList)
        do {
            try pMolXYZ.export(toFile: xyzUrl)
            print("xyz file has been saved.")
        } catch let error {
            print("An error occured: \(error).")
        }
    }
}

print("=================")
print("Duration of computation: \(timeTaken.rounded(digitsAfterDecimal: 4)) s.")
print("Total number of combinations to work with: \(pow(8, combrAtoms.count)).")
print("Total number of possible results: \(possibleList.count).")
