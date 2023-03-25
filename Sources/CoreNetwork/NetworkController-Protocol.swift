import Foundation
import Combine

protocol NetworkProtocol {
    var manager: NetworkController { get }
}

public protocol NetworkControllerProtocol: AnyObject {
    typealias Headers = [String: Any]
    
    //  MARK: - Async Await
    func request<T: Decodable>(_ method : HttpMethod,
                               decoder  : JSONDecoder,
                               url      : URL,
                               headers  : Headers,
                               params   : [String: Any]?
    ) async throws -> T
    
    //  MARK: - Combine
    func request<T: Decodable>(_ method : HttpMethod,
                    decoder  : JSONDecoder,
                    url      : URL,
                    headers  : Headers,
                    params   : [String: Any]?
    ) -> AnyPublisher<T, Error>
}

public enum HttpMethod: String{
    case get    = "GET"
    case post   = "POST"
    case put    = "PUT"
    case delete = "DELETE"
}

enum NetworkError: Error, Equatable {
    case invalidURL
    case noResponse
    case decode(String)
    case unknown
    case noInternet(String)
    case serverError(String)
}
