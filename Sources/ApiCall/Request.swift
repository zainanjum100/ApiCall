import Foundation
@available(macOS 10.15.0, *)
@available(iOS 13.0.0, *)
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

    public func requestApi<T: Codable>(_ type: T.Type, baseUrl: String? = nil, method: HTTPMethod, url: String, params: [String: Any]? = nil, isSnakeCase: Bool? = true) async throws -> T {
        if !Reachability.isConnectedToNetwork() {
            throw ServiceError.noInternetConnection
        }

        var request = URLRequest(url: URL(string: ((baseUrl != nil ? baseUrl : BASE_URL) ?? BASE_URL) + url)!)
        header.updateValue("application/json", forKey: "Content-Type")
        request.allHTTPHeaderFields = header
        request.httpMethod = method.rawValue

        if let params = params {
            let postData = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
            request.httpBody = postData
        }

        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ServiceError.custom("Invalid response")
        }

        switch httpResponse.status?.responseType {
        case .success:
            let JSON = try JSONDecoder().decode(type, from: data)
            return JSON
        default:
            throw ServiceError.custom("Error code: \(String(describing: httpResponse.status))")
        }
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

    public func uploadData<T: Codable>(_ type: T.Type, method: HTTPMethod, imageData: Data, url: String, params: [String: String]? = nil, isSnakeCase: Bool? = true, imageName: String) async throws -> T {
        if !Reachability.isConnectedToNetwork() {
            throw ServiceError.noInternetConnection
        }

        let boundary = "Boundary-\(UUID().uuidString)"
        header.updateValue("multipart/form-data; boundary=\(boundary)", forKey: "Content-Type")
        var request = URLRequest(url: URL(string: BASE_URL + url)!)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = header
        let httpBody = NSMutableData()

        if let params = params {
            for (key, value) in params {
                httpBody.appendString(convertFormField(named: key, value: value, using: boundary))
            }
        }

        httpBody.append(convertFileData(fieldName: imageName,
                                        fileName: "imagename.png",
                                        mimeType: "image/png",
                                        fileData: imageData,
                                        using: boundary))
        httpBody.appendString("--\(boundary)--")

        request.httpBody = httpBody as Data

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw ServiceError.custom("Invalid response")
        }

        switch httpResponse.status?.responseType {
        case .success:
            let JSON = try JSONDecoder().decode(type, from: data)
            return JSON
        default:
            let JSON = try JSONDecoder().decode(ErrorModel.self, from: data)
            throw ServiceError.custom(JSON.errors.first?.message ?? "")
        }
    }
}
