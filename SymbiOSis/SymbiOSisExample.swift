//
//  AppDelegate.swift
//  SymbiOSis
//
//  Created by Daniel Hall on 8/25/16.
//  Copyright © 2016 Daniel Hall. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
}

// MARK: Test classes. Gaze in wonder at how little code needs to be written to set up view models and bindings in SymbiOSis; essentially no boilerplate.

struct Person {
    let firstName:String
    let lastName:String
    var fullName:String? { return firstName + " " + lastName }
}

class PersonSource : ViewModelSource, ViewModelSourceProtocol {
    typealias ViewModelType = Person
    func initialize() {
        set(Person(firstName: "Pete", lastName: "Samuels"))
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.set(Person(firstName: "Sue", lastName: "Martin"))
        }
    }
}

class PersonBinding : Binding, BindingProtocol {
    @IBOutlet var source:PersonSource!
    @IBOutlet var fullNameLabels:[UILabel]?
    
    func initialize(with viewModel: () -> Person) {
        bind(viewModel().fullName, to: fullNameLabels.text)
    }
}

