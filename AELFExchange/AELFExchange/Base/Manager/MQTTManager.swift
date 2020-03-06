//
//  MQTTManager.swift
//  AELFExchange
//
//  Created by tng on 2019/1/22.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation

@objc class MQTTManager: NSObject {
    
    fileprivate static let ___donotUseThisVariableOfMQTTManager = MQTTManager()
    
    @discardableResult
    static func shared() -> MQTTManager {
        return MQTTManager.___donotUseThisVariableOfMQTTManager
    }
    
    private let client = CocoaMQTT(clientID: Config.mqttClientId, host: "", port: 0)
    private let wordQueue = DispatchQueue(label: "ios.aelf.mqtt")
    private var timerOfStatusCheckout: Timer!
    private let msgLogEnable = false
    
    public typealias RespCallback = ((Any?) -> ())
    public var statusCallback: ((_ connected: Bool) -> ())?
    public var dataCallbackOfMarketGrouped: RespCallback?
    public var dataCallbackOfMarketGroupedFormated: RespCallback?
    public var dataCallbackOfUpSymbols: RespCallback?
    public var dataCallbackOfHotSymbols: RespCallback?
    public var dataCallbackOfMarketTodaySymbols: RespCallback?
    public var dataCallbackOfMarketDelegateOrders: RespCallback?
    public var dataCallbackOfMarketDepth: RespCallback?
    public var dataCallbackOfMarketKLine: RespCallback?
    public var dataCallbackOfMarketLatestDealOrders: RespCallback?
    
    /// Topics.
    private var currentSubscribes = [String]()
    private var needsToSubscribesOnFailed = [(AELFUrlSuffix, [String])]()
    
    func setup() -> Void {
        self.getMqttConfig { [unowned self] (config) in
            guard let host = config.mqttHost, let portStr = config.tcpPort, let port = UInt16(portStr) else {
                InfoToast(withLocalizedTitle: "初始化连接失败，请退出重试！")
                return
            }
            Config.shared().showMarket = config.isShow ?? true
            self.client.host = host
            self.client.port = port
            self.client.username = config.subscriber
            self.client.password = config.subscriberPwd
            self.client.autoReconnect = true
            self.client.autoReconnectTimeInterval = 5
            self.client.keepAlive = UInt16(3600)
            self.client.logLevel = .error
            self.client.dispatchQueue = self.wordQueue
            self.client.delegate = self
            self.client.connect()
        }
        
        timerOfStatusCheckout = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.statusCheckout), userInfo: nil, repeats: true)
        timerOfStatusCheckout.fireDate = Date()
    }
    
    private func getMqttConfig(_ completion: @escaping ((MQTTConfigResponseData) -> ())) {
        Network.post(withUrl: URLs.shared().genUrl(with: .mqttConfig), to: MQTTConfigResponse.self) { (succeed, response) in
            guard succeed == true, response.succeed == true, let data = response.data else {
                InfoToast(withLocalizedTitle: "初始化连接失败，请退出重试！")
                return
            }
            completion(data)
        }
    }
    
    func reconnect(force: Bool = false) {
        if !force {
            guard self.client.connState == .disconnected else { return }
        } else {
            if self.client.connState != .disconnected {
                self.client.disconnect()
            }
        }
        self.client.connect()
    }
    
    @objc private func statusCheckout() {
        if let statusCallback = self.statusCallback {
            statusCallback(self.client.connState == .connected)
        }
    }
    
}

// MARK: - Utils.
extension MQTTManager {
    
