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

print("""
MIS Calculator will be a new tool to calculate the rotational constants information for multiple isotopic substitutions. The initial data source will be from single isotopic substitutions (sabc file), while `.xyz`, `.mol` are planned to be added in the future.

The program should predict the rotational constants under multiple isotopic substitutions from the given single isotopic substitution information (or data of the molecular structure). The outcomes are not expected to be unique if the structural information is not determined in the data source, but the program should perform as well as JYMT-StructureFinder in terms of reduction efficiency.

The program will utilize JYMTAdvancedKit, which depends on the interoperability bewteen Swift and Python to utilize the NumPy library to calculate the advanced matrix linear algebra.

This tool is still in initial development. Keep an eye on it.
""")
