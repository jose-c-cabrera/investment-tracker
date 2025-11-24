//
//  InvestmentFormView.swift
//  InvestmentsManager
//
//  Created by Ana Sofia R on 9/11/25.
//

import SwiftUI
import Charts

struct InvestmentFormView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var auth = AuthService.shared
    
    let investment: Investment?
    let onSave: (Investment) -> Void
    
    @State private var name: String
    @State private var initialAmount: String
    @State private var years: Int
    @State private var investmentType: InvestmentType
    
    // @State var only apply to Savings and Bonds
    @State private var interestRate: String
    @State private var monthlyContribution: String
    @State private var compoundFrequency: CompoundFrequency
    
    // @State var that only apply if investmentType is stock
    @State var stockViewModel = StockViewModel()
    @State private var stockSymbol: String = ""
    @State private var historicalData: [DailyStockEntry] = []
    @State private var selectedStockSymbol : String = ""

    
    @State private var errorMessage: String?
    @State private var isSaving = false
    @State private var showPreview = true
    @FocusState private var focusedField: Field?
    
    
    enum Field {
        case name, initialAmount, interestRate, monthlyContribution
    }

    init(investment: Investment?, onSave: @escaping (Investment) -> Void) {
        self.investment = investment
        self.onSave = onSave
        
        _name = State(initialValue: investment?.name ?? "")
        _initialAmount = State(initialValue: investment?.initialAmount.formatted() ?? "")
        _interestRate = State(initialValue: investment?.interestRate.formatted() ?? "")
        _years = State(initialValue: investment?.years ?? 1)
        _investmentType = State(initialValue: investment?.investmentType ?? .savingsAccount)
        _monthlyContribution = State(initialValue: investment?.monthlyContribution?.formatted() ?? "")
        _compoundFrequency = State(initialValue: investment?.compoundFrequency ?? .monthly)
        _selectedStockSymbol = State(initialValue: investment?.selectedStockSymbol ?? "")
        
    }
    
    var body: some View {
        NavigationStack {
            Form {
                basicInformationSection
                
                if investmentType == .stocks {
                    stockInvestmentDetailsSection
                    stocksSection
                } else {
                    investmentDetailsSection
                    optionalSection
                    projectedValueSection
                }
            
                
                if let errorMessage = errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle(investment == nil ? "Add Investment" : "Edit Investment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action:{
                        dismiss()
                    }){
                        Image(systemName: "xmark")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveInvestment()
                    }
                    .disabled(isSaving || !isFormValid)
                    .foregroundStyle(.green)
                    .bold()
                    .buttonStyle(.plain)
                }
                
            }
            .onChange(of: investmentType) { newType in
                if newType == .stocks {
                    compoundFrequency = .annually
                    interestRate = ""
                    monthlyContribution = ""
                }
                
            }
        }
    }
    

    private var basicInformationSection: some View {
        Section {
            TextField("Investment Name", text: $name)
                .focused($focusedField, equals: .name)
                .submitLabel(.next)
                .onSubmit {
                    focusedField = .initialAmount
                }
            
            Picker("Type", selection: $investmentType) {
                Label("Savings Account", systemImage: "banknote.fill")
                    .tag(InvestmentType.savingsAccount)
                Label("Stocks", systemImage: "chart.line.uptrend.xyaxis")
                    .tag(InvestmentType.stocks)
                Label("Bonds", systemImage: "doc.text.fill")
                    .tag(InvestmentType.bonds)
    
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
                    .focused($focusedField, equals: .initialAmount)
                    .submitLabel(.next)
                    .onSubmit {
                        focusedField = .interestRate
                    }
                    .keyboardType(.decimalPad)
                    .onChange(of: initialAmount) { _ in validateAndFormat() }
            }
            
            HStack {
                Image(systemName: "percent")
                    .foregroundColor(.blue)
                Text("Interest Rate")
                Spacer()
                TextField("0", text: $interestRate)
                    .focused($focusedField, equals: .interestRate)
                    .submitLabel(.next)
                    .onSubmit {
                        focusedField = .monthlyContribution
                    }
                    .keyboardType(.decimalPad)
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
                    .focused($focusedField, equals: .monthlyContribution)
                    .submitLabel(.next)
                    .onSubmit {
                        focusedField = nil
                    }
                    .keyboardType(.decimalPad)
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
    
    private var stockInvestmentDetailsSection: some View {
        Section("Investment Details") {

            HStack {
                Image(systemName: "dollarsign.circle.fill")
                    .foregroundColor(.green)
                Text("Amount to Invest")
                Spacer()
                TextField("0", text: $initialAmount)
                    .keyboardType(.decimalPad)
                    .frame(maxWidth: 120)
                    .onChange(of: initialAmount) { _ in validateAndFormat() }
            }

        }
    }
    
    private var stocksSection: some View {
        Section("Select Stock") {

            Picker("Stock", selection: $selectedStockSymbol) {
                Text("Select a stock").tag("")
                ForEach(StockSymbols.all) { stock in
                    Text("\(stock.symbol) - \(stock.name)").tag(stock.symbol)
                }
            }
            .pickerStyle(.menu)
            .onChange(of: selectedStockSymbol) { newSymbol in
                if !newSymbol.isEmpty {
                    Task {
                        await stockViewModel.fetchHistoricalData(for: newSymbol)
                    }
                }
            }

            if !stockViewModel.historicalData.isEmpty {

                Chart(stockViewModel.historicalData) { entry in
                    LineMark(
                        x: .value("Date", entry.date),
                        y: .value("Close", entry.close)
                    )
                }
                .frame(height: 200)
                .padding(.top, 4)

                if let latestPrice = stockViewModel.historicalData.last?.close {
                    HStack {
                        Text("Current Price")
                        Spacer()
                        Text(latestPrice, format: .currency(code: "USD"))
                            .fontWeight(.semibold)
                    }

                    if let first = stockViewModel.historicalData.first {
                        let change = ((latestPrice - first.close) / first.close) * 100
                        HStack {
                            Text("1Y Change")
                            Spacer()
                            Text(String(format: "%.2f%%", change))
                                .foregroundColor(change >= 0 ? .green : .red)
                        }
                    }
                }
            }
        }
    }

    private var projectedValueSection: some View {
            Section {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Projected Value Preview")
                            .font(.headline)
                        
                        Spacer()
                        
                        Button {
                            withAnimation {
                                showPreview.toggle()
                            }
                        } label: {
                            Image(systemName: showPreview ? "eye.fill" : "eye.slash.fill")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    if showPreview {
                        if let preview = generatePreview() {
                            VStack(spacing: 12) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Future Value")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        Text(preview.futureValue, format: .currency(code: "USD"))
                                            .font(.title2)
                                            .fontWeight(.bold)
                                            .foregroundColor(.green)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chart.line.uptrend.xyaxis.circle.fill")
                                        .font(.system(size: 40))
                                        .foregroundColor(.green.opacity(0.3))
                                }
                                
                                Divider()
                                
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Total Invested")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        Text(preview.totalInvested, format: .currency(code: "USD"))
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                    }
                                    
                                    Spacer()
                                    
                                    VStack(alignment: .trailing, spacing: 4) {
                                        Text("Total Gain")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        Text(preview.gain, format: .currency(code: "USD"))
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                            .foregroundColor(preview.gain >= 0 ? .green : .red)
                                    }
                                }
                                
                                if preview.totalInvested > 0 {
                                    HStack {
                                        Text("Return Rate")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        
                                        Spacer()
                                        
                                        Text("\(String(format: "%.2f", (preview.gain / preview.totalInvested) * 100))%")
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.blue)
                                    }
                                }
                            }
                        }   else {
                            Text("Enter investment details to see projection")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                        }
                    }
                    
                  
                }
                .padding(.vertical, 8)
            }
        }
    
    
    private func generatePreview() -> (futureValue: Double, totalInvested: Double, gain: Double)? {
            guard let initial = Double(initialAmount),
                  let rate = Double(interestRate),
                  initial > 0,
                  rate > 0,
                  let userId = auth.currentUser?.id else {
                return nil
            }
            
            let monthly = Double(monthlyContribution) ?? 0
            
            let tempInvestment = Investment(
                userId: userId,
                name: name,
                initialAmount: initial,
                interestRate: rate,
                years: years,
                investmentType: investmentType,
                monthlyContribution: monthly > 0 ? monthly : nil,
                compoundFrequency: compoundFrequency
            )
            
            let futureValue = InvestmentCalculator.calculateFutureValue(for: tempInvestment)
            let totalInvested = initial + (monthly * Double(years) * 12)
            let gain = futureValue - totalInvested
            
            return (futureValue, totalInvested, gain)
        }
    
    private var projectedValueChart: some View {
        guard let initial = Double(initialAmount),
              let rate = Double(interestRate) else { return AnyView(EmptyView()) }
        
        let monthly = Double(monthlyContribution) ?? 0
        var data: [(year: Int, value: Double)] = []
        var balance = initial
        
        for year in 1...years {
            balance += monthly * 12
            let r = rate / 100
            balance *= (1 + r)
            data.append((year: year, value: balance))
        }
        
        return AnyView(
            Chart(data, id: \.year) { point in
                LineMark(
                    x: .value("Year", point.year),
                    y: .value("Value", point.value)
                )
                .interpolationMethod(.catmullRom)
                .foregroundStyle(.green)
            }
            .frame(height: 200)
        )
    }

    
    private var isFormValid: Bool {
        switch investmentType {
        case .savingsAccount, .bonds:
            return Double(initialAmount) ?? 0 > 0 &&
            Double(interestRate) ?? 0 > 0 &&
            years > 0
        case .stocks:
            return !selectedStockSymbol.isEmpty &&
            Double(initialAmount) ?? 0 > 0
            
        }
       
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
        
        
        var rate: Double = 0
        if investmentType != .stocks {
            guard let interestRateValue = Double(interestRate), interestRateValue > 0 else {
                errorMessage = "Interest rate must be greater than 0"
                return
            }
            rate = interestRateValue
        }

        if investmentType == .stocks {
            guard !selectedStockSymbol.isEmpty else {
                errorMessage = "Please select a stock"
                return
            }
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
            compoundFrequency: compoundFrequency,
            selectedStockSymbol: investmentType == .stocks ? selectedStockSymbol : nil
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
