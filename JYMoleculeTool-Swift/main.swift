//
//  main.swift
//  JYMoleculeTool-Swift
//
//  Created by Jerry Yan on 6/20/19.
//  Copyright © 2019 Jerry Yan. All rights reserved.
//

import Foundation

//
// Currently a test ground to test everything
//

print("Hello, World!")

//let vec1 = Vector3D(1,2,3)
//let vec2 = Vector3D(2,3,4)
//let vec3 = Vector3D(1,2,3)
//
//print(vec1 == vec2)
//print(vec1 == vec3)

//let bond = ChemBondType("C", "O")
//let bond2 = ChemBondType("C", "C", 2)
//let bond3 = ChemBondType("C", "O", 1)
//print(bond == bond2)
//print(bond == bond3)

//let bond = ChemBondType("C", "C")
//print(bond.validate())

//let bond = ChemBond(Atom("C"), Atom("C"), ChemBondType("C", "C"))
//let bond2 = ChemBond(Atom("C"), Atom("C"), ChemBondType("C", "C", 1))
//print(bond == bond2)

let vec1 = Vector3D(1.5,2.3,3.2)
let vec2 = Vector3D(1.2,-1.2,9.0)
print(vec1 .* vec2)
