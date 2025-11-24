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
    public var userId:String
    public var name: String
    public var initialAmount: Double
    public var interestRate: Double
    public var years: Int
    public var investmentType: InvestmentType
    public var monthlyContribution: Double?
    public var compoundFrequency: CompoundFrequency
    public var selectedStockSymbol: String?
    
    public init(
         id: String? = nil,
         userId: String,
         name: String,
         initialAmount: Double,
         interestRate: Double,
         years: Int,
         investmentType: InvestmentType,
         monthlyContribution: Double? = nil,
         compoundFrequency: CompoundFrequency = .monthly,
         selectedStockSymbol: String? = nil,
     ) {
         self.id = id
         self.userId = userId
         self.name = name
         self.initialAmount = initialAmount
         self.interestRate = interestRate
         self.years = years
         self.investmentType = investmentType
         self.monthlyContribution = monthlyContribution
         self.compoundFrequency = compoundFrequency
         self.selectedStockSymbol = selectedStockSymbol
     }
 }

