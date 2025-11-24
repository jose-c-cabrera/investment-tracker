//
//  InvestmentListView.swift
//  InvestmentsManager
//
//  Created by Ana Sofia R on 9/11/25.
//

import SwiftUI
import Foundation
import FirebaseFirestore

struct InvestmentListView: View {

    @ObservedObject private var auth = AuthService.shared
        @State private var investments: [Investment] = []
        @State private var isLoading = false
        @State private var errorMessage: String?
        @State private var showingAddSheet = false
        @State private var selectedInvestment: Investment?

        var body: some View {
            NavigationStack {
                ZStack(alignment: .bottomTrailing) {
                    Group {
                        if isLoading {
                            ProgressView()
                        } else if let errorMessage = errorMessage {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                                .padding()
                        } else if investments.isEmpty {
                            emptyStateView
                        } else {
                            List {
                                investmentsList
                            }
                            .listStyle(.plain)
                            .listRowSeparator(.hidden)
                        }
                    }
                    .navigationTitle("My Investments")
                    
                    Button {
                        showingAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                            .background(
                                Circle()
                                    .fill(Color.blue)
                                    .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                            )
                    }
                    .padding()
                }
                .sheet(item: $selectedInvestment) { investment in
                    InvestmentFormView(investment: investment) { _ in
                        loadInvestments()
                    }
                }
                .sheet(isPresented: $showingAddSheet) {
                    InvestmentFormView(investment: nil) { _ in
                        loadInvestments()
                        showingAddSheet = false
                    }
                }
                .onAppear {
                    if auth.currentUser != nil {
                        loadInvestments()
                    }
                }
                .onChange(of: auth.currentUser?.id) { _ in
                    loadInvestments()
                }
                .refreshable {
                    loadInvestments()
                }
            }
        }

        
        private var emptyStateView: some View {
            VStack(spacing: 20) {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 70))
                    .foregroundColor(.gray)
                
                Text("No Investments Yet")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Start building your portfolio by adding your first investment")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
        }
        
        private var investmentsList: some View {
            ForEach(investments) { investment in
                NavigationLink(destination: InvestmentDetailView(investment: investment, onDelete: {
                    loadInvestments()
                })) {
                    InvestmentRowView(investment: investment)
                }
                .buttonStyle(.plain)
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) { deleteInvestment(investment) } label: {
                        Label("Delete", systemImage: "trash")
                    }
                    
                    Button { selectedInvestment = investment } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                    .tint(.blue)
                }
            }
        }

        
        private var totalInvested: Double {
            investments.reduce(0) { total, investment in
                let monthlyTotal = (investment.monthlyContribution ?? 0) * Double(investment.years) * 12
                return total + investment.initialAmount + monthlyTotal
            }
        }
        
        private var totalFutureValue: Double {
            investments.reduce(0) { $0 + InvestmentCalculator.calculateFutureValue(for: $1) }
        }
        
        private var totalGain: Double {
            totalFutureValue - totalInvested
        }

        
        private func loadInvestments() {
            guard let userId = auth.currentUser?.id else { return }
            isLoading = true
            InvestmentService.shared.getInvestments(for: userId) { result in
                isLoading = false
                switch result {
                case .success(let fetchedInvestments):
                    investments = fetchedInvestments.sorted { $0.name < $1.name }
                    errorMessage = nil
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
        }
        
        private func deleteInvestment(_ investment: Investment) {
            guard let _ = auth.currentUser?.id else { return }
            InvestmentService.shared.deleteInvestment(investment) { result in
                switch result {
                case .success:
                    loadInvestments()
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
        }
    }

    #Preview {
        InvestmentListView()
    }
