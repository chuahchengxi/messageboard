//
//  messageboardApp.swift
//  messageboard
//
//  Created by cheng xi on 19/7/26.
//

import SwiftUI
import SwiftData

@main
struct messageboardApp: App {
    // The ModelContainer is the SwiftData database itself.This is for the whole app.//
    let container: ModelContainer
    @StateObject private var chat: ChatManager

    init() {
//Build the database then tell it what to store.
        let container: ModelContainer
        do {
            container = try ModelContainer(for: StoredMessage.self)
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
        self.container = container

        // tell ChatManager to save the messages into the databse
        _chat = StateObject(wrappedValue: ChatManager(modelContext: container.mainContext))
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(chat)   // makes chat reachable from any view
        }
        .modelContainer(container)         // makes @Query work in the views
    }
}
