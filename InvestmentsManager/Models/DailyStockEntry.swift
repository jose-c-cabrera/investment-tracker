//
//  DailyStockEntry.swift
//  InvestmentsManager
//
//  Created by Ana Sofia R on 16/11/25.
//
import Foundation

struct DailyStockEntry: Identifiable {
    let id = UUID()
    let date: Date
    let close: Double
}
