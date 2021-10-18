//
//  CategoryData.swift
//  fort7350_project
//
//  Created by Adam Fortier on 2021-04-11.
//

import Foundation

class CategoryCodable : Decodable {
    let name : String

    private enum CodingKeys: String, CodingKey {
        case name
    }
    
    
    required init(from decoder:Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        
    }
} // CategoryCodable


