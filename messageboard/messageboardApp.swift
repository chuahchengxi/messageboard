//
//  messageboardApp.swift
//  messageboard
//
//  Created by cheng xi on 19/7/26.
//

import SwiftUI

@main
struct messageboardApp: App {
    @StateObject private var chat = ChatManager()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(chat)
        }
    }
}
