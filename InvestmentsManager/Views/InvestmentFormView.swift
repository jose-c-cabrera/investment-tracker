//
//  InvestmentFormView.swift
//  InvestmentsManager
//
//  Created by Ana Sofia R on 9/11/25.
//

import SwiftUI

struct InvestmentFormView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var auth = AuthService.shared
    let investment: Investment?
    let onSave: (Investment) -> Void
    @State private var name: String
    @State private var initialAmount: String
    @State private var interestRate: String
    @State private var years: Int
    @State private var investmentType: InvestmentType
    @State private var monthlyContribution: String
    @State private var compoundFrequency: CompoundFrequency
    
    @State private var errorMessage: String?
    @State private var isSaving = false
    @State private var showPreview = true

    init(investment: Investment?, onSave: @escaping (Investment) -> Void) {
        self.investment = investment
        self.onSave = onSave
        
        _name = State(initialValue: investment?.name ?? "")
        _initialAmount = State(initialValue: investment?.initialAmount.formatted() ?? "")
        _interestRate = State(initialValue: investment?.interestRate.formatted() ?? "")
        _years = State(initialValue: investment?.years ?? 10)
        _investmentType = State(initialValue: investment?.investmentType ?? .savingsAccount)
        _monthlyContribution = State(initialValue: investment?.monthlyContribution?.formatted() ?? "")
        _compoundFrequency = State(initialValue: investment?.compoundFrequency ?? .monthly)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                basicInformationSection
                
                investmentDetailsSection
                
                optionalSection
                
                if let errorMessage = errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
                }
                
                // add a preview section with graph on the yearly changes
                
           
            }
            .navigationTitle(investment == nil ? "Add Investment" : "Edit Investment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveInvestment()
                    }
                    .disabled(isSaving || !isFormValid)
                }
                
            }
        }
    }
    

    private var basicInformationSection: some View {
        Section {
            TextField("Investment Name", text: $name)
                
            
            Picker("Type", selection: $investmentType) {
                HStack {
                    Image(systemName: "banknote.fill")
                    Text("Savings Account")
                }
                .tag(InvestmentType.savingsAccount)
                
                HStack {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                    Text("Stocks")
                }
                .tag(InvestmentType.stocks)
                
                HStack {
                    Image(systemName: "doc.text.fill")
                    Text("Bonds")
                }
                .tag(InvestmentType.bonds)
            }
            .onChange(of: investmentType) { _, newValue in
                if newValue == .stocks {
                    compoundFrequency = .annually
                }
            }
        } header: {
            Text("Basic Information")
        } footer: {
            Text("Choose a descriptive name and investment type")
        }
    }
    
    private var investmentDetailsSection: some View {
        Section {
            HStack {
                Image(systemName: "dollarsign.circle.fill")
                    .foregroundColor(.green)
                Text("Initial Amount")
                Spacer()
                TextField("0", text: $initialAmount)
                    .onChange(of: initialAmount) { _, _ in
                        validateAndFormat()
                    }
            }
            
            HStack {
                Image(systemName: "percent")
                    .foregroundColor(.blue)
                Text("Interest Rate")
                Spacer()
                TextField("0", text: $interestRate)
                    .onChange(of: interestRate) { _, _ in
                        validateAndFormat()
                    }
            }
            
            Stepper("Years: \(years)", value: $years, in: 1...50)
        } header: {
            Text("Investment Details")
        } footer: {
            Text("Enter the initial investment amount and expected annual interest rate")
                .font(.caption)
        }
    }
    
    private var optionalSection: some View {
        Section {
            HStack {
                Image(systemName: "calendar.badge.plus")
                    .foregroundColor(.orange)
                Text("Monthly Contribution")
                Spacer()
                TextField("0 (Optional)", text: $monthlyContribution)
                    .onChange(of: monthlyContribution) { _, _ in
                        validateAndFormat()
                    }
            }
            
            if investmentType == .savingsAccount || investmentType == .bonds {
                Picker("Compound Frequency", selection: $compoundFrequency) {
                    Text("Monthly").tag(CompoundFrequency.monthly)
                    Text("Quarterly").tag(CompoundFrequency.quarterly)
                    Text("Semi-Annually").tag(CompoundFrequency.semiAnnually)
                    Text("Annually").tag(CompoundFrequency.annually)
                }
            }
        } header: {
            Text("Additional Options")
        } footer: {
            if investmentType == .stocks {
                Text("Stocks compound annually by default")
            } else {
                Text("Compound frequency affects how often interest is calculated and added to your balance")
            }
        }
    }
        
    
    private var isFormValid: Bool {
        Double(initialAmount) != nil &&
        Double(initialAmount) ?? 0 > 0 &&
        Double(interestRate) != nil &&
        Double(interestRate) ?? 0 > 0 &&
        years > 0
    }
    
    private func validateAndFormat() {
        initialAmount = initialAmount.filter { "0123456789.".contains($0) }
        interestRate = interestRate.filter { "0123456789.".contains($0) }
        monthlyContribution = monthlyContribution.filter { "0123456789.".contains($0) }
    }
        
    private func saveInvestment() {
        guard let userId = auth.currentUser?.id else {
            errorMessage = "User not authenticated"
            return
        }
        
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Investment name is required"
            return
        }
        
        guard let initial = Double(initialAmount), initial > 0 else {
            errorMessage = "Initial amount must be greater than 0"
            return
        }
        
        guard let rate = Double(interestRate), rate > 0 else {
            errorMessage = "Interest rate must be greater than 0"
            return
        }
        
        let monthly = Double(monthlyContribution)
        
        let newInvestment = Investment(
            id: investment?.id,
            userId: userId,
            name: name.trimmingCharacters(in: .whitespaces),
            initialAmount: initial,
            interestRate: rate,
            years: years,
            investmentType: investmentType,
            monthlyContribution: monthly,
            compoundFrequency: compoundFrequency
        )
        
        isSaving = true
        errorMessage = nil
        
        if investment != nil {
            InvestmentService.shared.updateInvestment(newInvestment) { result in
                DispatchQueue.main.async {
                    isSaving = false
                    switch result {
                    case .success:
                        onSave(newInvestment)
                        dismiss()
                    case .failure(let error):
                        errorMessage = error.localizedDescription
                    }
                }
            }
        } else {
            InvestmentService.shared.createInvestment(newInvestment) { result in
                DispatchQueue.main.async {
                    isSaving = false
                    switch result {
                    case .success(let savedInvestment):
                        onSave(savedInvestment)
                        dismiss()
                    case .failure(let error):
                        errorMessage = error.localizedDescription
                    }
                }
            }
        }
    }
}

#Preview {
    InvestmentFormView(investment: nil) { investment in     print("Saved investment: \(investment.name)")
    }
}
