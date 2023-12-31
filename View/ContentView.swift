//
//  ContentView.swift
//  SwiftUILearn
//
//  Created by Mayank Dubey on 17/10/23.
//

import SwiftUI
import RCHousing

public protocol HousingAppDelegate: AnyObject {
    func LaunchMethod(msg: String)
}

public class MyEdgeFrameworkClass {
    public init() {}
    public weak var delegate: HousingAppDelegate?
    public func doSomething() {
        delegate?.LaunchMethod(msg: "I am called from Swift UI screen")
    }
}


struct QnATagsModel: Codable {
    private var data: [QnATagsDatum]?
    
    var sortedTags: [QnATagsDatum]? {
        var index = 0
        var tags = data
        for tag in (tags ?? []) {
            if tag.name == "others" {
                break
            }
            index += 1
        }
        if let tag = tags?.remove(at: index) {
            tags?.append(tag)
        }
        
        return tags
    }
}

// MARK: - QnATagsDatum
struct QnATagsDatum: Codable, Hashable {
    var id: Int?
    var name, displayName: String?
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name
        case displayName = "display_name"
    }
}

public struct Content: View {
    public var myEdgeFrameworkInstance: MyEdgeFrameworkClass
    public init(myEdgeFrameworkInstance: MyEdgeFrameworkClass) {
        self.myEdgeFrameworkInstance = myEdgeFrameworkInstance
    }
    @Environment(\.presentationMode) var presentationMode
    @State private var isLinkActive = false
    public var body: some View {
        NavigationView {
            VStack {
                Button(action: {myEdgeFrameworkInstance.doSomething()}) {
                    Text("Open Filetrs Screen")
                        .padding()
                        .border(.blue)
                }
                
                let endPoint = Endpoint<QnATagsModel>(path: "odin/data/api/v1/master-tags",
                                                      method: .get,
                                                      domain: "odin")
                
                var apiDataNetworkConfig : ApiDataNetworkConfig?
                
                var globalHeaders : [String:String] {
                    get {
                        let version = (Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "")
                        let buildNo = (Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "")
                        let header = ["Content-Type":"application/json",
                                      "User-Agent":"Native/ios",
                                      "app_name":Bundle.main.bundleIdentifier ?? "",
                                      "app_version": "\(version) (\(buildNo))",
                                      //                      "js_bundle_version": "",
                                      "client_id": UIDevice.current.identifierForVendor?.uuidString ?? ""]
                        
                        return header
                    }
                }
                
                let apiFailureInterceptor : (_ apiFailureResponse : Any?,_ statusCode : Int, _ isErrorHandlingBeingDoneByClient: Bool, _ urlRequest : URLRequest?) -> () = { apiFailureResponse, statusCode, isErrorHandlingBeingDoneByClient, urlRequest in
                }
                
                let networkAndOtherErrorIntercepter : ((DataTransferError, Bool, URLRequest?) -> ()) = { error, isErrorHandlingBeingDoneByClient, urlRequest in
                    var message = ""
                }
                
                let apiDataTransferService: DataTransferService = {
                    apiDataNetworkConfig = ApiDataNetworkConfig(baseURL: URL(string: "https://housing.com")!,
                                                                headers: globalHeaders,
                                                                queryParameters: [:])
                    let apiDataNetwork = DefaultNetworkService(config: apiDataNetworkConfig!)
                    return DefaultDataTransferService(with: apiDataNetwork, apiFailureInterceptor: apiFailureInterceptor, networkAndOtherErrorIntercepter: networkAndOtherErrorIntercepter)
                }()
                
                Button {
                    Task {
                        let (data, _) = try await URLSession.shared.data(from: URL(string:"https://api.chucknorris.io/jokes/random")!)
                        apiDataTransferService.request(with: endPoint, apiSuccess: { result in
                            print(result)
                        })
                    }
                } label: {
                    Text("Fetch Joke")
                }
                
                Text("Hello, World!")
                
                Image("AC")
                
                Button("Back to UIKit") {
                    presentationMode.wrappedValue.dismiss()
                }
                
                VStack {
                    Text("click below to navigate to this same screen again")
                    Button("Navigate Again") {
                        isLinkActive.toggle()
                    }
                    NavigationLink("", destination: Content(myEdgeFrameworkInstance: myEdgeFrameworkInstance), isActive: $isLinkActive)
                        .hidden()
                }
            }
        }
    }
}

//#Preview {
//    Content()
//}
