//
//  Message.swift
//  Client
//
//  Created by vesko on 1.12.21..
//

import Foundation

struct Message: Hashable{
    var id = UUID()
    var data : Data
}
