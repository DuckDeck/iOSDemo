//
//  GrandStore.swift
//  GrandStoreDemo
//
//  Created by Tyrant on 1/6/16.
//  Copyright © 2016 Qfq. All rights reserved.
//

import Foundation
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func <= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l <= r
  default:
    return !(rhs < lhs)
  }
}


open class GrandStore<T> {
    fileprivate var name:String!
    fileprivate var value:T?
    fileprivate var defaultValue:T?
    fileprivate var hasValue:Bool = false
    fileprivate var timeout:Int = 0
    fileprivate var storeLevel:Int = 0
    fileprivate var isTemp = false//只是放到内存里临时保存
    fileprivate var timeoutDate:Date?
    fileprivate var observerBlock:((_ observerObject:AnyObject,_ observerKey:String,_ oldValue:AnyObject,_ newValue:AnyObject)->Void)?
   public  init(name:String,defaultValue:T) {
        self.name = name;
        self.defaultValue = defaultValue;
        storeLevel = self.getStoreLevel()
        //GrandStore.sharedStore.setObject(self, forKey: self.name)
    }
    

    
  public  init(name:String,defaultValue:T,timeout:Int) {  //一般这两个就够了
        self.name = name;
        self.defaultValue = defaultValue;
        self.timeout = timeout
        if self.timeout > 0{
            timeoutDate = Date(timeIntervalSinceNow: Double(self.timeout))
        }
        else{
            isTemp = true
        }
        storeLevel = self.getStoreLevel()
        //GrandStore.sharedStore.setObject(self, forKey: self.name)
    }
    
    
    
  open  var Value:T?
        {
        get
        {
            if isExpire{
                self.clear()
                hasValue = false
            }
            if !hasValue
            {
                if isTemp{
                    if self.value == nil{
                        self.value = defaultValue
                        hasValue = true
                    }
                }
                else{
                if storeLevel == 0 //如果存储等级为0,那么从userdefault取
                {
                    if GrandStore.settingData().object(forKey: name) == nil //如果取不出来
                    {
                        self.value = self.defaultValue;
                        GrandStore.settingData().set(self.value!, forKey: self.name)
                        GrandStore.settingData().synchronize()
                        hasValue = true
                    }
                    else
                    {
                        self.value = GrandStore.settingData().object(forKey: self.name) as? T
                        hasValue = true
                    }
                }
                if storeLevel == 1 //这是用归档保存, 日后处理
                {
                    if !GrandCache.globleCache.hasCacheForKey(self.name){
                        self.value = self.defaultValue
                        if timeoutDate != nil{
                            if self.value is NSCoding{
                                GrandCache.globleCache.setObject(self.value as! NSCoding, key: self.name, timeoutInterval: Double(self.timeout))
                                timeoutDate = Date(timeIntervalSinceNow: Double(self.timeout))
                            }
                            else{
                                assert(true, "if you want to store the complex  value, you must let it abide by NSCoding protocal")
                            }
                        }
                        else{
                            if self.value is NSCoding{
                                GrandCache.globleCache.setObject(self.value as! NSCoding, key: self.name)
                            }
                            else{
                                assert(true, "if you want to store the complex  value, you must let it abide by NSCoding protocal")
                            }
                        }
                        hasValue = true
                    }
                    else{
                        self.value = GrandCache.globleCache.objectForKey(self.name) as? T
                        hasValue = true
                    }
                }
                }
            }
            return self.value
        }
        set
        {
//            GrandStoreSetting.sharedObserverKey.enumerateObjectsUsingBlock { (obj, idx, stop) -> Void in
//                if obj.isEqualToString(self.name){
                    if let call = self.observerBlock{
                        if self.value == nil
                        {
                            self.value = self.defaultValue
                        }
                        call(self,self.name,self.value as AnyObject,newValue as AnyObject)
                    }
//                }
//            }
            self.value = newValue
            if isTemp{
                hasValue = true
            }
            else{
             if storeLevel == 0
            {
                GrandStore.settingData().set(self.value!, forKey: self.name)
                GrandStore.settingData().synchronize()
                if timeoutDate != nil{
                    timeoutDate = Date(timeIntervalSinceNow: Double(self.timeout))
                }
            }
            if storeLevel == 1  //这是用归档保存, 日后处理
            {
                if timeoutDate != nil{
                    if self.value is NSCoding{
                        GrandCache.globleCache.setObject(self.value as! NSCoding, key: self.name, timeoutInterval: Double(self.timeout))
                        timeoutDate = Date(timeIntervalSinceNow: Double(self.timeout))
                    }
                    else{
                        assert(true, "if you want to store the complex  value, you must let it abide by NSCoding protocal")
                    }
                }
                else{
                    if self.value is NSCoding{
                        GrandCache.globleCache.setObject(self.value as! NSCoding, key: self.name)
                        // timeoutDate = NSDate(timeIntervalSinceNow: Double(self.timeout))
                    }
                    else{
                        assert(true, "if you want to store the complex  value, you must let it abide by NSCoding protocal")
                    }
                }
                }
            }
            hasValue = true
        }
    }
    