    func sub<T>(on topic: AELFUrlSuffix, params: [String], convertTo: T.Type, handleResp: @escaping ((T) -> ())) -> Void where T: BaseAPIBusinessModel {
        self.sub(on: topic, params: params)
        switch topic {
        case .mqtopicMarketGrouped:
            self.dataCallbackOfMarketGrouped = { (data) in
                if let data = data as? String, let response = T.deserialize(from: data) {
                    handleResp(response)
                }
            }
        case .mqtopicMarketGroupedFormated:
            self.dataCallbackOfMarketGroupedFormated = { (data) in
                if let data = data as? String, let response = T.deserialize(from: data) {
                    handleResp(response)
                }
            }
        case .mqtopicUpSymbols:
            self.dataCallbackOfUpSymbols = { (data) in
                if let data = data as? String, let response = T.deserialize(from: data) {
                    handleResp(response)
                }
            }
        case .mqtopicHotSymbols:
            self.dataCallbackOfHotSymbols = { (data) in
                if let data = data as? String, let response = T.deserialize(from: data) {
                    handleResp(response)
                }
            }
        case .mqtopicMarketTodaySymbols:
            self.dataCallbackOfMarketTodaySymbols = { (data) in
                if let data = data as? String, let response = T.deserialize(from: data) {
                    handleResp(response)
                }
            }
        case .mqtopicMarketDelegateOrders:
            self.dataCallbackOfMarketDelegateOrders = { (data) in
                if let data = data as? String, let response = T.deserialize(from: data) {
                    handleResp(response)
                }
            }
        case .mqtopicMarketDepth:
            self.dataCallbackOfMarketDepth = { (data) in
                if let data = data as? String, let response = T.deserialize(from: data) {
                    handleResp(response)
                }
            }
        case .mqtopicMarketKLine:
            self.dataCallbackOfMarketKLine = { (data) in
                if let data = data as? String, let response = T.deserialize(from: data) {
                    handleResp(response)
                }
            }
        case .mqtopicMarketLatestDealOrders:
            self.dataCallbackOfMarketLatestDealOrders = { (data) in
                if let data = data as? String, let response = T.deserialize(from: data) {
                    handleResp(response)
                }
            }
        default:break
        }
    }
    
    private func sub(on topic: AELFUrlSuffix, params: [String]) -> Void {
        guard self.client.connState == .connected else {
            self.needsToSubscribesOnFailed.append((topic, params))
            self.client.connect()
            return
        }
        
        let topicFull = "\(topic.rawValue)\(params.joined(separator: "_"))"
        for case let containedTopic in self.currentSubscribes where containedTopic.contains(topic.rawValue) {
            if containedTopic != topicFull {
                self.currentSubscribes.removeAll { (content) -> Bool in
                    return content == containedTopic
                }
                self.client.unsubscribe(containedTopic)
            } else {
                return
            }
            break
        }
        
        self.currentSubscribes.append(topicFull)
        self.client.subscribe(topicFull)
    }
    
    /* TODO: 暂时不退订/暂停.
    func unsub(on topic: AELFUrlSuffix, params: [String]) -> Void {
        guard self.client.connState == .connected else {
            self.client.connect()
            return
        }
        let topicFull = "\(topic.rawValue)\(params.joined(separator: "_"))"
        self.currentSubscribes.removeAll { (content, _) -> Bool in
            return content == topicFull
        }
        self.client.unsubscribe(topicFull)
    }*/
    
    private func resubAfterReconnectedIfNeed() -> Void {
        guard self.client.connState == .connected else {
            self.client.connect()
            return
        }
        guard self.currentSubscribes.count > 0 else { return }
        for topic in self.currentSubscribes {
            self.client.subscribe(topic)
            loginfo(content: "MQTT Resubscribed on: \(topic)")
        }
    }
    
    private func resubAfterFirstimeConnectedIfNeeded() {
        guard self.needsToSubscribesOnFailed.count > 0 else { return }
        for (topic, params) in self.needsToSubscribesOnFailed {
            self.sub(on: topic, params: params)
            loginfo(content: "MQTT Resubscribed on: \(topic) when connected")
        }
    }
    
}

// MARK: - Pause and Resume.
extension MQTTManager {
    
