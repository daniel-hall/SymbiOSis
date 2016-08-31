//
//  SymbiOSis.swift
//  SymbiOSis
//
//  Created by Daniel Hall on 8/25/16.
//  Copyright © 2016 Daniel Hall. All rights reserved.
//

import Foundation
import UIKit

protocol SymbiOSisInitializable {
    func symbiOSisInitialize()
}

protocol Initializable {
    func initialize()
}


/// Protocol adopted by classes wanting to be notified when a View Model Source is updated
protocol ViewModelSourceObserver:class {
    func viewModelSourceDidUpdate(source:Any)
}

/// Protocol defining a View Model Source, a type which retrieves and holds one or an array of View Models for Bindings to connect to Views
protocol ViewModelSourceProtocol: class, Initializable {
    associatedtype ViewModelType
    func set(_ viewModel:ViewModelType)
    func set(_ viewModels:[ViewModelType])
    func add<Observer:ViewModelSourceObserver>(observer:Observer)
    subscript(indexPath:IndexPath?) -> ViewModelType? { get }
}

/// Base class for all View Model Sources.  Must inherit from NSObject to be used in Storyboards
class ViewModelSource : NSObject, SymbiOSisInitializable {
    private var _observerClosures = [()->()]()
    private var _contents:Any?
    func symbiOSisInitialize() {
        (self as? Initializable)?.initialize()
    }
}

// Default behaviors and implementations for View Model Sources
extension ViewModelSourceProtocol where Self:ViewModelSource {
    
    private var contents:[ViewModelType] {
        _contents = _contents ?? [ViewModelType]()
        return _contents as! [ViewModelType]
    }
    
    func set(_ viewModel:ViewModelType) {
        _contents = [viewModel]
        updateObservers()
    }
    
    func set(_ viewModels:[ViewModelType]) {
        _contents = viewModels
        updateObservers()
    }
    
    func add<Observer:ViewModelSourceObserver>(observer:Observer) {
        _observerClosures.append({ [weak observer, unowned self] in observer?.viewModelSourceDidUpdate(source: self) })
        observer.viewModelSourceDidUpdate(source: self)
    }
    
    subscript(indexPath:IndexPath?) -> ViewModelType? {
        return get(indexPath: indexPath)
    }
    
    private func updateObservers() {
        _observerClosures.forEach{ $0() }
    }
    
    private func get(indexPath:IndexPath?) -> ViewModelType? {
        if let indexPath = indexPath, indexPath.section == 0, indexPath.row < contents.count {
            return contents[indexPath.row]
        }
        
        return nil
    }
    
    private func get<ViewModelType:Collection where ViewModelType.Index == Int>(indexPath:IndexPath?) -> ViewModelType? {
        if let indexPath = indexPath, let section = contents[indexPath.section] as? [ViewModelType], indexPath.section < contents.count, indexPath.row < section.count {
            return section[indexPath.row]
        }
        return nil
    }
}

/// Protocol for Bindings, which are types that set properties on Views to match values on View Models.
protocol BindingProtocol : class, ViewModelSourceObserver, Initializable {
    associatedtype ViewModelSourceType:ViewModelSourceProtocol
    var source:ViewModelSourceType! { get set }
    /// Initializes the Binding by passing it a closure which will supply the View Model at runtime. The result of calling viewModel() can be used with the bind function inside this method.
    func initialize(with viewModel:()->ViewModelSourceType.ViewModelType)
}

/// Base class for Bindings.  Must inherit from NSObject to be used in Storyboards, must inherit from UIView to be added to prototype cells in Table Views and Collection Views
class Binding : UIView, SymbiOSisInitializable  {
    private var _bindingClosures = [()->()]()
    fileprivate var indexPath:IndexPath? = IndexPath(row:0, section:0)
    func symbiOSisInitialize() {
        (self as? Initializable)?.initialize()
    }
}

// Default behaviors and implementations for Binding types
extension BindingProtocol where Self:Binding {
    
    func initialize() {
        let viewModelClosure = { [unowned self] in self.source[self.indexPath]! }
        initialize(with: viewModelClosure)
    }
    
    func viewModelSourceDidUpdate(source:Any) {
        _bindingClosures.forEach{ $0() }
    }

    func bind<T>(_ value:@autoclosure(escaping) ()->T?, to property:@escaping (T)->()) {
        _bindingClosures.append({ if let value = value() { property(value) } })
        source.add(observer:self)
    }
    
    func bind<T>(_ value:@autoclosure(escaping) ()->T?, to property:@escaping (T?)->()) {
        _bindingClosures.append({ property(value()) })
        source.add(observer:self)
    }
}

/// Base class for Responders, which are types that contain a single behavior that runs in response to user interaction, size changes, segues, or other events.
class Responder: SymbiOSisInitializable {
    weak var viewController: UIViewController!
    func symbiOSisInitialize() {
        (self as? Initializable)?.initialize()
    }
}

// Makes all UIViewControllers interact with SymbiOSis types
extension UIViewController {
    private var topLevelObjects:[NSObject] { return self.value(forKey: "topLevelObjectsToKeepAliveFromStoryboard") as? [NSObject] ?? [NSObject]() }
    private var symbiOSisInitializables:[SymbiOSisInitializable] { return topLevelObjects.flatMap{ $0 as? SymbiOSisInitializable} }
    
    private class func swizzle(_ original: Selector, _ replacement: Selector) {
        let originalImplementation = class_getInstanceMethod(self, original)
        let replacementImplementation = class_getInstanceMethod(self, replacement)
        method_exchangeImplementations(originalImplementation, replacementImplementation)
    }
    
    override public class func initialize() {
        if self == UIViewController.self {
            swizzle(#selector(viewDidLoad), #selector(symbiOSisViewDidLoad))
            swizzle(#selector(prepare(for:sender:)), #selector(symbiOSisPrepare(for:sender:)))
        }
    }
    
    func symbiOSisInitialize() {
        (self as? Initializable)?.initialize()
        symbiOSisInitializables.forEach { ($0 as? Responder)?.viewController = self; $0.symbiOSisInitialize() }
    }
    
    func symbiOSisViewDidLoad() {
        symbiOSisViewDidLoad()
        symbiOSisInitialize()
    }
    
    func symbiOSisPrepare(for segue:UIStoryboardSegue, sender:AnyObject?) {
        print("Doing symbiOSisPrepareForSegue")
    }
}

// Adds a closure to all optional collections of UILabels to set the text property on all of those labels.  Used by Bindings.
extension Optional where Wrapped:Collection, Wrapped.Iterator.Element == UILabel {
    var text:(String?)->() {
        return {
            string in
            if let collection = self as? [UILabel] {
                collection.forEach { $0.text = string}
            }
        }
    }
}
