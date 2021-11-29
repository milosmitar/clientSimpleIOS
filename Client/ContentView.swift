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
struct ContentView: View {
    @State private var image = Image(systemName: "photo")
    @State private var showImagePicker = false
    @State private var inputImage: UIImage?
    var body: some View {
        NavigationView{
            VStack{
                ZStack{
                    image.resizable().scaledToFit().padding()
                }
                .onTapGesture {
                    self.showImagePicker = true
                }
            }
            .sheet(isPresented: $showImagePicker, onDismiss: loadImage){
                ImagePicker(image: self.$inputImage)
            }
        }
    
    }
   
    func loadImage(){
        guard let inputImage = inputImage else {
            return
        }
        image = Image(uiImage: inputImage)
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
            initClient(server: "192.168.0.27", port: 9999)
        }
        parent.presentationMode.wrappedValue.dismiss()
    }
    func initClient(server: String, port: UInt16) {
        let client = Client(host: server, port: port)
        client.start()
//        let uiimage = parent.image!.asUIImage()
//        let cgImage:CGImage = context.createCGImage(parent.image!, from:
//        cameraImage.extent)!     //cameraImage is grabbed from video frame
//        image = UIImage.init(cgImage: cgImage)
//        let data = UIImageJPEGRepresentation(image, 1.0)
      
        client.connection.send(data: parent.image!.jpegData(compressionQuality: 0.000005)!)
        }
   
    
}
