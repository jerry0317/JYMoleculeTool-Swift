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
public typealias PhysConst = Constants.Phys

/**
 Chemical constants.
 */
public typealias ChemConst = Constants.Chem

/**
 Chemical Elements.
 */
public typealias ChemElement = ChemConst.Element

/**
 Bond codes used by chemical bond types.
 */
public typealias BondCode = ChemConst.BondCode

/**
 Generic constants used in the program.
 */
public enum Constants {
    /**
     Constants in chemistry area.
     */
    public enum Chem {
        
        /**
         Known bond lengths of chemical bonds. Unit in Angstrom. **(Currently simplified list)**
         
         - **Source:** Allen, F. H., Kennard, O., Watson, D. G., Brammer, L., Orpen, A. G., & Taylor, R. (1987). Tables of bond lengths determined by X-ray and neutron diffraction. Part 1. Bond lengths in organic compounds. Journal of the Chemical Society, Perkin Transactions 2, (12), S1-S19.
         */
        public static let bondLengths: [BondCode: Double] = [
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
         Known minima and maxima of chemical bond lengths. Unit in Angstrom.
         
         - **Source:** Allen, F. H., Kennard, O., Watson, D. G., Brammer, L., Orpen, A. G., & Taylor, R. (1987). Tables of bond lengths determined by X-ray and neutron diffraction. Part 1. Bond lengths in organic compounds. Journal of the Chemical Society, Perkin Transactions 2, (12), S1-S19.
         */
        public static let bondLengthRangeTuples: [BondCode: (Double, Double)] = [
            .CC1: (1.377, 1.588),
            .CC2: (1.294, 1.435), // CC2 Normal: (1.294, 1.392), CC2 delocalized: (1.356, 1.435)
            .CC3: (1.174, 1.192),
            .CCl1: (1.713, 1.849),
            .CF1: (1.320, 1.428),
            .CN1: (1.321, 1.552),
            .CN2: (1.279, 1.362), // CN2 Normal: (1.279, 1.329), CN2 delocalized: (1.334, 1.362)
            .CN3: (1.136, 1.155),
            .CO1: (1.293, 1.492),
            .CO2: (1.187, 1.255),
            .ClN1: (1.705, 1.757),
            .ClO1: (1.414, 1.414),
            .FN1: (1.406, 1.406),
            .NN1: (1.304, 1.454), // NN1 Normal: (1.350, 1.454), NN1 aromatic: (1.304, 1.368)
            .NN2: (1.124, 1.255),
            .NO1: (1.234, 1.463),
            .NO2: (1.210, 1.239),
            .OO1: (1.464, 1.496)
        ]
        
        /**
         Known atom mass. Unit in amu.
         
         - **Source:** pdg.lbl.gov
         */
        public static let atomicMasses: [ChemElement: Double] = [
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
         Known isotope masses for elements. Unit in amu.
         
         - **Source:** https://physics.nist.gov/cgi-bin/Compositions/stand_alone.pl
         */
        public static let isotopeAtomicMasses: [ChemElement: [Int: Double]] = [
            .hydrogen: [
                1: 1.00782503223,
                2: 2.01410177812,
                3: 3.0160492779
            ],
            .helium: [
                3: 3.0160293201,
                4: 4.00260325413
            ],
            .lithium: [
                6: 6.0151228874,
                7: 7.0160034366
            ],
            .beryllium: [
                9: 9.012183065
            ],
            .boron: [
                10: 10.01293695,
                11: 11.00930536
            ],
            .carbon: [
                12: 12.0,
                13: 13.00335483507,
                14: 14.0032419884
            ],
            .nitrogen: [
                14: 14.00307400443,
                15: 15.00010889888
            ],
            .oxygen: [
                16: 15.99491461957,
                17: 16.99913175650,
                18: 17.99915961286
            ],
            .fluorine: [
                19: 18.99840316273
            ],
            .neon: [
                20: 19.9924401762,
                21: 20.993846685,
                22: 21.991365114
            ],
            .sodium: [
                23: 22.9897692820
            ],
            .magnesium: [
                24: 23.985041697,
                25: 24.985836976,
                26: 25.982592968
            ],
            .aluminum: [
                27: 26.98153853
            ],
            .silicon: [
                28: 27.97692653465,
                29: 28.97649466490,
                30: 29.973770136
            ],
            .phosphorus: [
                31: 30.97376199842
            ],
            .sulfur: [
                32: 31.9720711744,
                33: 32.9714589098,
                34: 33.976867004,
                36: 35.96708071
            ],
            .chlorine: [
                35: 34.968852682,
                37: 36.965902602
            ],
            .argon: [
                36: 35.967545105,
                38: 37.96273211,
                40: 39.9623831237
            ]
        ]
        
        /**
         The mass numbers of the most abundant isotopes for each element.
         
         - **Source:** https://physics.nist.gov/cgi-bin/Compositions/stand_alone.pl
         */
        public static let commonMassNumbers: [ChemElement: [Int]] = [
            .hydrogen: [1, 2, 3],
            .helium: [4, 3],
            .lithium: [7, 6],
            .beryllium: [9],
            .boron: [11, 10],
            .carbon: [12, 13, 14],
            .nitrogen: [14, 15],
            .oxygen: [16, 18, 17],
            .fluorine: [19],
            .neon: [20, 22, 21],
            .sodium: [23],
            .magnesium: [24, 26, 25],
            .aluminum: [27],
            .silicon: [28, 29, 30],
            .phosphorus: [31],
            .sulfur: [32, 34, 33, 36],
            .chlorine: [35, 37],
            .argon: [40, 36, 38]
        ]
        
        /**
         Usual valence of an atom in organic compounds.
         */
        public static let valences: [ChemElement: Int] = [
            .carbon: 4,
            .oxygen: 2,
            .nitrogen: 3,
            .fluorine: 1,
            .chlorine: 1
        ]
        
        /**
         The VESPR molecular type.
         */
        public enum VESPRType {
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
        public enum Element: String {
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
            
            /**
             The atomic mass of the element. Unit in `amu`.
             */
            public var atomicMass: Double {
                ChemConst.atomicMasses[self]!
            }
            
            /**
             The atomic mass of the element. Unit in `kg`.
             */
            public var mass: Double {
                atomicMass * PhysConst.amu
            }
            
            /**
             The mass numbers of the most common isotopes of the element with the order of abundance.
             */
            public var commonMassNumbers: [Int] {
                ChemConst.commonMassNumbers[self]!
            }
            
            /**
             The mass number of the most common isotopes of the element.
             */
            public var mostCommonMassNumber: Int {
                commonMassNumbers[0]
            }
            
            /**
             The atomic mass of the most common isotope of the element. Unit in `amu`.
             */
            public var mostCommonIsotopeAtomicMass: Double {
                isotopeAtomicMasses[mostCommonMassNumber]!
            }
            
            /**
             The mass number of the second-most common isotope of the element. If there is only one common isotope of the element, then it returns `nil`.
             */
            public var secondCommonMassNumber: Int? {
                commonMassNumbers.count >= 2 ? commonMassNumbers[1] : nil
            }
            
            /**
             The atomic mass of the second-most common isotope of the element. If there is only one common isotope of the element, hten it returns `nil`.
             */
            public var secondCommonIsotopeAtomicMass: Double? {
                if secondCommonMassNumber == nil {
                    return nil
                } else {
                    return isotopeAtomicMasses[secondCommonMassNumber!]
                }
            }
            
            /**
             The atomic masses for the isotopes of the element, accessed by the mass number.
             */
            public var isotopeAtomicMasses: [Int: Double] {
                ChemConst.isotopeAtomicMasses[self]!
            }
        }
        
        /**
         Known bond code.
         */
        public enum BondCode: String {
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
    public enum Phys {
        /**
         Speed of light. In SI unit `m/s`.
         */
        public static let speedOfLight = 299792458.0
        
        /**
         Shorthand of the speed of light.
         */
        public static var c: Double {
            return speedOfLight
        }
        
        /**
         Returns the measurement of the speed of light. *(Beta)*
         */
        public static var cMeasurement: Measurement<UnitSpeed> {
            return Measurement(value: c, unit: UnitSpeed.metersPerSecond)
        }
        
        /**
         Planck constant. In SI unit `J·s`.
         */
        public static let planckConstant = 6.626070040e-34
        
        /**
         Shorthand of Planck constant.
         */
        public static var h: Double {
            return planckConstant
        }
        
        /**
         Reduced Planck constant. In SI unit `J·s`.
         */
        public static let planckConstantReduced = 1.054571800e-34
        
        /**
         Shorthand of reduced Planck constant.
         */
        public static var hbar: Double {
            return planckConstantReduced
        }
        
        /**
         Electron charge magnitude. In SI unit `C`.
         */
        public static let electronChargeMagnitude = 1.6021766208e-19
        
        /**
         Shorthand of electron charge magnitude.
         */
        public static var e: Double {
            return electronChargeMagnitude
        }
        
        /**
         The atomic mass unit. In SI unit `kg`.
         */
        public static let atomicMassUnit = 1.660539066e-27
        
        /**
         Shorthand of atomic mass unit.
         */
        public static var amu: Double {
            return atomicMassUnit
        }
        
    }
}


