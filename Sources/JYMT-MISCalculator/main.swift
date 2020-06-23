//
//  main.swift
//  JYMT-MISCalculator
//
//  Created by Jerry Yan on 7/26/19.
//

import Foundation
import JYMTBasicKit
import JYMTAdvancedKit

printWelcomeBanner("MIS Calculator")

var (sabcSet, fileName) = sabcFileInput()
print()

var (saveResults, writePath) = exportingPathInput("log")
print()

var log = TextFile()

let sisCount = sabcSet.substituted!.count

var maximumDepth: Int = 2
maximumDepth = Int(input(name: "maximum depth", type: "int", defaultValue: 2, doubleRange: 0...Double(Int.max), printAfterSec: true)) ?? 2
print()

print("Number of atoms in SIS Data: \(sisCount)")
print()
log.add("----Imported Data----")
log.add("[Parent Molecule]")
let mhzForm = sabcSet.original!.megaHertzForm().map { String(format: "%.4f", $0) }
log.add("PM    A: \(mhzForm[0])    B: \(mhzForm[1])   C: \(mhzForm[2])   Mass: \(sabcSet.original!.totalAtomicMass)")
log.add("[Single Isotopic Substitutions]")
for (i, sisTuple) in sabcSet.substituted!.enumerated() {
    let sisMhzForm = sisTuple.megaHertzForm().map { String(format: "%.4f", $0) }
    let isotopeStr = sisTuple.substitutedIsotopes[0].0.rawValue + String(i + 1)
    log.add("\(toPrintWithSpace(isotopeStr, 4))  A: \(sisMhzForm[0])    B: \(sisMhzForm[1])   C: \(sisMhzForm[2])   Isotope: \(sisTuple.substitutedIsotopes[0].1)")
}
log.add("---------------------")
log.add()

let tInitial = Date()
let baseFileName = fileName.appendedUnixTime(tInitial)

if saveResults {
    (writePath, _) = createNewDirectory(baseFileName, at: writePath)
}

var rawAtoms = sabcSet.exportToAtoms()

for rAtom in rawAtoms {
    guard let number = rAtom.element?.secondCommonMassNumber else {
        continue
    }
    rAtom.massNumber = number
}

let identifiers = rawAtoms.compactMap { $0.identifier }
let idDict: [Int: Int] = identifiers.enumerated().reduce(into: [Int: Int](), { $0[$1.1] = $1.0 })
let stringIdsOfAtoms = createStringIdFunction(idDict)

guard rawAtoms.count == sisCount else {
    fatalError("Fatal Error: fail to calculate from SIS to atoms")
}

let A1 = selectFarthestAtom(from: rawAtoms) ?? rawAtoms[0]
print()

print("Calculating possible combinations...\n")

let combrAtoms = rawAtoms.removed(A1)
let initialSMol = StrcMolecule(Set([A1]))

let possibleMols = rcsActionDynProgrammed(rAtoms: combrAtoms, stMolList: [initialSMol], cache: &globalCache)

let possibleSAtoms: [[Atom]] = possibleMols.map({ Array($0.atoms) })

log.add("Total number of structural combinations: \(possibleSAtoms.count)\n")

log.add("----Possible Structural Combinations----")

for (i, pMol) in possibleMols.enumerated() {
    log.add("**** Structure No.\(i+1) ****")
    var atomTupList: [(Atom, Int)] = pMol.atoms.map { ($0, idDict[$0.identifier!]! )}
    
    atomTupList.sort(by: { $0.1 < $1.1 })
    
    for (atom, id) in atomTupList {
        let isotopeStr = atom.name + String(id + 1)
        log.add("\(toPrintWithSpace(isotopeStr, 4)) \(atom.rvec!.dictVec.sroundedString(digitsAfterDecimal: 5))")
    }
    
    log.add("====Bond Information====")
    for bond in pMol.bondGraphs.first!.bonds {
        let atoms = Array(bond.atoms)
        let atomsStrings = stringIdsOfAtoms(atoms)
        let atomsStr: String = atomsStrings.2.map( { atomsStrings.0[$0] }).joined(separator: "-")
        log.add("Atoms: \(atomsStr)   Distance: \(bond.distance!.srounded(digitsAfterDecimal: 5))")
    }
    if i < possibleMols.endIndex - 1 {
        log.add()
    }
}

log.add("-----------------------------------------\n")

let maxDep = min(maximumDepth, sisCount)
for depth in 1..<(maxDep + 1) {
    log.add("----\(depthForISStr(depth)) Isotopic Substitutions----")
    if depth == 1 && !possibleSAtoms.isEmpty {
        misHandler(log: &log, depth: depth, original: sabcSet.original!, subAtoms: possibleSAtoms[0], str: stringIdsOfAtoms)
    } else {
        for (i, sAtoms) in possibleSAtoms.enumerated() {
            log.add("**** Structure No.\(i+1) ****")
            misHandler(log: &log, depth: depth, original: sabcSet.original!, subAtoms: sAtoms, str: stringIdsOfAtoms)
            if i < possibleSAtoms.endIndex - 1 {
                log.add()
            }
        }
    }
    log.add("-------------------------------------\n")
}

let timeTaken = -(Double(tInitial.timeIntervalSinceNow))

log.add("Time of Computation: \(timeTaken.rounded(digitsAfterDecimal: 4)) s.")
log.add()

if saveResults {
    let txtUrl = writePath.appendingPathComponent(baseFileName + ".txt")
    log.safelyExport(toFile: txtUrl)
}
