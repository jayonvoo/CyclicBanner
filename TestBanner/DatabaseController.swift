//
//  DBDelegate.swift
//  TestBanner
//
//  Created by 創意遊玩 on 2018/4/30.
//  Copyright © 2018年 田腾飞. All rights reserved.
//

import UIKit
import SQLite3


class DatabaseController: UIViewController{
    
    var db: OpaquePointer?
    
    let createTableQuery_ip = "CREATE TABLE IF NOT EXISTS IPPlayerDB_ip(id INTEGER PRIMARY KEY AUTOINCREMENT, auth TEXT, address TEXT, console TEXT, cycle_time INTEGER)"
    
    let createTableQuery_data = "CREATE TABLE IF NOT EXISTS IPPlayerDB_data(id INTEGER PRIMARY KEY AUTOINCREMENT, path TEXT, type TEXT, address TEXT)"
    
    override func viewDidLoad() {
        
        let fileUrl = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("IPPlayer.db")
        
        if sqlite3_open(fileUrl.path, &db) != SQLITE_OK{
            print("Error opening database")
        }
        
        if sqlite3_exec(db, createTableQuery_ip, nil, nil, nil) != SQLITE_OK{
            print("Error creating table")
            return
        }
        
        if sqlite3_exec(db, createTableQuery_data, nil, nil, nil) != SQLITE_OK{
            print("Error creating table")
            return
        }
        
        print("Database OK")
    }
    
    func insertInitialData(auth: String, address: String, console: String, cycle_time: Int){
        
        let insertSqlQuery = "insert into IPPlayerDB_ip(auth, address, console, cycle_time) values('\(auth)', '\(address)', '\(console)', \(cycle_time))"
        var returnStmt: OpaquePointer?
        
        if !checkIfExists(address: address){
            if sqlite3_prepare(db, insertSqlQuery, -1, &returnStmt, nil) == SQLITE_OK{
                if sqlite3_step(returnStmt) == SQLITE_DONE{
                    print("Insert Data Success")
                }
            }
            sqlite3_finalize(returnStmt)
        }
        
    }
    
    func insertImageOnForeignTable(){
        let insertSqlQuery = "insert into picture_table where"
    }
    
    func checkIfExists(address: String) -> Bool{
        
        var returnStmt: OpaquePointer? = nil
        let checkExists = "select * from IPPlayerDB_ip where address like '\(address)'"
        
        sqlite3_prepare(db, checkExists, -1, &returnStmt, nil)
        
        if sqlite3_step(returnStmt) == SQLITE_ROW{
            print("table exists")
            return true
        }else{
            print(sqlite3_step(returnStmt))
            print("table no exists")
            return false
        }
    }
    
    func getDBValue_id(){
        
        var returnStmt: OpaquePointer?
        let sqlQuery = "select id from IPPlayerDB_ip where address = '192.168.0.138'"
        
        sqlite3_prepare(db, sqlQuery, -1, &returnStmt, nil)
        
        while sqlite3_step(returnStmt) == SQLITE_ROW{
            let id = sqlite3_column_int(returnStmt, 0)
            
            print("id=\(id)")
        }
    }
    
    
    func getDirectoryPath() -> String {
        
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        
        return documentsDirectory
    }
    
    
    //取得本機的ip_add
    func getWiFiAddress() -> String? {
        var address : String?
        
        // Get list of all interfaces on the local machine:
        var ifaddr : UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return nil }
        guard let firstAddr = ifaddr else { return nil }
        
        // For each interface ...
        for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let interface = ifptr.pointee
            
            // Check for IPv4 or IPv6 interface:
            let addrFamily = interface.ifa_addr.pointee.sa_family
            if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
                
                // Check interface name:
                let name = String(cString: interface.ifa_name)
                if  name == "en0" {
                    
                    // Convert interface address to a human readable string:
                    var addr = interface.ifa_addr.pointee
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(&addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                                &hostname, socklen_t(hostname.count),
                                nil, socklen_t(0), NI_NUMERICHOST)
                    address = String(cString: hostname)
                }
            }
        }
        freeifaddrs(ifaddr)
        
        return address
    }
    
    func saveImageDocumentDirectory(imageName: String, imageFile: UIImage){
        let fileManager = FileManager.default
        let paths = (NSSearchPathForDirectoriesInDomains(.applicationDirectory, .systemDomainMask, true)[0] + "MAMP/htdocs/" as NSString).appendingPathComponent("\(imageName).mp4")
        let image = imageFile
        print(paths)
        let imageData = UIImageJPEGRepresentation(image, 0.5)
        fileManager.createFile(atPath: paths as String, contents: imageData, attributes: nil)
    }
    /*
    func saveVideoDocumentDirectory(){
        let fileManager = FileManager.default
        let paths = (NSSearchPathForDirectoriesInDomains(.applicationDirectory, .systemDomainMask, true)[0] + "MAMP/htdocs/" as NSString).appendingPathComponent("\(imageName).mp4")
        let image = imageFile
        print(paths)
        let imageData = UIImageJPEGRepresentation(image, 0.5)
        fileManager.createFile(atPath: paths as String, contents: imageData, attributes: nil)
    }*/
    
    func getImage(getImagePath: String) -> UIImage{
        var getReturnImage: UIImage?
        let fileManager = FileManager.default
        var imagePAth = (self.getDirectoryPath() as NSString).appendingPathComponent(getImagePath)
        
        if fileManager.fileExists(atPath: imagePAth){
            //self.imageView.image = UIImage(contentsOfFile: imagePAth)
            getReturnImage =  UIImage(contentsOfFile: imagePAth)!
            return getReturnImage!
        }else{
            
            imagePAth = (self.getDirectoryPath() as NSString).appendingPathComponent("0401_empty_Darrel_Austin.jpg")
            getReturnImage =  UIImage(contentsOfFile: imagePAth)!
            return getReturnImage!
        }
    }
    
}
