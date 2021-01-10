//
//  CardSelectViewModel.swift
//  SelectSyncer
//
//  Created by SEONGJUN on 2021/01/09.
//

import Foundation


class CardMainViewModel {
    
    var selectedCards = Bindable<[Card?]>(value: [nil, nil, nil, nil, nil, nil])
    let defaultCards = DefaultLetters.AtoZ
    
    func checkCardIsSelected(card: Card) -> Card? {
        var modifiedCard = card
    
        if let index = self.selectedCards.value.firstIndex(where: { $0 == card }) {
            modifiedCard.isSelected = true
            modifiedCard.selectedOrderNumber = index + 1
        } else {
            modifiedCard.isSelected = false
            modifiedCard.selectedOrderNumber = nil
        }

        return modifiedCard
    }
    
    func updateSelectedCards(card: Card) {
        var card = card
        if selectedCards.value.contains(card) {
            card.isSelected = false
            card.selectedOrderNumber = nil
            if let index = selectedCards.value.firstIndex(of: card) {
                selectedCards.value.remove(at: index)
                selectedCards.value.append(nil)
            }
            return
        }
        
        if selectedCards.value.count >= 6 && selectedCards.value.allSatisfy({$0 != nil}) {
            return
        }
        
        if let index = selectedCards.value.firstIndex(where: {$0 == nil}) {
            card.isSelected = true
            selectedCards.value.remove(at: index)
            selectedCards.value.insert(card, at: index)
        }
    }
    
    func reset() {
        selectedCards.value = [nil, nil, nil, nil, nil, nil]
    }
}

class Bindable<T> {
    var value: T {
        didSet {
            observer?(value)
        }
    }
    init(value: T) {
        self.value = value
    }
    private var observer: ((T) -> Void)?
    
    func bind(observer: @escaping (T) -> Void) {
        self.observer = observer
    }
}
