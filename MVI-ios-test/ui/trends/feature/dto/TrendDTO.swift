//
//  TrendDTO.swift
//  MVI-ios-test
//
//  Created by ziryanov on 25.09.2021.
//

import Foundation

final class TrendDTO: Codable {
    var id: String?
    var name: String?
    
    private enum CodingKeys: String, CodingKey {
        case id
        case name
    }
    
    init(id: String?, name: String?) {
        self.id = id
        self.name = name
    }
}
