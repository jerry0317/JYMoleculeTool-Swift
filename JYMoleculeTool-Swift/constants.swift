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
         Known bond lengths of chemical bonds. Unit in Angstrom.
         */
        static let bondLengths = [
            "CC1": 1.54,
            "CC2": 1.34,
            "CC3": 1.20,
            "CO1": 1.43,
            "OO1": 1.48,
            "OO2": 1.21
        ]
        
        /**
         Known atom mass. Unit in amu. (source: pbg.lbl.gov)
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