    fileprivate var isExpire:Bool{
        get{
            if timeoutDate == nil{
                return false
            }
            else{
                return Date().compare(timeoutDate!) == ComparisonResult.orderedDescending
            }
        }
    }
    
  open  var wilfulValue:T?{
        return value
    }
    
 open  func deleteWith(_ block:(_ item:AnyObject)->Bool)->Bool{
        if let items = value as? NSArray {
            var i = 0
            let newItem = NSMutableArray(array: items)
            while i < items.count {
                if block(items[i] as AnyObject) {
                    newItem.removeObject(at: i)
                    self.Value = newItem as? T
                    return true
                }
                i += 1
            }
        }
        return false
    }
    
   open func replaceWith(_ item:AnyObject,block:(_ item:AnyObject)->Bool) -> Bool {
        if let items = value as? NSArray {
            let newItem = NSMutableArray(array: items)
            var i = 0
            while i < items.count {
                if block(items[i] as AnyObject) {
                    newItem.removeObject(at: i)
                    newItem.insert(item, at: i)
                    self.Value = newItem as? T
                    return true
                }
                i += 1
            }
        }
        return false
    }
    
  open  func appendWith(_ item:AnyObject) -> Bool {
        if let items = value as? NSArray {
            let newItem = NSMutableArray(array: items)
            newItem.add(item)
            self.Value = newItem as? T
            return true
        }
        return false

    }
    
    open func uniqueAppend(_ item:AnyObject,block:(_ item:AnyObject)->Bool) -> Bool {
        if let items = value as? NSArray {
            let newItem = NSMutableArray(array: items)
            var i = 0
            var flag = false
            while i < items.count {
                if block(items[i] as AnyObject) { //存在
                    flag = true
                    return false
                }
                i += 1
            }
            if !flag{
                newItem.add(item)
                self.Value = newItem as? T
                return true
            }
        }
        return false
    }
    
    func setCacheTime(_ cacheTime:Int){
        self.timeout = cacheTime
        if self.timeout > 0{
            timeoutDate = Date(timeIntervalSinceNow: Double(self.timeout))
        }
    }
    
    open func clear(){
//        GrandStoreSetting.sharedObserverKey.enumerateObjectsUsingBlock { (obj, idx, stop) -> Void in
//            if obj.isEqualToString(self.name){
            if let call = self.observerBlock{
                call(self,self.name,self.value as AnyObject,self.defaultValue as AnyObject)
            }
//            }
//        }
        GrandStore.settingData().removeObject(forKey: self.name)
        GrandCache.globleCache.removeCacheForKey(self.name)
        hasValue = false
    }
    
    
  open  func addObserver(_ block:@escaping (_ observerObject:AnyObject,_ observerKey:String,_ oldValue:AnyObject,_ newValue:AnyObject)->Void){
        //GrandStoreSetting.sharedObserverKey.addObject(self.name)
        self.observerBlock = block
    }
  open  func removeObserver(){
       // GrandStoreSetting.sharedObserverKey.removeObject(self.name)
        self.observerBlock = nil
    }
    fileprivate func getStoreLevel()->Int
    {
        if self.defaultValue! is NSNumber || self.defaultValue! is String || self.defaultValue! is Date || self.defaultValue! is Data
        { //need test NSData can store in the NSUserDefaults, I whether it need store the NSArray or NSdictonary
            return 0
        }
        return 1
    }
    
