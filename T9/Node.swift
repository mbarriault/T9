//
//  Node.swift
//  T9
//
//  Created by Mike Barriault on 2015/05/10.
//  Copyright (c) 2015 Mike Barriault. All rights reserved.
//

import Foundation

class Node: NSObject, NSCoding {
    var words = [String]()
    var letters: Int = 0
    var nodes = [Int:Node]()
    weak var parent: Node? = nil
    
    class func MakeRootNode() -> Node {
        var node = Node(letters: 0)
        let docDirStr = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        let docDir = NSURL(fileURLWithPath: docDirStr)
        let wordsDictFile = docDir.URLByAppendingPathComponent("words.plist")
        let validation = NSFileManager.defaultManager()
        if validation.fileExistsAtPath(wordsDictFile.absoluteString) {
            node = NSKeyedUnarchiver.unarchiveObjectWithFile(wordsDictFile.absoluteString) as! Node
        } else {
            let wordsfile = NSBundle.mainBundle().pathForResource("words", ofType: "txt")
            let reader = StreamReader(path: wordsfile!, delimiter: "\n")
            while let word = reader?.nextLine() {
                node.addWord(word)
            }
            NSKeyedArchiver.archiveRootObject(node, toFile: wordsDictFile.absoluteString)
        }
        return node
    }
    
    static let RootNode = Node.MakeRootNode()
    
    init(letters: Int) {
        self.letters = letters
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init()
        self.words = aDecoder.decodeObjectForKey("words") as! [String]
        self.letters = aDecoder.decodeObjectForKey("letters") as! Int
        self.nodes = aDecoder.decodeObjectForKey("nodes") as! [Int:Node]
        for node in self.nodes {
            node.1.parent = self
        }
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.words, forKey: "words")
        aCoder.encodeObject(self.letters, forKey: "letters")
        aCoder.encodeObject(self.nodes, forKey: "nodes")
    }
    
    convenience init(letters: Int, parent: Node) {
        self.init(letters: letters)
        self.parent = parent
    }
    
    func addWord(word: String) {
        if word.characters.count == self.letters {
            self.words.append(word)
        }
        else {
            let lowerword = word.lowercaseString
            let startindex = lowerword.startIndex.advancedBy(self.letters)
            let lastindex = startindex.successor()
            let keystr = lowerword.substringWithRange(Range<String.Index>(start: startindex, end: lastindex))
            var key: Int = 0
            for utf8val in keystr.utf8 {
                key *= 256
                key += Int(utf8val)
            }
            key -= 97
            if key >= 25 {
                key -= 1
            }
            if key >= 18 {
                key -= 1
            }
            key /= 3
            if key >= 0 && key < 8 {
                if self.nodes[key] == nil {
                    self.nodes[key] = Node(letters: self.letters+1, parent: self)
                }
                self.nodes[key]?.addWord(word)
            }
        }
    }
    
    override var description: String {
        var desc: String = ""
        if self.words.count > 0 {
            desc += "\(self.words)"
        }
        for node in self.nodes {
            desc += "\(node.0): \(node.1.description)"
        }
        return desc
    }
    
    func getTemplate(typed: [Int]) -> String {
        var txt = ""
        for type in typed {
            switch type {
            case 2:
                txt += "a"
            case 3:
                txt += "d"
            case 4:
                txt += "g"
            case 5:
                txt += "j"
            case 6:
                txt += "m"
            case 7:
                txt += "p"
            case 8:
                txt += "t"
            case 9:
                txt += "w"
            default:
                txt += " "
            }
        }
        return txt
    }
    
    func getWords(typed: [Int]) -> [String] {
        if typed.count == 0 {
            if self.words.count > 0 {
                return self.words
            }
            else {
                if self.nodes.count == 1 {
                    return self.nodes.values.first!.getWords([])
                }
                else {
                    return []
                }
            }
        }
        else {
            let key = typed[0] - 2
            if let node = self.nodes[key] {
                if typed.count == 1 {
                    return node.getWords([])
                }
                else {
                    let typeSlice = typed[1..<typed.count];
                    return node.getWords(Array(typeSlice))
                }
            }
            else {
                return []
            }
        }
    }
    
}
