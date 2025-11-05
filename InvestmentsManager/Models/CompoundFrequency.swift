//
//  CompoundFrequency.swift
//  InvestmentsManager
//
//  Created by José Carlos Cabrera Martínez on 11/3/25.
//

import Foundation

public enum CompoundFrequency: Int, CaseIterable, Codable{
    case annually = 1
    case semiAnnually = 2
    case quarterly = 4
    case monthly = 12
    
    var month: Double {
        switch self {
        case .annually: return 12
        case .semiAnnually: return 6
        case .quarterly: return 3
        case .monthly: return 1
        }
    }
}
