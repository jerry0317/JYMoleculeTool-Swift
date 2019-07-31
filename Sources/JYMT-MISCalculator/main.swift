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
print("Number of atoms in SIS: \(sisCount)")
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

var rawAtoms = sabcSet.exportToAtoms()

for rAtom in rawAtoms {
    guard let element = rAtom.element, let number = element.secondCommonMassNumber else {
        continue
    }
    rAtom.massNumber = number
}

let identifiers = rawAtoms.map { $0.identifier }

var idDict = [Int: Int]()

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

for (i, id) in identifiers.enumerated() {
    guard id != nil else {
        continue
    }
    idDict[id!] = i
}

guard rawAtoms.count == sisCount else {
    print("Fatal Error: fail to calculate from SIS to atoms")
    exit(-1)
}

rawAtoms.sort(by: { $0.rvec!.magnitude > $1.rvec!.magnitude })
let nonZeroAtoms = rawAtoms.filter({ !$0.rvec!.dictVec.contains(0.0) })

// Fix the first atom
let A1 = nonZeroAtoms.isEmpty ? rawAtoms[0] : nonZeroAtoms[0]
print("The first atom has been located.")
print()

print("Calculating possible combinations...\n")

let combrAtoms = rawAtoms.removed(A1)
let initialSMol = StrcMolecule(Set([A1]))

let possibleMols = rcsActionDynProgrammed(rAtoms: combrAtoms, stMolList: [initialSMol])

print()

let possibleSAtoms: [[Atom]] = possibleMols.map({ Array($0.atoms) })

log.add("Total number of structural combinations: \(possibleSAtoms.count)\n")

log.add("----Possible Structural Combinations----")

for (i, pMol) in possibleMols.enumerated() {
    log.add("**** Structure No.\(i+1) ****")
    var atomTupList: [(Atom, Int)] = pMol.atoms.map { ($0, idDict[$0.identifier!]! )}
    
    atomTupList.sort(by: { $0.1 < $1.1 })
    
    for (atom, id) in atomTupList {
        let isotopeStr = atom.name + String(id + 1)
        log.add("\(toPrintWithSpace(isotopeStr, 4)) \(atom.rvec!.dictVec.rounded(digitsAfterDecimal: 4))")
    }
    
    log.add("====Bond Information====")
    for bond in pMol.bondGraphs.first!.bonds {
        let atoms = Array(bond.atoms)
        let atomsStrings = stringIdsOfAtoms(atoms)
        let atomsStr: String = atomsStrings.2.map( { atomsStrings.0[$0] }).joined(separator: "-")
        log.add("Atoms: \(atomsStr)   Distance: \(bond.distance!.rounded(digitsAfterDecimal: 4))")
    }
    if i < possibleMols.endIndex - 1 {
        log.add()
    }
}

log.add("-----------------------------------------\n")

for depth in 1...maximumDepth {
    log.add("----\(depth)-atom Isotopic Substitutions----")
    for (i, sAtoms) in possibleSAtoms.enumerated() {
        log.add("**** Structure No.\(i+1) ****")
        var rABC = MISFromSubstitutedAtoms(depth: depth, original: sabcSet.original!, substitutedAtoms: sAtoms)
        rABC.sort(by: { stringIdsOfAtoms($0.0).1.reduce(0, +) < stringIdsOfAtoms($1.0).1.reduce(0, +)})
        for (atoms, abc) in rABC {
            let atomsStrings = stringIdsOfAtoms(atoms)
            let atomsStr = atomsStrings.2.map( { atomsStrings.0[$0] }).joined(separator: ",")
            let misMhzForm = abc.megaHertzForm().map { String(format: "%.6f", $0) }
            log.add("\(toPrintWithSpace(atomsStr, 4 * depth))  A: \(misMhzForm[0])    B: \(misMhzForm[1])   C: \(misMhzForm[2])")
        }
        if i < possibleSAtoms.endIndex - 1 {
            log.add()
        }
    }
    log.add("-------------------------------------\n")
}

let timeTaken = -(Double(tInitial.timeIntervalSinceNow))

log.add("Time of Computation: \(timeTaken.rounded(digitsAfterDecimal: 4)) s.")
log.add()

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
