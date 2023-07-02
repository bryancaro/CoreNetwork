import Foundation
import Combine

open class Network: NetworkProtocol {
    public var manager: NetworkController = NetworkController()
    
    public init() {}
}

public class NetworkController {
    public init() {}
    //  MARK: - Async Await
    public func request<T: Decodable>(_ method: HttpMethod,
                                      decoder: JSONDecoder = newJSONDecoder(),
                                      url: URL?,
                                      headers: [String: Any] = [String: Any](),
                                      params: [String: Any]? = nil,
                                      sendParamsInQuery: Bool = false) async throws -> T {
        let randomRequest = "\(Int.random(in: 0 ..< 100))"
        var timeDateRequest = Date()
        
        debugPrint("🌎🔵 [API][ASYNC] [id: \(randomRequest)] [URL]: [\(String(describing: url))]")
        debugPrint("🌎🔵 [API][ASYNC] [id: \(randomRequest)] [QUERY ITEMS]: [\(String(describing: params))]")
        debugPrint("🌎🔵 [API][ASYNC] [id: \(randomRequest)] [HEADER ITEMS]: [\(String(describing: headers))]")
        
        guard let url = url else {
            debugPrint("🌎🔴 [API][ASYNC] [id: \(randomRequest)] [RESPONSE ERROR]: [invalidURL]")
            throw NetworkError.invalidURL
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        
        if sendParamsInQuery {
            urlRequest.url = buildURLWithQueryItems(url: url, params: params)
        } else {
            urlRequest.httpBody = params?.paramsEncoded()
        }
        
        headers.forEach { (key, value) in
            if let value = value as? String {
                urlRequest.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        do {
            timeDateRequest = Date()
            debugPrint("🌎🔵 [API][ASYNC] [id: \(randomRequest)] [SUBSCRIPTION]")
            
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            
            debugPrint("🌎🔵 [API][ASYNC] [id: \(randomRequest)] [COMPLETION][TIME]: [\(Date().timeIntervalSince(timeDateRequest).milliseconds)ms]")
            print("🌎🔵 [API][ASYNC] [id: \(randomRequest)] [OUTPUT]: [\(data.printAsJSON())]")

            guard let response = response as? HTTPURLResponse else {
                debugPrint("🌎🔴 [API][ASYNC] [id: \(randomRequest)] [RESPONSE ERROR]: [noResponse]")
                throw NetworkError.noResponse
            }
            
            if response.statusCode >= 200 && response.statusCode < 299 {
                if T.Type.self == EmptyResponse.Type.self {
                    debugPrint("🌎🔵 [API][ASYNC] [id: \(randomRequest)] [PARSER]: [EmptyResponse]")
                    return EmptyResponse() as! T
                } else {
                    let value = try decoder.decode(T.self, from: data)
                    debugPrint("🌎🔵 [API][ASYNC] [id: \(randomRequest)] [PARSER]: [OK]")
                    return value
                }
            } else {
                let errorValue = try decoder.decode(ErrorResponse.self, from: data)
                debugPrint("🌎⚠️ [API][ASYNC] [id: \(randomRequest)] [ERROR RESPONSE]: [\(errorValue)]")
                
                throw NetworkError.serverError(errorValue.errorMessage ?? "default.error.message")
            }
        } catch let DecodingError.dataCorrupted(context) {
            debugPrint("🌎🔴 [API][ASYNC] [id: \(randomRequest)] [CANCEL][TIME]: [\(Date().timeIntervalSince(timeDateRequest).milliseconds)ms]")
            debugPrint("🌎🔴 [API][ASYNC] [id: \(randomRequest)] [DECODING-ERROR] [dataCorrupted]: [\(context)]")
            throw NetworkError.decode("decoding error")
        } catch let DecodingError.keyNotFound(key, context) {
            debugPrint("🌎🔴 [API] [id: \(randomRequest)] [CANCEL][TIME]: [\(Date().timeIntervalSince(timeDateRequest).milliseconds)ms]")
            debugPrint("🌎🔴 [API] [id: \(randomRequest)] [DECODING-ERROR] [keyNotFound]: [Key \(key) not found: \(context.debugDescription)]")
            debugPrint("🌎🔴 [API] [id: \(randomRequest)] [DECODING-ERROR] [keyNotFound]: [CodingPath: \(context.codingPath)]")
            throw NetworkError.decode("decoding error")
        } catch let DecodingError.valueNotFound(value, context) {
            debugPrint("🌎🔴 [API] [id: \(randomRequest)] [CANCEL][TIME]: [\(Date().timeIntervalSince(timeDateRequest).milliseconds)ms]")
            debugPrint("🌎🔴 [API] [id: \(randomRequest)] [DECODING-ERROR] [valueNotFound]: [Value \(value) not found: \(context.debugDescription)]")
            debugPrint("🌎🔴 [API] [id: \(randomRequest)] [DECODING-ERROR] [valueNotFound]: [CodingPath: \(context.codingPath)]")
            throw NetworkError.decode("decoding error")
        } catch let DecodingError.typeMismatch(type, context)  {
            debugPrint("🌎🔴 [API] [id: \(randomRequest)] [CANCEL][TIME]: [\(Date().timeIntervalSince(timeDateRequest).milliseconds)ms]")
            debugPrint("🌎🔴 [API] [id: \(randomRequest)] [DECODING-ERROR] [typeMismatch]: [Type \(type) mismatch: \(context.debugDescription)]")
            debugPrint("🌎🔴 [API] [id: \(randomRequest)] [DECODING-ERROR] [typeMismatch]: [CodingPath: \(context.codingPath)]")
            throw NetworkError.decode("decoding error")
        } catch URLError.Code.notConnectedToInternet {
            debugPrint("🌎🔴 [API] [id: \(randomRequest)] [CANCEL][TIME]: [\(Date().timeIntervalSince(timeDateRequest).milliseconds)ms]")
            debugPrint("🌎🔴 [API] [id: \(randomRequest)] [NO INTERNET CONNECTION]")
            throw NetworkError.noInternet("default.connection.error.message")
        } catch {
            debugPrint("🌎🔴 [API] [id: \(randomRequest)] [CANCEL][TIME]: [\(Date().timeIntervalSince(timeDateRequest).milliseconds)ms]")
            debugPrint("🌎🔴 [API] [id: \(randomRequest)] [ERROR]: [\(error)]")
            throw error
        }
    }
    
    //  MARK: - Combine
    public func request<T: Decodable>(_ method : HttpMethod,
                                      decoder  : JSONDecoder = newJSONDecoder(),
                                      url      : URL,
                                      headers  : [String: Any] = [String : Any](),
                                      params   : [String: Any]? = nil) -> AnyPublisher<T, Error> {
        let randomRequest   = "\(Int.random(in: 0 ..< 100))"
        var timeDateRequest = Date()
        
        debugPrint("🌎🔵 [API][COMBINE] [id: \(randomRequest)] [URL]: [\(String(describing: url))]")
        debugPrint("🌎🔵 [API][COMBINE] [id: \(randomRequest)] [PARAMETERS]: [\(String(describing: params))]")
        debugPrint("🌎🔵 [API][COMBINE] [id: \(randomRequest)] [HEADER ITEMS]: [\(String(describing: headers))]")

        
        var urlRequest        = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        urlRequest.httpBody   = params?.paramsEncoded()
        
        headers.forEach { (key, value) in
            if let value = value as? String {
                urlRequest.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
        //  MARK: - Combine Events
            .handleEvents(receiveSubscription: { subscription in
                timeDateRequest = Date()
                debugPrint("🌎🔵 [API][COMBINE] [id: \(randomRequest)] [SUBSCRIPTION]")
            }, receiveOutput: { value in
                debugPrint("🌎🔵 [API][COMBINE] [id: \(randomRequest)] [OUTPUT]: [\(value.data.printAsJSON())]")
            }, receiveCompletion: { value in
                debugPrint("🌎🔵 [API][COMBINE] [id: \(randomRequest)] [COMPLETION][TIME]: [\(Date().timeIntervalSince(timeDateRequest).milliseconds)ms]")
            }, receiveCancel: {
                debugPrint("🌎🔴 [API][COMBINE] [id: \(randomRequest)] [CANCEL][TIME]: [\(Date().timeIntervalSince(timeDateRequest).milliseconds)ms]")
            })
        //  MARK: - Map Error
            .mapError { error -> Error in
                debugPrint("🌎🔴 [API][COMBINE] [id: \(randomRequest)] [ERROR]: [\(error.localizedDescription)]")
                
                return error
            }
        //  MARK: - Map Response
            .tryMap { result in
                guard let response = result.response as? HTTPURLResponse else {
                    debugPrint("🌎🔴 [API][COMBINE] [id: \(randomRequest)] [RESPONSE ERROR]: [noResponse]")
                    throw NetworkError.noResponse
                }
                
                do {
                    timeDateRequest = Date()
                    
                    debugPrint("🌎🔵 [API][COMBINE] [id: \(randomRequest)] [OUTPUT]: [\(String(decoding: result.data, as: UTF8.self))]")
                    
                    if response.statusCode >= 200 && response.statusCode < 299 {
                        if T.Type.self == EmptyResponse.Type.self {
                            debugPrint("🌎🔵 [API][COMBINE] [id: \(randomRequest)] [PARSER]: [EmptyResponse]")
                            return EmptyResponse() as! T
                        } else {
                            let value = try decoder.decode(T.self, from: result.data)
                            debugPrint("🌎🔵 [API][COMBINE] [id: \(randomRequest)] [PARSER]: [OK]")
                            return value
                        }
                    } else {
                        let errorValue = try decoder.decode(ErrorResponse.self, from: result.data)
                        debugPrint("🌎⚠️ [API][COMBINE] [id: \(randomRequest)] [ERROR RESPONSE]: [\(errorValue)]")
                        
                        throw NetworkError.serverError(errorValue.errorMessage ?? "default.error.message")
                    }
                } catch let DecodingError.dataCorrupted(context) {
                    debugPrint("🌎🔴 [API][COMBINE] [id: \(randomRequest)] [CANCEL][TIME]: [\(Date().timeIntervalSince(timeDateRequest).milliseconds)ms]")
                    debugPrint("🌎🔴 [API][COMBINE] [id: \(randomRequest)] [DECODING-ERROR] [dataCorrupted]: [\(context)]")
                    throw NetworkError.decode("decoding error")
                } catch let DecodingError.keyNotFound(key, context) {
                    debugPrint("🌎🔴 [API][COMBINE] [id: \(randomRequest)] [CANCEL][TIME]: [\(Date().timeIntervalSince(timeDateRequest).milliseconds)ms]")
                    debugPrint("🌎🔴 [API][COMBINE] [id: \(randomRequest)] [DECODING-ERROR] [keyNotFound]: [Key \(key) not found: \(context.debugDescription)]")
                    debugPrint("🌎🔴 [API][COMBINE] [id: \(randomRequest)] [DECODING-ERROR] [keyNotFound]: [CodingPath: \(context.codingPath)]")
                    throw NetworkError.decode("decoding error")
                } catch let DecodingError.valueNotFound(value, context) {
                    debugPrint("🌎🔴 [API][COMBINE] [id: \(randomRequest)] [CANCEL][TIME]: [\(Date().timeIntervalSince(timeDateRequest).milliseconds)ms]")
                    debugPrint("🌎🔴 [API][COMBINE] [id: \(randomRequest)] [DECODING-ERROR] [valueNotFound]: [Value \(value) not found: \(context.debugDescription)]")
                    debugPrint("🌎🔴 [API][COMBINE] [id: \(randomRequest)] [DECODING-ERROR] [valueNotFound]: [CodingPath: \(context.codingPath)]")
                    throw NetworkError.decode("decoding error")
                } catch let DecodingError.typeMismatch(type, context)  {
                    debugPrint("🌎🔴 [API][COMBINE] [id: \(randomRequest)] [CANCEL][TIME]: [\(Date().timeIntervalSince(timeDateRequest).milliseconds)ms]")
                    debugPrint("🌎🔴 [API][COMBINE] [id: \(randomRequest)] [DECODING-ERROR] [typeMismatch]: [Type \(type) mismatch: \(context.debugDescription)]")
                    debugPrint("🌎🔴 [API][COMBINE] [id: \(randomRequest)] [DECODING-ERROR] [typeMismatch]: [CodingPath: \(context.codingPath)]")
                    throw NetworkError.decode("decoding error")
                } catch URLError.Code.notConnectedToInternet {
                    debugPrint("🌎🔴 [API][COMBINE] [id: \(randomRequest)] [CANCEL][TIME]: [\(Date().timeIntervalSince(timeDateRequest).milliseconds)ms]")
                    debugPrint("🌎🔴 [API][COMBINE] [id: \(randomRequest)] [NO INTERNET CONNECTION]")
                    throw NetworkError.noInternet("default.connection.error.message")
                } catch {
                    debugPrint("🌎🔴 [API][COMBINE] [id: \(randomRequest)] [CANCEL][TIME]: [\(Date().timeIntervalSince(timeDateRequest).milliseconds)ms]")
                    debugPrint("🌎🔴 [API][COMBINE] [id: \(randomRequest)] [ERROR]: [\(error)]")
                    throw error
                }
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

extension NetworkController {
    private func buildURLWithQueryItems(url: URL, params: [String: Any]?) -> URL {
        guard let params = params else {
            return url
        }
        
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
        urlComponents?.queryItems = params.queryItems
        return urlComponents?.url ?? url
    }
}
