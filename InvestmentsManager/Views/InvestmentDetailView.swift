//
//  InvestmentDetailView.swift
//  InvestmentsManager
//
//  Created by Ana Sofia R on 9/11/25.
//

import SwiftUI
import Charts

struct InvestmentDetailView: View {
    @Environment(\.dismiss) private var dismiss
    
    let investment: Investment
    let onDelete: () -> Void
    
    @State private var showingDeleteAlert = false
    @State private var showingEditSheet = false

    private var futureValue: Double {
        InvestmentCalculator.calculateFutureValue(for: investment)
    }
    
    private var totalInvested: Double {
        let monthlyTotal = (investment.monthlyContribution ?? 0) * Double(investment.years) * 12
        return investment.initialAmount + monthlyTotal
    }
    
    private var totalGain: Double {
        futureValue - totalInvested
    }
    
    private var yearlyGrowth: [Double] {
        InvestmentCalculator.calculateYearlyGrowth(for: investment)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                summaryCard
                
                // growth chart with n years of investment
                
                // general detail sections with type, initial amt, interest rt,
                // investment period
                
                
                // chart with breakdown years of investment (got)
            }
            .padding()
        }
        .navigationTitle(investment.name)
        .navigationBarTitleDisplayMode(.automatic)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        showingEditSheet = true
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                    
                    Button(role: .destructive) {
                        showingDeleteAlert = true
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .alert("Delete Investment", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteInvestment()
            }
        } message: {
            Text("Are you sure you want to delete this investment? This action cannot be undone.")
        }
        .sheet(isPresented: $showingEditSheet) {
            InvestmentFormView(investment: investment) { _ in
                dismiss()
                onDelete()
            }
        }
    }
    
    private var summaryCard: some View {
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
        
        
    private var typeIcon: String {
        switch investment.investmentType {
        case .savingsAccount: return "banknote"
        case .stocks: return "chart.line.uptrend.xyaxis"
        case .bonds: return "doc.text"
        }
    }
    
    private var typeColor: Color {
        switch investment.investmentType {
        case .savingsAccount: return .blue
        case .stocks: return .purple
        case .bonds: return .green
        }
    }
    
    
    private func deleteInvestment() {
        InvestmentService.shared.deleteInvestment(investment) { result in
            switch result {
            case .success:
                dismiss()
                onDelete()
            case .failure(let error):
                print("Error deleting investment: \(error.localizedDescription)")
            }
        }
    }
}


#Preview {
    NavigationStack {
        InvestmentDetailView(
            investment: Investment(
                userId: "preview-user-id",
                name: "Sample Investment",
                initialAmount: 0,
                interestRate: 7.5,
                years: 10,
                investmentType: .stocks,
                monthlyContribution: 0,
                compoundFrequency: .monthly
            ),
            onDelete: {}
        )
    }
}
