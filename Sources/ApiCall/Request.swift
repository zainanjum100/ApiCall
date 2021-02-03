//
//  Request.swift
//  ApiCall
//
//  Created by ZainAnjum on 17/08/2020.
//  Copyright © 2020 ZainAnjum. All rights reserved.
//
import Foundation

public class Request {
    public static let shared = Request()
    var BASE_URL = String()
    var header = [String: String]()
    var errorModel: Codable?
    public func setupVariables(baseUrl: String, header: [String: String], errorModel: Codable? = nil) {
        Request.shared.BASE_URL = baseUrl
        Request.shared.header = header
        Request.shared.errorModel = errorModel
    }
    
    public func requestApi<T: Codable>(_ type: T.Type,baseUrl: String? = nil,method : HTTPMethod,url : String,params: [String: Any]? = nil,isSnakeCase: Bool? = true,completion: @escaping Completion<T>){
        if !Reachability.isConnectedToNetwork() {
            completion(.failure(ServiceError.noInternetConnection))
        }
        var request = URLRequest(url: URL(string: ((baseUrl != nil ? baseUrl : BASE_URL) ?? BASE_URL) + url)!)
        header.updateValue("application/json", forKey: "Content-Type")
        request.allHTTPHeaderFields = header
        request.httpMethod = method.rawValue
        if let params = params{
            let postData = (try? JSONSerialization.data(withJSONObject: params, options: .prettyPrinted))
            request.httpBody = postData
        }
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                guard let data = data else{return}
                print(data.prettyPrintedJSONString ?? "")
                do {
                    let decoder = JSONDecoder()
                    if isSnakeCase == true{
                        decoder.keyDecodingStrategy = .convertFromSnakeCase
                    }
                    if let httpResponse = response as? HTTPURLResponse {
                        switch httpResponse.status?.responseType {
                        case .success:
                            let JSON = try decoder.decode(type , from: data)
                            completion(.success(JSON))
                        default:
                            completion(.failure(ServiceError.custom("Error decoding JSON")))
                        }
                    }
                } catch let err {
                    completion(.failure(err))
                }
            }
        }.resume()
        
    }
    
    func convertFormField(named name: String, value: String, using boundary: String) -> String {
        var fieldString = "--\(boundary)\r\n"
        fieldString += "Content-Disposition: form-data; name=\"\(name)\"\r\n"
        fieldString += "\r\n"
        fieldString += "\(value)\r\n"
        
        return fieldString
    }
    
    func convertFileData(fieldName: String, fileName: String, mimeType: String, fileData: Data, using boundary: String) -> Data {
        let data = NSMutableData()
        
        data.appendString("--\(boundary)\r\n")
        data.appendString("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(fileName)\"\r\n")
        data.appendString("Content-Type: \(mimeType)\r\n\r\n")
        data.append(fileData)
        data.appendString("\r\n")
        
        return data as Data
    }
    
    public func uploadData<T: Codable>(_ type: T.Type,method : HTTPMethod, imageData: Data,url : String,params: [String: String]? = nil,isSnakeCase: Bool? = true,imageName: String ,completion: @escaping Completion<T>){
        if !Reachability.isConnectedToNetwork() {
            completion(.failure(ServiceError.noInternetConnection))
        }
        let boundary = "Boundary-\(UUID().uuidString)"
        header.updateValue("multipart/form-data; boundary=\(boundary)", forKey: "Content-Type")
        var request = URLRequest(url: URL(string: BASE_URL + url)!)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = header
        let httpBody = NSMutableData()
        
        if let params = params{
            for (key, value) in params {
                httpBody.appendString(convertFormField(named: key, value: value, using: boundary))
            }
        }
        
        httpBody.append(convertFileData(fieldName: imageName ,
                                        fileName: "imagename.png",
                                        mimeType: "image/png",
                                        fileData: imageData,
                                        using: boundary))
        
        httpBody.appendString("--\(boundary)--")
        
        request.httpBody = httpBody as Data
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                guard let data = data else{return}
                print(data.prettyPrintedJSONString ?? "")
                do {
                    let decoder = JSONDecoder()
                    if isSnakeCase == true{
                        decoder.keyDecodingStrategy = .convertFromSnakeCase
                    }
                    if let httpResponse = response as? HTTPURLResponse {
                        switch httpResponse.status?.responseType {
                        case .success:
                            let JSON = try decoder.decode(type , from: data)
                            completion(.success(JSON))
                        default:
                            let JSON = try decoder.decode(ErrorModel.self, from: data)
                            completion(.failure(ServiceError.custom(JSON.errors.first?.message ?? "")))
                        }
                    }
                } catch let err {
                    completion(.failure(err))
                }
            }
        }.resume()
        
    }
    
}
