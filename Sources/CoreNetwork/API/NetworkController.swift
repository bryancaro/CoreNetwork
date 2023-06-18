import Foundation
import Combine

open class Network: NetworkProtocol {
    public var manager: NetworkController = NetworkController()

    public init() {}
}

public struct NetworkController {
    public init() {}
    //  MARK: - Async Await
    public func requestTwo<T: Decodable>(_ method: HttpMethod,
                                     decoder: JSONDecoder = newJSONDecoder(),
                                     url: URL?,
                                     headers: [String: Any] = [String: Any](),
                                     queryItems: [URLQueryItem]? = nil) async throws -> T {
        let randomRequest = "\(Int.random(in: 0 ..< 100))"
        var timeDateRequest = Date()

        print("🌎🔵 [API][ASYNC] [id: \(randomRequest)] [URL]: [\(String(describing: url))]")
        print("🌎🔵 [API][ASYNC] [id: \(randomRequest)] [QUERY ITEMS]: [\(String(describing: queryItems))]")

        guard let url = url else {
            print("🌎🔴 [API][ASYNC] [id: \(randomRequest)] [RESPONSE ERROR]: [invalidURL]")
            throw NetworkError.invalidURL
        }

        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
        urlComponents?.queryItems = queryItems

        guard let finalURL = urlComponents?.url else {
            print("🌎🔴 [API][ASYNC] [id: \(randomRequest)] [RESPONSE ERROR]: [invalidURL]")
            throw NetworkError.invalidURL
        }

        var urlRequest = URLRequest(url: finalURL)
        urlRequest.httpMethod = method.rawValue

        headers.forEach { (key, value) in
            if let value = value as? String {
                urlRequest.setValue(value, forHTTPHeaderField: key)
            }
        }

        do {
            timeDateRequest = Date()
            print("🌎🔵 [API][ASYNC] [id: \(randomRequest)] [SUBSCRIPTION]")

            let (data, response) = try await URLSession.shared.data(for: urlRequest)

            print("🌎🔵 [API][ASYNC] [id: \(randomRequest)] [COMPLETION][TIME]: [\(Date().timeIntervalSince(timeDateRequest).milliseconds)ms]")
            print("🌎🔵 [API][ASYNC] [id: \(randomRequest)] [OUTPUT]: [\(String(decoding: data, as: UTF8.self))]")

            guard let response = response as? HTTPURLResponse else {
                print("🌎🔴 [API][ASYNC] [id: \(randomRequest)] [RESPONSE ERROR]: [noResponse]")
                throw NetworkError.noResponse
            }

            if response.statusCode >= 200 && response.statusCode < 299 {
                if T.Type.self == EmptyResponse.Type.self {
                    print("🌎🔵 [API][ASYNC] [id: \(randomRequest)] [PARSER]: [EmptyResponse]")
                    return EmptyResponse() as! T
                } else {
                    let value = try decoder.decode(T.self, from: data)
                    print("🌎🔵 [API][ASYNC] [id: \(randomRequest)] [PARSER]: [OK]")
                    return value
                }
            } else {
                let errorValue = try decoder.decode(ErrorResponse.self, from: data)
                print("🌎⚠️ [API][ASYNC] [id: \(randomRequest)] [ERROR RESPONSE]: [\(errorValue)]")

                throw NetworkError.serverError(errorValue.errorMessage ?? "default.error.message")
            }
        } catch let DecodingError.dataCorrupted(context) {
            print("🌎🔴 [API][ASYNC] [id: \(randomRequest)] [CANCEL][TIME]: [\(Date().timeIntervalSince(timeDateRequest).milliseconds)ms]")
            print("🌎🔴 [API][ASYNC] [id: \(randomRequest)] [DECODING-ERROR] [dataCorrupted]: [\(context)]")
            throw NetworkError.decode("decoding error")
        } catch let DecodingError.keyNotFound(key, context) {
            print("🌎🔴 [API] [id: \(randomRequest)] [CANCEL][TIME]: [\(Date().timeIntervalSince(timeDateRequest).milliseconds)ms]")
            print("🌎🔴 [API] [id: \(randomRequest)] [DECODING-ERROR] [keyNotFound]: [Key \(key) not found: \(context.debugDescription)]")
            print("🌎🔴 [API] [id: \(randomRequest)] [DECODING-ERROR] [keyNotFound]: [CodingPath: \(context.codingPath)]")
            throw NetworkError.decode("decoding error")
        } catch let DecodingError.valueNotFound(value, context) {
            print("🌎🔴 [API] [id: \(randomRequest)] [CANCEL][TIME]: [\(Date().timeIntervalSince(timeDateRequest).milliseconds)ms]")
            print("🌎🔴 [API] [id: \(randomRequest)] [DECODING-ERROR] [valueNotFound]: [Value \(value) not found: \(context.debugDescription)]")
            print("🌎🔴 [API] [id: \(randomRequest)] [DECODING-ERROR] [valueNotFound]: [CodingPath: \(context.codingPath)]")
            throw NetworkError.decode("decoding error")
        } catch let DecodingError.typeMismatch(type, context)  {
            print("🌎🔴 [API] [id: \(randomRequest)] [CANCEL][TIME]: [\(Date().timeIntervalSince(timeDateRequest).milliseconds)ms]")
            print("🌎🔴 [API] [id: \(randomRequest)] [DECODING-ERROR] [typeMismatch]: [Type \(type) mismatch: \(context.debugDescription)]")
            print("🌎🔴 [API] [id: \(randomRequest)] [DECODING-ERROR] [typeMismatch]: [CodingPath: \(context.codingPath)]")
            throw NetworkError.decode("decoding error")
        } catch URLError.Code.notConnectedToInternet {
            print("🌎🔴 [API] [id: \(randomRequest)] [CANCEL][TIME]: [\(Date().timeIntervalSince(timeDateRequest).milliseconds)ms]")
            print("🌎🔴 [API] [id: \(randomRequest)] [NO INTERNET CONNECTION]")
            throw NetworkError.noInternet("default.connection.error.message")
        } catch {
            print("🌎🔴 [API] [id: \(randomRequest)] [CANCEL][TIME]: [\(Date().timeIntervalSince(timeDateRequest).milliseconds)ms]")
            print("🌎🔴 [API] [id: \(randomRequest)] [ERROR]: [\(error)]")
            throw error
        }
    }

