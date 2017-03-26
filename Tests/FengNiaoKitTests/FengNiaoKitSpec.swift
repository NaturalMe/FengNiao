//
//  FengNiaoKitSpec.swift
//  FengNiao
//
//  Created by 张润良 on 2017/3/26.
//
//

import Foundation
import Spectre
import PathKit
@testable import FengNiaoKit

public func specFengNiaoKit() {
    describe("FengNiaoKit") {
        
        let fixtures = Path(#file).parent().parent() + "Fixtures" // #file 获取当前路径
        
        $0.describe("String Extension") {
            $0.it("should return plain name") {
                let s1 = "image@2x.tmp"
                let s2 = "/usr/local/bin/find"
                let s3 = "image@3X.png"
                let s4 = "local.host"
                let s5 = "local.host.png"
                
                let exts = ["png"]
                
                try expect(s1.plainName(extensions: exts)) == "image@2x.tmp"
                try expect(s2.plainName(extensions: exts)) == "find"
                try expect(s3.plainName(extensions: exts)) == "image"
                try expect(s4.plainName(extensions: exts)) == "local.host"
                try expect(s5.plainName(extensions: exts)) == "local.host"
            }
        }
        
        $0.describe("String Searchers") {
            $0.it("Swift Searcher works") {
                let s1 = "UIImage(named: \"my_image\")"
                let s2 = "fjauilh \"aa\" sdji\"_lksjd\""
                let s3 = "let name = \"close_button@2x\"/nlet image = UIImage(named: name)"
                let s4 = "test string: \"local.png\""
                let s5 = "test string: \"local.host\"" // local.host.png
                
                
                let searcher = SwiftSearcher(extensions: ["png"])
                let result = [s1, s2, s3, s4, s5].map {
                    searcher.search(in: $0)
                }
                
                try expect(result[0]) == Set(["my_image"])
                try expect(result[1]) == Set(["aa", "_lksjd"])
                try expect(result[2]) == Set(["close_button"])
                try expect(result[3]) == Set(["local"])
                try expect(result[4]) == Set(["local.host"])
            }
        }
        
        
        $0.describe("FengNiaoKit Function") {
            $0.it("should find used strings in Swift") {
                let path = fixtures + "FileStringSearcher"
                let fengniao = FengNiao(projectPath: path.string, excludedPaths: [], resourceExtensions: ["png", "jpg"], fileExtensions: ["swift"])
                let result = fengniao.allStringsInUse()
                
                let expected: Set<String> = ["common.login",
                                             "common.logout",
                                             "live_btn_connect",
                                             "live_btn_connect",
                                             "name-key",
                                             "无法支持"]
                try expect(result) == expected
            }
        }
    }
    

    
}
