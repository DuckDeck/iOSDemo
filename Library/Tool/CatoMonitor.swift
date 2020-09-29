//
//  Clas.swift
//  iOSDemo
//
//  Created by shadowedge on 2020/9/29.
//  Copyright © 2020 Stan Hu. All rights reserved.
//

import Foundation
import Darwin
public class CatonMonitor{
    enum Constants {
        static let timeOutInterval:TimeInterval = 0.05
        static let queueTitle = "com.shadowedge.CartMonitor"
      
    }
    
    private var queue:DispatchQueue = DispatchQueue(label: Constants.queueTitle)
    private var isMonitoring = false
    private var semaphore = DispatchSemaphore(value: 0)
    
    public init() {
        
    }
    
    public func start(){
        guard !isMonitoring else {
            return
        }
        isMonitoring = true
        queue.async {
            while self.isMonitoring{
                var timeout = true
                DispatchQueue.main.async {
                    timeout = false
                    self.semaphore.signal()
                }
                Thread.sleep(forTimeInterval: Constants.timeOutInterval)
                if timeout {
                    let symbles = BackTrace.callStack(.main)
                    for symble in symbles {
                        print(symble.demangledSymbol)
                    }
                }
                self.semaphore.wait()
            }
        }
    }
    
    public func stop(){
        guard isMonitoring  else {
            return
        }
        isMonitoring = false
    }
}


extension Character {
    var isAscii: Bool {
        return unicodeScalars.allSatisfy { $0.isASCII }
    }
    var ascii: UInt32? {
        return isAscii ? unicodeScalars.first?.value : nil
    }
}

extension String {
    var ascii : [Int8] {
        var unicodeValues = [Int8]()
        for code in unicodeScalars {
            unicodeValues.append(Int8(code.value))
        }
        return unicodeValues
    }
}

public struct StackFrame {
    public let symbol: String
    public let file: String
    public let address: UInt64
    public let symbolAddress: UInt64

    public var demangledSymbol: String {
        return _stdlib_demangleName(symbol)
    }
}

class BackTrace: NSObject {
    
    public static let main_thread_t = mach_thread_self()

    public static func callStack(_ thread: Thread) -> [StackFrame] {
        let pthread = machThread(from: thread)
        return getCallStack(pthread_from_mach_thread_np(pthread)!) ?? []
    }

    static func machThread(from thread: Thread) -> thread_t {
        var name: [Int8] = [Int8]()
        var count: mach_msg_type_number_t = 0
        var threads: thread_act_array_t!

        guard task_threads(mach_task_self_, &(threads), &count) == KERN_SUCCESS else {
            return mach_thread_self()
        }

        if thread.isMainThread {
            return self.main_thread_t
        }

        let originName = thread.name

        for i in 0..<count {
            let index = Int(i)
            if let p_thread = pthread_from_mach_thread_np((threads[index])) {
                name.append(Int8(Character.init("\0").ascii!))
                pthread_getname_np(p_thread, &name, MemoryLayout<Int8>.size * 256)
                if (strcmp(&name, (thread.name!.ascii)) == 0) {
                    thread.name = originName
                    return threads[index]
                }
            }
        }

        thread.name = originName
        return mach_thread_self()
    }
}


private var targetThread: pthread_t?
private var callstack: [StackFrame]?
@inline(never)
private func signalHandler(code: Int32, info: UnsafeMutablePointer<__siginfo>?, uap: UnsafeMutableRawPointer?) -> Void {
    guard pthread_self() == targetThread else {
        return
    }

    callstack = frame()
}

private func setupCallStackSignalHandler() {
    let action = __sigaction_u(__sa_sigaction: signalHandler)
    var sigActionNew = sigaction(__sigaction_u: action, sa_mask: sigset_t(), sa_flags: SA_SIGINFO)

    if sigaction(SIGUSR2, &sigActionNew, nil) != 0 {
        return
    }
}
@inline(never)
public func getCallStack(_ threadId: pthread_t) -> [StackFrame]? {
    if threadId.hashValue == 0 || threadId == pthread_self() {
        return frame()
    }

    targetThread = threadId
    callstack = nil

    setupCallStackSignalHandler()

    if pthread_kill(threadId, SIGUSR2) != 0 {
        return nil
    }

    do {
        var mask = sigset_t()
        sigfillset(&mask)
        sigdelset(&mask, SIGUSR2)
    }

    return callstack
}
private func frame() -> [StackFrame]? {
    var symbols = [StackFrame]()
    let stackSize: UInt32 = 128
    let addrs = UnsafeMutablePointer<UnsafeMutableRawPointer?>.allocate(capacity: Int(stackSize))
    defer { addrs.deallocate() }
    let frameCount = backtrace(addrs, Int32(stackSize))
    let buf = UnsafeBufferPointer(start: addrs, count: Int(frameCount))
    for addr in buf {
        guard let addr = addr else { continue }
        var dlInfoPtr = UnsafeMutablePointer<Dl_info>.allocate(capacity: 1)
        defer { dlInfoPtr.deallocate() }
        guard dladdr(addr, dlInfoPtr) != 0 else {
            continue
        }
        let info = dlInfoPtr.pointee
        let symbol = String(cString: info.dli_sname)
        let filename = String(cString: info.dli_fname)
        let symAddrValue = unsafeBitCast(info.dli_saddr, to: UInt64.self)
        let addrValue = UInt64(UInt(bitPattern: addr))
        symbols.append(StackFrame(symbol: symbol, file: filename, address: addrValue, symbolAddress: symAddrValue))
    }
    return symbols
}
@_silgen_name("backtrace")
public func backtrace(_ stack: UnsafeMutablePointer<UnsafeMutableRawPointer?>!, _ maxSymbols: Int32) -> Int32
@_silgen_name("backtrace_symbols")
public func backtrace_symbols(_ stack: UnsafePointer<UnsafeMutableRawPointer?>!, _ frame: Int32) -> UnsafeMutablePointer<UnsafeMutablePointer<Int8>?>!

@_silgen_name("swift_demangle")
public
func _stdlib_demangleImpl(
    mangledName: UnsafePointer<CChar>?,
    mangledNameLength: UInt,
    outputBuffer: UnsafeMutablePointer<CChar>?,
    outputBufferSize: UnsafeMutablePointer<UInt>?,
    flags: UInt32
    ) -> UnsafeMutablePointer<CChar>?

public func _stdlib_demangleName(_ mangledName: String) -> String {
    return mangledName.utf8CString.withUnsafeBufferPointer {
        (mangledNameUTF8CStr) in

        let demangledNamePtr = _stdlib_demangleImpl(
            mangledName: mangledNameUTF8CStr.baseAddress,
            mangledNameLength: UInt(mangledNameUTF8CStr.count - 1),
            outputBuffer: nil,
            outputBufferSize: nil,
            flags: 0)

        if let demangledNamePtr = demangledNamePtr {
            let demangledName = String(cString: demangledNamePtr)
            free(demangledNamePtr)
            return demangledName
        }
        return mangledName
    }
}
