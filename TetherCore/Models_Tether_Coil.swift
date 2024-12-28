//
//  Models_Tether_Coil.swift
//  TetherCore
//
//  Created by Benjamin Tryon on 12/4/24.
//

import SwiftUI

/// [Model: 'ModelTether' ][Conformance: Identifiable, Codable]['Storage' Data Type][-> Tether]
struct Tether: Identifiable, Codable, Equatable {
    let id: UUID
    var tetherText: String
    var isCompleted: Bool
    var timeStamp: Date
    init(tetherText: String, isCompleted: Bool = false){
        self.id = UUID()
        self.tetherText = tetherText
        self.isCompleted = isCompleted
        self.timeStamp = Date()
    }
}

///[Model: 'ModelCoil'][Conformance: Identifiable, Codable]['Storage' Data Type][-> Tether]
struct Coil: Identifiable, Codable, Equatable {
    let id: UUID
    var tether1: Tether
    var tether2: Tether
    var isCompleted: Bool
    var timeStamp: Date
    init(tether1: Tether, tether2: Tether, isCompleted: Bool = false, _ timeStamp: Date = Date()) {
        self.id = UUID()
        self.tether1 = tether1
        self.tether2 = tether2
        self.isCompleted = isCompleted  ///Default false provided in init -- avoids compiler complaining "need all params"
        self.timeStamp = timeStamp       ///Default false provided in init -- avoids compiler complaining "need all params"
    }
    var formattedTimestamp: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        formatter.timeZone = TimeZone.current   ///Handles both US and China
        return formatter.string(from: timeStamp)
    }
}

///Toggle if the user wants to display the date in the Profile list
//struct Toggle {
//    let coil: Coil
//    var on: Bool
//    
//    func toToggle() {
//        coil.formattedTimestamp.timeZone
//    }
//}

