//
//  StockSymbol.swift
//  InvestmentsManager
//
//  Created by Ana Sofia R on 16/11/25.
//
import Foundation

struct StockSymbol: Identifiable {
    let id = UUID()
    let symbol: String
    let name: String
}

struct StockSymbols {
    static let all: [StockSymbol] = [
        StockSymbol(symbol: "AAPL", name: "Apple Inc."),
        StockSymbol(symbol: "MSFT", name: "Microsoft Corporation"),
        StockSymbol(symbol: "GOOGL", name: "Alphabet Inc."),
        StockSymbol(symbol: "AMZN", name: "Amazon.com, Inc."),
        StockSymbol(symbol: "TSLA", name: "Tesla, Inc."),
        StockSymbol(symbol: "FB", name: "Meta Platforms, Inc."),
        StockSymbol(symbol: "BRK.B", name: "Berkshire Hathaway Inc."),
        StockSymbol(symbol: "JNJ", name: "Johnson & Johnson"),
        StockSymbol(symbol: "V", name: "Visa Inc."),
        StockSymbol(symbol: "WMT", name: "Walmart Inc."),
        StockSymbol(symbol: "JPM", name: "JPMorgan Chase & Co."),
        StockSymbol(symbol: "NVDA", name: "NVIDIA Corporation"),
        StockSymbol(symbol: "PG", name: "Procter & Gamble Co."),
        StockSymbol(symbol: "DIS", name: "The Walt Disney Company"),
        StockSymbol(symbol: "HD", name: "The Home Depot, Inc."),
        StockSymbol(symbol: "MA", name: "Mastercard Incorporated"),
        StockSymbol(symbol: "BAC", name: "Bank of America Corporation"),
        StockSymbol(symbol: "XOM", name: "Exxon Mobil Corporation"),
        StockSymbol(symbol: "VZ", name: "Verizon Communications Inc."),
        StockSymbol(symbol: "ADBE", name: "Adobe Inc."),
        StockSymbol(symbol: "NFLX", name: "Netflix, Inc."),
        StockSymbol(symbol: "KO", name: "The Coca-Cola Company"),
        StockSymbol(symbol: "MRK", name: "Merck & Co., Inc."),
        StockSymbol(symbol: "CSCO", name: "Cisco Systems, Inc."),
        StockSymbol(symbol: "PFE", name: "Pfizer Inc."),
        StockSymbol(symbol: "PEP", name: "PepsiCo, Inc."),
        StockSymbol(symbol: "INTC", name: "Intel Corporation"),
        StockSymbol(symbol: "T", name: "AT&T Inc."),
        StockSymbol(symbol: "ORCL", name: "Oracle Corporation"),
        StockSymbol(symbol: "CVX", name: "Chevron Corporation"),
        StockSymbol(symbol: "ABT", name: "Abbott Laboratories"),
        StockSymbol(symbol: "CRM", name: "Salesforce, Inc."),
        StockSymbol(symbol: "NKE", name: "NIKE, Inc."),
        StockSymbol(symbol: "WFC", name: "Wells Fargo & Company"),
        StockSymbol(symbol: "QCOM", name: "QUALCOMM Incorporated"),
        StockSymbol(symbol: "MCD", name: "McDonald's Corporation"),
        StockSymbol(symbol: "COST", name: "Costco Wholesale Corporation"),
        StockSymbol(symbol: "TXN", name: "Texas Instruments Incorporated"),
        StockSymbol(symbol: "MDT", name: "Medtronic plc"),
        StockSymbol(symbol: "NEE", name: "NextEra Energy, Inc."),
        StockSymbol(symbol: "UNH", name: "UnitedHealth Group Incorporated"),
        StockSymbol(symbol: "LOW", name: "Lowe's Companies, Inc."),
        StockSymbol(symbol: "AMGN", name: "Amgen Inc."),
        StockSymbol(symbol: "BA", name: "The Boeing Company"),
        StockSymbol(symbol: "HON", name: "Honeywell International Inc."),
        StockSymbol(symbol: "IBM", name: "International Business Machines Corporation"),
        StockSymbol(symbol: "SBUX", name: "Starbucks Corporation"),
        StockSymbol(symbol: "GE", name: "General Electric Company"),
        StockSymbol(symbol: "MMM", name: "3M Company"),
        StockSymbol(symbol: "GILD", name: "Gilead Sciences, Inc.")
    ]
}

