//
//  fileToolsAdv.swift
//  JYMTAdvancedKit
//
//  Created by Jerry Yan BA on 7/22/19.
//

import Foundation
import JYMTBasicKit

public extension XYZFile {
    /**
     Calculate the rotational constants A, B, and C directly from the information of the XYZ set. An optional origin vector can be set.
     */
    func calculateABC(origin: Vector3D? = nil) -> ABCTuple? {
        if atoms == nil {
            return nil
        } else {
            return ABCFromAtoms(atoms!, origin: origin)
        }
    }
    
    /**
     The rotational constants A, B, and C calcualted directly from the information of the XYZ set.
     */
    var ABC: ABCTuple? {
        calculateABC()
    }
}
