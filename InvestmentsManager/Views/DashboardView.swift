//
//  DashboardView.swift
//  InvestmentsManager
//
//  Created by Ana Sofia R on 9/11/25.
//

import SwiftUI

struct DashboardView: View {
    var body: some View {
        TabView {
            InvestmentListView()
                .tabItem {
                    Label("Invesments", systemImage: "chart.line.uptrend.xyaxis")
                }
                
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.circle")
                }
        }

    }
}

#Preview {
    DashboardView()
}
