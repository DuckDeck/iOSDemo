//
//  GrandStore.swift
//  GrandStoreDemo
//
//  Created by Tyrant on 1/6/16.
//  Copyright © 2016 Qfq. All rights reserved.
//

import Foundation



open class GrandStore<T> where T: Codable {
    fileprivate var name: String!
    fileprivate var value: T!
    fileprivate var defaultValue: T
    fileprivate var hasValue: Bool = false
    fileprivate var timeout: Int = 0
    fileprivate var isTemp = false
    fileprivate var timeoutDate: Date?
    fileprivate var observerBlock: ((_ observerObject: AnyObject, _ observerKey: String, _ oldValue: AnyObject, _ newValue: AnyObject) -> Void)?
    fileprivate var desc = ""
    @objc var key: String {
        return name
    }
    
    public init(name: String, defaultValue: T, desc: String = "") {
        self.name = name
        self.defaultValue = defaultValue
        self.desc = desc
        GrandStoreSetting.shared[name] = storeLevel
    }
    
    public init(name: String, defaultValue: T, timeout: Int, desc: String = "") { // 一般这两个就够了
        self.name = name
        self.defaultValue = defaultValue
        self.timeout = timeout
        self.desc = desc
        if self.timeout > 0 {
            timeoutDate = Date(timeIntervalSinceNow: Double(self.timeout))
        } else {
            isTemp = true
        }
        GrandStoreSetting.shared[name] = storeLevel
    }
    
    open var Value: T {
        get {
            if isExpire {
                self.clear()
                hasValue = false
            }
            if !hasValue {
                if isTemp {
                    hasValue = true
                } else {
                    if storeLevel == 0 {
                        if store.object(forKey: name) == nil {
                            self.value = self.defaultValue
                            store.set(self.value, forKey: self.name)
                            store.synchronize()
                            hasValue = true
                        } else {
                            self.value = store.object(forKey: self.name) as? T ?? defaultValue
                            hasValue = true
                        }
                    }
                    if storeLevel == 1 {
                        if store.data(forKey: self.name) == nil {
                            self.value = self.defaultValue
                            if let d = self.value.data {
                                store.setValue(d, forKey: self.name)
                                store.synchronize()
                            } else {
                                print("convert decoble to data fail")
                            }
                            hasValue = true
                        } else {
                            self.value = T.parse(d: store.data(forKey: self.name)!)!
                            hasValue = true
                        }
                    }
                }
            }
            return self.value
        }
        set {
            if let call = self.observerBlock {
                call(self, self.name, self.value as AnyObject, newValue as AnyObject)
            }
            self.value = newValue
            if isTemp {
                hasValue = true
            } else {
                if storeLevel == 0 {
                    store.set(self.value, forKey: self.name)
                    store.synchronize()
                    if timeoutDate != nil {
                        timeoutDate = Date(timeIntervalSinceNow: Double(self.timeout))
                    }
                }
                if storeLevel == 1 {
                    if timeoutDate != nil, Date() > timeoutDate! { // 如果超时
                        clear()
                        self.value = self.defaultValue
                    } else {
                        if let d = self.value.data {
                            store.set(d, forKey: self.name)
                            store.synchronize()
                        }
                        else {
                            print("convert encodable to data fail")
                        }
                    }
                }
            }
            hasValue = true
        }
    }
    
    open var DictValue: [String: Any]? {
        get {
            if storeLevel == 1 {
                let jsonEncoder = JSONEncoder()
                guard let jsonData = try? jsonEncoder.encode(Value) else {return nil}
                guard let obj = try? JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments) else {return nil}
                return obj as? [String: Any]
            } else {
                return nil
            }
        }
        set {
            if storeLevel == 1 {
                if let dict = newValue {
                    guard let data = try? JSONSerialization.data(withJSONObject: dict, options: JSONSerialization.WritingOptions.fragmentsAllowed) else {return}
                    let jsonDecoder = JSONDecoder()
                    Value = try! jsonDecoder.decode(T.self, from: data)
                }
            }
        }
    }
    
    open var JsonValue: String? {
        get {
            if storeLevel == 1 {
                let jsonEncoder = JSONEncoder()
                guard let jsonData = try? jsonEncoder.encode(Value) else {return nil}
                return String(data: jsonData, encoding: .utf8)
            } else {
                return nil
            }
        }
        set {
            if storeLevel == 1 {
                if let str = newValue {
                    let jsonDecoder = JSONDecoder()
                    guard let data = str.data(using: .utf8) else {return}
                    Value = try! jsonDecoder.decode(T.self, from: data)
                }
            }
        }
    }
    
    fileprivate var isExpire: Bool {
        if timeoutDate == nil {
            return false
        } else {
            return Date().compare(timeoutDate!) == ComparisonResult.orderedDescending
        }
    }
    
    open var wilfulValue: T? {
        return value
    }
    
    func setCacheTime(_ cacheTime: Int) {
        timeout = cacheTime
        if timeout > 0 {
            timeoutDate = Date(timeIntervalSinceNow: Double(timeout))
        }
    }
    
    open func clear() {
        if let call = observerBlock {
            call(self, name, value as AnyObject, defaultValue as AnyObject)
        }
        store.removeObject(forKey: name)
        hasValue = false
    }
    
    open func addObserver(_ block: @escaping (_ observerObject: AnyObject, _ observerKey: String, _ oldValue: AnyObject, _ newValue: AnyObject) -> Void) {
        observerBlock = block
    }

    open func removeObserver() {
        observerBlock = nil
    }

    fileprivate var storeLevel: Int {
        if defaultValue is NSNumber || defaultValue is String || defaultValue is Date || defaultValue is Data {
            return 0
        }
        return 1
    }
    
    lazy var store: UserDefaults = { UserDefaults.standard }()
}

class GrandStoreSetting {
    static var shared = [String: Int]()
    
    class func clearAll() {
        let userDefault = UserDefaults.standard
        for item in shared.enumerated() {
            userDefault.removeObject(forKey: item.element.key)
        }
    }
    
    static var allKeys: [String] {
        return shared.keys.sorted()
    }

    static func clearCacheWithName(names: String) {
        let userDefault = UserDefaults.standard
        for item in shared.enumerated() {
            if names == item.element.key {
                userDefault.removeObject(forKey: item.element.key)
            }
        }
    }

    static func clearCacheWithNames(names: [String]) {
        let userDefault = UserDefaults.standard
        for item in shared.enumerated() {
            if names.contains(item.element.key) {
                userDefault.removeObject(forKey: item.element.key)
            }
        }
    }
}

extension Decodable {
    static func parse(d: Data) -> Self? {
        let decoder = JSONDecoder()
        return try? decoder.decode(Self.self, from: d)
    }
}

extension Encodable {
    var jsonString: String? {
        if let d = data {
            return String(data: d, encoding: .utf8)
        }
        return nil
    }

    var data: Data? {
        if let data = try? JSONEncoder().encode(self) {
            return data
        }
        return nil
    }
}
