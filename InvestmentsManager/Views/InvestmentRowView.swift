//
//  InvestmentRowView.swift
//  InvestmentsManager
//
//  Created by Ana Sofia R on 9/11/25.
//

import SwiftUI

struct InvestmentRowView: View {
    private var typeColor: Color {
        switch investment.investmentType {
        case .savingsAccount: return .blue
        case .stocks: return .purple
        case .bonds: return .green
        }
    }
    
    let investment: Investment
    private var futureValue: Double {
        InvestmentCalculator.calculateFutureValue(for: investment)
    }
    private var totalInvested: Double {
        let monthlyTotal = (investment.monthlyContribution ?? 0) * Double(investment.years) * 12
        return investment.initialAmount + monthlyTotal
    }
    private var gain: Double {
        futureValue - totalInvested
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(investment.name)
                    .font(.headline)
                
                Spacer()
                
                Text(investment.investmentType.rawValue.capitalized)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(typeColor.opacity(0.2))
                    .foregroundColor(typeColor)
                    .cornerRadius(8)
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Initial: \(investment.initialAmount, format: .currency(code: "CAD"))")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    if let monthly = investment.monthlyContribution, monthly > 0 {
                        Text("+ \(monthly, format: .currency(code: "CAD"))/monthly")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(futureValue, format: .currency(code: "CAD"))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Text("+ \(gain, format: .currency(code: "CAD"))")
                        .font(.caption)
                        .foregroundColor(.green)
                }
            }
            
            HStack {
                Text("\(String(format: "%.1f", investment.interestRate))% • \(investment.years) years")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal, 25)
    }
    
 
}

#Preview {
    InvestmentRowView(investment: Investment(
        userId: "preview-user-id",
        name: "Sample Investment",
        initialAmount: 3,
        interestRate: 7.5,
        years: 1,
        investmentType: .bonds,
        monthlyContribution: 10,
        compoundFrequency: .monthly
    ),)
}
