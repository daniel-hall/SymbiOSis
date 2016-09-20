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

protocol BindingModelProvider {
    func prepareModelForBinding()
    func updateBindingsFromModel()
}

protocol Initializable {
    func initialize()
}


/// Protocol adopted by classes wanting to be notified when a Model Outlet is updated
protocol ModelOutletObserver:class {
    func modelOutletDidUpdate(modelOutlet:Any)
}


/// Protocol defining a Model Outlet, a type which retrieves and holds one or an array of Models for Bindings to connect to Views
protocol ModelOutletProtocol: class, TypeEraseableModelOutlet {
    associatedtype ModelType
    var models:[ModelType] { get }
    func set(_ model:ModelType)
    func set(_ models:[ModelType])
    subscript(indexPath:IndexPath?) -> ModelType? { get }
}

// Protocol that exposes a type-erased Model Outlet (AnyModelOutlet) from a Model Outlet that has an associated type.
protocol TypeEraseableModelOutlet {
    var typeErased:AnyModelOutlet { get }
}

/// Base class for all Model Outlets.  Must inherit from NSObject to be used in Storyboards
class ModelOutlet : NSObject, SymbiOSisInitializable {
    fileprivate var _observerClosures = [()->()]()
    fileprivate var _existingObserverClosures = [(AnyObject)->Bool]()
    fileprivate var _contents:Any?
    func symbiOSisInitialize() {
        (self as? Initializable)?.initialize()
    }
}

// A type-erased Model Outlet that has no specific associated type or generic requirements. This allows it to be set, observed, and copied anywhere. Setting model data here only propogates back to the underlying Model Outlet if the type of the models passed in matches the Model Type of the underlying Model Outlet
class AnyModelOutlet {
    
    private let modelOutlet:ModelOutlet
    private let setModelClosure:([Any])->()
    private var contents : [Any] {
        return modelOutlet._contents as! [Any]
    }
    
    init<T:ModelOutlet, U>(modelOutlet:T) where T:ModelOutletProtocol, U == T.ModelType {
        self.modelOutlet = modelOutlet
        setModelClosure = { if let matchingData = $0 as? [U] { modelOutlet.set(matchingData) } }
    }

    var copy:[Any] {
        return modelOutlet._contents as? [Any] ?? [Any]()
    }
    
    func set(_ models:[Any]) {
        setModelClosure(models)
    }
    
    func add<Observer:ModelOutletObserver>(observer:Observer) {
        var alreadyObserving = false
        modelOutlet._existingObserverClosures.forEach { alreadyObserving = $0(observer) ? true : alreadyObserving }
        if alreadyObserving { return }
        modelOutlet._existingObserverClosures.append( { [weak observer] in $0 === observer} )
        modelOutlet._observerClosures.append({ [weak observer, weak modelOutlet] in observer?.modelOutletDidUpdate(modelOutlet: modelOutlet) })
        observer.modelOutletDidUpdate(modelOutlet: modelOutlet)
    }
    
    func remove<Observer:ModelOutletObserver>(observer:Observer) {
        let existing = modelOutlet._existingObserverClosures.enumerated().filter { $0.element(observer) }
        existing.forEach { _ = modelOutlet._existingObserverClosures.remove(at: $0.offset); _ = modelOutlet._observerClosures.remove(at: $0.offset) }
    }
    
    subscript(indexPath:IndexPath?) -> Any? {
        return get(indexPath: indexPath)
    }
    
    private func get(indexPath:IndexPath?) -> Any? {
        if let indexPath = indexPath, indexPath.section == 0, indexPath.row < contents.count {
            return contents[indexPath.row]
        }
        return nil
    }
    
    private func get<ModelType:Collection>(indexPath:IndexPath?) -> ModelType? where ModelType.Index == Int {
        if let indexPath = indexPath, let section = contents[indexPath.section] as? [ModelType], indexPath.section < contents.count, indexPath.row < section.count {
            return section[indexPath.row]
        }
        return nil
    }
}

// A protocol adopted by any sender that can trigger a segue and wants to provide a modelOutlet whose data should be pushed through that segue
protocol SegueModelOutletProvider {
    var modelOutletForSegue:AnyModelOutlet? { get }
}

// A further refinement of the SegueModelOutletProvider protocol that allows the sender to specify that only the model at a specific index path inside the Model Outlet's should be pushed throuh the segue
protocol IndexedSegueModelOutletProvider : SegueModelOutletProvider {
    var modelOutletIndexPathForSegue: NSRange? { get }
}


