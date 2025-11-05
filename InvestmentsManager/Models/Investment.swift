//
//  Investment.swift
//  InvestmentsManager
//
//  Created by José Carlos Cabrera Martínez on 11/3/25.
//

import Foundation

public struct Investment: Identifiable, Codable {
    
    public var id: UUID
    public var name: String
    public var initialAmount: Double
    public var interestRate: Double
    public var years: Int
    public var investmentType: InvestmentType
    public var monthlyContribution: Double?
    public var compoundFrequency: CompoundFrequency
    

    public func calculateFutureValue() -> Double {
        let rate = self.interestRate / 100.0
        let timePeriod = Double(self.years)
        
        switch self.investmentType {
        case .savingsAccount, .bonds:
            let months = Double(self.compoundFrequency.rawValue)
            let futureValueOfInitial = self.initialAmount * pow(1 + rate/months, months * timePeriod)
            
            if let monthly = self.monthlyContribution, monthly > 0 {
                let monthlyRate = rate / 12.0
                let totalMonths = timePeriod * 12.0
                let futureValueOfContributions = monthly * ((pow(1 + monthlyRate, totalMonths) - 1) / monthlyRate)
                return futureValueOfInitial + futureValueOfContributions
            }
            
            return futureValueOfInitial
            
        case .stocks:
            let futureValueOfInitial = self.initialAmount * pow(1 + rate, timePeriod)
            if let monthly = self.monthlyContribution, monthly > 0 {
                let annualContribution = monthly * 12.0
                let futureValueOfContributions = annualContribution * ((pow(1 + rate, timePeriod) - 1) / rate)
                return futureValueOfInitial + futureValueOfContributions
            }
            
            return futureValueOfInitial
        }
        
    }
        
        
    
    public func calculateYearlyGrowth() -> [Double] {
        var yearValues: [Double] = []
        for year in 1...self.years {
            let tempInvestment = Investment (
                id: self.id,
                name: self.name,
                initialAmount: self.initialAmount,
                interestRate: self.interestRate,
                years: year,
                investmentType: self.investmentType,
                monthlyContribution: self.monthlyContribution,
                compoundFrequency: self.compoundFrequency
            )
            yearValues.append(tempInvestment.calculateFutureValue())
        }
        return yearValues
    }
    
    
}
