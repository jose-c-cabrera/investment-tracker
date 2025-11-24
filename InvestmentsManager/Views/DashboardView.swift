//
//  DashboardView.swift
//  InvestmentsManager
//
//  Created by Ana Sofia R on 9/11/25.
//


import SwiftUI

struct DashboardView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                if selectedTab == 0 {
                    InvestmentListView()
                } else {
                    ProfileView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.bottom, 80)

            HStack(spacing: 0) {
                TabBarButton(
                    title: "Investments",
                    icon: "chart.line.uptrend.xyaxis",
                    isSelected: selectedTab == 0,
                    isExpanded: selectedTab == 0
                ) {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        selectedTab = 0
                    }
                }
                
                TabBarButton(
                    title: "Profile",
                    icon: "person.circle",
                    isSelected: selectedTab == 1,
                    isExpanded: selectedTab == 1
                ) {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        selectedTab = 1
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                .ultraThinMaterial,
                in: RoundedRectangle(cornerRadius: 30)
            )
            .padding(.horizontal, 16)
            .padding(.bottom, 20)
            .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}

struct TabBarButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let isExpanded: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                
                if isExpanded {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .frame(maxWidth: isExpanded ? .infinity : 60)
            .padding(.vertical, 14)
            .background(
                isSelected ? Color.blue.opacity(0.2) : Color.clear
            )
            .foregroundColor(isSelected ? .blue : .gray)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    DashboardView()
}
