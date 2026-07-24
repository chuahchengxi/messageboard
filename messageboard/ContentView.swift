//
//  ContentView.swift
//  messageboard
//
//  Created by cheng xi on 19/7/26.
//

import SwiftUI
import SwiftData
import MultipeerConnectivity

struct ContentView: View {
    @EnvironmentObject var chat: ChatManager
    //     @Query reads from SwiftData database. Whenever ChatManager saves a new StoredMessage, this array updates and the list changes automatically it sorts by keeping the chat in the order when messages were last saved.
    @Query(sort: \StoredMessage.timestamp) private var messages: [StoredMessage]
    // draft acts as a draft in the text field.
    @State private var draft = ""
    var body: some View {
        NavigationStack {
            List {
                //devices we havent connect yet duh
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
                
                //um the devices that we are connected to
                Section("Connected") {
                    if chat.connectedPeers.isEmpty {
                        Text("No one yet").foregroundStyle(.secondary)
                    } else {
                        ForEach(chat.connectedPeers, id: \.self) { peer in
                            Text(peer.displayName)
                        }
                    }
                }
                
                //sussy chat messages? history
                Section("Messages") {
                    ForEach(messages) { message in
                        VStack(alignment: .leading, spacing: 2) {
                            Text(message.sender)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(message.text)
                        }
                    }
                }
            }
            .navigationTitle("message board")
            //input is pinned at the bottom of the view
            .safeAreaInset(edge: .bottom) {
                HStack {
                    TextField("Message", text: $draft)
                        .textFieldStyle(.roundedBorder)
                    Button("Send") {
                        let text = draft.trimmingCharacters(in: .whitespaces)
                        guard !text.isEmpty else { return }
                        chat.send(text: text)
                        draft = ""
                    }
                }
                .padding()
                .background(.bar)
            }
        }
    }
}
