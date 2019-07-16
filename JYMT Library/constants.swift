//
//  constants.swift
//  JYMoleculeTool-Swift
//
//  Created by Jerry Yan BA on 6/24/19.
//  Copyright © 2019 Jerry Yan. All rights reserved.
//

import Foundation

/**
 Physical constants.
 */
typealias PhysConst = Constants.Phys

/**
 Chemical constants.
 */
typealias ChemConst = Constants.Chem

/**
 Chemical Elements.
 */
typealias ChemElement = ChemConst.Element

/**
 Bond codes used by chemical bond types.
 */
typealias BondCode = ChemConst.BondCode

/**
 Generic constants used in the program.
 */
enum Constants {
    /**
     Constants in chemistry area.
     */
    enum Chem {
        
        /**
         Known bond lengths of chemical bonds. Unit in Angstrom. **(Currently simplified list)**
         
         - **Source:** Allen, F. H., Kennard, O., Watson, D. G., Brammer, L., Orpen, A. G., & Taylor, R. (1987). Tables of bond lengths determined by X-ray and neutron diffraction. Part 1. Bond lengths in organic compounds. Journal of the Chemical Society, Perkin Transactions 2, (12), S1-S19.
         */
        static let bondLengths: [BondCode: Double] = [
            .CC1: 1.4825,
            .CC2: 1.343,
            .CC3: 1.183,
            .CO1: 1.3925,
            .CO2: 1.221,
            .OO1: 1.480,
            .CN1: 1.4365,
            .CN2: 1.3205,
            .CN3: 1.1455,
            .NN1: 1.402,
            .NN2: 1.1895,
            .NO1: 1.3835,
            .NO2: 1.2245,
            .CF1: 1.374,
            .FN1: 1.406,
            .CCl1: 1.781,
            .ClN1: 1.731,
            .ClO1: 1.414
        ]
        
        /**
         Known atom mass. Unit in amu.
         
         - **Source:** pdg.lbl.gov
         */
        static let atomicMasses: [ChemElement: Double] = [
            .hydrogen: 1.00794,
            .helium: 4.002602,
            .lithium: 6.941,
            .beryllium: 9.012182,
            .boron: 10.811,
            .carbon: 12.0107,
            .nitrogen: 14.0067,
            .oxygen: 15.9994,
            .fluorine: 18.9984032,
            .neon: 20.1797,
            .sodium: 22.98976928,
            .magnesium: 24.305,
            .aluminum: 26.9815385,
            .silicon: 28.085,
            .phosphorus: 30.973761998,
            .sulfur: 32.06,
            .chlorine: 35.45,
            .argon: 39.948
        ]
        
        /**
         Usual valence of an atom in organic compounds.
         */
        static let valences: [ChemElement: Int] = [
            .carbon: 4,
            .oxygen: 2,
            .nitrogen: 3,
            .fluorine: 1,
            .chlorine: 1
        ]
        
        /**
         The VESPR molecular type.
         */
        enum VESPRType {
            case ax2e0
            case ax2e1
            case ax2e2
            case ax2e3
            case ax3e0
            case ax3e1
            case ax3e2
            case ax4e0
            case ax4e1
            case ax4e2
            case ax5e0
            case ax5e1
            case ax5e2
            case ax6e0
            case ax6e1
            case ax7e0
            case ax8e0
            case ax9e0
        }
        
        /**
         Chemical Element.
         */
        enum Element: String {
            case hydrogen = "H"
            case helium = "He"
            case lithium = "Li"
            case beryllium = "Be"
            case boron = "B"
            case carbon = "C"
            case nitrogen = "N"
            case oxygen = "O"
            case fluorine = "F"
            case neon = "Ne"
            case sodium = "Na"
            case magnesium = "Mg"
            case aluminum = "Al"
            case silicon = "Si"
            case phosphorus = "P"
            case sulfur = "S"
            case chlorine = "Cl"
            case argon = "Ar"
            
            var atomicMass: Double {
                ChemConst.atomicMasses[self]!
            }
            
            var mass: Double {
                atomicMass * PhysConst.amu
            }
        }
        
        /**
         Known bond code.
         */
        enum BondCode: String {
            case CC1
            case CC2
            case CC3
            case CO1
            case CO2
            case OO1
            case CN1
            case CN2
            case CN3
            case NN1
            case NN2
            case NO1
            case NO2
            case CF1
            case FN1
            case CCl1
            case ClN1
            case ClO1
        }
    }
    
    /**
     Constants in chemistry area.
     */
    enum Phys {
        /**
         Speed of light. In SI unit `m/s`.
         */
        static let speedOfLight = 299792458.0
        
        /**
         Shorthand of the speed of light.
         */
        static var c: Double {
            return speedOfLight
        }
        
        /**
         Returns the measurement of the speed of light. *(Beta)*
         */
        static var cMeasurement: Measurement<UnitSpeed> {
            return Measurement(value: c, unit: UnitSpeed.metersPerSecond)
        }
        
        /**
         Planck constant. In SI unit `J·s`
         */
        static let planckConstant = 6.626070040e-34
        
        /**
         Shorthand of Planck constant.
         */
        static var h: Double {
            return planckConstant
        }
        
        /**
         Reduced Planck constant. In SI unit `J·s`
         */
        static let planckConstantReduced = 1.054571800e-34
        
        /**
         Shorthand of reduced Planck constant.
         */
        static var hbar: Double {
            return planckConstantReduced
        }
        
        /**
         Electron charge magnitude. In SI unit `C`.
         */
        static let electronChargeMagnitude = 1.6021766208e-19
        
        /**
         Shorthand of electron charge magnitude.
         */
        static var e: Double {
            return electronChargeMagnitude
        }
        
        static let atomicMassUnit = 1.660539066e-27
        
        static var amu: Double {
            return atomicMassUnit
        }
        
    }
}


