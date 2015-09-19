//
//  InterfaceController.swift
//  T9 WatchKit Extension
//
//  Created by Mike Barriault on 2015/05/10.
//  Copyright (c) 2015 Mike Barriault. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {
    let node: Node = Node.RootNode
    var typed = [Int]()
    var words = [String]()
    var curWord: String? = nil
    var curWordIdx: Int = 0
    var symbolIdx: Int = -1
    var availWords = [String]()
    var capitalise: Bool = false
    static let Symbols = ["!", "?", ",", "(", ")", "&", "$", "£", "-"]

    @IBOutlet weak var label: WKInterfaceLabel!
    @IBOutlet weak var cycleButton: WKInterfaceButton!
    
    func updateWord() {
        self.resetCurrent()
        self.availWords = node.getWords(typed)
        if availWords.count > 0 {
            curWord = availWords[curWordIdx]
        }
        else {
            curWord = node.getTemplate(typed)
        }
        if self.capitalise {
            curWord = curWord?.capitalizedString
        }
        self.updateLabel()
    }
    
    func updateLabel(sidx: Int = 0) {
        var labelWords = [String]()
        if sidx > 0 {
            labelWords.append("...")
        }
        labelWords.appendContentsOf(self.words[sidx..<self.words.count])
        if let curWord = self.curWord where self.symbolIdx < 0 {
            labelWords.append(curWord)
        }
        var txt = labelWords.joinWithSeparator(String(" "))
        if self.symbolIdx >= 0 {
            txt += InterfaceController.Symbols[self.symbolIdx]
        }
        if txt.characters.count > 40 {
            self.updateLabel(sidx+1)
        } else {
            self.label.setText(txt)
        }
        self.updateCycleButton()
    }

    @IBAction func backspace() {
        if typed.count > 0 {
            typed = Array(typed[0..<typed.count-1])
        }
        self.updateWord()
    }
    
    func updateCycleButton() {
        if self.availWords.count > 0 {
            self.cycleButton.setTitle("\(self.curWordIdx+1)/\(self.availWords.count)")
        } else if self.curWord != nil || self.symbolIdx >= 0 {
            self.cycleButton.setTitle("")
        } else {
            self.cycleButton.setTitle("⇪")
        }
    }
    
    @IBAction func cycle() {
        if self.availWords.count > 0 {
            self.curWordIdx = (self.curWordIdx + 1) % self.availWords.count
            self.curWord = self.availWords[self.curWordIdx]
        } else {
            self.capitalise = !self.capitalise
        }
        self.updateLabel()
    }
    
    func addWord() {
        if let curWord = self.curWord {
            self.words.append(curWord)
            self.resetCurrent()
            self.capitalise = false
            self.availWords = [String]()
            self.typed = [Int]()
        }
    }
    
    @IBAction func space() {
        if let _ = self.curWord {
            self.addWord()
        } else if var last = words.last {
            var sym = "."
            if self.symbolIdx >= 0 {
                sym = InterfaceController.Symbols[self.symbolIdx]
                self.symbolIdx = -1
            }
            if [".", "!", "?"].contains(sym) {
                self.capitalise = true
            } else {
                self.capitalise = false
            }
            last += sym
            self.words[self.words.count-1] = last
        }
        self.updateLabel()
    }
    
    @IBAction func symbol() {
        self.addWord()
        ++self.symbolIdx
        self.symbolIdx = self.symbolIdx % InterfaceController.Symbols.count
        self.updateLabel()
    }
    
    func resetCurrent() {
        self.curWord = nil
        self.curWordIdx = 0
        self.symbolIdx = -1
    }
    
    func type(index: Int) {
        typed.append(index)
        self.resetCurrent()
        updateWord()
    }
    
    @IBAction func abc() {
        self.type(2)
    }
    
    @IBAction func def() {
        self.type(3)
    }
    
    @IBAction func ghi() {
        self.type(4)
    }
    
    @IBAction func jkl() {
        self.type(5)
    }
    
    @IBAction func mno() {
        self.type(6)
    }
    
    @IBAction func pqrs() {
        self.type(7)
    }
    
    @IBAction func tuv() {
        self.type(8)
    }
    
    @IBAction func wxyz() {
        self.type(9)
    }
}
