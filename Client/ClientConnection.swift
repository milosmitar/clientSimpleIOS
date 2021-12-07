//
//  ClientConnection.swift
//  Client
//
//  Created by vesko on 22.11.21..
//

import Foundation
import Network

@available(macOS 10.14, *)
class ClientConnection {

    let  nwConnection: NWConnection
    let queue = DispatchQueue(label: "Client connection Q")
    var transferDataDelegate: TransferData?

    init(nwConnection: NWConnection, tranferDelegate: TransferData) {
        self.nwConnection = nwConnection
        self.transferDataDelegate = tranferDelegate
    }

    var didStopCallback: ((Error?) -> Void)? = nil

    func start() {
        print("connection will start")
        nwConnection.stateUpdateHandler = stateDidChange(to:)
        setupReceive()
        nwConnection.start(queue: queue)
    }

    private func stateDidChange(to state: NWConnection.State) {
        switch state {
        case .waiting(let error):
            connectionDidFail(error: error)
        case .ready:
            print("Client connection ready")
        case .failed(let error):
            connectionDidFail(error: error)
        default:
            break
        }
    }

    private func setupReceive() {
        nwConnection.receive(minimumIncompleteLength: 1, maximumLength: 251993) { (data, _, isComplete, error) in
            if let data = data, !data.isEmpty {
                self.transferDataDelegate?.onMessageReceive(data: data)
//                let message = String(data: data, encoding: .utf8)
//                print("connection did receive, data: \(data as NSData) string: \(message ?? "-" )")
            }
            if isComplete {
                self.connectionDidEnd()
            } else if let error = error {
                self.connectionDidFail(error: error)
            } else {
                self.setupReceive()
            }
        }
    }

    func send(data: Data) {
        /*
        var dataLength = data.count
//        var dataToSend = Data(capacity: 4)
//        var number = Data(bytes: &dataLength,
//                             count:4)
//        number.append(contentsOf: 4)
//        var countData = dataToSend.count
//
//        data.from
      
        
//        dataToSend.append(data)
        let value: Int32 = Int32(dataLength)
        let array = withUnsafeBytes(of: value.bigEndian, Array.init)
        print(array) // [255, 255, 250, 203]
        var dataOfLength: Data = Data(array)
        var rawData: Data = data
        var dataToSend: Data = dataOfLength.append(rawData)
        let byteArrayFromData: [UInt8] = [UInt8](data)
         */
        
        
//        print("-----Send data length=== \(dataLength) and full data length ===\(dataToSend.count)")
        nwConnection.send(content: data, completion: .contentProcessed( { error in
            if let error = error {
                self.connectionDidFail(error: error)
                return
            }
                print("connection did send, data: \(data as NSData)")
        }))
    }

    func stop() {
        print("connection will stop")
        stop(error: nil)
    }

    private func connectionDidFail(error: Error) {
        print("connection did fail, error: \(error)")
        self.stop(error: error)
    }

    private func connectionDidEnd() {
        print("connection did end")
        self.stop(error: nil)
    }

    private func stop(error: Error?) {
        self.nwConnection.stateUpdateHandler = nil
        self.nwConnection.cancel()
        if let didStopCallback = self.didStopCallback {
            self.didStopCallback = nil
            didStopCallback(error)
        }
    }
    func byteArray<T>(from value: T) -> [UInt8] where T: FixedWidthInteger {
        withUnsafeBytes(of: value.bigEndian, Array.init)
    }
}
