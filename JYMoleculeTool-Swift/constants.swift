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
            "OO1": 1.480
        ]
        
        /**
         Known atom mass. Unit in amu.
         
         - **Source:** pbg.lbl.gov)
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
            "Ne": 20.1797
        ]
    }
}
