import Foundation

//  MARK: - Empty Response
public class EmptyResponse: Decodable {}

//  MARK: - Error Response
public struct ErrorResponse: Decodable, Error {
    let errorMessage : String?
    let description  : String?
    let code         : Int?
}
