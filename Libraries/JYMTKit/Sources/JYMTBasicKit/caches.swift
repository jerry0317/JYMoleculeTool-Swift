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

public var globalCache = GlobalCache()

/**
 Provides a structure for cache that is easily to access globally.
 */
public struct GlobalCache {
    public var indexCombinations: [CombTuple: Set<Set<Int>>] = [:]
    
    public var rcsConstructorCache: Set<RcsConstructorTuple> = []
    
    public var possibleBondTypes: [Array<ChemElement>: [ChemBondType]] = [:]
    
    public var stMolMatched: (Set<Set<Atom>>, Set<Set<Atom>>) = ([], [])
    
    public var atomPossibles: [Atom: [Atom]] = [Atom: [Atom]]()
    
    public var bdCodes: [ChemBondType: BondCode] = [:]
    
    public var bondAngles: [BondAngleTuple: Double] = [:]
    
    public var atomNeighbors: [AtomNeighborTuple: (Bool, Atom)] = [:]
}

public struct CombTuple {
    public var n: Int
    public var k: Int
    
    public init(_ n: Int, _ k: Int) {
        self.n = n
        self.k = k
    }
}

extension CombTuple: Hashable {
    public static func == (lhs: CombTuple, rhs: CombTuple) -> Bool {
        return lhs.n == rhs.n && lhs.k == rhs.k
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(n)
        hasher.combine(k)
    }
}

public struct RcsConstructorTuple {
    public var atom: Atom
    public var stMol: StrcMolecule
}

extension RcsConstructorTuple: Hashable {
    public static func == (lhs: RcsConstructorTuple, rhs: RcsConstructorTuple) -> Bool {
        return lhs.atom == rhs.atom && lhs.stMol == rhs.stMol
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(atom)
        hasher.combine(stMol)
    }
}

public struct AtomNeighborTuple {
    public var atoms: Set<Atom>
    public var atom: Atom
    
    public init(_ atoms: Set<Atom>, _ atom: Atom) {
        self.atoms = atoms
        self.atom = atom
    }
}

extension AtomNeighborTuple: Hashable {
    public static func == (lhs: AtomNeighborTuple, rhs: AtomNeighborTuple) -> Bool {
        return lhs.atom == rhs.atom && lhs.atoms == rhs.atoms
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(atom)
        hasher.combine(atoms)
    }
}

public struct BondAngleTuple {
    public var center: Atom
    public var atom1: Atom
    public var atom2: Atom
    
    public init(_ center: Atom, _ atom1: Atom, _ atom2: Atom) {
        self.center = center
        self.atom1 = atom1
        self.atom2 = atom2
    }
    
    public init?(_ center: Atom, attached: [Atom]) {
        guard attached.count == 2 else {
            return nil
        }
        
        self.init(center, attached[0], attached[1])
    }
}

extension BondAngleTuple: Hashable {
    public static func == (lhs: BondAngleTuple, rhs: BondAngleTuple) -> Bool {
        return lhs.center == rhs.center && lhs.atom1 == rhs.atom1 && lhs.atom2 == rhs.atom2
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(center)
        hasher.combine(atom1)
        hasher.combine(atom2)
    }
}

