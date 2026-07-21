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

class ChatManager: NSObject,ObservableObject{
    @Published var messages: [ChatMessage] = []
    @Published var connectedPeers: [MCPeerID] = []
    @Published var discoveredPeers: [MCPeerID] = []
    //this declares what the UI watches over
    private let serviceType = "msgboard"
    let myPeerID = MCPeerID(displayName: UIDevice.current.name)
    //this must match the Info.plist so Swift knows what service type it is
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
    //this is the 3 versions of Multipeer Connectivity, with them being session, advertiser and browser. Session means that you create a session that is created when you connect the phones, browser and advertiser is to search for other devices in the room, with browser listening for other devices and advertiser to shout to other devices.//
    override init() {
        super.init()
        session.delegate = self
        browser.delegate = self
        advertiser.delegate = self
        advertiser.startAdvertisingPeer()
        browser.startBrowsingForPeers()
    }
    //init() to run ChatManager() when is created, since we already have a init() from NSObject, we need to override it for it to work.
    deinit {
        advertiser.stopAdvertisingPeer()
        browser.stopBrowsingForPeers()
        session.disconnect()
    }
    //tells us to destroy everything so that we don't waste resources and clean up every single session.
}
extension ChatManager: MCNearbyServiceBrowserDelegate {
    // Called when a nearby device is discovered
    func browser(_ browser: MCNearbyServiceBrowser,
                 foundPeer peerID: MCPeerID,
                 withDiscoveryInfo info: [String : String]?) {
        DispatchQueue.main.async {
            if !self.discoveredPeers.contains(peerID) {
                self.discoveredPeers.append(peerID)
            }
        }
    }

    // Called when a device goes out of range / closes the app
    func browser(_ browser: MCNearbyServiceBrowser,
                 lostPeer peerID: MCPeerID) {
        DispatchQueue.main.async {
            self.discoveredPeers.removeAll { $0 == peerID }
        }
    }
    func connect(to peer: MCPeerID) {
        browser.invitePeer(peer, to: session, withContext: nil, timeout: 20)
    }
    // Connect to the other devices by inviting
}
extension ChatManager: MCNearbyServiceAdvertiserDelegate {
    func advertiser(
        _ advertiser: MCNearbyServiceAdvertiser,
        didReceiveInvitationFromPeer peerID: MCPeerID,
        withContext context: Data?,
        invitationHandler: @escaping (Bool, MCSession?) -> Void
    ) {
        invitationHandler(true, session)
    }
}
//advertiser function
extension ChatManager: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        DispatchQueue.main.async {
            self.connectedPeers = session.connectedPeers
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        // messages will go here next step
    }
    
    // Required but unused, useless
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}
}