// Default behaviors and implementations for Model Outlets
extension ModelOutletProtocol where Self:ModelOutlet {
    
    fileprivate var contents:[ModelType] {
        _contents = _contents ?? [ModelType]()
        return _contents as! [ModelType]
    }
    
    var models:[ModelType] {
        return contents
    }
    
    var typeErased: AnyModelOutlet {
        return AnyModelOutlet(modelOutlet: self)
    }
    
    func set(_ model:ModelType) {
        _contents = [model]
        updateObservers()
    }
    
    func set(_ models:[ModelType]) {
        _contents = models
        updateObservers()
    }
    
    subscript(indexPath:IndexPath?) -> ModelType? {
        return get(indexPath: indexPath)
    }
    
    private func updateObservers() {
        _observerClosures.forEach{ $0() }
    }
    
    private func get(indexPath:IndexPath?) -> ModelType? {
        if let indexPath = indexPath, indexPath.section == 0, indexPath.row < contents.count {
            return contents[indexPath.row]
        }
        
        return nil
    }
    
    private func get<ModelType:Collection>(indexPath:IndexPath?) -> ModelType? where ModelType.Index == Int {
        if let indexPath = indexPath, let section = contents[indexPath.section] as? [ModelType], indexPath.section < contents.count, indexPath.row < section.count {
            return section[indexPath.row]
        }
        return nil
    }
}

/// Protocol for Bindings, which are types that set properties on Views to match values on Models.
protocol BindingProtocol : class, ModelOutletObserver, BindingModelProvider, TypeEraseableBinding {
    associatedtype ModelOutletType:ModelOutletProtocol
    var modelOutlet:ModelOutletType! { get set }
    
    /// Passes the Binding a closure which will supply the Model at runtime. The result of calling model() can be used with the bind function inside this method.
    func setup(with model:@escaping ()->ModelOutletType.ModelType?)
}

// Protocol that exposes a type-erased Binding (AnyBinding) from a Binding that has an associated type.
protocol TypeEraseableBinding {
    var typeErased:AnyBinding { get }
}

// A type-erased Binding that has no specific associated type or generic requirements. This allows the Model Outlet its referencing to be retrieved without knowing its specific type
class AnyBinding {
    
    private let binding:Binding
    private let modelOutletClosure:()->AnyModelOutlet?
    
    var modelOutlet:AnyModelOutlet? {
        return modelOutletClosure()
    }
    
    init<T:BindingProtocol>(binding:T) where T:Binding {
        self.binding = binding
        self.modelOutletClosure = { [weak binding] in binding?.modelOutlet.typeErased }
    }
}

/// Base class for Bindings.  Must inherit from NSObject to be used in Storyboards, must inherit from UIView to be added to prototype cells in Table Views and Collection Views
@IBDesignable class Binding : UIView, SymbiOSisInitializable  {
    fileprivate var _bindingClosures = [()->()]()
    fileprivate var _symbiOSisInitialized = false
    fileprivate var indexPath:IndexPath? = IndexPath(row:0, section:0) {
        didSet {
            (self as? BindingModelProvider)?.updateBindingsFromModel()
        }
    }
     func symbiOSisInitialize() {
        frame = CGRect.zero.offsetBy(dx: -9999, dy: -9999)
        isHidden = true
        (self as? BindingModelProvider)?.prepareModelForBinding()
        if _symbiOSisInitialized { return }
        (self as? Initializable)?.initialize()
    }
    override func prepareForInterfaceBuilder() {
        backgroundColor = UIColor.blue
    }
}

// Default behaviors and implementations for Binding types
extension BindingProtocol where Self:Binding {
    
    var typeErased: AnyBinding {
        return AnyBinding(binding: self)
    }
    
    func prepareModelForBinding() {
        let modelClosure = { [unowned self] in self.modelOutlet[self.indexPath] }
        (modelOutlet as? AnyModelOutlet)?.remove(observer: self)
        setup(with: modelClosure)
    }
    
    func updateBindingsFromModel() {
        _bindingClosures.forEach{ $0() }
    }
    
    func modelOutletDidUpdate(modelOutlet:Any) {
        _bindingClosures.forEach{ $0() }
    }

    func bind<T>(viewProperty property:@escaping (T)->(), toModelValue value:@autoclosure @escaping ()->T?) {
        _bindingClosures.append({ if let value = value() { property(value) } })
        modelOutlet.typeErased.add(observer:self)
    }
    
