//
//  GrammarRules.swift
//  Lab_02
//
//  Created by Serguei Diaz on 27.03.2024.
//

import Foundation

struct GrammarRule {
    let left: String
    var leftRecursiveRight: [String]
    var right: [String]
    
    init(_ p: String) {
        let firstSplit = p.split(separator: "->")
        let left = "\(firstSplit.first ?? "")"
        let secondSplit = "\(firstSplit.last ?? "")".split(separator: "|")
        let firstFilter = secondSplit.filter({ item in
            //item.contains(left)
            item.hasPrefix(left)
        })
        let secondFilter = secondSplit.filter({ item in
            !item.hasPrefix(left)
        })
        
        self.left = left
        self.leftRecursiveRight = firstFilter.map({ item in
            "\(item)"
        })
        self.right = secondFilter.map({ item in
            "\(item)"
        })
    }
    
    init(left: String, leftRecursiveRight: [String], right: [String]) {
        self.left = left
        self.leftRecursiveRight = leftRecursiveRight
        self.right = right
    }
}

struct Grammar {
    var rules: [GrammarRule] = []
    
    init(_ g: [String]) {
        self.rules = g.map({ p in
            GrammarRule(p)
        })
    }
    
    mutating func removeInnaccesibleSymbols() {
        var newRules: [GrammarRule] = []
        
        rules.forEach { rA in
            for rB in rules {
                if rA.left != rB.left {
                    if rB.leftRecursiveRight.contains(where: { item in
                        item.contains(rA.left)
                    }) || rB.right.contains(where: { item in
                        item.contains(rA.left)
                    }) {
                        newRules.append(rA)
                        return
                    }
                }
            }
        }
        
        rules = newRules
    }
    
    mutating func applyLeftFactorization() {
        var newRules: [GrammarRule] = []
        
        rules = rules.map({ r in
            
            var newLeft = "\(r.left)`"

            var currentRule = r.leftRecursiveRight
            currentRule.append(contentsOf: r.right)
            
            var maxPrefix = ""
            
            var newLeftRecursiveRight: [String] = []
            var newRight: [String] = []
            
            var newCurrentLeftRecursiveRight: [String] = []
            var newCurrentRight: [String] = []
            
            for i in 0...(currentRule.count-1) {
                if i < (currentRule.count-1) {
                    for j in (i+1)...(currentRule.count-1) {
                        let tempPrefix = longestCommonPrefix(currentRule[i], currentRule[j])
                        if tempPrefix.count > maxPrefix.count {
                            maxPrefix = tempPrefix
                        }
                    }
                }
            }
            
            if !maxPrefix.isEmpty {
                let newCurrentItem = "\(maxPrefix)\(newLeft)"
                
                if newCurrentItem.hasPrefix(r.left) {
                    newCurrentLeftRecursiveRight.append(newCurrentItem)
                }
                else {
                    newCurrentRight.append(newCurrentItem)
                }
                
                currentRule.forEach { item in
                    if item.hasPrefix(maxPrefix) {
                        let newItem = maxPrefix == item ? "ε" : "\(removePrefix(maxPrefix, from: item))"

                        if item.hasPrefix(r.left) {
                            newLeftRecursiveRight.append(newItem)
                        }
                        else {
                            newRight.append(newItem)
                        }
                        
                    }
                    else {
                        if item.hasPrefix(r.left) {
                            newCurrentLeftRecursiveRight.append(item)
                        }
                        else {
                            newCurrentRight.append(item)
                        }
                    }
                }
            }
            else {
                newCurrentRight = r.right
                newLeftRecursiveRight = r.leftRecursiveRight
            }
            
            if !newRight.isEmpty || !newLeftRecursiveRight.isEmpty {
                newRules.append(.init(
                    left: newLeft,
                    leftRecursiveRight: newLeftRecursiveRight,
                    right: newRight
                ))
            }
            
            return .init(
                left: r.left,
                leftRecursiveRight: newCurrentLeftRecursiveRight,
                right: newCurrentRight
            )
        })
        
        self.rules.append(contentsOf: newRules)
    }
    
    mutating func removeIndirectCalls() {
        for i in rules.indices {
            var loopRule = true
            while loopRule && i>0 {
                loopRule = false
                for j in 0...(i-1) {
                    
                    var newLeftRecursiveRight: [String] = []
                    var newRight: [String] = []
                    
                    var rulesI = rules[i].leftRecursiveRight
                    rulesI.append(contentsOf: rules[i].right)
                    
                    var rulesJ = rules[j].leftRecursiveRight
                    rulesJ.append(contentsOf: rules[j].right)

                    rulesI.forEach({ item in
                        //var newItem = item
                        if item.hasPrefix(rules[j].left) {
                            rulesJ.forEach { itemJ in
                                if itemJ.hasPrefix(rules[i].left) {
                                    newLeftRecursiveRight.append("\(itemJ)\(removePrefix(rules[j].left, from: item))")
                                }
                                else {
                                    newRight.append("\(itemJ)\(removePrefix(rules[j].left, from: item))")
                                }
                                
                            }
                            loopRule = true
                        }
                        else {
                            if item.hasPrefix(rules[i].left) {
                                newLeftRecursiveRight.append(item)
                            }
                            else {
                                newRight.append(item)
                            }
                            
                        }
                    })
                    
                    rules[i].leftRecursiveRight = newLeftRecursiveRight
                    rules[i].right = newRight
                }
            }
            
        }
    }
    
    mutating func removeLeftRecursion() {
        var newRules: [GrammarRule] = []
        
        self.rules = rules.map { rule in
            if !rule.leftRecursiveRight.isEmpty {
                var newRuleRight = rule.leftRecursiveRight.map({ r in
                    return "\(removePrefix(rule.left, from: r))\(rule.left)'"
                })
                let currentRuleRight = rule.right.map({ r in
                    return "\(r)\(rule.left)'"
                })
                
                let newRuleLeft = "\(rule.left)'"
                
                newRuleRight.append("ε")
                newRules.append(.init(
                    left: newRuleLeft,
                    leftRecursiveRight: [],
                    right: newRuleRight
                ))
                
                return GrammarRule(
                    left: rule.left,
                    leftRecursiveRight: [],
                    right: currentRuleRight.isEmpty ? [newRuleLeft] : currentRuleRight
                )
            }
            else {
                return rule
            }
        }
        
        self.rules.append(contentsOf: newRules)
    }
    
    func toStringArray() -> [String] {
        rules.map { rule in
            let left =  rule.left
            let leftRecursiveRight = rule.leftRecursiveRight.isEmpty ? "" : rule.leftRecursiveRight.joined(separator: "|")
            let right = rule.right.joined(separator: "|")
            let hideDivision = leftRecursiveRight.isEmpty || right.isEmpty
            return "\(left)->\(leftRecursiveRight)\(hideDivision ? "" : "|")\(right)"
        }
    }
    
    private func removePrefix(_ prefix: String, from text: String) -> String {
      guard text.hasPrefix(prefix) else {
        return text
      }
      return String(text.dropFirst(prefix.count))
    }
    
    private func longestCommonPrefix(_ firstString: String, _ secondString: String, _ prefix: String = "") -> String {
        guard let firstStringChar = firstString.first,
              let secondStringChar = secondString.first
        else {
            return prefix
        }
        if firstStringChar != secondStringChar {
            return prefix
        }
        else {
            return longestCommonPrefix(String(firstString.dropFirst()), String(secondString.dropFirst()), "\(prefix)\(firstStringChar)")
        }
    }
    
}
