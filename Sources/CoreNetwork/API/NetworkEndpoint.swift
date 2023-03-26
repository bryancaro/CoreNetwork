import Foundation

public struct Endpoint {
    var path       : String
    var queryItems : [URLQueryItem]
    
    public init(path: String, queryItems: [URLQueryItem] = []) {
        self.path = path
        self.queryItems = queryItems
    }
}


public extension Endpoint {
    var url: URL {
        var components        = URLComponents()
        components.scheme     = "https"
        components.host       = "" // example: cloudfunctions.net
        components.path       = "/" + path
        components.queryItems = queryItems
        
        guard let url = components.url else {
            preconditionFailure("Invalid URL components: \(components)")
        }
        
        return url
    }
    
    var headers: [String: Any] {
        /*
         let user              = "some api security"
         let password          = "some api security"
         let credentialData    = "\(user):\(password)".data(using: String.Encoding.utf8)!
         let base64Credentials = credentialData.base64EncodedString(options: [])
         
         return ["Authorization": "Basic \(base64Credentials)"]
         */
        return [String: Any]()
    }
}
