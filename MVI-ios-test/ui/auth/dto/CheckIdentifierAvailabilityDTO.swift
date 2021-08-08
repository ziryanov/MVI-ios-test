//
//  CheckIdentifierAvailabilityDTO.swift
//  ReduxVMSample
//
//  Created by ziryanov on 14.10.2020.
//

import Foundation

final class CheckIdentifierAvailabilityDTO: Codable {
    var notAvailable: Bool?

    private enum CodingKeys: String, CodingKey {
        case notAvailable = "not_available"
    }
}