    fileprivate static func settingData()->UserDefaults
    {
        return UserDefaults.standard
    }
    //在Swift中,当需要把一个类转为泛型类时,Swift必需知道这个泛型类是个什么样的类,不然就不行,现在Swift又没有KVC和KVO,所以很多OBJC的功能目前实现不了,以后看有没有机会实现
}

//class GrandStoreSetting {
//    private static let sharedStoreInstance = NSMutableDictionary()
//    class var sharedStore:NSMutableDictionary {
//        return sharedStoreInstance
//    }
//    private static let sharedObserverKeyInstance = NSMutableArray()
//    class var  sharedObserverKey:NSMutableArray{
//        return sharedObserverKeyInstance
//    }
//    static func clearAllCache(){
//        GrandStore.sharedStore.enumerateKeysAndObjectsUsingBlock { (obj, idx, stop) -> Void in
//            obj.clear()
//        }
//    }
//    static  func clearCacheWithNames(names:[String]){
//        GrandStore.sharedStore.enumerateKeysAndObjectsUsingBlock { (obj, idx, stop) -> Void in
//            if names.contains(obj.name){
//                obj.clear()
//            }
//        }
//    }
//    static func clearCacheExceptNames(names:[String]){
//        GrandStore.sharedStore.enumerateKeysAndObjectsUsingBlock { (obj, idx, stop) -> Void in
//            if !names.contains(obj.name){
//                obj.clear()
//            }
//        }
//    }
//    
//    static func clearCache(){
//        GrandStore.sharedStore.enumerateKeysAndObjectsUsingBlock { (obj, idx, stop) -> Void in
//            //            if let store = obj as? G_S{
//            //                if store.timeoutDate != nil{
//            //                    store.clear()
//            //                }
//            //            }
//            //没办法,只有用KVC了
//            //            if let _ = obj.valueForKey("timeoutDate") as? NSDate{
//            //
//            //            }
//            //            else{
//            //                obj.clear()
//            //            }
//            //swift 里面没有KVC
//            
//        }
//    }
    //    static  func getValueWithName(name:String)->AnyObject?{
    //        if let gs = GrandStore.sharedStore.objectForKey(name) as? G_S{
    //            return gs.Value as? AnyObject
    //        }
    //        else{
    //            return nil;
    //        }
    //    }
    //    static  func setValueWithName(name:String,value:AnyObject){
    //        if let gs = GrandStore.sharedStore.objectForKey(name) as? G_S{
    //            gs.Value = value as? T
    //        }
    //    }
    
//}
//在Swift目前的机制下,这个类没什么用


class GrandCache {
    // Now turn EGOCahce to swift laguage
    fileprivate static let sharedInstance = GrandCache()
    class  var globleCache:GrandCache {
        return sharedInstance
    }
    
    var cacheInfoQueue:DispatchQueue
    var frozenCacheInfoQueue:DispatchQueue
    var diskQueue:DispatchQueue
    var cacheInfo:[String:Date]
    var directory:String
    var needSave:Bool = false
    var frozenCacheInfo:[String:Date]
    var defaultTimeoutInterval:TimeInterval = Double(Int.max)
    init(){
        var cacheDirectory:NSString = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0] as NSString
        let oldCacheDirectroy = (cacheDirectory.appendingPathComponent(ProcessInfo.processInfo.processName) as NSString).appendingPathComponent("GrandStore")
        if FileManager.default.fileExists(atPath: oldCacheDirectroy){
            if let _ = try? FileManager.default.removeItem(atPath: oldCacheDirectroy){
                //do nothing
            }
        }
        cacheDirectory = (cacheDirectory.appendingPathComponent(Bundle.main.bundleIdentifier!) as NSString).appendingPathComponent("GrandStore") as NSString
        
