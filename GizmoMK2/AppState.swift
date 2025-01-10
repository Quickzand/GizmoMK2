//
//  AppState.swift
//  GizmoDesktopMK2
//
//  Created by Matthew Sand on 11/7/24.
//

import Foundation
import SwiftUI
import Combine
import Network


class AppState: ObservableObject {
    @Published var foundHosts: [FoundHost] = []
    @Published var settings : Settings = Settings.load()
    @Published var pages: [PageModel] = []
    @Published var actions : [ActionModel] = []
    @Published var currentPageID: String = "1"
    @Published var editMode : Bool = false
    
    @Published var shortcuts : [String] = []
    
    @Published var executorCreationShown : Bool = false
    @Published var executorCreationModel : ExecutorModel = ExecutorModel(label:"Default Label")
    
    @Published var pageCreationShown : Bool = false
    
    @Published var focusedApp : AppInfoModel = .init(name: "", bundleID: "")
    
    @Published var appInfos : [AppInfoModel] = []
    
    
    
    @Published var deviceOrientation: UIDeviceOrientation = UIDevice.current.orientation
    
    private let bonjourService = BonjourService()
    private var cancellables = Set<AnyCancellable>()
    
    @Published public var connection: NWConnection?
    private var messageReceiver = MessageReceiver()
    
    func getCurrentRotation() -> Angle {
        
        switch self.deviceOrientation {
        case .landscapeLeft:
            return Angle(degrees: 90.0)
        case .landscapeRight:
            return Angle(degrees: -90.0)
        default:
            return Angle(degrees: 0.0)
        }
    }
    
    init() {
        bonjourService.$discoveredClients
            .receive(on: DispatchQueue.main)
            .sink { [weak self] clients in
                print("Found hosts updated: \(clients)")
                self?.foundHosts = clients
            }
            .store(in: &cancellables)
        
        
        // Start generating device orientation notifications
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        
        // Subscribe to orientation change notifications
        NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)
            .receive(on: RunLoop.main) // Ensure updates happen on the main thread
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.deviceOrientation = UIDevice.current.orientation
            }
            .store(in: &cancellables)
    }
    
    // Start browsing for services
    func startBrowsing() {
        foundHosts = []
        bonjourService.startBrowsing(serviceType: "_gizmo._tcp.")
    }
    
    // Stop browsing for services
    func stopBrowsing() {
        bonjourService.stopBrowsing()
    }
    
    // Connect to a selected host
    func connectToHost(_ host: FoundHost) {
        let parameters = NWParameters.tcp
        self.settings.previouslyConnectedHostName = host.name
        let connection = NWConnection(
            host: NWEndpoint.Host(host.hostName),
            port: NWEndpoint.Port(rawValue: UInt16(host.port))!,
            using: parameters
        )
        
        self.connection = connection
        
        connection.stateUpdateHandler = { [weak self] newState in
            switch newState {
            case .ready:
                print("Connected to \(host.name) at \(host.hostName):\(host.port)")
                self?.requestPages()
                self?.requestActions()
                self?.requestAppInfos()
            case .failed(let error):
                print("Connection failed with error: \(error)")
                self?.connection = nil
            case .cancelled:
                print("Connection cancelled")
                self?.connection = nil
            default:
                break
            }
        }
        
        connection.start(queue: .main)
        receiveData(connection: connection)
    }
    
    // Disconnect from the host
    func disconnect() {
        connection?.cancel()
        connection = nil
        print("Disconnected from host.")
    }
    
    // Request the list of pages from the host
    func requestPages() {
        print("Getting pages...")
        guard let connection = connection else { return }
        let request = ListPagesRequest()
        if let message = encodeMessage(type: .listPages, payload: request) {
            sendMessage(message, on: connection)
        }
    }
    
    func requestShortcuts() {
        print("Getting shortcuts...")
        guard let connection = connection else { return }
        let request = ListShortcutsRequest()
        if let message = encodeMessage(type: .listShortcuts, payload: request) {
            sendMessage(message, on: connection)
        }
    }
    
    func requestActions() {
        print("Getting actions...")
        guard let connection = connection else { return }
        let request = ListActionsRequest()
        if let message = encodeMessage(type: .listActions, payload: request) {
            sendMessage(message, on: connection)
        }
    }
    
    // Execute a specific action on the host
    func executeAction(actionID: String) {
        guard let connection = connection else { return }
        guard let action = actions.first(where: { $0.id == actionID }) else {return}
            switch action.type {
            case .siriShortcut:
                executeShortcut(shortcut: action.shortcut)
            default:
                let request = ExecuteActionRequest(actionID: actionID)
                if let message = encodeMessage(type: .executeAction, payload: request) {
                    sendMessage(message, on: connection)
                }
            }
            
            
    }
    
    func executeShortcut(shortcut: String) {
        guard let connection = connection else { return }
        let request = ExecuteShortcutRequest(shortcut: shortcut)
        if let message = encodeMessage(type: .executeShortcut, payload: request) {
            sendMessage(message, on: connection)
        }
    }
    
    // Create a new action
    func createAction(action: ActionModel) {
        guard let connection = connection else { return }
        let request = CreateActionRequest(action: action)
        if let message = encodeMessage(type: .createAction, payload: request) {
            sendMessage(message, on: connection)
        }
    }
    
