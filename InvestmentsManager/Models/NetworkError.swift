//
//  NetworkError.swift
//  InvestmentsManager
//
//  Created by Ana Sofia R on 16/11/25.
//

import Foundation

enum NetworkError: Error {
    case badUrl
    case invalidRequest
    case badResponse
    case badStatus //200(OK),400(Error or not found or not authorized) ,500 (Internal Server Error)
    case failedToDecodeResponse
}


