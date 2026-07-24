//
//  ChatMessage.swift
//  messageboard
//
//  Created by cheng xi on 19/7/26.
//
import Foundation

struct ChatMessage: Codable, Identifiable {
    let id: UUID
    let text: String
    let content: String
    let sender: String 

    init(id: UUID = UUID(), text: String, content: String = "", sender: String) {
        self.id = id
        self.text = text
        self.content = content
        self.sender = sender
    }
}
