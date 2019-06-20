//
//  mTools.swift
//  JYMoleculeTool-Swift
//
//  Created by Jerry Yan on 6/20/19.
//  Copyright © 2019 Jerry Yan. All rights reserved.
//

import Foundation

/**
 Position vector (three-dimensional)
 */
class Vector{
    var x: Double
    var y: Double
    var z: Double
    
    init(_ x: Double = 0, _ y: Double = 0, _ z: Double = 0){
        self.x = x
        self.y = y
        self.z = z
    }
    
}

extension Vector: Hashable {
    static func == (lhs: Vector, rhs: Vector) -> Bool {
        return
            lhs.x == rhs.x &&
                lhs.y == rhs.y &&
                lhs.z == rhs.z
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
        hasher.combine(z)
    }
}

/**
 Atom
 */
class Atom {
    /**
     The name of the atom.
     */
    var name: String
    
    /**
     The position vector of the atom.
     */
    var rvec: Vector?
    
    init(_ name: String, _ rvec: Vector? = nil){
        self.name = name
        self.rvec = rvec
    }
}

extension Atom: Hashable {
    static func == (lhs: Atom, rhs: Atom) -> Bool {
        return
            lhs.name == rhs.name &&
            lhs.rvec == rhs.rvec
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(rvec)
    }
}

/**
 Chemical bond type (between two atoms)
 */
class ChemBondType {
    /**
     The names of the two atoms in the chemical bond.
     */
    var atomNames: Set<String>
    
    /**
     The order of the bond.
     */
    var bondOrder: Int
    
    init(_ atom1: String, _ atom2: String, _ bondOrder: Int = 1){
        self.atomNames = [atom1, atom2]
        self.bondOrder = bondOrder
    }
    
    /**
     The bond code for the bond. For example, the single carbon-carbon bond is denoted as "CC1".
     */
    var bdCode: String {
        var code = ""
        var atomNamesArray = Array(atomNames)
        atomNamesArray.sort()
        for a in atomNamesArray {
            code.append(a)
        }
        code.append(String(bondOrder))
        return code
    }
    
    /**
     The bond length of this bond type.
     */
    var length: Double? {
        if validate(){
            return bondLengths[bdCode]
        } else {
            return nil
        }
    }
    
    /**
     The dictionary storing the known bond lengths.
     */
    private let bondLengths = [
        "CC1": 1.54,
        "CC2": 1.34,
        "CC3": 1.20,
        "CO1": 1.43,
        "OO1": 1.48,
        "OO2": 1.21
    ]
    
    /**
     Tells if a bond type is valid.
     */
    func validate() -> Bool{
        guard let _ = bondLengths[bdCode] else {
            return false
        }
        return true
    }

}

extension ChemBondType: Hashable {
    static func == (lhs: ChemBondType, rhs: ChemBondType) -> Bool {
        return
            lhs.bdCode == rhs.bdCode
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(bdCode)
    }
}

/**
 Chemical bond between two atoms.
 */
class ChemBond {
    /**
     The atoms engaged in the chemical bond.
     */
    var atoms: Set<Atom>
    
    /**
     The type of the chemical bond.
     */
    var type: ChemBondType
    
    init(_ atom1: Atom, _ atom2: Atom, _ bondType: ChemBondType){
        self.atoms = [atom1, atom2]
        self.type = bondType
    }
    
//    var distance: Double {
//
//    }
}

extension ChemBond: Hashable {
    static func == (lhs: ChemBond, rhs: ChemBond) -> Bool {
        return
            lhs.atoms == rhs.atoms &&
            lhs.type == rhs.type
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(atoms)
        hasher.combine(type)
    }
}

/**
 Chemical bond graph constructed by multiple bonds
 */
class ChemBondGraph {
    /**
     The bonds engaged in this bond graph.
     */
    var bonds: Set<ChemBond>
    
    init(_ bonds: Set<ChemBond> = Set()){
        self.bonds = bonds
    }
    
    /**
     The number of bonds that is connected to the atom.
     */
    func degreeOfAtom(_ atom: Atom) -> Int{
        var deg = 0
        for bond in bonds {
            if bond.atoms.contains(atom){
                deg = deg + 1
            }
        }
        return deg
    }
}

extension ChemBondGraph: Hashable {
    static func == (lhs: ChemBondGraph, rhs: ChemBondGraph) -> Bool {
        return lhs.bonds == rhs.bonds
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(bonds)
    }
}

/**
 Structural molecule: a not necessarily meaningful "molecule" with atoms constrained by serveral possible bond graphs
 */
class StrcMolecule {
    /**
     The atoms in this structural molecule.
     */
    var atoms: Set<Atom>
    
    /**
     The possible bond graphs to connect the atoms in this structural molecule. Not necessarily unique.
     */
    var bondGraphs: Set<ChemBondGraph>
    
    init(_ atoms: Set<Atom> = Set(), _ bondGraphs: Set<ChemBondGraph> = Set()) {
        self.atoms = atoms
        self.bondGraphs = bondGraphs
    }
    
    /**
     The number of atoms in this structual molecule.
     */
    var size: Int {
        return atoms.count
    }
}

extension StrcMolecule: Hashable {
    static func == (lhs: StrcMolecule, rhs: StrcMolecule) -> Bool {
        return
            lhs.atoms == rhs.atoms &&
            lhs.bondGraphs == rhs.bondGraphs
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(atoms)
        hasher.combine(bondGraphs)
    }
}
