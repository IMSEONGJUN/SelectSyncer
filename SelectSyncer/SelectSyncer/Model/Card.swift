//
//  Card.swift
//  SelectSyncer
//
//  Created by SEONGJUN on 2021/01/09.
//

import Foundation

struct Card: Equatable {
    static func ==(lhs: Card, rhs: Card) -> Bool {
        return lhs.letter == rhs.letter
    }
    
    var letter: String
    var isSelected: Bool
    var selectedOrderNumber: Int?
}

