//
//  SummaryCard.swift
//  InvestmentsManager
//
//  Created by Ana Sofia R on 10/11/25.
//

import SwiftUI

struct SummaryCard: View {
    let futureValue: Double
    let totalInvested: Double
    let totalGain: Double
    let typeIcon: String
    let typeColor: Color
    let investment: Investment
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Future Value")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text(futureValue, format: .currency(code: "USD"))
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
                
                Spacer()
                
                Image(systemName: typeIcon)
                    .font(.system(size: 40))
                    .foregroundColor(typeColor)
            }
            
            Divider()
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Total Invested")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(totalInvested, format: .currency(code: "USD"))
                        .font(.headline)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Total Gain")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(totalGain, format: .currency(code: "USD"))
                        .font(.headline)
                        .foregroundColor(totalGain >= 0 ? .green : .red)
                }
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Return Rate")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(String(format: "%.1f", (totalGain / totalInvested) * 100))%")
                        .font(.headline)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Time Period")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(investment.years) years")
                        .font(.headline)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}
 


#Preview {
    SummaryCard(
           futureValue: 12000,
           totalInvested: 10000,
           totalGain: 2000,
           typeIcon: "chart.line.uptrend.xyaxis",
           typeColor: .green,
           investment: Investment(
            userId: "preview-user-id",
            name: "Sample Investment",
            initialAmount: 3,
            interestRate: 7.5,
            years: 1,
            investmentType: .bonds,
            monthlyContribution: 10,
            compoundFrequency: .monthly
           )
       )
}
