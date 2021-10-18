//
//  Array.swift
//  fort7350_project
//
//  Created by Adam Fortier on 2021-04-18.
//

import Foundation

public extension Array where Element: Equatable {
    func removeDuplicates() -> Array {
        return reduce(into: []) { result, element in
            if !result.contains(element) {
                result.append(element)
            }
        }
    }
}
