//
//  ThreadViewController.swift
//  iOSDemo
//
//  Created by Stan Hu on 27/12/2017.
//  Copyright © 2017 Stan Hu. All rights reserved.
//

import UIKit

class ThreadViewController: UIViewController {
    var unfairLock:os_unfair_lock?
    var pNormalLock:pthread_mutex_t! = nil
    var pRecursiveLock:pthread_mutex_t! = nil
    var recursiveLock:NSRecursiveLock! = nil
    var cond:NSCondition!
    var data:Data?
    static var  recursiveCount = 0
     var arrData = ["测试信号量","os_unfair_lock","Pthread_mutex_normal","Pthread_mutex_recursive","semaphore_asnyc_to_sync","semaphore_to_lock_thread"
    ,"semaphore_to_limit_max_concurrent","NSLock","NSCondition","NSConditionLock"]
//    let btn = UIButton().then {
//        $0.setTitle("按钮", for: .normal)
//        $0.color(color: UIColor.red).bgColor(color: UIColor.gray).completed()
//        $0.frame = CGRect(x: 100, y: 80, width: 100, height: 30)
//        $0.layer.borderColor = UIColor.green.cgColor
//        $0.layer.borderWidth = 2
//        $0.addTarget(self, action: #selector(ThreadViewController.clickDown(sender:)), for: .touchUpInside)
//    }

    
    
    let tb = UITableView().then{
        $0.tableFooterView = UIView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        tb.dataSource = self
        tb.delegate = self
        view.addSubview(tb)
        tb.snp.makeConstraints { (m) in
            m.edges.equalTo(0)
        }
     
       
    }

//    @objc func clickDown(sender:UIButton)  {
//        Semaphore.testSemaphore()
//        Semaphore.testAsyncFinished()
//        Semaphore.testProductionAndConsumer()
//    }
    
    
    func processCode(flag:Int,completed:@escaping ()->Void)  {
        DispatchQueue.global().async {
            print("the process flag is :\(flag)")
            sleep(1+arc4random_uniform(3))
            print("finish process :\(flag)")
            completed()
        }
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        // pthread_mutex_destroy(&pRecursiveLock)
    }
}
extension ThreadViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil{
            cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        }
        cell?.textLabel?.text = arrData[indexPath.row]
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            Semaphore.testSemaphore()
        case 1:
            useOS_Unfair_lock()
        case 2:
            usePthread_mutex_normal()
        case 3:
            usePthread_mutex_recursive()
        case 4:
            semaphoreTest1()
        case 5:
            semaphoreTest2()
        case 6:
            semaphoreTest3()
        case 7:
            useNSLock()
        case 8:
            useNSCondition()
        case 9:
            useNSConditionLock()
        default:
            break
        }
    }
}
// test os_unfair_lock
extension ThreadViewController{
    func useOS_Unfair_lock()  {
        unfairLock = os_unfair_lock.init()
        
        let thread1 = Thread(target: self, selector: #selector(request1), object: nil)
        thread1.start()
        let thread2 = Thread(target: self, selector: #selector(request2), object: nil)
        thread2.start()
    }
    //使用了unfairLock就能严格按照代码的顺序执行了
    @objc func request1()  {
        os_unfair_lock_lock(&unfairLock!)
        print("Do:1")
        sleep(2+arc4random_uniform(4))
        print("Finish:1")
        os_unfair_lock_unlock(&unfairLock!)
    }
    
    @objc func request2() {
        os_unfair_lock_lock(&unfairLock!)
        print("Do:2")
        sleep(2+arc4random_uniform(4))
        print("Finish:2")
        os_unfair_lock_unlock(&unfairLock!)
    }
}
// test Pthread_mutex
extension ThreadViewController{
    func usePthread_mutex_normal() {
        var attr = pthread_mutexattr_t()
        //pthread_mutexattr_init(&attr)
        pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_NORMAL)
        pNormalLock = pthread_mutex_t()
        pthread_mutex_init(&pNormalLock, &attr)
        
        pthread_mutexattr_destroy(&attr)
        //有点不对
        pthread_mutex_lock(&pNormalLock)
        processCode(flag: 1) {
            pthread_mutex_unlock(&self.pNormalLock)
        }
        pthread_mutex_lock(&pNormalLock)
        processCode(flag: 2) {
            pthread_mutex_unlock(&self.pNormalLock)
        }
        pthread_mutex_lock(&pNormalLock)
        processCode(flag: 3) {
            pthread_mutex_unlock(&self.pNormalLock)
        }
        pthread_mutex_lock(&pNormalLock)
        processCode(flag: 4) {
            pthread_mutex_unlock(&self.pNormalLock)
        }
    }

    func usePthread_mutex_recursive() {
        var attr = pthread_mutexattr_t()
        //pthread_mutexattr_init(&attr)
        pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_RECURSIVE)
        pRecursiveLock = pthread_mutex_t()
        pthread_mutex_init(&pRecursiveLock, &attr)
        pthread_mutexattr_destroy(&attr)
        recursiveThread()
    }
    
