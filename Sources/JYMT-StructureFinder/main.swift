//
//  main.swift
//  JYMoleculeTool-Swift
//
//  Created by Jerry Yan on 6/20/19.
//  Copyright © 2019 Jerry Yan. All rights reserved.
//

import Foundation
import JYMTBasicKit

printWelcomeBanner("Structure Finder")

var saveResults = true
var writePath = URL(fileURLWithPath: "")

var xyzSet = XYZFile()
var fileName = ""

fileInput(name: "XYZ file", tryAction: { (filePath) in
    xyzSet = try XYZFile(fromPath: filePath)
    fileName = URL(fileURLWithPath: filePath).lastPathComponentName
    return true
})

guard let rawAtoms = xyzSet.atoms else {
    print("No Atoms. Exit with fatal Error.")
    exit(-1)
}

print()

fileInput(message: "XYZ & MOL exporting Path (leave empty if not to save)", successMessage: false) { (writePathInput) in
    if writePathInput.isEmpty {
        saveResults = false
        print("The results will not be saved.")
        return true
    } else {
        let writePathUrl = URL(fileURLWithPath: writePathInput)
        guard writePathUrl.hasDirectoryPath else {
            print("Not a valid directory. Please try again.")
            return false
        }
        writePath = writePathUrl
        print("The results will be saved in \(writePath.relativeString).")
        return true
    }
}

print()

/**
 Tolerance level used in bond length filter. Unit in angstrom.
 */
let tolerenceLevel = Double(input(name: "Bond length tolerance level in angstrom", type: "double", defaultValue: 0.01, doubleRange: 0...1, printAfterSec: true)) ?? 0.01
print()

/**
 Tolerance ratio used in bond angle filter.
 */
let toleranceRatio = Double(input(name: "Bond angle tolerance ratio", type: "double", defaultValue: 0.1, doubleRange: 0...1, printAfterSec: true)) ?? 0.1
print()

/**
 The number of digits preserved after rounding the position vector of the atoms. The rounding level is suggested to be significantly smaller than the major component(s) of the position vector.
 */
let roundDigits = Int(input(name: "Rounded digits (of position) after decimal", type: "int", defaultValue: 2, doubleRange: 0...10, printAfterSec: true)) ?? 2
print()

/**
 Trim level used to trim down the component of the position vector of an atom to zero if the absolute value of that component is less than the trim level. Unit in angstrom. Suggested to be siginificantly smaller than the major component(s) of the position vector.
 */
let trimLevel = Double(input(name: "Trim level (of position) in angstrom", type: "double", defaultValue: 0, doubleRange: 0...1, printAfterSec: true)) ?? 0
print()

var combAtoms: [Atom] = rawAtoms.removed(byElement: .hydrogen)

combAtoms.trimDownRVecs(level: trimLevel)
combAtoms.roundRVecs(digitsAfterDecimal: roundDigits)

print("Total number of non-hydrogen atoms: \(combAtoms.count).")

combAtoms.sort(by: { $0.rvec!.magnitude > $1.rvec!.magnitude })

// Fix the first atom
let A1 = combAtoms[0]
print("The first atom has been located.")
print()

let combrAtoms = combAtoms.removed(A1)
let initialSMol = StrcMolecule(Set([A1]))

var possibleList: [StrcMolecule] = []

let tInitial = Date()
print("Computation started on \(displayTime(tInitial)).")
print()

possibleList = rcsActionDynProgrammed(rAtoms: combrAtoms, stMolList: [initialSMol], tolRange: tolerenceLevel, tolRatio: toleranceRatio, trueMol: StrcMolecule(Set(combAtoms)))

let timeTaken = -(Double(tInitial.timeIntervalSinceNow))

print("Computation completed. Generating results...")
print()

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
        try FileManager.default.createDirectory(at: newDirectoryPath.appendingPathComponent("xyz", isDirectory: true), withIntermediateDirectories: false)
        try FileManager.default.createDirectory(at: newDirectoryPath.appendingPathComponent("mol", isDirectory: true), withIntermediateDirectories: false)
        writePath = newDirectoryPath
    } catch let error {
        print("An error occured when creating a new directory: \(error).")
    }
}

let xyzPath = writePath.appendingPathComponent("xyz", isDirectory: true)
let molPath = writePath.appendingPathComponent("mol", isDirectory: true)