    public func request<T : Decodable>(_ method: HttpMethod,
                                       decoder: JSONDecoder = newJSONDecoder(),
                                       url: URL?,
                                       headers: [String: Any] = [String : Any](),
                                       params: [String : Any]? = nil) async throws -> T {
        let randomRequest = "\(Int.random(in: 0 ..< 100))"
        var timeDateRequest = Date()

        print("🌎🔵 [API][ASYNC] [id: \(randomRequest)] [URL]: [\(String(describing: url))]")
        print("🌎🔵 [API][ASYNC] [id: \(randomRequest)] [PARAMETERS]: [\(String(describing: params))]")

        guard let url else {
            print("🌎🔴 [API][ASYNC] [id: \(randomRequest)] [RESPONSE ERROR]: [invalidURL]")
            throw NetworkError.invalidURL
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        urlRequest.httpBody = params?.paramsEncoded()

        headers.forEach { (key, value) in
            if let value = value as? String {
                urlRequest.setValue(value, forHTTPHeaderField: key)
            }
        }

        do {
            timeDateRequest = Date()
            print("🌎🔵 [API][ASYNC] [id: \(randomRequest)] [SUBSCRIPTION]")

            let (data, response) = try await URLSession.shared.data(for: urlRequest)

            print("🌎🔵 [API][ASYNC] [id: \(randomRequest)] [COMPLETION][TIME]: [\(Date().timeIntervalSince(timeDateRequest).milliseconds)ms]")
            print("🌎🔵 [API][ASYNC] [id: \(randomRequest)] [OUTPUT]: [\(String(decoding: data, as: UTF8.self))]")

            guard let response = response as? HTTPURLResponse else {
                print("🌎🔴 [API][ASYNC] [id: \(randomRequest)] [RESPONSE ERROR]: [noResponse]")
                throw NetworkError.noResponse
            }

            if response.statusCode >= 200 && response.statusCode < 299 {
                if T.Type.self == EmptyResponse.Type.self {
                    print("🌎🔵 [API][ASYNC] [id: \(randomRequest)] [PARSER]: [EmptyResponse]")
                    return EmptyResponse() as! T
                } else {
                    let value = try decoder.decode(T.self, from: data)
                    print("🌎🔵 [API][ASYNC] [id: \(randomRequest)] [PARSER]: [OK]")
                    return value
                }
            } else {
                let errorValue = try decoder.decode(ErrorResponse.self, from: data)
                print("🌎⚠️ [API][ASYNC] [id: \(randomRequest)] [ERROR RESPONSE]: [\(errorValue)]")

                throw NetworkError.serverError(errorValue.errorMessage ?? "default.error.message")
            }
        } catch let DecodingError.dataCorrupted(context) {
            print("🌎🔴 [API][ASYNC] [id: \(randomRequest)] [CANCEL][TIME]: [\(Date().timeIntervalSince(timeDateRequest).milliseconds)ms]")
            print("🌎🔴 [API][ASYNC] [id: \(randomRequest)] [DECODING-ERROR] [dataCorrupted]: [\(context)]")
            throw NetworkError.decode("decoding error")
        } catch let DecodingError.keyNotFound(key, context) {
            print("🌎🔴 [API] [id: \(randomRequest)] [CANCEL][TIME]: [\(Date().timeIntervalSince(timeDateRequest).milliseconds)ms]")
            print("🌎🔴 [API] [id: \(randomRequest)] [DECODING-ERROR] [keyNotFound]: [Key \(key) not found: \(context.debugDescription)]")
            print("🌎🔴 [API] [id: \(randomRequest)] [DECODING-ERROR] [keyNotFound]: [CodingPath: \(context.codingPath)]")
            throw NetworkError.decode("decoding error")
        } catch let DecodingError.valueNotFound(value, context) {
            print("🌎🔴 [API] [id: \(randomRequest)] [CANCEL][TIME]: [\(Date().timeIntervalSince(timeDateRequest).milliseconds)ms]")
            print("🌎🔴 [API] [id: \(randomRequest)] [DECODING-ERROR] [valueNotFound]: [Value \(value) not found: \(context.debugDescription)]")
            print("🌎🔴 [API] [id: \(randomRequest)] [DECODING-ERROR] [valueNotFound]: [CodingPath: \(context.codingPath)]")
            throw NetworkError.decode("decoding error")
        } catch let DecodingError.typeMismatch(type, context)  {
            print("🌎🔴 [API] [id: \(randomRequest)] [CANCEL][TIME]: [\(Date().timeIntervalSince(timeDateRequest).milliseconds)ms]")
            print("🌎🔴 [API] [id: \(randomRequest)] [DECODING-ERROR] [typeMismatch]: [Type \(type) mismatch: \(context.debugDescription)]")
            print("🌎🔴 [API] [id: \(randomRequest)] [DECODING-ERROR] [typeMismatch]: [CodingPath: \(context.codingPath)]")
            throw NetworkError.decode("decoding error")
        } catch URLError.Code.notConnectedToInternet {
            print("🌎🔴 [API] [id: \(randomRequest)] [CANCEL][TIME]: [\(Date().timeIntervalSince(timeDateRequest).milliseconds)ms]")
            print("🌎🔴 [API] [id: \(randomRequest)] [NO INTERNET CONNECTION]")
            throw NetworkError.noInternet("default.connection.error.message")
        } catch {
            print("🌎🔴 [API] [id: \(randomRequest)] [CANCEL][TIME]: [\(Date().timeIntervalSince(timeDateRequest).milliseconds)ms]")
            print("🌎🔴 [API] [id: \(randomRequest)] [ERROR]: [\(error)]")
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

        print("🌎🔵 [API][COMBINE] [id: \(randomRequest)] [URL]: [\(String(describing: url))]")
        print("🌎🔵 [API][COMBINE] [id: \(randomRequest)] [PARAMETERS]: [\(String(describing: params))]")

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
                print("🌎🔵 [API][COMBINE] [id: \(randomRequest)] [SUBSCRIPTION]")
            }, receiveOutput: { value in
                print("🌎🔵 [API][COMBINE] [id: \(randomRequest)] [OUTPUT]: [\(String(decoding: value.data, as: UTF8.self))]")
            }, receiveCompletion: { value in
                print("🌎🔵 [API][COMBINE] [id: \(randomRequest)] [COMPLETION][TIME]: [\(Date().timeIntervalSince(timeDateRequest).milliseconds)ms]")
            }, receiveCancel: {
                print("🌎🔴 [API][COMBINE] [id: \(randomRequest)] [CANCEL][TIME]: [\(Date().timeIntervalSince(timeDateRequest).milliseconds)ms]")
            })
        //  MARK: - Map Error
            .mapError { error -> Error in
                print("🌎🔴 [API][COMBINE] [id: \(randomRequest)] [ERROR]: [\(error.localizedDescription)]")

                return error
            }
        //  MARK: - Map Response
            .tryMap { result in
                guard let response = result.response as? HTTPURLResponse else {
                    print("🌎🔴 [API][COMBINE] [id: \(randomRequest)] [RESPONSE ERROR]: [noResponse]")
                    throw NetworkError.noResponse
                }

                do {
                    timeDateRequest = Date()

                    print("🌎🔵 [API][COMBINE] [id: \(randomRequest)] [OUTPUT]: [\(String(decoding: result.data, as: UTF8.self))]")

                    if response.statusCode >= 200 && response.statusCode < 299 {
                        if T.Type.self == EmptyResponse.Type.self {
                            print("🌎🔵 [API][COMBINE] [id: \(randomRequest)] [PARSER]: [EmptyResponse]")
                            return EmptyResponse() as! T
                        } else {
                            let value = try decoder.decode(T.self, from: result.data)
                            print("🌎🔵 [API][COMBINE] [id: \(randomRequest)] [PARSER]: [OK]")
                            return value
                        }
                    } else {
                        let errorValue = try decoder.decode(ErrorResponse.self, from: result.data)
                        print("🌎⚠️ [API][COMBINE] [id: \(randomRequest)] [ERROR RESPONSE]: [\(errorValue)]")

                        throw NetworkError.serverError(errorValue.errorMessage ?? "default.error.message")
                    }
                } catch let DecodingError.dataCorrupted(context) {
                    print("🌎🔴 [API][COMBINE] [id: \(randomRequest)] [CANCEL][TIME]: [\(Date().timeIntervalSince(timeDateRequest).milliseconds)ms]")
                    print("🌎🔴 [API][COMBINE] [id: \(randomRequest)] [DECODING-ERROR] [dataCorrupted]: [\(context)]")
                    throw NetworkError.decode("decoding error")
                } catch let DecodingError.keyNotFound(key, context) {
                    print("🌎🔴 [API][COMBINE] [id: \(randomRequest)] [CANCEL][TIME]: [\(Date().timeIntervalSince(timeDateRequest).milliseconds)ms]")
                    print("🌎🔴 [API][COMBINE] [id: \(randomRequest)] [DECODING-ERROR] [keyNotFound]: [Key \(key) not found: \(context.debugDescription)]")
                    print("🌎🔴 [API][COMBINE] [id: \(randomRequest)] [DECODING-ERROR] [keyNotFound]: [CodingPath: \(context.codingPath)]")
                    throw NetworkError.decode("decoding error")
                } catch let DecodingError.valueNotFound(value, context) {
                    print("🌎🔴 [API][COMBINE] [id: \(randomRequest)] [CANCEL][TIME]: [\(Date().timeIntervalSince(timeDateRequest).milliseconds)ms]")
                    print("🌎🔴 [API][COMBINE] [id: \(randomRequest)] [DECODING-ERROR] [valueNotFound]: [Value \(value) not found: \(context.debugDescription)]")
                    print("🌎🔴 [API][COMBINE] [id: \(randomRequest)] [DECODING-ERROR] [valueNotFound]: [CodingPath: \(context.codingPath)]")
                    throw NetworkError.decode("decoding error")
                } catch let DecodingError.typeMismatch(type, context)  {
                    print("🌎🔴 [API][COMBINE] [id: \(randomRequest)] [CANCEL][TIME]: [\(Date().timeIntervalSince(timeDateRequest).milliseconds)ms]")
                    print("🌎🔴 [API][COMBINE] [id: \(randomRequest)] [DECODING-ERROR] [typeMismatch]: [Type \(type) mismatch: \(context.debugDescription)]")
                    print("🌎🔴 [API][COMBINE] [id: \(randomRequest)] [DECODING-ERROR] [typeMismatch]: [CodingPath: \(context.codingPath)]")
                    throw NetworkError.decode("decoding error")
                } catch URLError.Code.notConnectedToInternet {
                    print("🌎🔴 [API][COMBINE] [id: \(randomRequest)] [CANCEL][TIME]: [\(Date().timeIntervalSince(timeDateRequest).milliseconds)ms]")
                    print("🌎🔴 [API][COMBINE] [id: \(randomRequest)] [NO INTERNET CONNECTION]")
                    throw NetworkError.noInternet("default.connection.error.message")
                } catch {
                    print("🌎🔴 [API][COMBINE] [id: \(randomRequest)] [CANCEL][TIME]: [\(Date().timeIntervalSince(timeDateRequest).milliseconds)ms]")
                    print("🌎🔴 [API][COMBINE] [id: \(randomRequest)] [ERROR]: [\(error)]")
                    throw error
                }
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
