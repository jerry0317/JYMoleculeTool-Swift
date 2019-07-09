//
//  caches.swift
//  JYMoleculeTool-Swift
//
//  Created by Jerry Yan on 7/4/19.
//  Copyright © 2019 Jerry Yan. All rights reserved.
//
//  This is a page mainly built for storing cache information to avoid repetitive calculation and optimize runtime.
//  (Currently experimental)
//

import Foundation

var globalCache = GlobalCache()

/**
 Provides a structure for cache that is easily to access globally.
 */
struct GlobalCache {
    var indexCombinations: [CombTuple: Set<Set<Int>>] = [:]
    
    var rcsConstructorCache: Set<RcsConstructorTuple> = []
    
    var possibleBondTypes: [Array<ChemElement>: [ChemBondType]] = [:]
    
    var stMolMatched: (Set<Set<Atom>>, Set<Set<Atom>>) = ([], [])
    
    var atomPossibles: [Atom: [Atom]] = [Atom: [Atom]]()
    
    var bdCodes: [ChemBondType: String] = [ChemBondType: String]()
    
    var bondAngles: [BondAngleTuple: Double] = [BondAngleTuple: Double]()
    
    var atomNeighbors: [AtomNeighborTuple: (Bool, Atom)] = [:]
}

struct CombTuple {
    var n: Int
    var k: Int
    
    init(_ n: Int, _ k: Int) {
        self.n = n
        self.k = k
    }
}

extension CombTuple: Hashable {
    static func == (lhs: CombTuple, rhs: CombTuple) -> Bool {
        return lhs.n == rhs.n && lhs.k == rhs.k
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(n)
        hasher.combine(k)
    }
}

struct RcsConstructorTuple {
    var atom: Atom
    var stMol: StrcMolecule
}

extension RcsConstructorTuple: Hashable {
    static func == (lhs: RcsConstructorTuple, rhs: RcsConstructorTuple) -> Bool {
        return lhs.atom == rhs.atom && lhs.stMol == rhs.stMol
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(atom)
        hasher.combine(stMol)
    }
}

struct AtomNeighborTuple {
    var atoms: Set<Atom>
    var atom: Atom
    
    init(_ atoms: Set<Atom>, _ atom: Atom) {
        self.atoms = atoms
        self.atom = atom
    }
}

extension AtomNeighborTuple: Hashable {
    static func == (lhs: AtomNeighborTuple, rhs: AtomNeighborTuple) -> Bool {
        return lhs.atom == rhs.atom && lhs.atoms == rhs.atoms
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(atom)
        hasher.combine(atoms)
    }
}

struct BondAngleTuple {
    var center: Atom
    var atom1: Atom
    var atom2: Atom
    
    init(_ center: Atom, _ atom1: Atom, _ atom2: Atom) {
        self.center = center
        self.atom1 = atom1
        self.atom2 = atom2
    }
    
    init?(_ center: Atom, attached: [Atom]) {
        guard attached.count == 2 else {
            return nil
        }
        
        self.init(center, attached[0], attached[1])
    }
}

extension BondAngleTuple: Hashable {
    static func == (lhs: BondAngleTuple, rhs: BondAngleTuple) -> Bool {
        return lhs.center == rhs.center && lhs.atom1 == rhs.atom1 && lhs.atom2 == rhs.atom2
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(center)
        hasher.combine(atom1)
        hasher.combine(atom2)
    }
}
