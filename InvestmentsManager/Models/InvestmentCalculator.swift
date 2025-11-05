//
//  InvestmentCalculator.swift
//  InvestmentsManager
//
//  Created by Ana Sofia R on 5/11/25.
//

import Foundation
class InvestmentCalculator {
    static func calculateFutureValue(for investment:Investment) -> Double {
        let rate = investment.interestRate / 100.0
        let timePeriod = Double(investment.years)
        
        switch investment.investmentType {
        case .savingsAccount, .bonds:
            let months = Double(investment.compoundFrequency.rawValue)
            let futureValueOfInitial = investment.initialAmount * pow(1 + rate/months, months * timePeriod)
            
            if let monthly = investment.monthlyContribution, monthly > 0 {
                let monthlyRate = rate / 12.0
                let totalMonths = timePeriod * 12.0
                let futureValueOfContributions = monthly * ((pow(1 + monthlyRate, totalMonths) - 1) / monthlyRate)
                return futureValueOfInitial + futureValueOfContributions
            }
            
            return futureValueOfInitial
            
        case .stocks:
            let futureValueOfInitial = investment.initialAmount * pow(1 + rate, timePeriod)
            if let monthly = investment.monthlyContribution, monthly > 0 {
                let annualContribution = monthly * 12.0
                let futureValueOfContributions = annualContribution * ((pow(1 + rate, timePeriod) - 1) / rate)
                return futureValueOfInitial + futureValueOfContributions
            }
            
            return futureValueOfInitial
        }
        
    }
        
    static func calculateYearlyGrowth(for investment:Investment) -> [Double] {
        var yearValues: [Double] = []
        for year in 1...investment.years {
            let tempInvestment = Investment (
                id: investment.id,
                name: investment.name,
                initialAmount: investment.initialAmount,
                interestRate: investment.interestRate,
                years: year,
                investmentType: investment.investmentType,
                monthlyContribution: investment.monthlyContribution,
                compoundFrequency: investment.compoundFrequency
            )
            yearValues.append(calculateFutureValue(for: tempInvestment))
        }
        return yearValues
    }

}
