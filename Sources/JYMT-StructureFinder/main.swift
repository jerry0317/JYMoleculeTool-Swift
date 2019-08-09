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

var modes: Set<SFProgramMode> = [.ordinary]

if CommandLine.arguments.count >= 2 {
    if CommandLine.arguments.contains("-t") {
        modes.remove(.ordinary)
        modes.insert(.test)
        print("[Test mode] This session will run in test mode.\n")
    }
    if CommandLine.arguments.contains("-s") {
        modes.insert(.simple)
        print("[Simple mode] All the parameters will be set as default values.\n")
    }
}

let testMode = modes.contains(.test)

var (xyzSet, fileName) = xyzFileInput()

let rawAtoms = xyzSet.atoms!

print()

var (saveResults, writePath) = exportingPathInput("xyz & mol")
print()

/**
 Tolerance level used in bond length filter. Unit in angstrom.
 */
var toleranceLevel: Double = 0.01

/**
 Tolerance ratio used in bond angle filter.
 */
var toleranceRatio: Double = 0.1

/**
 The number of digits preserved after rounding the position vector of the atoms. The rounding level is suggested to be significantly smaller than the major component(s) of the position vector.
 */
var roundDigits: Int = 2

/**
 Trim level used to trim down the component of the position vector of an atom to zero if the absolute value of that component is less than the trim level. Unit in angstrom. Suggested to be siginificantly smaller than the major component(s) of the position vector.
 */
var trimLevel: Double = 0

if !modes.contains(.simple) {
    toleranceLevel = Double(input(name: "Bond length tolerance level in angstrom", type: "double", defaultValue: 0.01, doubleRange: 0...1, printAfterSec: true)) ?? 0.01
    print()

    toleranceRatio = Double(input(name: "Bond angle tolerance ratio", type: "double", defaultValue: 0.1, doubleRange: 0...1, printAfterSec: true)) ?? 0.1
    print()

    roundDigits = Int(input(name: "Rounded digits (of position) after decimal", type: "int", defaultValue: 2, doubleRange: 0...10, printAfterSec: true)) ?? 2
    print()

    trimLevel = Double(input(name: "Trim level (of position) in angstrom", type: "double", defaultValue: 0, doubleRange: 0...1, printAfterSec: true)) ?? 0
    print()
}

var combAtoms: [Atom] = rawAtoms.removed(byElement: .hydrogen)

combAtoms.trimDownRVecs(level: trimLevel)
combAtoms.roundRVecs(digitsAfterDecimal: roundDigits)

print("Total number of non-hydrogen atoms: \(combAtoms.count).")

// Fix the first atom
let A1 = selectFarthestAtom(from: combAtoms) ?? rawAtoms[0]
print()

let combrAtoms = combAtoms.removed(A1)
let initialSMol = StrcMolecule(Set([A1]))

var possibleList: [StrcMolecule] = []

let tInitial = Date()
print("Computation started on \(displayTime(tInitial)).")
print()

possibleList = rcsActionDynProgrammed(rAtoms: combrAtoms, stMolList: [initialSMol], tolRange: toleranceLevel, tolRatio: toleranceRatio, trueMol: StrcMolecule(Set(combAtoms)), testMode: testMode)

let timeTaken = -(Double(tInitial.timeIntervalSinceNow))

print("Computation completed. Generating results...")
print()

// Sort the possible List by CM deviation
possibleList.sort(by: {
    ($0.centerOfMass - combAtoms.centerOfMass).magnitude < ($1.centerOfMass - combAtoms.centerOfMass).magnitude
})

let idGraphs = possibleList.reduce(Set<HashGraph>(), {
    $0.union($1.bondGraphs.map({ $0.identifierGraph }))
})

let elementGraphs = possibleList.reduce(Set<HashGraph>(), {
    $0.union($1.bondGraphs.map({ $0.elementGrpah }))
})

var log = TextFile()
var iCode = 0
var success = false
let baseFileName = fileName + "_" + String(Int(tInitial.timeIntervalSince1970))

var (xyzPath, molPath) = (writePath, writePath)

if saveResults {
    let cndResult = createNewDirectory(baseFileName, subDirectories: ["xyz", "mol"], at: writePath)
    writePath = cndResult.0
    xyzPath = cndResult.1[0]
    molPath = cndResult.1[1]
}

print("**------------Results------------**")
log.add("-----------------------------------")
log.add("[Basic Settings]")
if testMode {
    log.add("<Test Mode>")
}
log.add("Bond length tolerance level: \(toleranceLevel)")
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
        if firstBondGraph.degreeOfAtom(atom) == 3 {
            log.add("     D3APD: \(degreeThreeAtomPlanarDistance(center: atom, attached: adjacentAtoms)!.rounded(digitsAfterDecimal: 5))", terminator: "")
        }
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
log.add("Total number of Lewis structures: between \(elementGraphs.count) and \(idGraphs.count).")
log.add("Reduction efficiency: \((Double(pow(8, Double(combrAtoms.count))) / Double(possibleList.count)).rounded(digitsAfterDecimal: 1)).")
log.add("-----------------------------------")

if saveResults {
    let txtUrl = writePath.appendingPathComponent(baseFileName + ".txt")
    log.safelyExport(toFile: txtUrl)
}
print()

print("Exited on \(displayTime(Date())).")
print()
