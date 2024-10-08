//
//  NotificationManager.swift
//  PresentIO
//
//  Created by Gonçalo Borrêga on 07/03/15.
//  Copyright (c) 2015 Borrega. All rights reserved.
//  Inspired by http://moreindirection.blogspot.pt/2014/08/nsnotificationcenter-swift-and-blocks.html

import Foundation

struct NotificationGroup {
    let entries: [String]
    
    init(_ newEntries: String...) {
        entries = newEntries
    }
}

final class NotificationManager {
    private var observerTokens: [AnyObject] = []
    
    deinit {
        deregisterAll()
    }
    
    func deregisterAll() {
        for token in observerTokens {
            NotificationCenter.default.removeObserver(token)
        }
        
        observerTokens = []
    }
    
    func registerObserver(name: String, block: @escaping ((Notification) -> Void)) {
        let observerName = NSNotification.Name(name)
        let newToken = NotificationCenter.default.addObserver(
            forName: observerName,
            object: nil,
            queue: nil
        ) { notification in
            block(notification)
        }
        observerTokens.append(newToken)
    }
    
    func registerObserver(name: String, dispatchAsyncToMainQueue: Bool, block: @escaping ((Notification) -> Void)) {
        let observerName = NSNotification.Name(name)
        let newToken = NotificationCenter.default.addObserver(
            forName: observerName,
            object: nil,
            queue: nil
        ) { notification in
            if dispatchAsyncToMainQueue {
                DispatchQueue.main.async {
                    block(notification)
                }
            } else {
                block(notification)
            }
        }
        observerTokens.append(newToken)
    }
    
    func registerObserver(name: String, forObject object: AnyObject, block: @escaping ((Notification) -> Void)) {
        self.registerObserver(name: name, forObject: object, dispatchAsyncToMainQueue: false, block: block)
    }
    
    func registerObserver(name: String, forObject object: AnyObject?, dispatchAsyncToMainQueue: Bool, block: @escaping ((Notification) -> Void)) {
        let observerName = NSNotification.Name(name)
        let newToken = NotificationCenter.default.addObserver(
            forName: observerName,
            object: nil,
            queue: nil
        ) { notification in
            if dispatchAsyncToMainQueue {
                DispatchQueue.main.async {
                    block(notification)
                }
            } else {
                block(notification)
            }
        }
        
        observerTokens.append(newToken)
    }
    
    
    
    func registerGroupObserver(group: NotificationGroup, block: @escaping ((Notification) -> Void)) {
        for name in group.entries {
            self.registerObserver(name: name, block: block)
        }
    }
}
