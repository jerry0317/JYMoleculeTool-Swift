//
//  main.swift
//  JYMT-ABCCalculator
//
//  Created by Jerry Yan on 7/19/19.
//

import Foundation
import JYMTBasicKit
import JYMTAdvancedKit

printWelcomeBanner("ABC Calculator")

var log = TextFile()

var (xyzSet, fileName) = xyzFileInput()
print()

var (saveResults, writePath) = exportingPathInput("log")
print()

var maximumDepth: Int = 2
maximumDepth = Int(input(name: "maximum depth", type: "int", defaultValue: 1, doubleRange: 0...Double(Int.max), printAfterSec: true)) ?? 1
print()

var rawAtoms = xyzSet.atoms!

let identifiers = rawAtoms.compactMap { $0.identifier }
let idDict: [Int: Int] = identifiers.enumerated().reduce(into: [Int: Int](), { $0[$1.1] = $1.0 })
let stringIdsOfAtoms = createStringIdFunction(idDict)

log.add("Molecule name: \(fileName)")
log.add("Number of atoms: \(rawAtoms.count)")
log.add("Total Atomic Mass: \(rawAtoms.totalAtomicMass.rounded(digitsAfterDecimal: 4)) amu")
log.add("Center of Mass: \(rawAtoms.centerOfMass.dictVec.rounded(digitsAfterDecimal: 4)) Å")
log.add()

rawAtoms.setMassNumbersToMostCommon()

let tInitial = Date()
let baseFileName = fileName.appendedUnixTime(tInitial)
guard let abcTup = xyzSet.calculateABC() else {
    fatalError("Unable to calculate the rotational constants")
}
let MHzForm = abcTup.megaHertzForm(roundDigits: 6)

log.add("**--------Parent Molecule---------**")
log.add("PM    A: \(MHzForm[0])    B: \(MHzForm[1])    C: \(MHzForm[2])   (MHz)")
log.add("-----------------------------------")
log.add()

rawAtoms.setMassNumbersToSecondCommon()

let maxDep = min(maximumDepth, rawAtoms.count)
for depth in 1..<(maxDep + 1) {
    log.add("----\(depthForISStr(depth)) Isotopic Substitutions----")
    misHandler(log: &log, depth: depth, original: abcTup, subAtoms: rawAtoms, str: stringIdsOfAtoms)
    log.add("-------------------------------------\n")
}

let timeTaken = -(Double(tInitial.timeIntervalSinceNow))

log.add("-----------------------------------")
log.add("Computation time: \(timeTaken.rounded(digitsAfterDecimal: 4)) s.")
log.add()

if saveResults {
    let txtUrl = writePath.appendingPathComponent(baseFileName + ".txt")
    log.safelyExport(toFile: txtUrl)
}
