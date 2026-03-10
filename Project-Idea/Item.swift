//
//  Item.swift
//  Project-Idea
//
//  Created by Tom Brophy on 10/03/2026.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
