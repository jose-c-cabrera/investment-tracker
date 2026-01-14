//
//  StockViewModel.swift
//  InvestmentsManager
//
//  Created by Ana Sofia R on 16/11/25.
//

import Foundation
import Combine

class StockViewModel: ObservableObject {
    @Published var historicalData: [DailyStockEntry] = []
    @Published var errorMessage: String?
    
    @MainActor
    func fetchHistoricalData(for symbol: String) async {
        let apiKey = APIKeys.alphaVantage
        let url = "https://www.alphavantage.co/query?function=TIME_SERIES_DAILY&symbol=\(symbol)&apikey=\(apiKey)"

        guard let response: AlphaVantageDailyResponse = await WebService().downloadData(fromUrl: url) else {
            errorMessage = "Failed to fetch data for \(symbol)"
            historicalData = []
            return
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        let entries = response.timeSeries.compactMap { (dateString, dailyStock) -> DailyStockEntry? in
            guard let date = formatter.date(from: dateString),
                  let close = Double(dailyStock.close) else { return nil }
            return DailyStockEntry(date: date, close: close)
        }
        .sorted { $0.date < $1.date }

        historicalData = entries
        errorMessage = nil
    }



}
    

