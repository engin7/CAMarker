//
//  Models.swift
//  CAMarker
//
//  Created by Engin KUK on 6.02.2021.
//

import UIKit
 
class DataBase {
    static let shared = DataBase()
    var markers: [LayoutMapData] = []
}

enum cornerPoint {
    // corners selected
    case leftTop
    case leftBottom
    case rightBottom
    case rightTop
    case noCornersSelected
    init() {
        self = .noCornersSelected
    }
}

struct LayoutMapData {
    let vector: LayoutVector
    let metaData: VectorMetaData
}

struct VectorMetaData {
    let color: String
    let iconUrl: String
    let recordId: String
    let recordTypeId: String
}

enum LayoutVector {
    case PIN(point: CGPoint)
    case PATH(points: [CGPoint])
    case ELLIPSE(points: [CGPoint]) // operation is different here even data model is same!
}

struct InputBundle {
    let layoutUrl: String
    let mode: EnumLayoutMapActivity
    let layoutData: LayoutMapData? // empty array if no shape/pin exists in the map
}

enum EnumLayoutMapActivity: Int {
    case VIEW = 0
    case ADD = 1
    case EDIT = 2
}

