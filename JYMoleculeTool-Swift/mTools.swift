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
struct Vector3D {
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
    
    subscript(index: Int) -> Double {
        get {
            return dictVec[index]
        }
        set {
            dictVec[index] = newValue
        }
    }
    
    var magnitude: Double {
        return sqrt(self.*self)
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
    
    /**
     Scalar projection of the vector onto another vector (not necessarily normal)
     */
    func scalarProject(on bVec: Vector3D) -> Double {
        return (self .* bVec) / bVec.magnitude
    }
    
    /**
     Vector projection of the vector onto another vector (not necessarily normal)
     */
    func vectorProject(on bVec: Vector3D) -> Vector3D {
        return (scalarProject(on: bVec) / bVec.magnitude) * bVec
    }
    
    /**
     The angle between the self vector and another vector. Returns a measurement with unit in UnitAngle.
     */
    func angle(to bVec: Vector3D) -> Measurement<UnitAngle> {
        let cosTheta = (self .* bVec) / (magnitude * bVec.magnitude)
        let theta = acos(cosTheta)
        return Measurement(value: theta, unit: UnitAngle.radians)
    }
    
    /**
     The angle between the self vector and another vector. Provided with the desired unit, the function will return the value of the angle.
     */
    func angle(to bVec: Vector3D, unit: UnitAngle) -> Double {
        return angle(to: bVec).converted(to: unit).value
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
infix operator **: MultiplicationPrecedence
infix operator *: MultiplicationPrecedence
infix operator /: MultiplicationPrecedence
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
    /**
     Cross Product
     */
    static func ** (left: Vector3D, right: Vector3D) -> Vector3D {
        return Vector3D(left.y * right.z - left.z * right.y, left.z * right.x - left.x * right.z, left.x * right.y - left.y * right.x)
    }
    /**
     Scalar Product
     */
    static func * (left: Double, right: Vector3D) -> Vector3D {
        return Vector3D(left * right.x, left * right.y, left * right.z)
    }
    /**
     Scalar Product
     */
    static func * (left: Vector3D, right: Double) -> Vector3D {
        return Vector3D(left.x * right, left.y * right, left.z * right)
    }
    /**
     Scalar Product (Division)
     */
    static func / (left: Vector3D, right: Double) -> Vector3D {
        return Vector3D(left.x / right, left.y / right, left.z / right)
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
        possibleList = Array(Set(possibleList)) // Remove duplicates
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
    
    var possibles: [Atom] {
        var possibleList: [Atom] = []
        if rvec == nil {
            return []
        } else {
            let possibleRvecList = rvec!.resign()
            for possibleRvec in possibleRvecList {
                let newAtom = Atom(name, possibleRvec)
                possibleList.append(newAtom)
            }
        }
        return possibleList
    }
    
    /**
     Trim down the component of the position vector of an atom to zero if the absolute value of that component is less than the trim level.
     */
    @discardableResult
    mutating func trimDownRVec(level trimLevel: Double = 0.01) -> Bool {
        guard rvec != nil else {
            return false
        }
        for i in 0...2 {
            if abs(rvec!.dictVec[i]) <= trimLevel {
                rvec!.dictVec[i] = 0
            }
        }
        return true
    }
    
    /**
     Round the component of the position vector to provided digits after decimal.
     */
    @discardableResult
    mutating func roundRVec(digitsAfterDecimal digit: Int) -> Bool {
        guard rvec != nil else {
            return false
        }
        for i in 0...2 {
            rvec!.dictVec[i].round(digitsAfterDecimal: digit)
        }
        return true
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
    var atomNames: Array<String>
    
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
        var atomNamesArray = atomNames
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
    private var bondLengths: [String: Double] {
        return Constants.Chem.bondLengths
    }
    
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
    
    var distance: Double? {
        let atomList = Array(atoms)
        guard atomList.count == 2 else {
            return nil
        }
        return atomDistance(atomList[0], atomList[1])
    }
    
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
            if bond.atoms.contains(atom) {
                deg = deg + 1
            }
        }
        return deg
    }
    
    /**
     The adjacencies of atom. Returns the neighboring atoms and connecting bonds.
     */
    func adjacenciesOfAtom(_ atom: Atom) -> ([Atom], [ChemBond]) {
        var atomList: [Atom] = []
        var bondList: [ChemBond] = []
        for bond in bonds {
            if bond.atoms.contains(atom) {
                let rAtoms = Array(bond.atoms).filter({$0 != atom})
                atomList.append(rAtoms[0])
                bondList.append(bond)
            }
        }
        return (atomList, bondList)
    }
}

/**
 A protocol to control the subgraphs of a bond graph.
 */
protocol SubChemBondGraph {
    var bonds: Set<ChemBond> { get set }
}

/**
 A subgraph of the bond graph that centered on one atom for VSEPR analysis. (Not finished)
 */
struct VESPRSubBondGraph: SubChemBondGraph {
    var bonds: Set<ChemBond>
    
    var type: Constants.Chem.VESPRType
    
    var center: Atom
    
    var attached: [Atom]
    
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
    
    /**
     The center of mass of the molecule
     */
    var centerOfMass: Vector3D {
        return atoms.centerOfMass
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
 A bond angle filter for AX2E2 type. (Experimental)
 */
func ax2e2BondAngleFilter(center aAtom: Atom, attached xAtoms: [Atom], range: ClosedRange<Double> = 90.0...120.0) -> Bool {
    let bondAngle = degreeTwoAtomBondAngle(center: aAtom, attached: xAtoms, unit: UnitAngle.degrees)
    if bondAngle == nil || !range.contains(bondAngle!) {
        return false
    } else {
        return true
    }
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
                                var bPass = true
                                // Experimental
                                for bAtom in mol.atoms {
                                    if pBondGraph.degreeOfAtom(bAtom) == 2 {
                                        let (adjacentAtoms, _) = pBondGraph.adjacenciesOfAtom(bAtom)
                                        if !ax2e2BondAngleFilter(center: bAtom, attached: adjacentAtoms) {
                                            bPass = false
                                        }
                                    }
                                }
                                if bPass {
                                    mol.bondGraphs.insert(pBondGraph)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    return mol
}

extension Array where Element == Atom {
    /**
     Extension of Atom array to be selected by name
     */
    func select(byName name: String) -> [Atom] {
        return filter({$0.name == name})
    }
    
    /**
     Extension of Atom array to be removed by name
     */
    func removed(byName name: String) -> [Atom] {
        return filter({$0.name != name})
    }
    
    /**
     Extension of Atom array to remove atoms by name
     */
    mutating func remove(byName name: String) {
        self = removed(byName: name)
    }
    
    /**
     Extension of Atom array to be removed by a specific atom.
     */
    func removed(_ atom: Atom) -> [Atom] {
        return filter({$0 != atom})
    }
    
    /**
     Extension of Atom array to remove a specific atom.
     */
    mutating func remove(_ atom: Atom) {
        self = removed(atom)
    }
    
    /**
     Trim down the position vectors of all the atoms in the array.
     */
    @discardableResult
    mutating func trimDownRVecs(level trimLevel: Double = 0.005) -> [Bool] {
        return self.indices.map({self[$0].trimDownRVec(level: trimLevel)})
    }
    
    /**
     Round the position vectors of all the atoms in the array.
     */
    @discardableResult
    mutating func roundRVecs(digitsAfterDecimal digits: Int) -> [Bool] {
        return self.indices.map({self[$0].roundRVec(digitsAfterDecimal: digits)})
    }
}

extension Collection where Iterator.Element == Atom {
    /**
     Possible atoms after resigning
     */
    var possibles: [Atom] {
        var possibleList: [Atom] = []
        for atom in self {
            possibleList.append(contentsOf: atom.possibles)
        }
        return possibleList
    }
    
    /**
     The center of mass of several atoms
     */
    var centerOfMass: Vector3D {
        var cmVec = Vector3D()
        if self.count > 0 {
            var totalMass: Double = 0.0
            for atom in self {
                guard let rvec: Vector3D = atom.rvec else {
                    continue
                }
                guard let mass: Double = Constants.Chem.atomicMasses[atom.name] else {
                    continue
                }
                totalMass = totalMass + mass
                cmVec = cmVec + mass * rvec
            }
            cmVec = cmVec / totalMass
        }
        return cmVec
    }
}

/**
 The recursion constructor. It takes a test atom and compared it with a valid structrual molecule. It will return the possible structural molecules as the atom and the molecule join together.
 */
func rcsConstructor(atom: Atom, stMol: StrcMolecule, tolRange: Double = 0.1) -> [StrcMolecule] {
    let possibleAtoms = atom.possibles
    var possibleSMList: [StrcMolecule] = []
    
    for pAtom in possibleAtoms {
        let sMol = bondLengthStrcMoleculeConstructor(stMol: stMol, atom: pAtom, tolRange: tolRange)
        
        if !sMol.bondGraphs.isEmpty {
            possibleSMList.append(sMol)
        }
    }
    return possibleSMList
}

/**
 The recursion action to perform recursion.
 */
func rcsAction(rAtoms: [Atom], stMolList mList: [StrcMolecule], tolRange: Double = 0.1, possibleList pList: inout [StrcMolecule], trueMol: StrcMolecule? = nil) {
    if !rAtoms.isEmpty {
        for stMol in mList {
            for rAtom in rAtoms {
                let newMList = rcsConstructor(atom: rAtom, stMol: stMol, tolRange: tolRange)
                if !newMList.isEmpty {
                    let newRAtoms = rAtoms.filter({$0 != rAtom})
                    rcsAction(rAtoms: newRAtoms, stMolList: newMList, tolRange: tolRange, possibleList: &pList, trueMol: trueMol)
                }
            }
        }
    } else {
        for stMol in mList {
            if pList.filter({$0 == stMol}).isEmpty {
                pList.append(stMol)
                print("Number of possible results: \(pList.count)", terminator: "")
                if trueMol != nil && trueMol!.atoms == stMol.atoms {
                    print("     ## The correct structure has been found.")
                } else {
                    print()
                }
            }
        }
    }
}

/**
 (D3APD) The distance between a degree-3 atom and the co-plane of its three adjacent atom.
 */
func degreeThreeAtomPlanarDistance(center: Atom, attached: [Atom]) -> Double? {
    let attachedRVecs = attached.compactMap { $0.rvec }
    guard center.rvec != nil && attachedRVecs.count == 3 else{
        return nil
    }
    let dVec1 = attachedRVecs[0] - attachedRVecs[1]
    let dVec2 = attachedRVecs[0] - attachedRVecs[2]
    let nVec = dVec1 ** dVec2
    let dVec = center.rvec! - attachedRVecs[0]
    
    return abs(dVec.scalarProject(on: nVec))
}

/**
 (D2ABA) The angle between the two adjacent atoms of a degree-2 atom.
 */
func degreeTwoAtomBondAngle(center: Atom, attached: [Atom]) -> Measurement<UnitAngle>? {
    let attachedRVecs = attached.compactMap { $0.rvec }
    guard center.rvec != nil && attachedRVecs.count == 2 else {
        return nil
    }
    let dVec1 = center.rvec! - attachedRVecs[0]
    let dVec2 = center.rvec! - attachedRVecs[1]
    
    return dVec1.angle(to: dVec2)
}

/**
 The bond angle of the two bonds of an atom. Takes the two attached atoms as parameter.
 */
func bondAngle(center: Atom, attached: [Atom]) -> Measurement<UnitAngle>? {
    let attachedRVecs = attached.compactMap { $0.rvec }
    guard center.rvec != nil && attachedRVecs.count == 2 else {
        return nil
    }
    let dVec1 = center.rvec! - attachedRVecs[0]
    let dVec2 = center.rvec! - attachedRVecs[1]
    
    return dVec1.angle(to: dVec2)
}

/**
 The bond angle of the two bonds of an atom. Takes the two attached bonds as parameter.
 */
func bondAngle(center: Atom, bonds: [ChemBond]) -> Measurement<UnitAngle>? {
    var attachedAtoms = bonds.flatMap { $0.atoms }
    attachedAtoms.remove(center)
    attachedAtoms = Array(Set(attachedAtoms))
    
    return bondAngle(center: center, attached: attachedAtoms)
}


/**
 (D2ABA) The angle between the two adjacent atoms of a degree-2 atom. Return the value of the angle given provided unit.
 */
func degreeTwoAtomBondAngle(center: Atom, attached: [Atom], unit: UnitAngle) -> Double? {
    return degreeTwoAtomBondAngle(center: center, attached: attached)?.converted(to: unit).value
}

/**
 The bond angle of the two bonds of an atom. Takes the two attached atoms as parameter. Return the value of the angle given provided unit.
 */
func bondAngle(center: Atom, attached: [Atom], unit: UnitAngle) -> Double? {
    return bondAngle(center: center, attached: attached)?.converted(to: unit).value
}

/**
 The bond angle of the two bonds of an atom. Takes the two attached bonds as parameter. Return the value of the angle given provided unit.
 */
func bondAngle(center: Atom, bonds: [ChemBond], unit: UnitAngle) -> Double? {
    return bondAngle(center: center, bonds: bonds)?.converted(to: unit).value
}
