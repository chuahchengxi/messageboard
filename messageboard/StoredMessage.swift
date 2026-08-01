//
//  StoredMessage.swift
//  messageboard
//
//  Created by cheng xi on 25/7/26.
//
import Foundation
import SwiftData

@Model //creating data persistence relationships//
final class StoredMessage {
    var id: UUID
    var text: String
    var content: String
    var sender: String
    var timestamp: Date
    
    init(id: UUID = UUID(), text: String, content: String = "", sender: String, timestamp: Date = .now) {
        self.id = id
        self.text = text
        self.content = content
        self.sender = sender
        self.timestamp = timestamp
    }
}