    /* 暂时不退订/暂停.
    func pause(for topics: [AELFUrlSuffix]) -> Void {
        self.pauseOrResume(with: topics, forPause: true)
    }
    
    func resume(for topics: [AELFUrlSuffix]) -> Void {
        self.pauseOrResume(with: topics, forPause: false)
    }
    
    private func pauseOrResume(with topics: [AELFUrlSuffix], forPause: Bool) -> Void {
        guard topics.count > 0, self.currentSubscribes.count > 0 else { return }
        guard self.client.connState == .connected else {
            self.client.connect()
            return
        }
        for topic in topics {
            for case let item in self.currentSubscribes where item.contains(topic.rawValue) {
                if forPause {
                    self.client.unsubscribe(item)
                } else {
                    self.client.subscribe(item)
                }
            }
        }
    }*/
    
}

extension MQTTManager: CocoaMQTTDelegate {
    
    func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        loginfo(content: "MQTT Succeed to connect:(\(ack)...)")
        if ack == .accept {
//            if let statusCallback = self.statusCallback {
//                statusCallback(true)
//            }
            self.resubAfterReconnectedIfNeed()
            self.resubAfterFirstimeConnectedIfNeeded()
        }
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {
        // ...
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16) {
        // ...
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16) {
        if msgLogEnable {
            loginfo(content: "MQTT Did received msg with len: \((message.string ?? "").count)")
        }
        
//        if let statusCallback = self.statusCallback {
//            statusCallback(true)
//        }
        
        if message.topic.contains(AELFUrlSuffix.mqtopicMarketGrouped.rawValue) {
            if let callback = self.dataCallbackOfMarketGrouped {
                let data = message.string
                callback(data)
            }
        } else if message.topic.contains(AELFUrlSuffix.mqtopicMarketGroupedFormated.rawValue) {
            if let callback = self.dataCallbackOfMarketGroupedFormated {
                let data = message.string
                callback(data)
            }
        } else if message.topic.contains(AELFUrlSuffix.mqtopicUpSymbols.rawValue) {
            if let callback = self.dataCallbackOfUpSymbols {
                let data = message.string
                callback(data)
            }
        } else if message.topic.contains(AELFUrlSuffix.mqtopicHotSymbols.rawValue) {
            if let callback = self.dataCallbackOfHotSymbols {
                let data = message.string
                callback(data)
            }
        } else if message.topic.contains(AELFUrlSuffix.mqtopicMarketTodaySymbols.rawValue) {
            if let callback = self.dataCallbackOfMarketTodaySymbols {
                let data = message.string
                callback(data)
            }
        } else if message.topic.contains(AELFUrlSuffix.mqtopicMarketDelegateOrders.rawValue) {
            if let callback = self.dataCallbackOfMarketDelegateOrders {
                let data = message.string
                callback(data)
            }
        } else if message.topic.contains(AELFUrlSuffix.mqtopicMarketDepth.rawValue) {
            if let callback = self.dataCallbackOfMarketDepth {
                let data = message.string
                callback(data)
            }
        } else if message.topic.contains(AELFUrlSuffix.mqtopicMarketKLine.rawValue) {
            if let callback = self.dataCallbackOfMarketKLine {
                let data = message.string
                callback(data)
            }
        } else if message.topic.contains(AELFUrlSuffix.mqtopicMarketLatestDealOrders.rawValue) {
            if let callback = self.dataCallbackOfMarketLatestDealOrders {
                let data = message.string
                callback(data)
            }
        }
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopic topic: String) {
        loginfo(content: "MQTT Did subscribe on :\(topic)")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopic topic: String) {
        loginfo(content: "MQTT Did unsubscribe for :\(topic)")
    }
    
    func mqttDidPing(_ mqtt: CocoaMQTT) {
        loginfo(content: "MQTT PING out...")
    }
    
    func mqttDidReceivePong(_ mqtt: CocoaMQTT) {
        loginfo(content: "MQTT PING in...")
    }
    
    func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: Error?) {
        logerror(content: "MQTT Error: \(err?.localizedDescription ?? "")")
//        if let statusCallback = self.statusCallback {
//            statusCallback(false)
//        }
        self.client.connect()
    }
    
}
