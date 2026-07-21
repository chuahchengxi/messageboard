//
//  ContentView.swift
//  messageboard
//
//  Created by cheng xi on 19/7/26.
//

import SwiftUI
import MultipeerConnectivity

struct ContentView: View {
    @EnvironmentObject var chat: ChatManager

    var body: some View {
        NavigationStack {
            List {
                Section("Nearby devices") {
                    if chat.discoveredPeers.isEmpty {
                        Text("Searching…").foregroundStyle(.secondary)
                    } else {
                        ForEach(chat.discoveredPeers, id: \.self) { peer in
                            Button(peer.displayName) {
                                chat.connect(to: peer)
                            }
                        }
                    }
                }

                Section("Connected") {
                    if chat.connectedPeers.isEmpty {
                        Text("No one yet").foregroundStyle(.secondary)
                    } else {
                        ForEach(chat.connectedPeers, id: \.self) { peer in
                            Text(peer.displayName)
                        }
                    }
                }
            }
            .navigationTitle("message board")
        }
    }
}

//#Preview {
//    ContentView()
//        .environmentObject(chat)
//}
