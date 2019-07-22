//
//  fileToolsAdv.swift
//  JYMTAdvancedKit
//
//  Created by Jerry Yan BA on 7/22/19.
//

import Foundation
import JYMTBasicKit

public extension XYZFile {
    func calculateABC(origin: Vector3D? = nil) -> ABCTuple? {
        if atoms == nil {
            return nil
        } else {
            return ABCFromAtoms(atoms!, origin: origin)
        }
    }
    
    var ABC: ABCTuple? {
        calculateABC()
    }
}
