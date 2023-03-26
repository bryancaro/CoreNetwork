//
//  CoreDataControllerProtocol.swift
//  AdHealth Tracker
//
//  Created for AdHealth Tracker in 2023
//  Using Swift 5.0
//  Running on macOS 13.1
//
//  Created by Bryan Caro on 26/2/23.
//  
//

import CoreData

//  MARK: - CoreDataProtocol
protocol CoreDataProtocol {
    var manager: CoreDataController { get }
}

//  MARK: - CoreDataControllerProtocol
protocol CoreDataControllerProtocol: AnyObject {
    func saveData() -> Result<Void, CoreDataError>
    func getSavedData<T: NSManagedObject>(_ objectType: T.Type) -> Result<[T], CoreDataError>
    func deleteSavedData<T: NSManagedObject>(_ objectType: T.Type) -> Result<Void, CoreDataError>
}

//  MARK: - CoreDataError
public enum CoreDataError: Error {
    case saveError
    case deleteError
    case fetchError
    case updateError
    
    var localizedDescription: String {
        switch self {
        case .saveError:
            return "Failed to save changes."
        case .deleteError:
            return "Failed to delete object."
        case .fetchError:
            return "Failed to fetch objects."
        case .updateError:
            return "Failed to update object."
        }
    }
}

