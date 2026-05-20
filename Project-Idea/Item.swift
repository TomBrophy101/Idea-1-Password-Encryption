//
//  Item.swift
//  Project-Idea
//
//  Created by Tom Brophy on 10/03/2026.
//  This is to save the accounts for the user.

import Foundation
import SwiftData

@Model
final class Item {
    var title: String
    var serviceType: String
    var secureData: String
    var timestamp: Date
    
    init(title: String, serviceType: String, secureData: String, timestamp: Date = .now) {
        self.title = title
        self.serviceType = serviceType
        self.secureData = secureData
        self.timestamp = timestamp
    }
}
