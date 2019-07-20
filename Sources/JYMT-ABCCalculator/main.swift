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

print("""
ABC Calculator will be a new tool to calculate the rotational constants A, B, and C from the structural information (XYZ). It is basically the inverse process of ABC Tool.

The program will utilize JYMTAdvancedKit, which depends on the interoperability bewteen Swift and Python to utilize the NumPy library to calculate the advanced matrix linear algebra.

This tool is still in early development. Keep an eye on it.
""")

print("***")
print("The use of eigensystem of a matrix is demonstrated as below:")
print("For example, for a matrix\n")

let m = Matrix([[1,2,3,4],[9,10,11,12],[5,6,7,8],[13,14,15,16]])!
print(m.matrixForm)

print("It has the following eigensystems: \n")
if let result = m.eigenSystem() {
    if let eigVals = result.0, let eigVecs = result.1 {
        let n = min(eigVals.count, eigVecs.count)
        for i in 0..<n {
            print("Eigenvalue: \(toPrintWithSpace(eigVals[i].rounded(digitsAfterDecimal: 4), 10)) Normalized eigenvector:   \(eigVecs[i].rounded(digitsAfterDecimal: 4))")
        }
    } else {
        print("[Error: Can't parse result from NumPy]")
    }
} else {
    print("[Error: Invalid Matrix]")
}

print()
