//
//  ChatManager.swift
//  messageboard
//
//  Created by cheng xi on 19/7/26.
//
import Foundation
import UIKit
import Combine
import MultipeerConnectivity
import SwiftData

class ChatManager: NSObject, ObservableObject {
    // @Published = the UI redraws automatically whenever there are changes. //
    // Observable so the UI can watch over the class. //
    // NSObject cause MultipeerConnectivity requires it. //
    @Published var connectedPeers: [MCPeerID] = []   // devices we're actually talking to //
    @Published var discoveredPeers: [MCPeerID] = []  // devices we can see nearby //
    private let serviceType = "msgboard" //remember service type //
    let myPeerID = MCPeerID(displayName: UIDevice.current.name) //identity of device
    private let modelContext: ModelContext //write-access "handle" into SwiftData database and is passed so ChatManager can save them. //
    
    // The three MultipeerConnectivity objects, created lazily (only when first used):
    //   session    —> the live connection once two devices are paired //
    //   advertiser —> "shouts" that this device is available //
    //   browser    —> "listens" for other devices shouting //
    private lazy var session = MCSession(
        peer: myPeerID,
        securityIdentity: nil,
        encryptionPreference: .required
    )
    
    private lazy var advertiser = MCNearbyServiceAdvertiser(
        peer: myPeerID,
        discoveryInfo: nil,
        serviceType: serviceType
    )
    
    private lazy var browser = MCNearbyServiceBrowser(
        peer: myPeerID,
        serviceType: serviceType
    )
    
    // init runs once when ChatManager() is created. it receive the database handle, wire up the three delegates, and the start advertising + browsing so discovery begins immediately. //
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        super.init()
        session.delegate = self
        browser.delegate = self
        advertiser.delegate = self
        advertiser.startAdvertisingPeer()
        browser.startBrowsingForPeers()
    }
    
    // deinit runs when ChatManager is destroyed. it stop advertising/browsing and disconnect so we dont waste electricity?? resources ig //
    deinit {
        advertiser.stopAdvertisingPeer()
        browser.stopBrowsingForPeers()
        session.disconnect()
    }
    // send function builds a ChatMessage, then save it to database, encode it into um data then send duh its in the name of the function//
    func send(text: String, content: String = "") {
        let message = ChatMessage(text: text, content: content, sender: myPeerID.displayName)
        // save our own messages //
        DispatchQueue.main.async {
            self.save(message)
        }
        
        guard !session.connectedPeers.isEmpty else { return }
        do {
            let data = try JSONEncoder().encode(message)  // struct -> bytes
            try session.send(data, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            print("send failed:", error)
        }
    }
    // save function copies a network ChatMessage into a StoredMessage then put it into the SwiftData database. //
    private func save(_ message: ChatMessage) {
        let stored = StoredMessage(
            id: message.id,
            text: message.text,
            content: message.content,
            sender: message.sender
        )
        modelContext.insert(stored)
    }
}

extension ChatManager: MCNearbyServiceBrowserDelegate {
    // called when a nearby device is discovered //
    func browser(_ browser: MCNearbyServiceBrowser,
                 foundPeer peerID: MCPeerID,
                 withDiscoveryInfo info: [String : String]?) {
        DispatchQueue.main.async {
            if !self.discoveredPeers.contains(peerID) {
                self.discoveredPeers.append(peerID)
            }
        }
    }
    
    //called when the device is out of range or app is closed //
    func browser(_ browser: MCNearbyServiceBrowser,
                 lostPeer peerID: MCPeerID) {
        DispatchQueue.main.async {
            self.discoveredPeers.removeAll { $0 == peerID }
        }
    }
    
    // connect invites a discovered device to join session //
    func connect(to peer: MCPeerID) {
        browser.invitePeer(peer, to: session, withContext: nil, timeout: 20)
    }
}

extension ChatManager: MCNearbyServiceAdvertiserDelegate {
    // when device invites us, we join them //
    func advertiser(
        _ advertiser: MCNearbyServiceAdvertiser,
        didReceiveInvitationFromPeer peerID: MCPeerID,
        withContext context: Data?,
        invitationHandler: @escaping (Bool, MCSession?) -> Void
    ) {
        invitationHandler(true, session)   // true = accept, always accept
    }
}

extension ChatManager: MCSessionDelegate {
    // when a device is connected or disconnected, it is called //
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        DispatchQueue.main.async {
            self.connectedPeers = session.connectedPeers
        }
    }
    //decodes it and then saves it to SwiftData
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        guard let message = try? JSONDecoder().decode(ChatMessage.self, from: data) else { return }
        DispatchQueue.main.async {
            self.save(message)
        }
    }
    //large file usage
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}
}
