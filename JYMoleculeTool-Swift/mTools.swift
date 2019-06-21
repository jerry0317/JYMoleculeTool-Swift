//
//  mTools.swift
//  JYMoleculeTool-Swift
//
//  Created by Jerry Yan on 6/20/19.
//  Copyright © 2019 Jerry Yan. All rights reserved.
//

import Foundation
import Accelerate

/**
 Position vector (three-dimensional)
 */
struct Vector3D{
    var x: Double
    var y: Double
    var z: Double
    
    init(_ x: Double = 0, _ y: Double = 0, _ z: Double = 0){
        self.x = x
        self.y = y
        self.z = z
    }
    
    init(_ dictVec: [Double]){
        self.init()
        self.dictVec = dictVec
    }
    
    var dictVec: [Double] {
        get {
            return [x, y, z]
        }
        set(newDictVec) {
            x = newDictVec[0]
            y = newDictVec[1]
            z = newDictVec[2]
        }
    }
    
}

extension Vector3D: Hashable {
    static func == (lhs: Vector3D, rhs: Vector3D) -> Bool {
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

prefix operator -
extension Vector3D {
    /**
     Inverse Vector
     */
    static prefix func - (vector: inout Vector3D) -> Vector3D {
        return Vector3D(-vector.x, -vector.y, -vector.z)
    }
}

infix operator +: AdditionPrecedence
infix operator -: AdditionPrecedence
infix operator .*: MultiplicationPrecedence
extension Vector3D {
    /**
     Vector Addition
     */
    static func + (left: Vector3D, right: Vector3D) -> Vector3D {
        return Vector3D(left.x + right.x, left.y + right.y, left.z + right.z)
    }
    /**
     Vector Subtraction
     */
    static func - (left: Vector3D, right: Vector3D) -> Vector3D {
        return Vector3D(left.x - right.x, left.y - right.y, left.z - right.z)
    }
    /**
     Dot Product
     */
    static func .* (left: Vector3D, right: Vector3D) -> Double {
        return left.x * right.x + left.y * right.y + left.z * right.z
    }
}

extension Vector3D {
    /**
     Resign the vector based on |x|, |y|, and |z|.
     */
    func resign() -> [Vector3D] {
        var possibleList: [Vector3D] = []
        let signList = [[1,1,1], [1,1,-1], [1,-1,1], [1,-1,-1], [-1,1,1], [-1,1,-1], [-1,-1,1], [-1,-1,-1]]
        for sign in signList {
            var newDict: [Double] = [0,0,0]
            for i in [0,1,2] {
                newDict[i] = dictVec[i] * Double(sign[i])
            }
            let newRVec = Vector3D(newDict)
            possibleList.append(newRVec)
        }
        return possibleList
    }
}

/**
 Atom
 */
struct Atom {
    /**
     The name of the atom.
     */
    var name: String
    
    /**
     The position vector of the atom.
     */
    var rvec: Vector3D?
    
    init(_ name: String, _ rvec: Vector3D? = nil){
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
struct ChemBondType {
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
struct ChemBond {
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
struct ChemBondGraph {
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
struct StrcMolecule {
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
    
    mutating func addAtom(_ atom: Atom){
        atoms.insert(atom)
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


/**
 Resign the rvec for a list of atoms
 */
func findPossibleAtoms(_ atoms: [Atom]) -> [Atom] {
    var possibleList: [Atom] = []
    for atom in atoms {
        guard atom.rvec != nil else {
            continue
        }
        let possibleRvecList = atom.rvec!.resign()
        for possibleRvec in possibleRvecList {
            let newAtom = Atom(atom.name, possibleRvec)
            possibleList.append(newAtom)
        }
    }
    return possibleList
}

/**
 Calculate the distance between two atoms
 */
func atomDistance(_ atom1: Atom, _ atom2: Atom) -> Double?{
    guard atom1.rvec != nil && atom2.rvec != nil else {
        return nil
    }
    let dvec = atom1.rvec! - atom2.rvec!
    let d = sqrt(dvec .* dvec)
    return d
}

/**
 Filtering by bond length with the reference of bond type
 */
func bondTypeLengthFilter(_ atom1: Atom, _ atom2: Atom, _ bondType: ChemBondType, _ tolRange: Double = 0.1) -> Bool {
    let d = atomDistance(atom1, atom2)
    guard d != nil && bondType.validate() else {
        return false
    }
    if d! > (bondType.length! - tolRange) && d! < (bondType.length! + tolRange) {
        return true
    }
    else {
        return false
    }
}

/**
 Find possible bond types between two atom names
 */
func possibleBondTypes(_ atomName1: String, _ atomName2: String) -> [ChemBondType] {
    var possibleBondTypeList: [ChemBondType] = []
    for order in 1...4 {
        let bond = ChemBondType(atomName1, atomName2, order)
        if bond.validate() {
            possibleBondTypeList.append(bond)
        }
    }
    return possibleBondTypeList
}

/**
 Molecule constructor for an atom. One atom is compared with a valid structural molecule. The atom will be added to the structural molecule. If the atom is valid to be connected through certain bonds to the structural molecule, that bond will be added to the existing bond graphs. Otherwise, the bond graphs will be empty.
 
 - Parameter stMol: The existing valid structural molecule.
 
 - Parameter atom: The atom to test with the structural molecule `stMol`.
 
 - Parameter tolRange: The tolerance level, unit in angstrom.
 
 */

func bondLengthStrcMoleculeConstructor(stMol: StrcMolecule, atom: Atom, tolRange: Double = 0.1) -> StrcMolecule {
    var mol = stMol
    let bondGraphs = mol.bondGraphs
    
    if mol.size <= 0 {
        mol.addAtom(atom)
    }
    else {
        mol.bondGraphs.removeAll()
        
        for vAtom in stMol.atoms {
            let possibleBts = possibleBondTypes(vAtom.name, atom.name)
            for bondType in possibleBts {
                guard bondType.validate() else {
                    continue
                }
                var dPass = false
                if bondTypeLengthFilter(vAtom, atom, bondType, tolRange) {
                    let vRemainingAtoms = stMol.atoms.filter({$0 != vAtom})
                    dPass = true
                    for vRAtom in vRemainingAtoms {
                        guard let d: Double = atomDistance(vRAtom, atom) else {
                            dPass = false
                            continue
                        }
                        if d < (bondType.length! - tolRange) {
                            dPass = false
                        }
                    }
                    if dPass {
                        let pBond = ChemBond(vAtom, atom, bondType)
                        mol.addAtom(atom)
                        if stMol.size == 1 {
                            mol.bondGraphs.insert(ChemBondGraph(Set([pBond])))
                        }
                        else if stMol.size > 1 {
                            for bondGraph in bondGraphs {
                                var pBondGraph = bondGraph
                                pBondGraph.bonds.insert(pBond)
                                mol.bondGraphs.insert(pBondGraph)
                            }
                        }
                    }
                }
            }
        }
    }
    return mol
}
