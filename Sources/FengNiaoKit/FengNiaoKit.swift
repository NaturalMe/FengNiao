import Foundation
import PathKit
import Rainbow

enum FileType {
    case swift
    case objc
    case xib
    
    init?(ext: String) {
        switch ext {
        case "swift":
            self = .swift
            
        case "mm", "m":
            self = .objc
            
        case "xib", "storyboard":
            self = .xib
            
        default:
            return nil
        }
    }
    
    func searcher(extensions: [String]) -> StringsSearcher {
        switch self {
        case .swift:
            return SwiftSearcher(extensions: extensions)
        case .objc:
            return ObjCSearcher(extensions: extensions)
        case .xib:
            return XibSearcher(extensions: extensions)
        }
    }
    
    
}

public struct FileInfo {
    let path: String
}

public struct FengNiao {
    let projectPath: Path
    let excludedPaths: [Path]
    let resourceExtensions: [String]
    let fileExtensions: [String]
    
    public init(projectPath: String, excludedPaths: [String], resourceExtensions: [String], fileExtensions: [String] ) {
        let path = Path(projectPath).absolute()
        self.projectPath = path
        self.excludedPaths = excludedPaths.map { path + Path($0) }
        self.resourceExtensions = resourceExtensions
        self.fileExtensions = fileExtensions
    }
    
    public func unusedResource() -> [FileInfo] {
        fatalError()
    }
    
    func allStringsInUse() -> Set<String> {
        return stringsInUse(at: projectPath)
    }
    
    func stringsInUse(at path: Path) -> Set<String> {
        guard let subPaths = try? path.children() else {
            print("Path reading error. \(path)".red)
            return []
        }
        
        var result = [String]()
        for subPath in subPaths {
            if subPath.lastComponent.hasPrefix(".") { //是隐藏文件夹
                continue
            }
            
            if excludedPaths.contains(subPath) {
                continue
            }
            
            if subPath.isDirectory {
                result.append(contentsOf: stringsInUse(at: subPath))
            } else {
                let fileExt = subPath.extension ?? ""
                guard fileExtensions.contains(fileExt) else {
                    continue
                }
                
                let searcher: StringsSearcher
                if let fileType = FileType(ext: fileExt) {
                    searcher = fileType.searcher(extensions: fileExtensions)
                } else {
                    searcher = GeneralSearcher(extensions: fileExtensions)
                }
                
                let content = (try? subPath.read()) ?? ""
                result.append(contentsOf: searcher.search(in: content))
            }
        }
        return Set(result)
    }
    
    func resourcesInUse() -> [String: String] {
        guard let process = FindProcess(path: projectPath, extensions: resourceExtensions, excluded:  excludedPaths) else {
            return [:]
        }
        
        let found = process.execute()
        
        var files = [String: String]()
        
        let regularDirExtensions = ["imageset", "launchimage", "appiconset", "bundle"]
        
        fileLoop: for file in found {
            
            // Skip resources in a bundle
            let dirPath = regularDirExtensions.map { ".\($0)/" }
            for dir in dirPath where file.contains(dir) {
                continue fileLoop
            }
            
        }
        
        fatalError()
    }
    
    public func delete() {
        
    }
}
