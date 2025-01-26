////
////  File.swift
////  
////
////  Created by Nicolai Dam on 16/07/2022.
////
//
//import Foundation
//
public enum CustomError: Equatable, Error {
    case noMSUserFound
    case emptyJWT
    case other(type: String = "Unknown", description: String)
}
//
//
//
//public enum ErrorType: Error, Equatable, LocalizedError {
//    case msError(MicrosoftError)
//    case customError(CustomError)
//    
//    // localizedDescription
//    public var errorDescription: String? {
//        
//        switch self {
//        case .msError(let microsoftError):
//            return "MS error: \(microsoftError.error.message)"
//
//        case .customError(let customError):
//            return "Something went wrong"
//        }
//        
////        switch self {
////        case .apiError(let apiError):
////            #warning("DEBUG virker ikke.. Det skal altså fikses")
////#if DEBUG
////            return "\(apiError.errorMessage) DeveloperInfo: \(apiError.devInfo)"
////#else
////            return apiError.errorMessage
////#endif
////        default:
////            return self.localizedDescription.description
//////#if DEBUG
//////            return "LocalizedDescription: \(self.localizedDescription)"
//////#else
//////            return defaultError
//////#endif
////        }
//    }
//}
//
