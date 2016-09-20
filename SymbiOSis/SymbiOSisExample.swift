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

// MARK: Example classes
// Gaze in wonder at how little code needs to be written to set up models and bindings in SymbiOSis; essentially no boilerplate.

struct Person {
    let firstName:String
    let lastName:String
    var fullName:String? { return firstName + " " + lastName }
}

// A base class for all outlets that expose a Person model
class PersonOutlet : ModelOutlet, ModelOutletProtocol {
    typealias ModelType = Person
}

// Person outlet subclass that initializes itself with mock data
class PersonMockDataOutlet : PersonOutlet, Initializable {
    func initialize() {
        set([Person(firstName: "Sue", lastName: "Martin"), Person(firstName: "Pete", lastName: "Samuels"), Person(firstName: "Mary", lastName: "Connor")])
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            self.set(self.models + [Person(firstName: "Les", lastName: "Tolbin"), Person(firstName: "Jacqueline", lastName: "Freese"), Person(firstName: "Robert", lastName: "Kolter")])
        }
    }
}

class PersonBinding : Binding, BindingProtocol {
    @IBOutlet var modelOutlet:PersonOutlet!
    @IBOutlet var fullNameLabels:[UILabel]?
    func setup(with model: @escaping () -> Person?) {
        bind(viewProperty: fullNameLabels.text, toModelValue: model()?.fullName)
    }
}

