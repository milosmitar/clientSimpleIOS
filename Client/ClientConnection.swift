//
//  ClientConnection.swift
//  Client
//
//  Created by tarmi on 22.11.21..
//

import Foundation
import Network

@available(macOS 10.14, *)
class ClientConnection {

    let  nwConnection: NWConnection
    let queue = DispatchQueue(label: "Client connection Q")
    var transferDataDelegate: TransferData?
    var receivedDataCount: UInt32? = nil
    var displayData = Data()

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

//    private func setupReceive() {
//        nwConnection.receive(minimumIncompleteLength: 1, maximumLength: 251993) { (data, _, isComplete, error) in
//            if let data = data, !data.isEmpty {
//                self.transferDataDelegate?.onMessageReceive(data: data)
////                let message = String(data: data, encoding: .utf8)
////                print("connection did receive, data: \(data as NSData) string: \(message ?? "-" )")
//            }
//            if isComplete {
//                self.connectionDidEnd()
//            } else if let error = error {
//                self.connectionDidFail(error: error)
//            } else {
//                self.setupReceive()
//            }
//        }
//    }
    private func setupReceive() {
        nwConnection.receive(minimumIncompleteLength: 1, maximumLength: 251993) { (data, _, isComplete, error) in
            //            var inputStream: InputStream
            if let data = data, !data.isEmpty {
                if self.receivedDataCount == nil {
                    
                    let count = data.withUnsafeBytes{
                        [UInt8](UnsafeBufferPointer(start: $0, count: 4))
                    }
                    let cutingData = data
                    let rawData = cutingData.dropFirst(4)

                    let countData = Data(bytes: count)
                    self.receivedDataCount = UInt32(bigEndian: countData.withUnsafeBytes { $0.pointee })

                    self.displayData.append(rawData)

                    if(self.receivedDataCount! > UInt32(data.count)){
                    self.receivedDataCount = self.receivedDataCount! - UInt32(cutingData.count)
                    }else{
                        self.transferDataDelegate?.onMessageReceive(data: self.displayData)
                        self.displayData = Data()
                        self.receivedDataCount = nil
                    }
                    print(rawData)

                }else if(self.receivedDataCount! > 0 && self.receivedDataCount! > UInt32(data.count)){

                    self.displayData.append(data)
                    self.receivedDataCount = self.receivedDataCount! - UInt32(data.count)
                }else{
                    self.displayData.append(data)
                    self.transferDataDelegate?.onMessageReceive(data: self.displayData)
                    self.displayData = Data()
                    self.receivedDataCount = nil
                }
                
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
        let dataLength = data.count
        
        let value: UInt32 = UInt32(dataLength)
        var finalData = withUnsafeBytes(of: value.bigEndian, Array.init)
        finalData.append(contentsOf: data)
        
        nwConnection.send(content: finalData, completion: .contentProcessed( { error in
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
