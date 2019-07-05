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
    
    /**
     The magnitude of the vector.
     */
    var magnitude: Double {
        return sqrt(self.*self)
    }
    
    /**
     The array form of the vector. Returns [x,y,z].
     */
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
     Re-sign the vector based on |x|, |y|, and |z|.
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
    
    /**
     Possible atoms after re-signing it.
     */
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
     The valence of the atom.
     */
    var valence: Int {
        return Constants.Chem.valences[name] ?? 0
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
    var order: Int
    
    init(_ atom1: String, _ atom2: String, _ bondOrder: Int = 1){
        self.atomNames = [atom1, atom2]
        self.order = bondOrder
    }
    
    /**
     The bond code for the bond. For example, the single carbon-carbon bond is denoted as "CC1".
     */
    var bdCode: String {
        var atomNamesArray = atomNames
        if atomNamesArray[0] > atomNamesArray[1] {
            atomNamesArray.swapAt(0, 1)
        }
        let code = atomNamesArray[0] + atomNamesArray[1] + String(order)
        return code
    }
    
    /**
     The bond length of this bond type.
     */
    var length: Double? {
        return bondLengths[bdCode]
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
    
    /**
     The interatomic distance between the two atoms in the bond.
     */
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
    
    /**
     Find the VSEPR graph based on the given center atom in the bond graph.
     */
    func findVseprGraph(_ atom: Atom) -> VSEPRGraph {
        let (_, bonds) = adjacenciesOfAtom(atom)
        return VSEPRGraph(bonds: Set(bonds))
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
 A protocol to control the subgraphs of a bond graph.
 */
protocol SubChemBondGraph {
    /**
     The bonds engaged in this sub bond graph.
     */
    var bonds: Set<ChemBond> { get set }
}

/**
 A subgraph of the bond graph that centered on one atom for VSEPR analysis. (Not finished)
 */
struct VSEPRGraph: SubChemBondGraph {
    /**
     The bonds engaged in this VSEPR graph.
     */
    var bonds: Set<ChemBond>
    
    /**
     The VSEPR type of this graph. Automatically determined based on the information of bonds.
     */
    var type: Constants.Chem.VESPRType? {
        return determineType()
    }
    
    /**
     The center atom. Automatically determined from the information of bonds. *(Computationally intensive, may be modified later)*
     */
    var center: Atom? {
        guard bonds.count >= 2 else {
            return nil
        }
        let atomList = bonds.flatMap { Array($0.atoms) }
        var centerAtom: Atom? = nil
        for atom in atomList {
            if (atomList.filter { $0 == atom }).count == bonds.count {
                centerAtom = atom
                break
            }
        }
        return centerAtom
    }
    
    /**
     The atoms attached to the center atom. *(Computationally intensive, may be modified later)*
     */
    var attached: [Atom] {
        return bonds.flatMap({ Array($0.atoms) }).filter { $0 != center }
    }
    
    /**
     The degree of the center atom.
     */
    var degree: Int {
        return bonds.count
    }
    
    /**
     The valence of the center atom. *(Computationally intensive, may be modified later)*
     */
    var valenceAllowed: Int {
        return center?.valence ?? 0
    }
    
    /**
     The valence occupied by the bonds attached to the center atom.
     */
    var valenceOccupied: Int {
        return bonds.reduce(0, { $0 + $1.type.order })
    }
    
    /**
     The valence available on the center atom. *(Computationally intensive, may be modified later)*
     */
    var valenceAvailable: Int {
        return valenceAllowed - valenceOccupied
    }
    
    /**
     To determine if the bond orders are all the same.
     */
    var completelySymmetric: Bool {
        var bondList = Array(bonds)
        let fOrder = bondList[0].type.order
        bondList.removeFirst()
        for bond in bondList {
            if bond.type.order != fOrder {
                return false
            }
        }
        return true
    }
    
    /**
     To determine the VESPR type of the graph.
     */
    private func determineType() -> Constants.Chem.VESPRType? {
        guard bonds.count >= 2 else {
            return nil
        }
        let numOfLonePairsAndH = 4 - valenceOccupied
        switch (degree, numOfLonePairsAndH) {
        case (2, 0):
            return .ax2e0
        case (2, 1):
            return .ax2e1
        case (2, 2):
            return .ax2e2
        case (2, 3):
            return .ax2e3
        case (3, 0):
            return .ax3e0
        case (3, 1):
            return .ax3e1
        case (3, 2):
            return .ax3e2
        case (4, 0):
            return .ax4e0
        case (4, 1):
            return .ax4e1
        case (4, 2):
            return .ax4e2
        default:
            break
        }
        return nil
    }
    
    /**
     A filter to determine if this VSEPR graph is valid.
     */
    func filter(bondAngleTolRatio tolRatio: Double = 0.1) -> Bool {
        guard let cAtom: Atom = center else {
            return false
        }
        guard (cAtom.valence - valenceOccupied) >= 0 else {
            return false
        }
        let vType = type
        switch vType {
        case .ax2e0, .ax2e1, .ax2e2, .ax3e0, .ax3e1, .ax4e0:
            var range = 0.0...0.0
            switch vType {
            case .ax2e0: // linear
                range = 180.0...180.0
            case .ax3e0, .ax2e1: // trigonal planar
                range = 120.0...120.0
            case .ax4e0, .ax3e1, .ax2e2: // tetrahedral
                range = 90...109.5
            default:
                break
            }
            return bondAnglesFilter(center: cAtom, bonds: Array(bonds), range: range)
        default:
            break
        }
        return true
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
    
    /**
     Add an atom to the molecule.
     */
    mutating func addAtom(_ atom: Atom){
        atoms.insert(atom)
    }
    
    /**
     Combine two molecules given they are 'atom match' (`~=`) to each other.
     
     - The function effectively joins the bondgraphs of two 'atom match' molecules.
     */
    @discardableResult
    mutating func combine(_ stMol: StrcMolecule) -> Bool {
        if stMol ~= self {
            bondGraphs = bondGraphs.union(stMol.bondGraphs)
            return true
        } else {
            return false
        }
    }
    
    /**
     Return the molecule after the combination of two 'atom match' molecules.
     */
    func combined(_ stMol: StrcMolecule) -> StrcMolecule? {
        var result = stMol
        if result ~= self {
            result.combine(self)
            return result
        } else {
            return nil
        }
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

infix operator ~=: ComparisonPrecedence
infix operator !~=: ComparisonPrecedence

extension StrcMolecule {
    /**
     Atom Match
     - Returns true if the two molecules have the same set of atoms.
     */
    static func ~= (lhs: StrcMolecule, rhs: StrcMolecule) -> Bool {
        return
            lhs.atoms == rhs.atoms
    }
    
    /**
     Atom Not Match
     - Returns true if the two molecules does not the same set of atoms.
     */
    static func !~= (lhs: StrcMolecule, rhs: StrcMolecule) -> Bool {
        return !(lhs ~= rhs)
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
    guard let d = atomDistance(atom1, atom2), let length = bondType.length else {
        return false
    }
    if d < (length - tolRange) || d > (length + tolRange) {
        return false
    }
    else {
        return true
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

func possibleBondTypesDynProgrammed(_ atomName1: String, _ atomName2: String) -> [ChemBondType] {
    let btTuple = BondTypeTuple(atomName1, atomName2)
    var bondTypes = globalCache.possibleBondTypes[btTuple]
    
    if bondTypes == nil {
        bondTypes = possibleBondTypes(atomName1, atomName2)
        globalCache.possibleBondTypes[btTuple] = bondTypes!
    }
    
    return bondTypes!
}

/**
 Filtering by bond angle with a given range.
 */
func bondAnglesFilter(center aAtom: Atom, bonds: [ChemBond], range: ClosedRange<Double>, tolRatio: Double = 0.1) -> Bool {
    var thetaList: [Double?] = []
    if bonds.count == 2 {
        thetaList = [bondAngle(center: aAtom, bonds: bonds, unit: UnitAngle.degrees)]
    } else if bonds.count >= 2 {
        let rList = bondAngles(center: aAtom, bonds: bonds, unit: UnitAngle.degrees)
        thetaList = rList.map { $0.0 }
    } else if bonds.count >= 0{
        return true
    } else {
        return false
    }
    
    let lowerBound = range.lowerBound * (1 - tolRatio)
    let upperBound = range.upperBound * (1 + tolRatio)
    let tRange: ClosedRange<Double> = lowerBound...upperBound
    for theta in thetaList {
        if theta == nil || !tRange.contains(theta!) {
            return false
        }
    }
    return true
}

/**
 Molecule constructor for an atom. One atom is compared with a valid structural molecule. The atom will be added to the structural molecule. If the atom is valid to be connected through certain bonds to the structural molecule, that bond will be added to the existing bond graphs. Otherwise, the bond graphs will be empty.
 
 - Parameter stMol: The existing valid structural molecule.
 
 - Parameter atom: The atom to test with the structural molecule `stMol`.
 
 - Parameter tolRange: The tolerance level acting in bond length filters, unit in angstrom.
 
 - Parameter tolRatio: The tolerance ratio acting in bond angle filters. Reference with the VSEPR graph.
 
 */
func strcMoleculeConstructor(stMol: StrcMolecule, atom: Atom, tolRange: Double = 0.1, tolRatio: Double = 0.1) -> StrcMolecule {
    var mol = stMol
    let bondGraphs = mol.bondGraphs
    
    if mol.size <= 0 {
        mol.addAtom(atom)
    }
    else {
        mol.bondGraphs.removeAll()
        for vAtom in stMol.atoms {
            let possibleBts = possibleBondTypesDynProgrammed(vAtom.name, atom.name)
            for bondType in possibleBts {
                if bondTypeLengthFilter(vAtom, atom, bondType, tolRange) {
                    let vRemainingAtoms = stMol.atoms.filter({$0 != vAtom})
                    var dPass = true
                    for vRAtom in vRemainingAtoms {
                        guard let d: Double = atomDistance(vRAtom, atom) else {
                            dPass = false
                            break
                        }
                        if d < (bondType.length! - tolRange) {
                            dPass = false
                            break
                        }
                    }
                    if dPass {
                        let pBond = ChemBond(vAtom, atom, bondType)
                        mol.addAtom(atom)
                        if stMol.size == 1 {
                            mol.bondGraphs.insert(ChemBondGraph(Set([pBond])))
                        } else if stMol.size > 1 {
                            for bondGraph in bondGraphs {
                                var pBondGraph = bondGraph
                                pBondGraph.bonds.insert(pBond)
                                var bPass = true
                                for bAtom in mol.atoms {
                                    if pBondGraph.degreeOfAtom(bAtom) >= 2 {
                                        let vseprGraph = pBondGraph.findVseprGraph(bAtom)
                                        if !vseprGraph.filter(bondAngleTolRatio: tolRatio) {
                                            bPass = false
                                            break
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

/**
 The recursion constructor. It takes a test atom and compared it with a valid structrual molecule. It will return the possible structural molecules as the atom and the molecule join together.
 */
func rcsConstructor(atom: Atom, stMol: StrcMolecule, tolRange: Double = 0.1, tolRatio: Double = 0.1) -> [StrcMolecule] {
    let possibleAtoms = atom.possibles
    var possibleSMList: [StrcMolecule] = []
    
    for pAtom in possibleAtoms {
        let sMol = strcMoleculeConstructor(stMol: stMol, atom: pAtom, tolRange: tolRange, tolRatio: tolRatio)
        
        if !sMol.bondGraphs.isEmpty {
            possibleSMList.append(sMol)
        }
    }
    return possibleSMList
}

/**
 The recursion action to perform recursion.
 
 - TODO: Optimize with tail recursion.
 */
func rcsAction(rAtoms: [Atom], stMolList mList: [StrcMolecule], tolRange: Double = 0.1, tolRatio: Double = 0.1, possibleList pList: inout [StrcMolecule], trueMol: StrcMolecule? = nil) {
    if rAtoms.isEmpty {
        for stMol in mList {
            if pList.filter({ $0 == stMol }).isEmpty {
                let saList = pList.filter { $0 ~= stMol }
                if saList.isEmpty {
                    pList.append(stMol)
                    print("Current possible results: \(pList.count)", terminator: "")
                    if trueMol != nil && trueMol!.atoms == stMol.atoms {
                        print("     !!## <The correct structure> has been found.")
                    } else {
                        print()
                    }
                } else {
                    let daList = pList.filter { !saList.contains($0) }
                    let newStMol: StrcMolecule = saList.reduce(StrcMolecule(stMol.atoms), { $0.combined($1) ?? $0 })
                    pList = daList + [newStMol]
                    
                    print("Current possible results: \(pList.count)", terminator: "")
                    print("     ## Duplicated")
                }
            }
        }
    } else {
        for stMol in mList {
            for rAtom in rAtoms {
                let rcsTuple = rcsConstructorTuple(atom: rAtom, stMol: stMol)
                if globalCache.rcsConstructorCache.contains(rcsTuple) {
                    continue
                } else {
                    globalCache.rcsConstructorCache.insert(rcsTuple)
                }
                let newMList = rcsConstructor(atom: rAtom, stMol: stMol, tolRange: tolRange, tolRatio: tolRatio)
                if !newMList.isEmpty {
                    let newRAtoms = rAtoms.filter({$0 != rAtom})
                    rcsAction(rAtoms: newRAtoms, stMolList: newMList, tolRange: tolRange, tolRatio: tolRatio, possibleList: &pList, trueMol: trueMol)
                }
            }
        }
    }
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
 The bond angle of any number of bonds of an atom. Returns tuple of angle and the set of the adjacent atoms involved in the two bonds of the bond angle.
 */
func bondAngles(center: Atom, attached: [Atom]) -> [(Measurement<UnitAngle>?, Set<Atom>)] {
    let attachedAtomsList = combinationsDynProgrammed(attached, 2)
    return attachedAtomsList.map { (bondAngle(center: center, attached: Array($0)), $0) }
}

/**
 The bond angle of any number of bonds of an atom. Returns tuple of angle and the set of the adjacent atoms involved in the two bonds of the bond angle.
 */
func bondAngles(center: Atom, bonds: [ChemBond]) -> [(Measurement<UnitAngle>?, Set<ChemBond>)] {
    let attachedAtomsList = combinationsDynProgrammed(bonds, 2)
    return attachedAtomsList.map { (bondAngle(center: center, bonds: Array($0)), $0) }
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

/**
 The bond angle of any number of bonds of an atom. Returns tuple of the value of the angle given provided unit and the set of the adjacent atoms involved in the two bonds of the bond angle.
 */
func bondAngles(center: Atom, attached: [Atom], unit: UnitAngle) -> [(Double?, Set<Atom>)] {
    let attachedAtomsList = combinationsDynProgrammed(attached, 2)
    return attachedAtomsList.map { (bondAngle(center: center, attached: Array($0), unit: unit), $0) }
}

/**
 The bond angle of any number of bonds of an atom. Returns tuple of the value of the angle given provided unit and the set of the adjacent atoms involved in the two bonds of the bond angle.
 */
func bondAngles(center: Atom, bonds: [ChemBond], unit: UnitAngle) -> [(Double?, Set<ChemBond>)] {
    let attachedAtomsList = combinationsDynProgrammed(bonds, 2)
    return attachedAtomsList.map { (bondAngle(center: center, bonds: Array($0), unit: unit), $0) }
}
