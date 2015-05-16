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
    static let Symbols = ["!", "?", ",", "(", ")", "&", "$", "£", "-"]

    @IBOutlet weak var label: WKInterfaceLabel!
    @IBOutlet weak var cycleButton: WKInterfaceButton!
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)

        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func updateWord() {
        self.resetCurrent()
        self.availWords = node.getWords(typed)
        if availWords.count > 0 {
            curWord = availWords[curWordIdx]
            self.cycleButton.setTitle("\(self.curWordIdx+1)/\(self.availWords.count)")
        }
        else {
            curWord = node.getTemplate(typed)
        }
        self.updateLabel()
    }
    
    func updateLabel(sidx: Int = 0) {
        var labelWords = [String]()
        if sidx > 0 {
            labelWords.append("...")
        }
        labelWords.extend(self.words[sidx..<self.words.count])
        if let curWord = self.curWord where self.symbolIdx < 0 {
            labelWords.append(curWord)
        }
        var txt = String(" ").join(labelWords)
        if self.symbolIdx >= 0 {
            txt += InterfaceController.Symbols[self.symbolIdx]
        }
        if count(txt) > 40 {
            self.updateLabel(sidx: sidx+1)
        } else {
            self.label.setText(txt)
        }
    }

    @IBAction func backspace() {
        typed = Array(typed[0..<typed.count-1])
        self.updateWord()
    }
    
    @IBAction func cycle() {
        if self.availWords.count > 0 {
            self.curWordIdx = (self.curWordIdx + 1) % self.availWords.count
            self.curWord = self.availWords[self.curWordIdx]
            self.cycleButton.setTitle("\(self.curWordIdx+1)/\(self.availWords.count)")
        }
        else {
            self.cycleButton.setTitle("")
        }
        self.updateLabel()
    }
    
    func addWord() {
        if let curWord = self.curWord {
            self.words.append(curWord)
            self.resetCurrent()
            self.availWords = [String]()
            self.typed = [Int]()
        }
    }
    
    @IBAction func space() {
        if let curWord = self.curWord {
            self.addWord()
        } else if var last = words.last {
            if self.symbolIdx < 0 {
                last += "."
            } else {
                last += InterfaceController.Symbols[self.symbolIdx]
                self.symbolIdx = -1
            }
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
