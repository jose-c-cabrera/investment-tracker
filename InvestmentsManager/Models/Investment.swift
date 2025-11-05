//
//  Investment.swift
//  InvestmentsManager
//
//  Created by José Carlos Cabrera Martínez on 11/3/25.
//

import Foundation
import FirebaseFirestore

public struct Investment: Identifiable, Codable {
    @DocumentID public var id: String?
    public var name: String
    public var initialAmount: Double
    public var interestRate: Double
    public var years: Int
    public var investmentType: InvestmentType
    public var monthlyContribution: Double?
    public var compoundFrequency: CompoundFrequency
}
