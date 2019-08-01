//
//  main.swift
//  JYMT-ABCTool
//
//  Created by Jerry Yan BA on 7/10/19.
//  Copyright © 2019 Jerry Yan. All rights reserved.
//

import Foundation
import JYMTBasicKit

printWelcomeBanner("ABC Tool")

var (sabcSet, fileName) = sabcFileInput()
print()

var (saveResults, writePath) = exportingPathInput("xyz")
print()

print("Number of atoms: \(sabcSet.substituted!.count)")
print()

let tInitial = Date()
var xyzSet = sabcSet.exportToXYZ()
let timeTaken = -(Double(tInitial.timeIntervalSinceNow))

print("**------------Results------------**")
print(xyzSet)

if saveResults {
    xyzSet.note = "* unsigned positions (absolute values)"
    xyzSet.safelyExport(toFile: writePath.appendingPathComponent(fileName + ".xyz"))
}

print("-----------------------------------")
print("Computation time: \(timeTaken.rounded(digitsAfterDecimal: 4)) s.")
print()
