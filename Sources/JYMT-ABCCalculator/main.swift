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

print("Number of atoms: \(rawAtoms.count)")
print("Total Mass: \(rawAtoms.totalAtomicMass)")
print("Center of Mass: \(rawAtoms.centerOfMass)")
print()

let tInitial = Date()
let abc = xyzSet.calculateABC()!
let timeTaken = -(Double(tInitial.timeIntervalSinceNow))

print("**------------Result------------**")
print("[Unit in MHz]")
print("A: \(abc.A.rounded(digitsAfterDecimal: 1))    B: \(abc.B.rounded(digitsAfterDecimal: 1))    C: \(abc.C.rounded(digitsAfterDecimal: 1))")
print("-----------------------------------")
print("Computation time: \(timeTaken.rounded(digitsAfterDecimal: 4)) s.")
print()
