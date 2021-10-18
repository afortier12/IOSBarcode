//
//  SharingDeck.swift
//  fort7350_a3
//
//  Created by Adam Fortier on 2021-02-14.
//
import Foundation

class SharingDeck {

    static let sharedDeck = SharingDeck()
    let fileName = "cards.archive"
    var timestamp = ""
    private let rootKey = "rootKey"
    private let timeKey = "timeKey"
    var deck : Deck?

    // Define the path to the archive
    func dataFilePath() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(
        FileManager.SearchPathDirectory.documentDirectory,
        FileManager.SearchPathDomainMask.userDomainMask, true)
        let documentsDirectory = paths[0] as NSString
        return documentsDirectory.appendingPathComponent(fileName) as String
    }

    // un-archive the data, load it into the Deck
    func loadDeck() throws{
        let filePath = self.dataFilePath()
        if (FileManager.default.fileExists(atPath: filePath)) {
            let data = NSMutableData(contentsOfFile: filePath)!
            let unarchiver = NSKeyedUnarchiver(forReadingWith: data as Data)
            deck = unarchiver.decodeObject(forKey: rootKey) as? Deck
            timestamp = unarchiver.decodeObject(forKey: timeKey) as? String ?? ""
            unarchiver.finishDecoding()
        } else {
            deck  = Deck()
        }
    }

    // archive the Deck into the file, you may need to save the “last used time” in this method
    func saveDeck(){
        let filePath = self.dataFilePath()
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWith: data)
        archiver.encode(SharingDeck.sharedDeck.deck, forKey: rootKey)
        archiver.encode(timestamp, forKey: timeKey)
        archiver.finishEncoding()
        data.write(toFile: filePath, atomically: true)
    }
    
    func getDeck() -> Deck? {
        return self.deck
    }

}
