//
//  Formatter.swift
//  protobuf-swift-realm-runtime
//
//  Created by Alexey Khokhlov on 17.10.2017.
//

import Foundation
import ProtocolBuffers
public extension String {
    fileprivate func element(_ i:Int) -> String {
        return String(self[index(self.startIndex, offsetBy: i)])
    }
    
    fileprivate func protoCamelCase() -> String {
        var index = 0
        var returned = ""
        self.forEach({
            if index == 0 {
                let char = String($0).uppercased()
                returned += char
            } else if self.element(index).uppercased() == String($0) {
                returned += String($0).uppercased()
            } else {
                let char = String($0)
                returned += char
            }
            index += 1
        })
        return returned
    }
    
    fileprivate func tempProtoCamelCase() -> String {
        var index = 0
        var returned = ""
        self.forEach({
            if index == 0 {
                let char = String($0).uppercased()
                returned += char
            } else {
                let prev = self.element(index-1)
                if prev.lowercased() != prev {
                    returned += String($0).lowercased()
                } else {
                    returned += String($0)
                }
            }
            index += 1
        })
        return returned
    }
    
    public func capitalizedCamelCase(separator:String = ".") -> String {
        let components = self.components(separatedBy: CharacterSet.alphanumerics.inverted).filter({ $0 != ""})
        let separator = self.components(separatedBy: ".").count > 1 ? separator : ""
        let returned = components.map({
            return $0.protoCamelCase()
        }).joined(separator: separator)
        guard String(describing:returned.first) != "." else {
            return String(describing:returned.dropFirst())
        }
        return returned
    }
    public func oldCapitalizedCamelCase(separator:String = ".") -> String {
        let components = self.components(separatedBy: CharacterSet.alphanumerics.inverted).filter({ $0 != ""})
        let separator = self.components(separatedBy: ".").count > 1 ? separator : ""
        let returned = components.map({
            return $0.tempProtoCamelCase()
        }).joined(separator: separator)
        guard String(describing:returned.first) != "." else {
            return String(describing:returned.dropFirst())
        }
        return returned
    }
    
    public func underscoreCapitalizedCamelCase(separator:String = "") -> String {
        let returned = self.capitalizedCamelCase(separator: separator)
        let first = returned.first!
        let firstStr = String(describing:first).uppercased()
        let newStr = returned.dropFirst()
        return firstStr + newStr
    }
    
    public func oldUnderscoreCapitalizedCamelCase(separator:String = "") -> String {
        let returned = self.oldCapitalizedCamelCase(separator: separator)
        let first = returned.first!
        let firstStr = String(describing:first).uppercased()
        let newStr = returned.dropFirst()
        return firstStr + newStr
    }
    
    public func camelCase() -> String {
        let str = self.capitalizedCamelCase().components(separatedBy: ".").joined()
        guard let first = str.first else {
            return ""
        }
        let newStr = str.dropFirst()
        return String(describing:first).lowercased() + String(describing:newStr)
    }
    
    public func oldCamelCase() -> String {
        let str = self.oldCapitalizedCamelCase().components(separatedBy: ".").joined()
        guard let first = str.first else {
            return ""
        }
        let newStr = str.dropFirst()
        return String(describing:first).lowercased() + String(describing:newStr)
    }
}


private let _write = write
private func printToFd(_ s: String, fd: Int32, appendNewLine: Bool = true) {
    let bytes: [UInt8] = [UInt8](s.utf8)
    bytes.withUnsafeBufferPointer { (bp: UnsafeBufferPointer<UInt8>) -> () in
        write(fd, bp.baseAddress, bp.count)
    }
    if appendNewLine {
        [UInt8(10)].withUnsafeBufferPointer { (bp: UnsafeBufferPointer<UInt8>) -> () in
            write(fd, bp.baseAddress, bp.count)
        }
    }
}

public class Stdout {
    public static func print(_ s: String) { printToFd(s, fd: 1) }
    public static func write(bytes: Data) {
        bytes.withUnsafeBytes { (p: UnsafePointer<UInt8>) -> () in
            _ = _write(1, p, bytes.count)
        }
    }
}

public class Stdin {
    public static func readall() -> Data? {
        let fd: Int32 = 0
        let buffSize = 1024
        var buff = [UInt8]()
        var fragment = [UInt8](repeating: 0, count: buffSize)
        while true {
            let count = read(fd, &fragment, buffSize)
            if count < 0 {
                return nil
            }
            if count < buffSize {
                if count > 0 {
                    buff += fragment[0..<count]
                }
                return Data(bytes: buff)
            }
            buff += fragment
        }
    }
}


func readFileData(filename: String) throws -> Data {
    let url = URL(fileURLWithPath: filename)
    return try Data(contentsOf: url)
}


public final class CodeWriter {
    public let file:Google.Protobuf.FileDescriptorProto
    fileprivate var suffix = ""
    public init(file:Google.Protobuf.FileDescriptorProto, suffix:String = "") {
        self.file = file
        self.suffix = suffix
    }
    public var outputFile:String {
        var fileName = ""
        if self.file.hasPackage {
            fileName = self.file.package.capitalizedCamelCase() + "."
        }
        fileName += self.file.name.components(separatedBy: "/").last!.capitalizedCamelCase().replacingOccurrences(of: ".Proto", with: "")
        return fileName + self.suffix + ".swift"
    }
    var summaryIndent:String = ""
    public func indent() {
        summaryIndent += "\t"
    }
    public func outdent() {
        summaryIndent.removeLast()
    }
    var contentScalars = String.UnicodeScalarView()
    public var content: String {
        return String(contentScalars)
    }
    public func write(_ str:String..., newLine:Bool = true) {
        var data = ""
        if str.count > 0 {
            data =  str.joined()
        }
        contentScalars.append(contentsOf: summaryIndent.unicodeScalars)
        contentScalars.append(contentsOf: data.unicodeScalars)
        if newLine {
            contentScalars.append(contentsOf: "\n".unicodeScalars)
        }
    }
}

