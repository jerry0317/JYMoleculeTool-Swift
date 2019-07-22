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

var saveResults = true
var writePath = URL(fileURLWithPath: "")
var sabcSet = SABCFile()
var fileName = ""

fileInput(name: "SABC file") { (filePath) -> Bool in
    sabcSet = try SABCFile(fromPath: filePath)
    if !sabcSet.isValid {
        print("Not a valid SABC file.")
        return false
    }
    fileName = URL(fileURLWithPath: filePath).lastPathComponentName
    return true
}

fileInput(message: "XYZ exporting Path (leave empty if not to save)", successMessage: false) { (writePathInput) in
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
        print("The result will be saved in \(writePath.relativeString).")
        return trues
    }
}

print("Number of atoms: \(sabcSet.substituted!.count)")

let tInitial = Date()
let xyzSet = sabcSet.exportToXYZ()
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
