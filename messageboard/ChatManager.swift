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
