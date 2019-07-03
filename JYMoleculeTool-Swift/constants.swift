//
//  constants.swift
//  JYMoleculeTool-Swift
//
//  Created by Jerry Yan BA on 6/24/19.
//  Copyright © 2019 Jerry Yan. All rights reserved.
//

import Foundation

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
        static let bondLengths = [
            "CC1": 1.4825,
            "CC2": 1.343,
            "CC3": 1.183,
            "CO1": 1.3925,
            "CO2": 1.221,
            "OO1": 1.480,
            "CN1": 1.4365,
            "CN2": 1.3205,
            "CN3": 1.1455,
            "NN1": 1.402,
            "NN2": 1.1895,
            "NO1": 1.3835,
            "NO2": 1.2245,
            "CF1": 1.374,
            "FN1": 1.406,
            "CCl1": 1.781,
            "ClN1": 1.731,
            "ClO1": 1.414
        ]
        
        /**
         Known atom mass. Unit in amu.
         
         - **Source:** pdg.lbl.gov
         */
        static let atomicMasses = [
            "H": 1.00794,
            "He": 4.002602,
            "Li": 6.941,
            "Be": 9.012182,
            "B": 10.811,
            "C": 12.0107,
            "N": 14.0067,
            "O": 15.9994,
            "F": 18.9984032,
            "Ne": 20.1797,
            "Na": 22.98976928,
            "Mg": 24.305,
            "Al": 26.9815385,
            "Si": 28.085,
            "P": 30.973761998,
            "S": 32.06,
            "Cl": 35.45,
            "Ar": 39.948
        ]
        
        /**
         Usual valence of an atom in organic compounds.
         */
        static let valences = [
            "C": 4,
            "O": 2,
            "N": 3,
            "F": 1,
            "Cl": 1
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
    }
}
