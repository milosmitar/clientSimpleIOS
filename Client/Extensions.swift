//
//  Extensions.swift
//  Client
//
//  Created by tarmi on 23.11.21..
//

import Foundation
import UIKit
import SwiftUI

extension View {
// This function changes our View to UIView, then calls another function
// to convert the newly-made UIView to a UIImage.
    public func asUIImage() -> UIImage {
        let controller = UIHostingController(rootView: self)
        
        controller.view.frame = CGRect(x: 0, y: CGFloat(Int.max), width: 1, height: 1)
        UIApplication.shared.windows.first!.rootViewController?.view.addSubview(controller.view)
        
        let size = controller.sizeThatFits(in: UIScreen.main.bounds.size)
        controller.view.bounds = CGRect(origin: .zero, size: size)
        controller.view.sizeToFit()
        
// here is the call to the function that converts UIView to UIImage: `.asUIImage()`
        let image = controller.view.asUIImage()
        controller.view.removeFromSuperview()
        return image
    }
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners) )
    }
}

extension UIView {
// This is the function to convert UIView to UIImage
    public func asUIImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}
struct RoundedCorner: Shape {

    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
extension Data {

    /// Creates an Data instance based on a hex string (example: "ffff" would be <FF FF>).
    ///
    /// - parameter hex: The hex string without any spaces; should only have [0-9A-Fa-f].
    init?(hex: String) {
        if hex.count % 2 != 0 {
            return nil
        }

        let hexArray = Array(hex)
        var bytes: [UInt8] = []

        for index in stride(from: 0, to: hexArray.count, by: 2) {
            guard let byte = UInt8("\(hexArray[index])\(hexArray[index + 1])", radix: 16) else {
                return nil
            }

            bytes.append(byte)
        }

        self.init(bytes: bytes, count: bytes.count)
    }

    /// Gets one byte from the given index.
    ///
    /// - parameter index: The index of the byte to be retrieved. Note that this should never be >= length.
    ///
    /// - returns: The byte located at position `index`.
    func getByte(at index: Int) -> Int8 {
        let data: Int8 = self.subdata(in: index ..< (index + 1)).withUnsafeBytes { rawPointer in
            rawPointer.bindMemory(to: Int8.self).baseAddress!.pointee
        }

        return data
    }

    /// Gets an unsigned int (32 bits => 4 bytes) from the given index.
    ///
    /// - parameter index: The index of the uint to be retrieved. Note that this should never be >= length -
    ///                    3.
    ///
    /// - returns: The unsigned int located at position `index`.
    func getUnsignedInteger(at index: Int, bigEndian: Bool = true) -> UInt32 {
        let data: UInt32 =  self.subdata(in: index ..< (index + 4)).withUnsafeBytes { rawPointer in
            rawPointer.bindMemory(to: UInt32.self).baseAddress!.pointee
        }

        return bigEndian ? data.bigEndian : data.littleEndian
    }

    /// Gets an unsigned long integer (64 bits => 8 bytes) from the given index.
    ///
    /// - parameter index: The index of the ulong to be retrieved. Note that this should never be >= length -
    ///                    7.
    ///
    /// - returns: The unsigned long integer located at position `index`.
    func getUnsignedLong(at index: Int, bigEndian: Bool = true) -> UInt64 {
        let data: UInt64 = self.subdata(in: index ..< (index + 8)).withUnsafeBytes { rawPointer in
            rawPointer.bindMemory(to: UInt64.self).baseAddress!.pointee
        }

        return bigEndian ? data.bigEndian : data.littleEndian
    }

    /// Appends the given byte (8 bits) into the receiver Data.
    ///
    /// - parameter data: The byte to be appended.
    mutating func append(byte data: Int8) {
        var data = data
        self.append(Data(bytes: &data, count: MemoryLayout<Int8>.size))
    }

    /// Appends the given unsigned integer (32 bits; 4 bytes) into the receiver Data.
    ///
    /// - parameter data: The unsigned integer to be appended.
    mutating func append(unsignedInteger data: UInt32, bigEndian: Bool = true) {
        var data = bigEndian ? data.bigEndian : data.littleEndian
        self.append(Data(bytes: &data, count: MemoryLayout<UInt32>.size))
    }

    /// Appends the given unsigned long (64 bits; 8 bytes) into the receiver Data.
    ///
    /// - parameter data: The unsigned long to be appended.
    mutating func append(unsignedLong data: UInt64, bigEndian: Bool = true) {
        var data = bigEndian ? data.bigEndian : data.littleEndian
        self.append(Data(bytes: &data, count: MemoryLayout<UInt64>.size))
    }
}
