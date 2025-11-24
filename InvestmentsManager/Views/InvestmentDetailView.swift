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
                
                growthChart
                
                detailsSection
                
                yearlyBreakdownSection
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
    
    private var growthChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Growth Over Time")
                .font(.headline)
            
            Chart {
                ForEach(Array(yearlyGrowth.enumerated()), id: \.offset) { index, value in
                    LineMark(
                        x: .value("Year", index + 1),
                        y: .value("Value", value)
                    )
                    .foregroundStyle(.green)
                    .interpolationMethod(.catmullRom)
                    
                    AreaMark(
                        x: .value("Year", index + 1),
                        y: .value("Value", value)
                    )
                    .foregroundStyle(
                        .linearGradient(
                            colors: [.green.opacity(0.3), .green.opacity(0.05)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .interpolationMethod(.catmullRom)
                }
            }
            .frame(height: 200)
            .chartXAxis {
                AxisMarks(values: .automatic(desiredCount: 5))
            }
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisValueLabel {
                        if let doubleValue = value.as(Double.self) {
                            Text(doubleValue, format: .currency(code: "USD").precision(.fractionLength(0)))
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Investment Details")
                .font(.headline)
            
            DetailRow(label: "Type", value: investment.investmentType.rawValue.capitalized)
            DetailRow(label: "Initial Amount", value: investment.initialAmount, format: .currency(code: "USD"))
            DetailRow(label: "Interest Rate", value: "\(String(format: "%.2f", investment.interestRate))%")
            DetailRow(label: "Investment Period", value: "\(investment.years) years")
            
            if let monthly = investment.monthlyContribution, monthly > 0 {
                DetailRow(label: "Monthly Contribution", value: monthly, format: .currency(code: "USD"))
            }
            
            if investment.investmentType == .savingsAccount || investment.investmentType == .bonds {
                DetailRow(label: "Compound Frequency", value: compoundFrequencyText)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var yearlyBreakdownSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Yearly Breakdown")
                .font(.headline)
            
            ForEach(Array(yearlyGrowth.enumerated()), id: \.offset) { index, value in
                HStack {
                    Text("Year \(index + 1)")
                        .font(.subheadline)
                    
                    Spacer()
                    
                    Text(value, format: .currency(code: "USD"))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                .padding(.vertical, 4)
                
                if index < yearlyGrowth.count - 1 {
                    Divider()
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
    
    private var compoundFrequencyText: String {
        switch investment.compoundFrequency {
        case .monthly: return "Monthly"
        case .quarterly: return "Quarterly"
        case .semiAnnually: return "Semi-Annually"
        case .annually: return "Annually"
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

struct DetailRow: View {
    let label: String
    let value: String
    
    init(label: String, value: String) {
        self.label = label
        self.value = value
    }
    
    init(label: String, value: Double, format: FloatingPointFormatStyle<Double>.Currency) {
        self.label = label
        self.value = value.formatted(format)
    }
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}

#Preview {
    NavigationStack {
        InvestmentDetailView(
            investment: Investment(
                userId: "preview-user-id",
                name: "Sample Investment",
                initialAmount: 10000,
                interestRate: 7.5,
                years: 10,
                investmentType: .stocks,
                monthlyContribution: 500,
                compoundFrequency: .monthly
            ),
            onDelete: {}
        )
    }
}
