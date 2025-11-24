//
//  WebService.swift
//  InvestmentsManager
//
//  Created by Ana Sofia R on 16/11/25.
//


import Foundation

class WebService{

    enum HTTPMethod: String{
        case GET, POST, PUt, DELETE
    }

    //new send request method
    func sendRequest<T: Codable>(
        toURL: String,
        method: HTTPMethod,
        body: T? = nil
    )async -> T?{
        do{
            guard let url = URL(string: toURL) else{
                throw NetworkError.badUrl
            }
            var request = URLRequest(url: url)
            request.httpMethod = method.rawValue

            if let body = body{
                request.httpBody = try JSONEncoder().encode(body)
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }

            let(data, response) = try await URLSession.shared.data(for: request)

            guard let response = response as? HTTPURLResponse else {
                throw NetworkError.badResponse
            }

            guard 200..<300 ~= response.statusCode else{
                throw NetworkError.badStatus
            }

            print("Response Status Code: \(response.statusCode)")

            return try JSONDecoder().decode(T.self, from: data)

        }catch{
            print("Request Failed: \(error.localizedDescription)")
            return nil
        }
    }


    //responsible for downloading the data


    func downloadData<T: Decodable>(fromUrl: String) async -> T?{
        do{
            guard let url = URL(string: fromUrl) else{ throw NetworkError.badUrl }
            let (data, response) = try await URLSession.shared.data(from: url)

            guard let response = response as? HTTPURLResponse else{
                throw NetworkError.badResponse
            }
            guard response.statusCode >= 200 && response.statusCode < 300 else{
                throw NetworkError.badStatus
            }

            guard let decodeResponse = try? JSONDecoder().decode(T.self, from: data) else {
                throw NetworkError.failedToDecodeResponse
            }
            return decodeResponse


        }catch NetworkError.badUrl{
            print("Bad URL")
        }catch NetworkError.badResponse{
            print("Did not get a valid response")
        }catch NetworkError.badStatus{
            print("Did not get a 2xx status code from the server")
        }catch NetworkError.failedToDecodeResponse{
            print("An error occurred downloading the data")
        }catch{
            print(error.localizedDescription) // any other unhandled error
        }


        return nil
    }

}
 
