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
            Group {
                if isLoading {
                    ProgressView()
                } else if investments.isEmpty {
                    emptyStateView
                } else {
                    investmentsList
                }
            }
            .navigationTitle("My Investments")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddSheet = true
                    } label: {
                        Image (systemName: "plus")
                    }
                }
            }
            .sheet(item: $selectedInvestment) { investment in
                InvestmentFormView(investment: investment) { _ in
                    loadInvestments()
                }
            }
            .sheet(isPresented: $showingAddSheet) {  
                InvestmentFormView(investment: nil) { newInvestment in
                    loadInvestments()
                    showingAddSheet = false
                }
            }

            .onAppear() {
                loadInvestments()
            }
            .refreshable {
                loadInvestments()
            }
        }
    }
    private var emptyStateView: some View {
        VStack (spacing: 20) {
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
            
            Button {
                showingAddSheet = true
            } label: {
                Label("Add Investment", systemImage: "plus.circle.fill")
                    .font(.headline)
            }
            .buttonStyle(.borderedProminent)
            .padding(.top)
            
        }
        .padding()
    }
    
    private var investmentsList: some View {
        ForEach(investments) { investment in
            NavigationLink(destination: InvestmentDetailView(investment: investment, onDelete: {
                loadInvestments()
            })) {
                InvestmentRowView(investment: investment)
            }
            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                Button(role: .destructive) {
                    deleteInvestment(investment)
                } label: {
                    Label("Delete", systemImage: "trash")
                }
                
                Button {
                    selectedInvestment = investment
                } label : {
                    Label("Edit: ", systemImage: "pencil")
                }
                .tint(.blue)
            }
        }
    }
    
    private var portfolioSummaryCard: some View {
           VStack(alignment: .leading, spacing: 12) {
               Text("Portfolio Summary")
                   .font(.headline)
               
               HStack {
                   VStack(alignment: .leading) {
                       Text("Total Invested")
                           .font(.caption)
                           .foregroundColor(.secondary)
                       Text(totalInvested, format: .currency(code: "USD"))
                           .font(.title3)
                           .fontWeight(.bold)
                   }
                   
                   Spacer()
                   
                   VStack(alignment: .trailing) {
                       Text("Projected Value")
                           .font(.caption)
                           .foregroundColor(.secondary)
                       Text(totalFutureValue, format: .currency(code: "USD"))
                           .font(.title3)
                           .fontWeight(.bold)
                           .foregroundColor(.green)
                   }
               }
               
               HStack {
                   VStack(alignment: .leading) {
                       Text("Total Gain")
                           .font(.caption)
                           .foregroundColor(.secondary)
                       Text(totalGain, format: .currency(code: "USD"))
                           .font(.title3)
                           .fontWeight(.semibold)
                           .foregroundColor(totalGain >= 0 ? .green : .red)
                   }
                   
                   Spacer()
                   
                   VStack(alignment: .trailing) {
                       Text("Investments")
                           .font(.caption)
                           .foregroundColor(.secondary)
                       Text("\(investments.count)")
                           .font(.title3)
                           .fontWeight(.semibold)
                   }
               }
           }
           .padding()
           .background(Color(.systemGray6))
           .cornerRadius(10)
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
           guard let userId = auth.currentUser?.id,
                 let investmentId = investment.id else { return }
           
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
