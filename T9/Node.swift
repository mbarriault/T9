//
//  Node.swift
//  T9
//
//  Created by Mike Barriault on 2015/05/10.
//  Copyright (c) 2015 Mike Barriault. All rights reserved.
//

import Foundation

class Node {
    var words = [String]()
    var letters: Int = 0
    var nodes = [Node?]()
    weak var parent: Node? = nil
    
    class func MakeRootNode() -> Node {
        let node = Node(letters: 0)
        let wordsfile = NSBundle.mainBundle().pathForResource("words", ofType: "txt")
        let reader = StreamReader(path: wordsfile!, delimiter: "\n")
        while let word = reader?.nextLine() {
            node.addWord(word)
        }
        return node
    }
    
    static let RootNode = Node.MakeRootNode()
    
    init(letters: Int) {
        self.letters = letters
        self.nodes = [Node?](count: 8, repeatedValue: nil)
    }
    
    convenience init(letters: Int, parent: Node) {
        self.init(letters: letters)
        self.parent = parent
    }
    
    func addWord(word: String) {
        if count(word) == self.letters {
            self.words.append(word)
        }
        else {
            let lowerword = word.lowercaseString
            let startindex = advance(lowerword.startIndex, self.letters)
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
    
    var description: String {
        var desc: String = ""
        if self.words.count > 0 {
            desc += "\(self.words)"
        }
        for node in self.nodes {
            if node != nil {
                desc += "\(node!.description)"
            }
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
                var nilnodecount: Int = 0
                var onlyNode: Node? = nil
                for node in self.nodes {
                    if node != nil {
                        ++nilnodecount
                        onlyNode = node
                    }
                }
                if nilnodecount == 1 {
                    return onlyNode!.getWords([])
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
