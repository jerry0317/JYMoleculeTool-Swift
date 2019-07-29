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

//var saveResults = true
//var writePath = URL(fileURLWithPath: "")
//var sabcSet = SABCFile()
//var fileName = ""
//
//fileInput(name: "SABC file") { (filePath) -> Bool in
//    sabcSet = try SABCFile(fromPath: filePath)
//    if !sabcSet.isValid {
//        print("Not a valid SABC file.")
//        return false
//    }
//    fileName = URL(fileURLWithPath: filePath).lastPathComponentName
//    return true
//}
//
//fileInput(message: "log exporting Path (leave empty if not to save)", successMessage: false) { (writePathInput) in
//    if writePathInput.isEmpty {
//        saveResults = false
//        print("The results will not be saved.")
//        return true
//    } else {
//        let writePathUrl = URL(fileURLWithPath: writePathInput)
//        guard writePathUrl.hasDirectoryPath else {
//            print("Not a valid directory. Please try again.")
//            return false
//        }
//        writePath = writePathUrl
//        print("The result will be saved in \(writePath.relativeString).")
//        return true
//    }
//}
//
//let sisCount = sabcSet.substituted!.count
//
//var maximumDepth: Int = 2
//
//maximumDepth = Int(input(name: "Maximum depth", type: "int", defaultValue: 2, doubleRange: 0...Int.max, printAfterSec: true)) ?? 2
//
//print()
//print("Number of atoms in SIS: \(sisCount)")
//print()
//
//let tInitial = Date()
//let rawAtoms = sabcSet.exportToAtoms()



