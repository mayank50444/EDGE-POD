//
//  ContentView.swift
//  SwiftUILearn
//
//  Created by Mayank Dubey on 17/10/23.
//

import SwiftUI


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