        cacheInfoQueue = DispatchQueue(label: "DuckDeck.GrandStore.Info", attributes: [])
        var priority = DispatchQueue.global(qos: DispatchQoS.QoSClass.userInteractive) //what is this suppose to do......
        
        priority.setTarget(queue: cacheInfoQueue)
        
        frozenCacheInfoQueue = DispatchQueue(label: "DuckDeck.GrandStore.Frozen", attributes: [])
        priority = DispatchQueue.global(qos: DispatchQoS.QoSClass.userInteractive)
        priority.setTarget(queue: frozenCacheInfoQueue)
        
        diskQueue = DispatchQueue(label: "DuckDeck.GrandStore.Disk", attributes: DispatchQueue.Attributes.concurrent)
        priority = DispatchQueue.global(qos: DispatchQoS.QoSClass.userInteractive)
        priority.setTarget(queue: diskQueue)
        
        directory = cacheDirectory as String
        
        if let  tempCacheInfo = NSDictionary(contentsOfFile: directory + "GrandStore.plist") as? [String:Date]{
            cacheInfo = tempCacheInfo
        }
        else{
            cacheInfo = [String:Date]()
        }
        if let _ = try? FileManager.default.createDirectory(atPath: directory, withIntermediateDirectories: true, attributes: nil){
            //do nothing
        }
        let now = Date().timeIntervalSinceReferenceDate
        var removedKeys = [String]()
        for key in cacheInfo.keys{
            if cacheInfo[key]?.timeIntervalSinceReferenceDate <= now{
                if let  _  = try? FileManager.default.removeItem(atPath: directory + key.replacingOccurrences(of: "/", with: "_")) {
                    removedKeys.append(key)
                }
            }
        }
        for key in removedKeys{
            cacheInfo.removeValue(forKey: key)
        }
        frozenCacheInfo = cacheInfo
    }
    
    func clearCache(){
        cacheInfoQueue.sync { () -> Void in
            for key in self.cacheInfo.keys{
                if let  _  = try? FileManager.default.removeItem(atPath: self.cachePathForKey(self.directory, key: key)){
                    
                }
            }
            self.cacheInfo.removeAll()
            self.frozenCacheInfoQueue.sync(execute: { () -> Void in
                self.frozenCacheInfo = self.cacheInfo
            })
            self.setNeedSave()
        }
    }
    
    func setNeedSave(){
        cacheInfoQueue.async { () -> Void in
            if self.needSave{
                return
            }
            self.needSave = true
            let delayInSeconds = 0.5
            let popTime = DispatchTime.now() + Double(Int64(delayInSeconds * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            self.cacheInfoQueue.asyncAfter(deadline: popTime, execute: { () -> Void in
                if !self.needSave {
                    return;
                }
                (self.cacheInfo as NSDictionary).write(toFile: self.cachePathForKey(self.directory, key: "GrandStore.plist"), atomically: true)
                self.needSave = false
            })
        }
    }
    
    
    func removeCacheForKey(_ key:String){
        if key == "GrandStore.plist"{
            return
        }
        diskQueue.async { () -> Void in
            if let  _  = try?  FileManager.default.removeItem(atPath: self.cachePathForKey(self.directory, key: key)){
                
            }
        }
        self.setCacheTimeoutInterval(0, key: key)
    }
    
    func hasCacheForKey(_ key:String)->Bool{
        if let date = dateForKey(key){
            if date.timeIntervalSinceReferenceDate < CFAbsoluteTimeGetCurrent(){
                return false
            }
            return FileManager.default.fileExists(atPath: cachePathForKey(self.directory, key: key))
        }
        else{
            return false
        }
    }
    
    func dateForKey(_ key:String)->Date?{
        var date:Date? = nil
        self.frozenCacheInfoQueue.sync { () -> Void in   //why shoudl do this, that's weird,mey be this is for thread lock
            date = self.frozenCacheInfo[key]
        }
        return date
    }
    
    func allKeys()->[String]?{
        var keys:[String]? = nil
        self.frozenCacheInfoQueue.sync { () -> Void in
            for key in self.frozenCacheInfo.keys{ //目前只有这样 了
                keys?.append(key)
            }
        }
        return keys
    }
    
    func setCacheTimeoutInterval(_ timeoutInterval:TimeInterval,key:String){
        let date:Date? = timeoutInterval > 0 ? Date(timeIntervalSinceNow: timeoutInterval) : nil
        frozenCacheInfoQueue.sync { () -> Void in
            if date != nil{
                self.frozenCacheInfo[key] = date!
            }
            else{
                self.frozenCacheInfo.removeValue(forKey: key)
            }
        }
        
        cacheInfoQueue.async { () -> Void in
            if date != nil{
                self.cacheInfo[key] = date
            }
            else
            {
                self.cacheInfo.removeValue(forKey: key)
            }
            self.frozenCacheInfoQueue.sync(execute: { () -> Void in
                self.frozenCacheInfo = self.cacheInfo
            })
            self.setNeedSave()
        }
    }
    
    
    func copyFilePath(_ filePath:String,key:String){
        coprFilePath(filePath, key: key, timeoutInterval: defaultTimeoutInterval)
    }
    
    func coprFilePath(_ filePath:String,key:String,timeoutInterval:TimeInterval){
        diskQueue.async { () -> Void in
            if let _ = try? FileManager.default.copyItem(atPath: filePath, toPath: self.cachePathForKey(self.directory, key: key)){
                
            }
        }
        setCacheTimeoutInterval(timeoutInterval, key: key)
    }
    
    func setData(_ data:Data,key:String){
        setData(data, key: key, timeoutInterval: defaultTimeoutInterval)
    }
    
    func setData(_ data:Data,key:String,timeoutInterval:TimeInterval){
        if key == "GrandStore.plist"{
            return
        }
        let cachePath = cachePathForKey(directory, key: key)
        self.diskQueue.async { () -> Void in
            try? data.write(to: URL(fileURLWithPath: cachePath), options: [.atomic])
        }
        setCacheTimeoutInterval(timeoutInterval, key: key)
    }
    
    func dataForKey(_ key:String)->Data?{
        if hasCacheForKey(key){
            if let data = try? Data(contentsOf: URL(fileURLWithPath: cachePathForKey(directory, key: key)), options: NSData.ReadingOptions.mappedIfSafe){
                return data
            }
            else
            {
                return nil
            }
        }
        else{
            return nil
        }
    }
    
    func stringForKey(_ key:String)->String?{
        if let data = self.dataForKey(key){
            return String(data: data, encoding: String.Encoding.utf8)
        }
        else
        {
            return nil
        }
    }
    
    func setString(_ str:String,key:String){
        self.setString(str, key: key, timeoutInterval: defaultTimeoutInterval)
    }
    
    func setString(_ str:String,key:String,timeoutInterval:TimeInterval){
        self.setData(str.data(using: String.Encoding.utf8)!, key: key, timeoutInterval: timeoutInterval)
    }
    
    //Image就不要了
    //plist 也不要了
    //Object
    func objectForKey(_ key:String)-> NSCoding?{
        if self.hasCacheForKey(key){
            if let data = self.dataForKey(key){
                return NSKeyedUnarchiver.unarchiveObject(with: data) as? NSCoding
            }
            else{
                return nil
            }
        }
        return nil
    }
    
    func setObject(_ obj:NSCoding,key:String){
        setObject(obj, key: key, timeoutInterval: defaultTimeoutInterval)
    }
    
    func setObject(_ obj:NSCoding,key:String,timeoutInterval:TimeInterval){
        self.setData(NSKeyedArchiver.archivedData(withRootObject: obj), key: key, timeoutInterval: timeoutInterval)
    }
    
    
    func cachePathForKey(_ directory:String,key:String)->String{
       let path = key.replacingOccurrences(of: "/", with: "_")
        return directory + path
    }
}
