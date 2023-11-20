//
//  ContentView.swift
//  SwiftUILearn
//
//  Created by Mayank Dubey on 17/10/23.
//

import SwiftUI
import RCHousing


public protocol HousingAppDelegate: AnyObject {
    func LaunchMethod()
}

public class MyEdgeFrameworkClass {
    public init() {}
    public weak var delegate: HousingAppDelegate?
    public func doSomething() {
        delegate?.LaunchMethod()
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
    
     public var body: some View {
         VStack {
             Button(action: {myEdgeFrameworkInstance.doSomething()}) {
               Text("Border Button")
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
                     var header = ["Content-Type":"application/json",
                                   "User-Agent":"Native/ios",
                                   "app_name":Bundle.main.bundleIdentifier ?? "",
                                   "app_version": "\(version) (\(buildNo))",
                                   //                      "js_bundle_version": "",
                                   "client_id": UIDevice.current.identifierForVendor?.uuidString ?? ""]
                     
                     return header
                 }
             }
             
             var apiFailureInterceptor : (_ apiFailureResponse : Any?,_ statusCode : Int, _ isErrorHandlingBeingDoneByClient: Bool, _ urlRequest : URLRequest?) -> () = { apiFailureResponse, statusCode, isErrorHandlingBeingDoneByClient, urlRequest in
             }
             
             var networkAndOtherErrorIntercepter : ((DataTransferError, Bool, URLRequest?) -> ()) = { error, isErrorHandlingBeingDoneByClient, urlRequest in
                 var message = ""
             }
             
             var apiDataTransferService: DataTransferService = {
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
            //  Text("Hello, World!")
            //  Text("Hello, World!")
            //  Text("Hello, World!")
            //  Text("Hello, World! Edge")
         }
    }
}

//#Preview {
//    Content()
//}
