//
//  miscToolsAdv.swift
//  JYMTAdvancedKit
//
//  Created by Jerry Yan on 8/8/19.
//

import Foundation
import JYMTBasicKit

/**
 A printing function for isotopic substitutions used by ABC Calculator and MIS Calculator.
 */
public func misHandler(log: inout TextFile, depth: Int, original: ABCTuple, subAtoms: [Atom], str: (([Atom]) -> ([String], [Int], [Int]))) {
    var rABC = MISFromSubstitutedAtoms(depth: depth, original: original, substitutedAtoms: subAtoms)
    rABC.sort(by: { str($0.0).1.reduce(0, +) < str($1.0).1.reduce(0, +)})
    for (atoms, abc) in rABC {
        let atomsStrings = str(atoms)
        let atomsStr = atomsStrings.2.map( { atomsStrings.0[$0] }).joined(separator: ",")
        let misMhzForm = abc.megaHertzForm().map { String(format: "%.6f", $0) }
        log.add("\(toPrintWithSpace(atomsStr, 4 * depth))  A: \(misMhzForm[0])    B: \(misMhzForm[1])   C: \(misMhzForm[2])")
    }
}
