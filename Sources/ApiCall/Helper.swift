//
//  File.swift
//  
//
//  Created by ZainAnjum on 09/09/2020.
//

import Foundation
public typealias Completion<T> = (Result<T,Error>) -> ()

public extension NSMutableData {
    func appendString(_ string: String) {
        if let data = string.data(using: .utf8) {
            self.append(data)
        }
    }
}
public enum HTTPMethod: String{
    case post = "POST"
    case get = "GET"
    case put = "PUT"
    case delete = "DELETE"
    case update = "UPDATE"
}
public extension Data {
    var prettyPrintedJSONString: NSString? { /// NSString gives us a nice sanitized debugDescription
        guard let object = try? JSONSerialization.jsonObject(with: self, options: []),
            let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
            let prettyPrintedString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) else { return nil }
        
        return prettyPrintedString
    }
}
enum ServiceError: Error {
    case noInternetConnection
    case custom(String)
}
extension ServiceError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .noInternetConnection:
            return "No Internet connection"
        case .custom(let message):
            return message
        }
    }
}



// MARK: - ErrorModel
struct ErrorModel:Codable {
    let errors: [ErrorElement]
}

struct ErrorElement:Codable {
    let message: String
}

