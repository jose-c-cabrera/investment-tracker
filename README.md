# Investments Manager

Investments Manager is a native iOS application built with Swift, designed to help users track their financial portfolios and project future growth. The application provides a dashboard for managing Savings Accounts, Bonds, and Stocks, utilizing financial formulas to calculate future values based on interest rates and contribution frequencies.

## Overview

The application allows users to input various investment vehicles and visualize their potential growth over time. It features a modular architecture separating business logic, networking, and data models.

### Key Features

* **Investment Dashboard:** A central view to manage different types of investments including Savings Accounts, Bonds, and Stocks.
* **Financial Calculator:**
    * Calculates the Future Value of investments based on initial principal, interest rate, and duration.
    * Supports monthly contributions added to the principal.
    * Handles specific compound frequencies (Annually, Semi-Annually, Quarterly, Monthly) for accurate projections on savings and bonds.
    * Generates yearly growth arrays for visualization.
* **Stock Market Integration:**
    * Fetches historical stock data (Daily Close) using the Alpha Vantage API.
    * Includes a pre-defined list of major stock symbols (e.g., AAPL, MSFT, TSLA) for easy selection.
* **Data Persistence:** Integrated with Firebase Firestore to store user profiles and investment records.

## Technical Architecture

The project follows the MVVM (Model-View-ViewModel) pattern and utilizes modern Swift concurrency features.

* **Language:** Swift
* **Networking:**
    * Custom `WebService` class using `async/await`.
    * Generic request handling for GET, POST, PUT, and DELETE methods.
    * Custom error handling for network status codes.
* **Reactive Programming:** Uses `Combine` for data binding in ViewModels.
* **Backend:** Firebase Firestore (via `FirebaseFirestoreSwift`).

### Project Structure

* **Models:** `Investment`, `AppUser`, `StockSymbol`, `DailyStockEntry`.
* **ViewModels:** `StockViewModel` (Handles API communication and state).
* **Utilities:** `InvestmentCalculator` (Contains the core math logic for compound interest and growth), `WebService` (Network layer).

## Installation and Setup

1. **Clone the repository:**
   ```bash
   git clone [https://github.com/yourusername/investments-manager.git](https://github.com/yourusername/investments-manager.git)```

2. ***Open the project:***
   Open the .xcodeproj file in Xcode.

3. **Firebase Configuration:**
   Ensure you have a GoogleService-Info.plist file added to the project root to enable Firestore connectivity.

4. **API Configuration:**
    The project requires an Alpha Vantage API key to fetch stock data. Create a file named APIKeys.swift (or similar) and ensure the StockViewModel has access to a valid key:
   ```swift
   struct APIKeys {
    static let alphaVantage = "YOUR_API_KEY_HERE"
    }´´´
5. **Build and Run:**
    Select your target simulator or device and press Cmd + R.

## Current Limitations
* **Stock Functionality:** The stock module is currently in development. While it successfully fetches historical data, complex real-time tracking and portfolio balancing features are not yet fully implemented.
* **Projections:** Stock growth projections currently utilize a standard compound interest formula rather than historical volatility models.

## Dependencies
**Firebase/Firestore:** For cloud database storage.
**Combine:** For handling asynchronous events.
