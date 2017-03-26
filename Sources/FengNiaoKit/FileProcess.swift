//
//  FileProcess.swift
//  FengNiao
//
//  Created by 张润良 on 2017/3/26.
//
//

import Foundation
import PathKit

struct FindProcess {
    let p: Process
    init?(path: Path, extensions: [String], excluded: [Path]) {
        p = Process()
        p.launchPath = "usr/bin/find"
        
        // 什么都不想找
        guard !extensions.isEmpty else {
            return nil
        }
        
        var args = [String]()
        args.append(path.string)
        
        for(i, ext) in extensions.enumerated() {
            if i == 0 {
                args.append("(")
            } else {
                args.append("-or")
            }
            args.append("-name")
            args.append("*.\(ext)")
            
            if i == extensions.count - 1 {
                args.append(")")
            }
        }
        
        for excludedPath in excluded {
            args.append("-not")
            args.append("-path")
            
            let filePath = path + excludedPath
            guard filePath.exists else { continue }
            
            if filePath.isDirectory {
                args.append("\(filePath.string)/*")
            } else {
                args.append(filePath.string)
            }
        }
        
        p.arguments = args
    }
    
    func execute() -> Set<String> {
        let pipe = Pipe()
        p.standardOutput = pipe
        
        let fileHandler = pipe.fileHandleForReading
        p.launch()
        
        let data = fileHandler.readDataToEndOfFile()
        if let string = String(data: data, encoding: .utf8) {
            return Set(string.components(separatedBy: "\n").dropLast())
        } else {
            return []
        }
    }
}