    func bind<T>(viewProperty property:@escaping (T?)->(), toModelValue value:@autoclosure @escaping ()->T?) {
        _bindingClosures.append({ property(value()) })
        modelOutlet.typeErased.add(observer:self)
    }
}

/// Base class for Responders, which are types that contain a single behavior that runs in response to user interaction, size changes, segues, or other events.
class Responder: NSObject, SymbiOSisInitializable {
    weak var viewController: UIViewController!
    func symbiOSisInitialize() {
        (self as? Initializable)?.initialize()
    }
}


// MARK: - UIKit Extensions =

// Makes all UIViewControllers interact with SymbiOSis types
extension UIViewController {
    private var topLevelObjects:[NSObject] { return self.value(forKey: "topLevelObjectsToKeepAliveFromStoryboard") as? [NSObject] ?? [NSObject]() }
    private var symbiOSisInitializables:[SymbiOSisInitializable] { return topLevelObjects.flatMap{ $0 as? SymbiOSisInitializable} }
    private var initializedAssociationKey:UInt8 { get { return 0} set { } }
    private var symbiOSisInitialized : Bool {
        get {
            return objc_getAssociatedObject(self, &initializedAssociationKey) as? Bool ?? false
        }
        set {
            objc_setAssociatedObject(self, &initializedAssociationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private class func swizzle(_ original: Selector, _ replacement: Selector) {
        let originalImplementation = class_getInstanceMethod(self, original)
        let replacementImplementation = class_getInstanceMethod(self, replacement)
        method_exchangeImplementations(originalImplementation, replacementImplementation)
    }
    
    override open class func initialize() {
        if self == UIViewController.self {
            swizzle(#selector(viewDidLoad), #selector(symbiOSisViewDidLoad))
            swizzle(#selector(prepare(for:sender:)), #selector(symbiOSisPrepare(for:sender:)))
            swizzle(#selector(shouldPerformSegue(withIdentifier:sender:)), #selector(symbiOSisShouldPerformSegue(withIdentifier:sender:)))
        }
    }
    
    func symbiOSisInitialize() {
        guard !symbiOSisInitialized else { return }
        symbiOSisInitialized = true
        (self as? Initializable)?.initialize()
        symbiOSisInitializables.forEach { ($0 as? Responder)?.viewController = self; $0.symbiOSisInitialize() }
    }
    
    private dynamic func symbiOSisViewDidLoad() {
        symbiOSisViewDidLoad()
        symbiOSisInitialize()
    }
    
    private dynamic func symbiOSisShouldPerformSegue(withIdentifier:String, sender:AnyObject?) {
        // TODO: Check with any SegueResponders
        symbiOSisShouldPerformSegue(withIdentifier:withIdentifier, sender:sender)
    }
    
    // When a segue runs, check if the sender that triggered it has an associated Model Outlet, and if so, retrieve that model data and set it on any matching Model Outlets in the destination
    private dynamic func symbiOSisPrepare(for segue:UIStoryboardSegue, sender:AnyObject?) {
        // TODO: Alert any SegueResponders
        symbiOSisPrepare(for: segue, sender: sender)
        if let sender = sender as? SegueModelOutletProvider  {
            segue.destination.loadViewIfNeeded()
            segue.destination.setModelOutlets(from: sender.modelOutletForSegue, usingIndexPath: (sender as? IndexedSegueModelOutletProvider)?.modelOutletIndexPathForSegue?.indexPath)
        }
    }
    
    private func setModelOutlets(from modelOutlet:AnyModelOutlet?, usingIndexPath:IndexPath?) {
        guard let modelOutlet = modelOutlet else { return }
        if let indexPath = usingIndexPath {
            symbiOSisInitializables.forEach { ($0 as? TypeEraseableModelOutlet)?.typeErased.set([modelOutlet[indexPath]]) }
            return
        }
        symbiOSisInitializables.forEach { ($0 as? TypeEraseableModelOutlet)?.typeErased.set(modelOutlet.copy) }
    }
}


/// Protocol that allows an instance to provide custom logic for what cell should be dequeued for a specific index path associated with specific model data
protocol UITableViewCellForRowDelegate {
    func tableView(_:UITableView, cellForRowAt indexPath:IndexPath, with data:Any?) -> UITableViewCell
}

/// A default responder used by TableViewBinding to dequeue a cell for a specific index path. This default implementation first checks to see if its view controller conforms to UITableViewCellForRowDelegate and thus wants to specify which cell is dequeued, and it not, it just gets the first registered reuse identifier and uses that to dequeue a cell
class CellForRowResponder: Responder, UITableViewCellForRowDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath, with data: Any?) -> UITableViewCell {
        if let delegate = viewController as? UITableViewCellForRowDelegate {
            return delegate.tableView(tableView, cellForRowAt: indexPath, with: data)
        }
        guard let identifier = (tableView.value(forKey: "nibMap") as? Dictionary<NSString, NSObject>)?.keys.first as? String else {
            fatalError("There are no prototype cells created for the SymbiOSis TableViewBinding to retrieve from the UITableView. Please make sure there is a prototype cell and that you have given it a reuse identifer")
        }
        return tableView.dequeReusableCell(withIdentifier: identifier, indexPath: indexPath)
    }
}

/// Serves as a UITableViewDataSource and UITableViwDelegate for any UITableView, using the connected Model Outlet as the source of data.
class TableViewBinding : Binding, ModelOutletObserver, UITableViewDataSource {
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var modelOutlet: ModelOutlet!
    @IBOutlet private var cellForRowResponder:CellForRowResponder! = CellForRowResponder()
    
    override func symbiOSisInitialize() {
        super.symbiOSisInitialize()
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.dataSource = self
        (modelOutlet as? TypeEraseableModelOutlet)?.typeErased.add(observer: self)
    }
    
    func modelOutletDidUpdate(modelOutlet: Any) {
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (modelOutlet as? TypeEraseableModelOutlet)?.typeErased.copy.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cellForRowResponder.tableView(tableView, cellForRowAt: indexPath, with: (modelOutlet as? TypeEraseableModelOutlet)?.typeErased.copy[indexPath.row])
    }
}


/// Implements UITableViewCells as SegueModelOutletProviders, so when a segue is triggered by the cell, the model data that populated that cell is pushed through the segue
extension UITableViewCell : IndexedSegueModelOutletProvider {
    var modelOutletIndexPathForSegue: NSRange? { return indexPath?.range }
    var modelOutletForSegue: AnyModelOutlet? { return (allBindings.first as? TypeEraseableBinding)?.typeErased.modelOutlet }
}

/// Adds logic to UITableViewCells so that they pass their index path down to any child Bindings, so those bindings can get the right model from the Model Outlet based on their row
extension UITableViewCell {
    var indexPath:IndexPath? {
        get { return allBindings.first?.indexPath }
        set { allBindings.forEach{ $0.symbiOSisInitialize(); $0.indexPath = newValue } }
    }
    
    fileprivate var allBindings:[Binding]{
        return bindingsOf(view: contentView)
    }
    
    private func bindingsOf(view:UIView) -> [Binding] {
        var result = [Binding]()
        view.subviews.forEach{ result += bindingsOf(view: $0) }
        if let binding = view as? Binding {
            result.append(binding)
        }
        return result
    }
}

/// Sends UITableViewCells their current index path, so they can forward it onto any bindings they contain
private extension UITableView {
    func dequeReusableCell(withIdentifier identifier:String, indexPath:IndexPath) -> UITableViewCell {
        let cell = self.dequeueReusableCell(withIdentifier:identifier, for: indexPath)
        cell.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.estimatedRowHeight)
        cell.contentView.frame = cell.frame
        cell.layoutIfNeeded()
        cell.indexPath = indexPath
        cell.setNeedsLayout()
        return cell
    }
}

// These extensions map NSRanges to IndexPaths, so IndexPaths can be set easily in IBInspectable properties as a range (which looks like IndexPath notation), and then converted to a real IndexPath

private extension NSRange {
    var indexPath:IndexPath {
        return IndexPath(row: self.length, section: self.location)
    }
}

private extension IndexPath {
    var range:NSRange {
        return NSRange(location: section, length: row)
    }
}


// MARK - View Property extensions. These extensions allow bindings to set properties on a whole collection of a specific UIView type using a single setter.

// Adds a closure to all optional collections of UILabels to set the text property on all of those labels.  Used by Bindings.
extension Optional where Wrapped:Collection, Wrapped.Iterator.Element == UILabel {
    var text:(String?)->() {
        return {
            string in
            if let collection = self as? [UILabel] {
                collection.forEach { $0.text = string; $0.setNeedsLayout() }
            }
        }
    }
}
