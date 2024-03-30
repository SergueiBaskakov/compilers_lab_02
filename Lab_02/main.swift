//
//  main.swift
//  Lab_02
//
//  Created by Serguei Diaz on 26.03.2024.
//

import Foundation

let input: [String] = readLineUntilEmpty()
var grammar: Grammar = .init(input)

print("Initial Rigth Linear Grammar:")
printArrayOfStrings(grammar.toStringArray())
print()

grammar.removeIndirectCalls()

print("Rigth Linear Grammar Without Indirect Calls:")
printArrayOfStrings(grammar.toStringArray())
print()

grammar.removeLeftRecursion()


print("Rigth Linear Grammar Without Left Recursion:")
printArrayOfStrings(grammar.toStringArray())
print()

grammar.applyLeftFactorization()


print("Rigth Linear Grammar With Left Factorization:")
printArrayOfStrings(grammar.toStringArray())
print()

grammar.removeInnaccesibleSymbols()


print("Rigth Linear Grammar Without Innaccesible Symbols:")
printArrayOfStrings(grammar.toStringArray())
print()


func readLineUntilEmpty() -> [String] {
    var lines: [String] = []
    
    while let line = readLine(), !line.isEmpty {
        lines.append(line)
    }
    
    return lines
}

func printArrayOfStrings(_ array: [String]) {
    array.forEach { element in
        print(element)
    }
}


/*
E->E+T|T
T->T*F|F
F->(E)|a
 
E->E+T|T
T->T*F|F
F->(E)|id
 
S->iEtS|iEtSeS|a
E->b
 
A->Br
B->Cd|a
C->At
 */
