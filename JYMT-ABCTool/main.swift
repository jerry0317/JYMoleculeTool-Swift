//
//  main.swift
//  JYMT-ABCTool
//
//  Created by Jerry Yan BA on 7/10/19.
//  Copyright © 2019 Jerry Yan. All rights reserved.
//

import Foundation

print("""
This is a program under developement to provide a tool for implementing Kraitchman's equations to find the absolute values of the position vector (components) of each atoms in the molecule.

The program will take data of A,B,C (rotational constants) of the original molecule and the ones after single isotopic substitution.

The goal for the program is to design a tool to make the JYMT-StructureFinder more practical in lab use.

Keep an eye on it.

""")

//let i = tensorIFromABC(1936.55844e6, 1228.63567e6, 1127.02099e6)
//let ip = tensorIFromABC(1929.20910e6, 1226.98871e6, 1125.97313e6)
//let di = ip - i
//let p = tensorDeltaP(fromDeltaI: di)
//let v = 1e10 * rVecFromSIS(mu: reducedMass(M: 120 * PhysConst.amu, deltaM: PhysConst.amu), deltaP: p!, I: i)!
//print(ip.matrixForm)
//print(di.matrixForm)
//print(p!.matrixForm)
//print(v)
