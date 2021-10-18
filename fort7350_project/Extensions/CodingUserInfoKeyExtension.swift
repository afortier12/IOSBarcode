//
//  CodingUserInfoKeyExtension.swift
//  fort7350_project
//
//  Created by Adam Fortier on 2021-04-17.
//

import Foundation

public extension CodingUserInfoKey {
    // Helper property to retrieve the context
    static let managedObjectContext = CodingUserInfoKey(rawValue: "managedObjectContext")
}
