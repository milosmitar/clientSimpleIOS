//
//  ContentView.swift
//  Client
//
//  Created by vesko on 19.11.21..
//

import SwiftUI

//struct ContentView: View {
//    var body: some View {
//        Text("Hello, world!")
//            .padding()
//            .onTapGesture {
//                initClient(server: "192.168.0.27", port: 9999)
//            }
//    }
//        func initClient(server: String, port: UInt16) {
//            let client = Client(host: server, port: port)
//            client.start()
//
//            client.connection.send(data: "Poruka".data(using: .utf8)!)
//            }
//
//
//}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
protocol TransferData{
    func onMessageReceive(data: Data)
    func onClientConnected(message: String)
}

struct ContentView: View , TransferData{
    func onMessageReceive(data: Data) {
        let message = Message(data: data)
        self.messages.append(message)
    }
    
    func onClientConnected(message: String) {
        
    }
    
    @State private var image = Image(systemName: "photo")
    @State private var showImagePicker = false
    @State private var inputImage: UIImage?
    @State private var messages: [Message] = []
    @State var write = ""
    @State var client: Client?
    var body: some View {
        NavigationView{
            VStack{
                ScrollView(.vertical, showsIndicators: false){
                    VStack(alignment: .center){
                        ForEach(messages, id: \.self){ message in
                            ChatRow(message: message)
                        }
                    }
                }
                HStack{
                    cameraButton
                    TextField("message...", text: $write)
                        .padding(10)
                        .background(Color(red: 233.0/255, green: 234.0/255, blue: 243.0/255))
                        .cornerRadius(25)
                    Image(systemName: "paperplane.fill").font(.system(size: 20))
                        .foregroundColor((self.write.count > 0) ? Color.blue : Color.gray).rotationEffect(.degrees(45))
                        .onTapGesture {
                            initClient()
                            sendMessage(data: self.write.data(using: .ascii) ?? Data())
                        }
                }.padding()
                
            }
            .sheet(isPresented: $showImagePicker, onDismiss: loadImage){
                ImagePicker(image: self.$inputImage)
            }
            .navigationBarItems(leading: titleBar)
//            VStack{
//                ZStack{
//                    image.resizable().scaledToFit().padding()
//                }
//                .onTapGesture {
//                    self.showImagePicker = true
//                }
//            }
//            .sheet(isPresented: $showImagePicker, onDismiss: loadImage){
//                           ImagePicker(image: self.$inputImage)
//                       }
        }
    }
//    func titleBar -> some View{
//        HStack{
////            Button(
//        }
//    }
    
    private var titleBar: some View{
        HStack{
            Button( "neki tekst")  {
            }
            //            Text(self.connectionStatus).foregroundColor((self.connectionStatus.elementsEqual("connect")) ? Color.green : Color.red)
        }
    }
    private var cameraButton: Button<Image>{
        return Button(action:{
            self.showImagePicker = true
            
        }){
            Image(systemName: "camera")
        }
    }
    private func sendMessage(data: Data){
        guard let client = client else {
            return
        }
        client.connection.send(data: data)
    }
    func loadImage(){
        guard let inputImage = inputImage else {
            return
        }
        initClient()
        image = Image(uiImage: inputImage)
        guard let data = inputImage.jpegData(compressionQuality: 0.5) else { return }
        sendMessage(data: data)
    }
    func initClient() {
        if client == nil {
            client = Client(host: Commons.SERVER_IP, port: Commons.SERVER_PORT, transferDelegate: self)
            client?.start()
        }
//        let uiimage = parent.image!.asUIImage()
//        let cgImage:CGImage = context.createCGImage(parent.image!, from:
//        cameraImage.extent)!     //cameraImage is grabbed from video frame
//        image = UIImage.init(cgImage: cgImage)
//        let data = UIImageJPEGRepresentation(image, 1.0)
      
//        client.connection.send(data: parent.image!.jpegData(compressionQuality: 0.5)!)
        }
  
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
struct ImagePicker: UIViewControllerRepresentable{
    
    @Environment(\.presentationMode) var presentationMode
    @Binding var image: UIImage?
    
    func makeCoordinator() -> Coordinator{
        Coordinator(self)
    }
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {
        
    }
    
}
class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate{
    let parent: ImagePicker
    
    init(_ parent: ImagePicker) {
        self.parent = parent
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let uiImage = info[.originalImage] as? UIImage {
            parent.image = uiImage
            guard let data = uiImage.jpegData(compressionQuality: 1.0) else{
                return
            }
//            initClient(server: "192.168.0.27", port: 9999)
        }
        parent.presentationMode.wrappedValue.dismiss()
    }
    
   
    
}