//    Create a new executor
    func createExecutor(executor: ExecutorModel, pageID: String) {
        guard let connection = connection else { return }
        let request = CreateExecutorRequest(executor: executor, pageID: pageID)
        if let message = encodeMessage(type: .createExecutor, payload: request) {
            sendMessage(message, on: connection)
        }
    }
    
    func createPage(page: PageModel) {
        guard let connection = connection else { return }
        let request = CreatePageRequest(page: page)
        if let message = encodeMessage(type: .createPage, payload: request) {
            sendMessage(message, on: connection)
        }
    }
    
    func modifyPage(page: PageModel) {
        guard let connection = connection else { return }
        let request = ModifyPageRequest(page: page)
        if let message = encodeMessage(type: .modifyPage, payload: request) {
            sendMessage(message, on: connection)
        }
    }
    
    func deletePage(withID pageId : String) {
        guard let connection = connection else { return }
        let request = DeletePageRequest(pageID:  pageId)
        if let message = encodeMessage(type: .deletePage, payload: request) {
            sendMessage(message, on: connection)
        }
    }
    
    
    // Modify an existing action
    func modifyAction(action:ActionModel) {
        guard let connection = connection else { return }
        let request = ModifyActionRequest(action:action)
        if let message = encodeMessage(type: .modifyAction, payload: request) {
            sendMessage(message, on: connection)
        }
    }
    
    func deleteAction(id: String) {
        guard let connection = connection else { return }
        let request = DeleteActionRequest(actionID: id)
        if let message = encodeMessage(type: .deleteAction, payload: request) {
            sendMessage(message, on: connection)
        }
    }
    
    func deleteExecutor(id: String) {
        guard let connection = connection else {return}
        let request = DeleteExecutorRequest(executorID: id)
        if let message = encodeMessage(type: .deleteExecutor, payload: request) {
            sendMessage(message, on: connection)
        }
    }
    
    func modifyExecutor(executor: ExecutorModel) {
        guard let connection = connection else { return }
        let request = UpdateExecutorRequest(executor: executor)
        if let message = encodeMessage(type: .updateExecutor, payload: request) {
            sendMessage(message, on: connection)
        }
    }
    
    func swapExecutors(executorID: String, pageID: String, index : Int) {
        guard let connection = connection else { return }
        let request = SwapExecutorRequest(executorID: executorID, pageID: pageID, index: index)
        if let message = encodeMessage(type: .swapExecutor, payload: request) {
            sendMessage(message, on: connection)
        }
    }
    
    func requestAppInfos() {
        guard let connection = connection else { return }
        let request = ListAppsRequest()
        if let message = encodeMessage(type: .listApps, payload: request) {
            sendMessage(message, on: connection)
        }
    }
    
    func updateAppInfo(appInfo: AppInfoModel) {
        guard let connection = connection else {return}
        let request = UpdateAppInfoRequest(appInfo: appInfo)
        if let message = encodeMessage(type: .updateAppInfo, payload: request) {
            sendMessage(message, on: connection)
        }
    }
    
    // MARK: - Messaging Utilities
    
    // Encode a message with a specific type and payload
    private func encodeMessage<T: Codable>(type: MessageType, payload: T) -> Message? {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(payload)
            let payloadString = data.base64EncodedString()
            return Message(type: type, payload: payloadString)
        } catch {
            print("Failed to encode payload: \(error)")
            return nil
        }
    }

    
    // Send a Message over the connection
    private func sendMessage(_ message: Message, on connection: NWConnection) {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(message)
            // Convert to string and append delimiter
            if var jsonString = String(data: data, encoding: .utf8) {
                jsonString += "\n"
                if let messageData = jsonString.data(using: .utf8) {
                    connection.send(content: messageData, completion: .contentProcessed({ error in
                        if let error = error {
                            print("Send error: \(error)")
                        } else {
                            print("Sent message of type \(message.type.rawValue)")
                        }
                    }))
                }
            }
        } catch {
            print("Failed to encode message: \(error)")
        }
    }
    
    // Receive data from the connection
    private func receiveData(connection: NWConnection) {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { [weak self] data, _, isComplete, error in
            guard let self = self else { return }
            
            if let data = data, !data.isEmpty {
                print("Data received: \(data.count) bytes")
                print("Raw data: \(String(data: data, encoding: .utf8) ?? "Invalid data")")
                
                self.messageReceiver.receive(data: data) { messageData in
                    self.handleReceivedMessage(messageData)
                }
            }
            
            if let error = error {
                print("Receive error: \(error)")
                connection.cancel()
                self.connection = nil
            } else if isComplete {
                print("Connection closed by remote peer")
                connection.cancel()
                self.connection = nil
            } else {
                self.receiveData(connection: connection)
            }
        }
    }

    // Handle received messages
    private func handleReceivedMessage(_ data: Data) {
        let decoder = JSONDecoder()
        do {
            let message = try decoder.decode(Message.self, from: data)
            print("Decoded message type: \(message.type.rawValue)")
            switch message.type {
            case .pagesList:
                if let response = message.decodePayload(as: PagesListResponse.self) {
                    DispatchQueue.main.async {
                        self.pages = response.pages
                        self.currentPageID = response.pages.first?.id ?? ""
                        print("Pages list updated with \(response.pages.count) pages.")
                    }
                } else {
                    print("Failed to decode `pagesList` payload as `PagesListResponse`.")
                }
            case .shortcutsList:
                if let response = message.decodePayload(as: ShortcutsListResponse.self) {
                    DispatchQueue.main.async {
                        self.shortcuts = response.shortcuts
                        for shortcut in self.shortcuts {
                            self.actions.append(ActionModel(name: shortcut, type: .siriShortcut))
                        }
                        print("Shortcuts lsit updated with \(response.shortcuts.count) shortcuts.")
                    }
                }
            case .actionsList:
                if let response = message.decodePayload(as: ActionsListResponse.self) {
                    DispatchQueue.main.async {
                        self.requestShortcuts()
                        self.actions = response.actions
                        self.actions.append(contentsOf: coreActions)
                        print("Actions list updated with \(response.actions.count) actions.")
                    }
                }
            case .actionExecuted:
                if let response = message.decodePayload(as: ActionExecutedResponse.self) {
                    print("Action executed: \(response.success ? "Success" : "Failure")")
                }
            case .actionUpdated:
                if let response = message.decodePayload(as: ActionUpdatedResponse.self) {
                    print("Action updated: \(response.success ? "Success" : "Failure")")
                    requestActions()
                }
            case .executorUpdated:
                if let response = message.decodePayload(as: ExecutorUpdatedResponse.self) {
                    print("Action updated: \(response.success ? "Success" : "Failure")")
                    self.executorCreationModel = ExecutorModel(label:"Default Label")
                    self.requestPages()
                }
            case .actionDeleted:
                if let response = message.decodePayload(as: ActionDeletedResponse.self) {
                    print("Action deleted: \(response.success ? "Success" : "Failure")")
                }
            case .executorDeleted:
                if let response = message.decodePayload(as: ExecutorDeletedResponse.self) {
                    print("Executor deleted: \(response.success ? "Success" : "Failure") ")
                    requestPages()
                }
                
            case .executorSwapped:
                if let response = message.decodePayload(as: ExecutorSwappedResponse.self) {
                    print("Executor swapped: \(response.success ? "Success" : "Failure")")
                    requestPages()
                }
            case .focusedAppUpdated:
                if let request = message.decodePayload(as: FocusedAppUpdateRequest.self) {
                    print("Focus app updated: \(request.appInfo)")
                    self.focusedApp = request.appInfo
                }
            case .appsList:
                if let response = message.decodePayload(as: AppsListResponse.self) {
                    print("App list updated: ")
                    print(response.appInfos)
                    self.appInfos = response.appInfos
                }
            case .pageUpdated:
                if let response = message.decodePayload(as: PageUpdatedResponse.self) {
                    print("Page updated: \(response.success ? "Success" : "Failure")")
                    if response.success {
                        self.requestPages()
                    }
                }
            case .error:
                if let errorMsg = message.decodePayload(as: ErrorMessage.self) {
                    print("Error from host: \(errorMsg.message)")
                }
            default:
                print("Received unsupported message type: \(message.type.rawValue)")
            }
        } catch {
            print("Failed to decode message: \(error)")
        }
    }
}

// MARK: - Message Decoding Extensions
extension Message {
    // Decode payload into a specific type without base64 decoding
    func decodePayload<T: Codable>(as type: T.Type) -> T? {
        guard let payloadString = payload, let payloadData = Data(base64Encoded: payloadString) else {
            print("Payload is nil or invalid Base64 string.")
            return nil
        }
        let decoder = JSONDecoder()
        do {
            return try decoder.decode(T.self, from: payloadData)
        } catch {
            print("Failed to decode payload as \(T.self): \(error)")
            return nil
        }
    }

}
