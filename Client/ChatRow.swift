//
//  ChatRow.swift
//  Client
//
//  Created by vesko on 7.12.21..
//


import SwiftUI

struct ChatRow: View{
    
    var message: Message
//    var uid : String
    
    var body: some View{
        HStack{
            if image(data: message.data) != nil{
                image(data: message.data)?.resizable()
            }else{
                textMessage(data: message.data)
            }
        }
    }
    func image(data: Data) -> Image?{
        let uiimate = UIImage(data: data)
        if(uiimate != nil){
            return Image(uiImage: uiimate!)
        }
        return nil
    }
    func textMessage(data: Data) -> Text{
        return Text(String(data: data, encoding: .utf8) ?? "")
    }
}