    func recursiveThread()  {
        pthread_mutex_lock(&pRecursiveLock)
        
        ThreadViewController.recursiveCount += 1
        if ThreadViewController.recursiveCount < 10{
            print("count:\(ThreadViewController.recursiveCount)")
            recursiveThread()
        }
        pthread_mutex_unlock(&pRecursiveLock)
        print("finish:\(ThreadViewController.recursiveCount)")
    }
}
//test Semaphore
extension ThreadViewController{
    //异步变同步
    func semaphoreTest1() {
        let queue = DispatchQueue.global(qos: DispatchQoS.QoSClass.default)
         let semapthore = DispatchSemaphore(value: 0)//信号总量是0
        var i = 0
        queue.async {
            i = 100
            semapthore.signal()
        }
        _ = semapthore.wait(timeout: DispatchTime.distantFuture)
        print("the i is :\(i)")
    }
    //顺序执行
    func semaphoreTest2() {
        let semapthore = DispatchSemaphore(value: 1)//信号总量是1
        _ = semapthore.wait(timeout: DispatchTime.distantFuture)
        processCode(flag: 1) {
            semapthore.signal()
        }
        _ = semapthore.wait(timeout: DispatchTime.distantFuture)
        processCode(flag: 2) {
            semapthore.signal()
        }
        _ = semapthore.wait(timeout: DispatchTime.distantFuture)
        processCode(flag: 3) {
            semapthore.signal()
        }
        _ = semapthore.wait(timeout: DispatchTime.distantFuture)
        processCode(flag: 4) {
            semapthore.signal()
        }
    }
    //最大并发数被限制在了 3,其实这个用nsoperationqueue更好
    func semaphoreTest3() {
        let queue = DispatchQueue.global(qos: DispatchQoS.QoSClass.default)
        let semapthore = DispatchSemaphore(value: 3)//信号总量是3
        for _ in 0 ..< 100{
            queue.async {
                _ = semapthore.wait(timeout: DispatchTime.distantFuture)
                print("running...")
                sleep(1)
                print("Completed.......")
                semapthore.signal()
            }
        }
    }
}
//test nslock
extension ThreadViewController{
    func useNSLock() {
        let locker = NSLock()
        locker.lock()
        processCode(flag: 1) {
            locker.unlock()
        }
        locker.lock()
        processCode(flag: 2) {
            locker.unlock()
        }
        locker.lock()
        processCode(flag: 3) {
            locker.unlock()
        }
        locker.lock()
        processCode(flag: 4) {
            locker.unlock()
        }
    }
    func useRecursiveLock()  {
        recursiveLock = NSRecursiveLock()
        
        ThreadViewController.recursiveCount = 0
        
    }
    
    func recursiveLockThread() {
        recursiveLock.lock()
        ThreadViewController.recursiveCount += 1
        if ThreadViewController.recursiveCount < 10{
            print("count:\(ThreadViewController.recursiveCount)")
            useRecursiveLock()
        }
        recursiveLock.unlock()
        print("finish\(ThreadViewController.recursiveCount)")
    }
}
// test NSCondition
extension ThreadViewController{
    func useNSCondition() {
        cond = NSCondition()
        data = nil
        ns_produter()
        for _ in 0 ..< 10{
            DispatchQueue.global().async {
                self.ns_consumer()
            }
            DispatchQueue.global().async {
                self.ns_produter()
            }
        }
    }
    
    func ns_consumer() {
        cond.lock()
        while data == nil {
            cond.wait()
        }
        print("data is finish")
        cond.unlock()
    }
    
    func ns_produter(){
        cond.lock()
        data = Data()
        print("preparing data....")
        sleep(1)
        cond.signal()
        cond.unlock()
    }
}
//test NSConditionLock
extension ThreadViewController{
    func useNSConditionLock(){
//        let condLock = NSConditionLock(condition: 1)
//        condLock.lock(whenCondition: 1)
//        processCode(flag: 1) {
//            condLock.unlock(withCondition: 2)
//        }
//        condLock.lock(whenCondition: 2)
//        processCode(flag: 2) {
//            condLock.unlock(withCondition: 3)
//        }
//        condLock.lock(whenCondition: 3)
//        processCode(flag: 3) {
//            condLock.unlock(withCondition: 3)
//        }
//        condLock.lock(whenCondition: 4)
//        processCode(flag: 4) {
//            condLock.unlock()
//        }
        
        for i in 0..<19999{
           Logs.log(type: .info, tag: "1 号模块", content: "\(i)Test.mmap2 是缓存文件，不用关心，我们需要的是 Test_20170103.xlog 文件，我们把这个文件使用Mars提供的 Python 脚本进行解密。脚本在mars-master/mars/log/crypt/decode_mars_log_file.py把 decode_mars_log_file.py 和 Test_20170103.xlog 拉到桌面，从 MacOS 的终端使用 cd 命令进入桌面，再输入命令")
            
       }
    }
}
