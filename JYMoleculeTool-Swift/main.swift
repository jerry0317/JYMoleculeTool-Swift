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
 Tolerance ratio used in bond angle filter.
 */
let toleranceRatio = 0.1


/**
 (Deprecated, may be invoked for future use)
 Trim level used to trim down the component of the position vector of an atom to zero if the absolute value of that component is less than the trim level. Unit in angstrom. Suggested to be siginificantly smaller than the major component(s) of the position vector.
 */
//let trimLevel = 0.05

/**
 The number of digits preserved after rounding the position vector of the atoms. The rounding level is suggested to be siginificantly smaller than the major component(s) of the position vector.
 */
let roundDigits = 2

var saveResults = true
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

if saveResults {
    while !writePass {
        let writePathInput = String(describing: input(name: "XYZ exporting Path (leave empty if not to save)", type: "string"))
        if writePathInput.isEmpty {
            saveResults = false
            writePass = true
            print("The results will not be saved.")
            break
        } else {
            let writePathUrl = URL(fileURLWithPath: writePathInput)
            guard writePathUrl.hasDirectoryPath else {
                print("Not a valid directory. Please try again.")
                continue
            }
            writePath = writePathUrl
            writePass = true
            print("The result will be saved in xyz files.")
            break
        }
    }

    
}

var combAtoms: [Atom] = rawAtoms.removed(byName: "H")
//combAtoms.trimDownRVecs(level: trimLevel)
combAtoms.roundRVecs(digitsAfterDecimal: roundDigits)

print("Total number of non-Hydrogen atoms: \(combAtoms.count)")

combAtoms.sort(by: { $0.rvec!.magnitude > $1.rvec!.magnitude })

// Fix the first atom
let A1 = combAtoms[0]
print("The first atom has been fixed.")

let combrAtoms = combAtoms.removed(A1)
let initialSMol = StrcMolecule(Set([A1]))

var possibleList: [StrcMolecule] = []

let tInitial = Date()
print("Computation started on \(displayTime(tInitial)).")

rcsAction(rAtoms: combrAtoms, stMolList: [initialSMol], tolRange: tolerenceLevel, tolRatio: toleranceRatio, possibleList: &possibleList, trueMol: StrcMolecule(Set(combAtoms)))

let timeTaken = -(Double(tInitial.timeIntervalSinceNow))

print("Computation completed. Generating results...")

// Sort the possible List by CM deviation
possibleList.sort(by: {
    ($0.centerOfMass - combAtoms.centerOfMass).magnitude < ($1.centerOfMass - combAtoms.centerOfMass).magnitude
})

var log = TextFile()
var iCode = 0
var success = false
let baseFileName = fileName + "_" + String(Int(tInitial.timeIntervalSince1970))

if saveResults {
    do {
        let newDirectoryPath = writePath.appendingPathComponent(baseFileName, isDirectory: true)
        try FileManager.default.createDirectory(at: newDirectoryPath, withIntermediateDirectories: false)
        writePath = newDirectoryPath
    } catch let error {
        print("An error occured when creating a new directory: \(error).")
    }
}

log.add("----------------------------------")
// Printing results
for pMol in possibleList {
    iCode = iCode + 1
    log.add("**** Molecule No.\(iCode) ****")
    if pMol.atoms == Set(combAtoms) {
        log.add("<Correct Molecule>")
        success = true
    }
    let atomList = Array(pMol.atoms).sorted(by: {
        guard $0.rvec != nil && $1.rvec != nil else {
            return false
        }
        return $0.rvec!.magnitude > $1.rvec!.magnitude
    })
    let bondGraph = Array(pMol.bondGraphs)[0]
    
    for atom in atomList {
        log.add("\(atom.name)     \(atom.rvec!.dictVec)", terminator: "")
        let (adjacentAtoms, _) = bondGraph.adjacenciesOfAtom(atom)
//        if bondGraph.degreeOfAtom(atom) == 3 {
//            print("     D3APD: \(degreeThreeAtomPlanarDistance(center: atom, attached: adjacentAtoms)!.rounded(digitsAfterDecimal: 5))", terminator: "")
//        }
        let vGraph = bondGraph.findVseprGraph(atom)
        let vseprType = vGraph.type
        log.add("     VSEPR Type: ", terminator: "")
        if vseprType != nil {
            log.add(vseprType!, terminator: "")
        } else {
            log.add("n/a  ", terminator: "")
        }
        
        let bAString: String = bondAngles(center: atom, attached: adjacentAtoms, unit: UnitAngle.degrees).map({ Array($0.1.map { $0.name }).joined(separator: atom.name) + ": " + String($0.0!.rounded(digitsAfterDecimal: 1)) + "°" }).joined(separator: ", ")
        log.add("     BAs: [" + bAString + "]", terminator: "")
        log.add()
    }
    
    log.add("--Bond information--")
    log.add("The number of possible bond graphs: \(pMol.bondGraphs.count)")
    log.add("====The first bond graph====")
    for bond in bondGraph.bonds {
        log.add("Bond code: \(bond.type.bdCode)   Bond distance: \(bond.distance!.rounded(digitsAfterDecimal: 4))")
    }
    
    let cmVec = pMol.centerOfMass
    let cmDevVec = cmVec - combAtoms.centerOfMass
    log.add("- Center of Mass: \(cmVec.dictVec.rounded(digitsAfterDecimal: 4))")
    log.add("- CM Deviation: \(cmDevVec.dictVec.rounded(digitsAfterDecimal: 4))")
    log.add("- CM Deviation Magnitude: \(cmDevVec.magnitude.rounded(digitsAfterDecimal: 5))")
    
    if saveResults {
        let xyzUrl = writePath.appendingPathComponent(baseFileName + "_" + String(iCode) + ".xyz")
        let pMolXYZ = XYZFile(fromAtoms: atomList)
        do {
            try pMolXYZ.export(toFile: xyzUrl)
            // log.add("Results have been saved to xyz files.")
        } catch let error {
            print("An error occured when saving xyz file: \(error).")
        }
    }
}

log.add("-----------------------------------")
log.add("[Molecule name] \(fileName)")
log.add("-- -- -- -- -- -- -- -- -- -- -- --")
log.add("[Result] ", terminator: "")
if success {
    log.add("Correct structure has been found.")
} else {
    log.add("Failed to find the correct structure.")
}
log.add("-----------------------------------")
log.add("Duration of computation: \(timeTaken.rounded(digitsAfterDecimal: 4)) s.")
log.add("Total number of non-Hydrogen atoms: \(combAtoms.count).")
log.add("Total number of combinations to work with: \(pow(8, combrAtoms.count)).")
log.add("Total number of possible results: \(possibleList.count).")
log.add("Reduction efficiency: \((Double(pow(8, Double(combrAtoms.count))) / Double(possibleList.count)).rounded(digitsAfterDecimal: 1))")

if saveResults {
    let txtUrl = writePath.appendingPathComponent(baseFileName + ".txt")
    do {
        try log.save(asURL: txtUrl)
        print("Results have been saved to txt file.")
    } catch let error {
        print("An error occured: \(error).")
    }
}

print("**------------Results------------**")
log.print()
