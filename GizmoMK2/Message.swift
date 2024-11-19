//
//  Message.swift
//  GizmoMK2
//
//  Created by Matthew Sand on 11/7/24.
//

import Foundation

// Define message types for communication
enum MessageType: String, Codable {
    case listPages
    case pagesList
    case listShortcuts
    case shortcutsList
    case listActions
    case actionsList
    case executeAction
    case actionExecuted
    case createAction
    case modifyAction
    case actionUpdated
    case deleteAction
    case actionDeleted
    case createExecutor
    case updateExecutor
    case deleteExecutor
    case executorUpdated
    case executorDeleted
    case swapExecutor
    case executorSwapped
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
    let pages: [Page]
}

struct ListShortcutsRequest : Codable {
}

struct ShortcutsListResponse : Codable {
    let shortcuts: [String]
}

struct ListActionsRequest : Codable {}

struct ActionsListResponse : Codable {
    let actions: [ActionModel]
}

// 3. ExecuteAction (Client Request)
struct ExecuteActionRequest: Codable {
    let actionID: String
}

// 4. ActionExecuted (Host Response)
struct ActionExecutedResponse: Codable {
    let actionID: String
    let success: Bool
    let message: String?
}

// 5. CreateAction (Client Request)
struct CreateActionRequest: Codable {
    let action : ActionModel
}

// 6. ModifyAction (Client Request)
struct ModifyActionRequest: Codable {
    let action : ActionModel
}

// 7. ActionUpdated (Host Response)
struct ActionUpdatedResponse: Codable {
    let actionID: UUID
    let success: Bool
    let message: String?
}

struct DeleteActionRequest: Codable {
    let actionID: String
}

struct ActionDeletedResponse: Codable {
    let actionID: String
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