log.add("-----------------------------------")
log.add("[Basic Settings]")
log.add("Bond length tolerance level: \(tolerenceLevel)")
log.add("Bond angle tolerance ratio: \(toleranceRatio)")
log.add("Rounded digits after decimal: \(roundDigits)")
log.add("Trim level: \(trimLevel)")
log.add("-----------------------------------")
// Printing results
for pMol in possibleList {
    iCode = iCode + 1
    log.add("**** Molecule No.\(iCode) ****")
    if pMol.atoms == Set(combAtoms) {
        log.add("<Original Structure>")
        success = true
    }
    let atomList = Array(pMol.atoms).sorted(by: {
        guard $0.rvec != nil && $1.rvec != nil else {
            return false
        }
        return $0.rvec!.magnitude > $1.rvec!.magnitude
    })
    let firstBondGraph = Array(pMol.bondGraphs)[0]
    
    for atom in atomList {
        log.add("\(atom.name)     \(atom.rvec!.dictVec)", terminator: "")
        let (adjacentAtoms, _) = firstBondGraph.adjacenciesOfAtom(atom)
        let vGraph = firstBondGraph.findVseprGraph(atom)
        let vseprType = vGraph.type
        log.add("     VSEPR Type: ", terminator: "")
        if vseprType != nil {
            log.add(vseprType!, terminator: "")
        } else {
            log.add("n/a  ", terminator: "")
        }
        
        let bAString: String = bondAnglesInDeg(center: atom, attached: adjacentAtoms).map({ Array($0.1.map { $0.name }).joined(separator: atom.name) + ": " + String($0.0!.rounded(digitsAfterDecimal: 1)) + "°" }).joined(separator: ", ")
        log.add("     BAs: [" + bAString + "]", terminator: "")
        log.add()
    }
    
    log.add("--Bond information--")
    log.add("The number of possible bond graphs: \(pMol.bondGraphs.count)")
    log.add("====The first bond graph====")
    for bond in firstBondGraph.bonds {
        log.add("Bond code: \(bond.type.bdCode?.rawValue ?? "N/A")   Bond distance: \(bond.distance!.rounded(digitsAfterDecimal: 4))")
    }
    
    let cmVec = pMol.centerOfMass
    let cmDevVec = cmVec - combAtoms.centerOfMass
    log.add("- Center of Mass: \(cmVec.dictVec.rounded(digitsAfterDecimal: 4))")
    log.add("- CM Deviation: \(cmDevVec.dictVec.rounded(digitsAfterDecimal: 4))")
    log.add("- CM Deviation Magnitude: \(cmDevVec.magnitude.rounded(digitsAfterDecimal: 5))")
    
    if saveResults {
        // xyz saving
        let xyzUrl = xyzPath.appendingPathComponent(baseFileName + "_" + String(iCode) + ".xyz")
        let pMolXYZ = XYZFile(fromAtoms: atomList)
        pMolXYZ.safelyExport(toFile: xyzUrl)
        
        // mol saving
        var jCode = 0
        for bondGraph in pMol.bondGraphs {
            jCode += 1
            let molUrl = molPath.appendingPathComponent("\(baseFileName)_\(iCode)_\(jCode).mol")
            let molFile = MOLFile(title: fileName, comment: "*Generated by JYMT-StructureFinder", atoms: pMol.atoms, bonds: bondGraph.bonds)
            molFile.safelyExport(toFile: molUrl)
        }
    }
}

log.add("-----------------------------------")
log.add("[Molecule name] \(fileName)")
log.add("-- -- -- -- -- -- -- -- -- -- -- --")
log.add("[Note] ", terminator: "")
if success {
    log.add("The original structure is in the results.")
} else {
    log.add("The original structure is not in the results.")
}
log.add("-----------------------------------")
log.add("Duration of computation: \(timeTaken.rounded(digitsAfterDecimal: 4)) s.")
log.add("Total number of non-hydrogen atoms: \(combAtoms.count).")
log.add("Total number of combinations to work with: \(pow(8, combrAtoms.count)).")
log.add("Total number of possible structures: \(possibleList.count).")
log.add("Total number of possible bond graphs: \(possibleList.reduce(0, { $0 + $1.bondGraphs.count })).")
log.add("Reduction efficiency: \((Double(pow(8, Double(combrAtoms.count))) / Double(possibleList.count)).rounded(digitsAfterDecimal: 1)).")
log.add("-----------------------------------")

if saveResults {
    let txtUrl = writePath.appendingPathComponent(baseFileName + ".txt")
    do {
        try log.save(asURL: txtUrl)
        print("Results have been saved to txt file.")
    } catch let error {
        print("Failed to save the results. An error occured: \(error).")
        print("Note: You may save the console log for further reference of the results.")
    }
}
print()
print("**------------Results------------**")
log.print()

print("Exited on \(displayTime(Date())).")
print()
