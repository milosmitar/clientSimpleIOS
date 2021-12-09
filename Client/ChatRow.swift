//
//  ChatRow.swift
//  Client
//
//  Created by tarmi on 7.12.21..
//


import SwiftUI

struct ChatRow: View{
    
    var message: Message
    //    var uid : String
    
    var body: some View{
        HStack{
            if image(data: message.data) != nil{
                if !message.recived {
                    HStack {
                        Spacer()
                        image(data: message.data)?.resizable().scaledToFit().frame(width: 250, height: 200, alignment: .trailing).cornerRadius(5)
                    }.padding(.leading,75)
                    
                    //                    image(data: message.data)?.resizable().scaledToFit().frame(width: 250, height: 200, alignment: .leading)
                    //                    Spacer()
                    
                }else{
                    HStack {
                        image(data: message.data)?.resizable().scaledToFill().frame(width: 250, height: 200, alignment: .leading).cornerRadius(5)
                        Spacer()
                    }.padding(.trailing,75)
                    //                    Spacer()
                    //                    image(data: message.data)?.resizable().scaledToFit().frame(width: 250, height: 200, alignment: .trailing)
                }
            }else{
                if !message.recived {
                    HStack {
                        Spacer()
                        textMessage(data: message.data)
                            .modifier(chatModifier(myMessage: true))
                    }.padding(.leading,75)
                }else{
                    HStack {
                        textMessage(data: message.data)
                            .modifier(chatModifier(myMessage: false))
                        Spacer()
                    }.padding(.trailing,75)
                    //                    Spacer()
                    //                    textMessage(data: message.data)
                }
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
struct chatModifier : ViewModifier{
    var myMessage : Bool
    func body(content: Content) -> some View {
        content
            .padding(10)
            .background(myMessage ? Color.blue : .red)
            .cornerRadius(7)
            .foregroundColor(Color.white)
    }
}
