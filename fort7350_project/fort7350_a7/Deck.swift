//
//  Deck.swift
//  fort7350_a3
//
//  Created by Adam Fortier on 2021-02-13.
//
import Foundation
import UIKit

class Deck: NSObject, NSCoding {

    private var cards = [Card]()
    private var current : Int = 0 // index to the current card
    private var time: String?
    private let deckKey = "deckKey"
    private let indexKey = "indexKey"
    private let timeKey = "timeKey"

    // MARK: - NSCoding methods
    override init(){
        super.init()
        initDeck() // initialize the deck
    }

    required convenience init?(coder decoder: NSCoder) {
        self.init()
        cards = (decoder.decodeObject(forKey: deckKey) as? [Card])!
        current = (decoder.decodeInteger(forKey: indexKey))
        time = (decoder.decodeObject(forKey: timeKey) as? String)
    }

    func encode(with acoder: NSCoder) {
        acoder.encode(cards, forKey: deckKey)
        acoder.encode(current, forKey: indexKey)
        acoder.encode(time, forKey: timeKey)
    } // You will need to implement other helper methods such as initDeck

    func initDeck() {
        var image = UIImage(named: "name")
        cards.append(Card(image: image, question:"What's your name?", answer:"Adam Fortier")!)
        image = UIImage(named: "rome")
        cards.append(Card(image: image, question:"What place would you like to visit?", answer:"Rome")!)
        image = UIImage(named: "tims")
        cards.append(Card(image:image, question:"What is your favorite beverage?", answer:"Tim Horton's coffee")!)
        image = UIImage(named: "transit")
        cards.append(Card(image: image, question:"What car do you drive?", answer:"Ford Transit Connect")!)
        let today = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM y HH:MM e"
        self.time = "Last used:" + formatter.string(from: today)
    }
    
    // return the current card
    func card()->Card?{
        if (cards.count > 0){
            let currentCard = cards[current]
            return currentCard
        } else {
            let image = UIImage(named: "question")
            return Card(image: image, question:"Please add a question using the Add Card tab", answer:"----")
        }
    }

    func setCurrentIndex(to index: Int) { // you may need this function for
    // relaunching the app
        current = index
    }
        
    func getSize() -> Int{ // you may need this function for
    // relaunching the app
        return cards.count
    }

    // other helper functions you may need when relaunching the app

    // return the index of the current card in the deck
    func getCurrentIndex() -> Int {
        return current
    }// getCurrentIndex}
    
    func addCard(card: Card){
        cards.append(card)
    }
    
    
    func deleteCardAtIndex(index: Int){
        if (cards.count > 0){
            cards.remove(at: index)
        }
    }
}
