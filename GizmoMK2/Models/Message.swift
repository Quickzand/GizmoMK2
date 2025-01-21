//
//  Message.swift
//  GizmoDesktopMK2
//
//  Created by Matthew Sand on 11/7/24.
//

import Foundation

// Enum to differentiate message types
enum MessageType: String, Codable {
    case listPages
    case pagesList
    case listShortcuts
    case shortcutsList
    case executeAction
    case actionExecuted
    case createExecutor
    case updateExecutor
    case deleteExecutor
    case executorUpdated
    case executorDeleted
    case swapExecutor
    case executorSwapped
    case focusedAppUpdated
    case listApps
    case appsList
    case createPage
    case modifyPage
    case deletePage
    case pageUpdated
    case updateAppInfo
    case AppInfoUpdated
    case error
}


// Base message structure
struct Message: Codable {
    let type: MessageType
    let payload: String?
}

// Payload structures for each message type

// 1. ListPages (Client Request)
struct ListPagesRequest: Codable { }

// 2. PagesList (Host Response)
struct PagesListResponse: Codable {
    let pages: [PageModel]
}

struct ListShortcutsRequest : Codable {
}

struct ShortcutsListResponse : Codable {
    let shortcuts: [String]
}




struct ExecuteActionRequest: Codable {
    let executorID: String
    let actionContextOption : ActionContextOption
}


struct ActionExecutedResponse: Codable {
    let executorId: String
    let success: Bool
    let message: String?
}


struct ShortcutExecutedResponse : Codable {
    let shortcut: String
    let success: Bool
    let message: String?
}

struct UpdateExecutorRequest: Codable {
    let executor: ExecutorModel
}

struct ExecutorUpdatedResponse : Codable {
    let executorID: String
    let success: Bool
    let message: String?
}


struct DeleteExecutorRequest: Codable {
    let executorID: String
}

struct ExecutorDeletedResponse : Codable {
    let executorID: String
    let success: Bool
    let message: String?
}



struct CreateExecutorRequest: Codable {
    let executor: ExecutorModel
    let pageID: String
}


struct SwapExecutorRequest: Codable {
    let executorID: String
    let pageID: String
    let index : Int
}

struct ExecutorSwappedResponse : Codable {
    let executorID: String
    let success: Bool
    let message: String?
}

struct FocusedAppUpdateRequest : Codable {
    let appInfo : AppInfoModel
}

struct ListAppsRequest : Codable {
    
}

struct AppsListResponse : Codable {
    let appInfos : [AppInfoModel]
}

struct CreatePageRequest : Codable {
    let page : PageModel
}

struct ModifyPageRequest : Codable {
    let page : PageModel
}

struct DeletePageRequest : Codable {
    let pageID: String
}

struct PageUpdatedResponse : Codable {
    let pageID: String
    let success: Bool
    let message: String?
}

struct UpdateAppInfoRequest : Codable {
    let appInfo : AppInfoModel
}

struct AppInfoUpdatedResponse : Codable {
    let appInfoID: String
    let success: Bool
    let message: String?
}



// 8. Error Message
struct ErrorMessage: Codable {
    let message: String
}


// Utility class to handle message framing
class MessageReceiver {
    private var buffer = Data()
    private let delimiter = "\n".data(using: .utf8)!
    
    func receive(data: Data, process: (Data) -> Void) {
        buffer.append(data)
        
        while let range = buffer.range(of: delimiter) {
            let messageData = buffer.subdata(in: buffer.startIndex..<range.lowerBound)
            process(messageData)
            buffer.removeSubrange(buffer.startIndex..<range.upperBound)
        }
    }
}
