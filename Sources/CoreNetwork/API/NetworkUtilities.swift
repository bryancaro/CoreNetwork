import Foundation

//  MARK: - JSON Decoder
public func newJSONDecoder() -> JSONDecoder {
    let decoder = JSONDecoder()
    if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
        decoder.dateDecodingStrategy = .iso8601
    }
    return decoder
}

//  MARK: - Extension TimeInterval
extension TimeInterval {
    var milliseconds: Int {
        return Int(self * 1_000)
    }
}

//  MARK: - Extension Dictionary
extension Dictionary {
    func paramsEncoded() -> Data? {
        return map { key, value in
            let escapedKey = "\(key)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            let escapedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            return escapedKey + "=" + escapedValue
        }
        .joined(separator: "&")
        .data(using: .utf8)
    }
}

extension Dictionary where Key == String, Value == Any {
    var queryItems: [URLQueryItem] {
        var items: [URLQueryItem] = []
        for (key, value) in self {
            let stringValue: String
            if let arrayValue = value as? [Any] {
                stringValue = arrayValue.compactMap { String(describing: $0) }.joined(separator: ",")
            } else {
                stringValue = String(describing: value)
            }
            let queryItem = URLQueryItem(name: key, value: stringValue)
            items.append(queryItem)
        }
        return items
    }
}
