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

var (xyzSet, fileName) = xyzFileInput()

let rawAtoms = xyzSet.atoms!

print()

print("Molecule name: \(fileName)")
print("Number of atoms: \(rawAtoms.count)")
print("Total Atomic Mass: \(rawAtoms.totalAtomicMass.rounded(digitsAfterDecimal: 4)) amu")
print("Center of Mass: \(rawAtoms.centerOfMass.dictVec.rounded(digitsAfterDecimal: 4)) Å")
print()

let tInitial = Date()
guard let abc = xyzSet.calculateABC() else {
    fatalError("Unable to calculate the rotational constants")
}

let timeTaken = -(Double(tInitial.timeIntervalSinceNow))
let MHzForm = abc.megaHertzForm(roundDigits: 1)

print("**------------Result------------**")
print("A: \(MHzForm[0])    B: \(MHzForm[1])    C: \(MHzForm[2])   (MHz)")
print("-----------------------------------")
print("Computation time: \(timeTaken.rounded(digitsAfterDecimal: 4)) s.")
print()
