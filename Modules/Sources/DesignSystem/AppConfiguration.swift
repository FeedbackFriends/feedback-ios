//
//  File.swift
//  
//
//  Created by Nicolai Dam on 20/02/2022.
//

import Foundation

public enum AppConfiguration {
    enum Error: Swift.Error {
        case missingKey, invalidValue
    }
    static func value<T>(for key: String) throws -> T where T: LosslessStringConvertible {
        guard let object = Bundle.main.object(forInfoDictionaryKey: key) else {
            throw Error.missingKey
        }
        switch object {
        case let value as T:
            return value
        case let string as String:
            guard let value = T(string) else { fallthrough }
            return value
        default:
            throw Error.invalidValue
        }
    }
    static func value<T>(for key: String) throws -> [T] where T: LosslessStringConvertible {
        guard let object = Bundle.main.object(forInfoDictionaryKey: key) else {
            throw Error.missingKey
        }
        switch object {
        case let string as String:
            let splits = string.split(separator: " ").map(String.init)
            guard !splits.isEmpty else { fallthrough }
            return splits.compactMap(T.init)
        default:
            throw Error.invalidValue
        }
    }
    
    public static var compilerFlag: CompilerFlag {
        do {
            let value: String = try AppConfiguration.value(for: "COMPILER_FLAG") as String
            if value == "TEST" {
                return .TEST
            }
            else if value == "DEBUG" {
                return .DEBUG
            } else if value == "MOCK" {
                return .MOCK
            } else if value == "RELEASE" {
                return .RELEASE
            } else {
                fatalError()
            }
            
        } catch {
            fatalError()
        }
    }
    
    public static var baseURL: URL {
        do {
            let baseURL: String = try AppConfiguration.value(for: "BASE_URL") as String
            return URL(string: "https://" + baseURL)!
        } catch {
            fatalError()
        }
    }
    
    public static var kCLientID: String {
        do {
            let kClientID: String = try AppConfiguration.value(for: "MS_KCLIENTID") as String
            return kClientID
        } catch {
            fatalError()
        }
    }
    public static var msAuthRedirect: String {
        do {
            let redirect: String = try AppConfiguration.value(for: "MS_REDIRECT") as String
            return redirect
        } catch {
            fatalError()
        }
    }
}


public enum CompilerFlag: Sendable {
    case TEST
    case RELEASE
    case MOCK
    case DEBUG
}
