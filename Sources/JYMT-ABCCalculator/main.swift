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

var maximumDepth: Int = 2
maximumDepth = Int(input(name: "maximum depth", type: "int", defaultValue: 1, doubleRange: 0...Double(Int.max), printAfterSec: true)) ?? 1
print()

var rawAtoms = xyzSet.atoms!

let identifiers = rawAtoms.compactMap { $0.identifier }
let idDict: [Int: Int] = identifiers.enumerated().reduce(into: [Int: Int](), { $0[$1.1] = $1.0 })

func stringIdsOfAtoms(_ atoms: [Atom]) -> ([String], [Int], [Int]) {
    var result = [String]()
    var idResult = [Int]()
    for atom in atoms {
        guard let identifier = atom.identifier, let id = idDict[identifier] else {
            continue
        }
        result.append(atom.name + String(id + 1))
        idResult.append(id)
    }
    let order = (0..<result.count).sorted(by: {idResult[$0] < idResult[$1]})
    return (result, idResult, order)
}

log.add()

log.add("Molecule name: \(fileName)")
log.add("Number of atoms: \(rawAtoms.count)")
log.add("Total Atomic Mass: \(rawAtoms.totalAtomicMass.rounded(digitsAfterDecimal: 4)) amu")
log.add("Center of Mass: \(rawAtoms.centerOfMass.dictVec.rounded(digitsAfterDecimal: 4)) Å")
log.add()

rawAtoms.setMassNumbersToMostCommon()

let tInitial = Date()
guard let abcTup = xyzSet.calculateABC() else {
    fatalError("Unable to calculate the rotational constants")
}
let MHzForm = abcTup.megaHertzForm(roundDigits: 6)

print("**--------Parent Molecule---------**")
print("PM    A: \(MHzForm[0])    B: \(MHzForm[1])    C: \(MHzForm[2])   (MHz)")
print("-----------------------------------")
print()

rawAtoms.setMassNumbersToSecondCommon()

for depth in 1...maximumDepth {
    var depthStr = ""
    switch depth {
    case 1:
        depthStr = "Single"
    case 2:
        depthStr = "Double"
    case 3:
        depthStr = "Triple"
    default:
        depthStr = "\(depth)-atom"
    }
    log.add("----\(depthStr) Isotopic Substitutions----")
    var rABC = MISFromSubstitutedAtoms(depth: depth, original: abcTup, substitutedAtoms: rawAtoms)
    rABC.sort(by: { stringIdsOfAtoms($0.0).1.reduce(0, +) < stringIdsOfAtoms($1.0).1.reduce(0, +)})
    for (atoms, abc) in rABC {
        let atomsStrings = stringIdsOfAtoms(atoms)
        let atomsStr = atomsStrings.2.map( { atomsStrings.0[$0] }).joined(separator: ",")
        let misMhzForm = abc.megaHertzForm().map { String(format: "%.6f", $0) }
        log.add("\(toPrintWithSpace(atomsStr, 4 * depth))  A: \(misMhzForm[0])    B: \(misMhzForm[1])   C: \(misMhzForm[2])", terminator: "")
        if depth == 1 {
            log.add("   Isotope: \(atoms[0].massNumber ?? 0)")
        } else {
            log.add()
        }
    }
    log.add("-------------------------------------\n")
}

let timeTaken = -(Double(tInitial.timeIntervalSinceNow))

print("-----------------------------------")
print("Computation time: \(timeTaken.rounded(digitsAfterDecimal: 4)) s.")
print()
