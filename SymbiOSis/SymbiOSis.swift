//
//  SymbiOSis.swift
//  SymbiOSis
//
//  Created by Daniel Hall on 8/25/16.
//  Copyright © 2016 Daniel Hall. All rights reserved.
//

import Foundation
import UIKit

private protocol SymbiOSisInitializable {
    func symbiOSisInitialize()
}

protocol Initializable {
    func initialize()
}

protocol DataObserver:class {
    associatedtype ObservedDataType
    func updateWith(data:Data<ObservedDataType>)
}

class Data<DataType> {
    private var observerClosures = [(Data<DataType>)->()]()
    private var data = [DataType]()
    
    var count:Int {
        return data.count
    }
    
    var copy:[DataType] {
        return data
    }
    
    func add<Observer:DataObserver where Observer.ObservedDataType == DataType>(observer:Observer) {
        observerClosures.append({
            [weak observer](data:Data<DataType>) in
            observer?.updateWith(data: data)
        })
        observer.updateWith(data:self)
    }
    
    func set(_ newData:DataType) {
        data = [newData]
        updateObservers()
    }
    
    func set(_ newData:[DataType]) {
        data = newData
        updateObservers()
    }
    
    subscript(indexPath:IndexPath?) -> DataType? {
        return get(indexPath: indexPath)
    }
    
    private func updateObservers() {
        observerClosures.forEach{ $0(self) }
    }
    
    private func get(indexPath:IndexPath?) -> DataType? {
        if let indexPath = indexPath, indexPath.section == 0, indexPath.row < data.count {
            return data[indexPath.row]
        }
        
        return nil
    }
    
    private func get<DataType:Collection where DataType.Index == Int>(indexPath:IndexPath?) -> DataType? {
        if let indexPath = indexPath, let section = data[indexPath.section] as? [DataType], indexPath.section < data.count, indexPath.row < section.count {
            return section[indexPath.row]
        }
        return nil
    }
}

protocol DataSourceProtocol: class, Initializable {
    associatedtype DataType
    var data:Data<DataType> { get }
}

protocol BindingProtocol : class, DataObserver, Initializable {
    associatedtype DataSourceType:DataSourceProtocol
    var dataSource:DataSourceType! { get }
    var dataIndexPath:IndexPath? { get }
}


class Binding : NSObject, SymbiOSisInitializable  {
    private var bindingClosures = [(Any)->()]()
    fileprivate var _dataIndexPath:IndexPath? = IndexPath(row:0, section:0)
    func symbiOSisInitialize() {
        if let initializable = self as? Initializable {
            initializable.initialize()
        }
    }
}

class DataSource : NSObject, SymbiOSisInitializable {
    private func symbiOSisInitialize() {
        (self as? Initializable)?.initialize()
    }
}

extension BindingProtocol where Self:Binding {
    typealias ObservedDataType = DataSourceType.DataType
    
    var dataIndexPath:IndexPath? { return _dataIndexPath }
    
    func updateWith(data:Data<DataSourceType.DataType>) {
        bindingClosures.forEach{ $0(data) }
    }
    func bind<T, U>(_ dataMethod:(DataSourceType.DataType)->()->U, to outletCollection:[T], viewMethod:(T)->(U)->()) {
        bindingClosures.append({
            [unowned self] data in
            guard let data = data as? Data<DataSourceType.DataType> else { return }
            outletCollection.forEach{
                view in
                if let value = data[self.dataIndexPath] {
                    viewMethod(view)(dataMethod(value)())
                }
            }
        })
        dataSource.data.add(observer: self)
    }
}

class Responder: SymbiOSisInitializable {
    weak var viewController: UIViewController!
    
    private func symbiOSisInitialize() {
        (self as? Initializable)?.initialize()
    }
}

class SymbiOSisViewController: UIViewController, SymbiOSisInitializable {
    private lazy var topLevelObjects:[NSObject] = self.value(forKey: "topLevelObjectsToKeepAliveFromStoryboard") as? [NSObject] ?? [NSObject]()
    private var symbiOSisInitializables:[SymbiOSisInitializable] { return topLevelObjects.flatMap{ $0 as? SymbiOSisInitializable} }
    
    func symbiOSisInitialize() {
        (self as? Initializable)?.initialize()
        symbiOSisInitializables.forEach { ($0 as? Responder)?.viewController = self; $0.symbiOSisInitialize() }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        symbiOSisInitialize()
    }
}

extension UILabel {
    @nonobjc func setText(to string:String) {
        text = string
    }
}



struct Person {
    let firstName:String
    let lastName:String
    func fullName() -> String {
        return "\(firstName) \(lastName)"
    }
}

class PersonDataSource : DataSource, DataSourceProtocol {
    let data = Data<Person>()
    func initialize() {
        self.data.set(Person(firstName: "Sally", lastName: "Black"))
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.data.set(Person(firstName: "Joseph", lastName: "Schmoseph"))
        }
    }
}

class PersonBinding : Binding, BindingProtocol {
    @IBOutlet var dataSource:PersonDataSource!
    @IBOutlet var fullNameLabels:[UILabel]!
    
    func initialize() {
        bind(Person.fullName, to: fullNameLabels, viewMethod: UILabel.setText)
    }
}



