//
//  InvestmentRowView.swift
//  InvestmentsManager
//
//  Created by Ana Sofia R on 9/11/25.
//

import SwiftUI

struct InvestmentRowView: View {
    
    let investment: Investment
    
    private var typeColor: Color {
        switch investment.investmentType {
        case .savingsAccount: return .blue
        case .stocks: return .purple
        case .bonds: return .green
        }
    }
    
    private var futureValue: Double {
        InvestmentCalculator.calculateFutureValue(for: investment)
    }
    
    private var totalInvested: Double {
        let monthly = (investment.monthlyContribution ?? 0)
        let monthlyTotal = monthly * Double(investment.years) * 12
        return investment.initialAmount + monthlyTotal
    }
    
    private var gain: Double {
        futureValue - totalInvested
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            
            HStack {
                Text(investment.name)
                    .font(.headline)
                
                Spacer()
                
                Text(investment.investmentType.rawValue.capitalized)
                    .font(.caption2)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(typeColor.opacity(0.15))
                    .foregroundColor(typeColor)
                    .cornerRadius(8)
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Initial: \(investment.initialAmount, format: .currency(code: "CAD"))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if let m = investment.monthlyContribution, m > 0 {
                        Text("Monthly: \(m, format: .currency(code: "CAD"))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text(futureValue, format: .currency(code: "CAD"))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text("\(gain >= 0 ? "+" : "")\(gain, format: .currency(code: "CAD"))")
                        .font(.caption)
                        .foregroundColor(gain >= 0 ? .green : .red)
                }
            }
            
            Text("\(String(format: "%.1f", investment.interestRate))% · \(investment.years) years")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        .padding(.vertical, 4)
        .padding(.horizontal)
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
