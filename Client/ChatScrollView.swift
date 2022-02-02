//
//  ChatScrollView.swift
//  Client
//
//  Created by vesko on 2.2.22..
//

import SwiftUI

struct ChatScrollView: View {
    @Binding var messages: [Message]
    var body: some View {
        ScrollViewReader{ proxy in
            ScrollView(.vertical, showsIndicators: true){
                VStack(alignment: .center){
                    ForEach(messages.indices, id: \.self){ index in
                        ChatRow(message: messages[index])
                        
                    }
                }
            }.onChange(of: self.messages.count, perform: { index in
                withAnimation (.easeInOut){
                    print(index)
                    proxy.scrollTo(index - 1)
                }
            })
        }.padding(.bottom, 8)
    }
}

