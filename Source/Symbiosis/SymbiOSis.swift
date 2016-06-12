//
//  SymbiOSis.swift
//  SymbiOSis-Alpha
//
//  Created by Daniel Hall on 10/3/15.
//  Copyright © 2015 Daniel Hall. All rights reserved.
//

import Foundation
import UIKit


// MARK: - General SymbiOSis protocols -

// A protocol for all objects participating in SymbiOSis to get initialized at the proper time. Default implementations are provided bythe framework and shouldn't be overridden
protocol InternallyInitializable {
    func internalInitialize()
}

// A protocol for users of the framework to conform to in order to get a custom initialization point that happens right after internalInitialize()
protocol Initializable {
    func initialize()
}


// MARK: - Internal Data Classes and Protocols -

// A generic container for DataSources to hold a specific type of data in, which can be observed for changes and can provide values for specifc index paths.
class Data<DataType> {
    private var observers:[AnyDataObserver<DataType>] = [AnyDataObserver<DataType>]()
    private var data:[DataType] = [DataType]()
    
    var first:DataType? {
        get {
            return get(NSIndexPath(forRow: 0, inSection: 0))
        }
    }
    
    var count:Int {
        get {
            return self.data.count
        }
    }
    
    func add<ConcreteObserver:DataObserver where ConcreteObserver.ObservedDataType == DataType>(observer: ConcreteObserver) {
        observers.append(AnyDataObserver(observer))
        if data.count > 0 {
            observer.updateWith(self)
        }
    }
    
    func updateObservers() {
        self.observers = self.observers.filter{
            return $0.isNil == false
        }
        
        for observer in observers {
            observer.updateWith(self)
        }
    }
    
    func set(data:DataType) {
        self.data = [data]
        self.updateObservers()
    }
    
    func set(data:[DataType]) {
        self.data = data
        self.updateObservers()
    }
    
    //If the contained data is an array of arrays (2D array), then this method is used to retrieve by section and row
    func get<DataType:CollectionType where DataType.Index == Int>(index:NSIndexPath?) -> DataType.Generator.Element? {
        
        if index == nil || self.data.count <= index!.section {
            return nil
        }
        
        if let section:DataType = self.data[index!.section] as? DataType {
            if (section.count <= index!.row) {
                return section.first
            }
            return section[index!.row]
        }
        
        return nil
    }
    
    //If the contained data is a flat array, retrieve using the row value of the index path
    func get(index:NSIndexPath?) -> DataType? {
        
        if index == nil || index!.section > 0 || self.data.count <= index!.row {
            return nil
        }
        
        return self.data[index!.row]
    }
    
    func copy() -> [DataType] {
        return self.data
    }
}


// A type eraser used by Data<DataType> to store multiple types that conform to the generic DataObserver protocol in a homogenous array
private class AnyDataObserver<DataType>: DataObserver {
    
    let updateClosure:(Data<DataType>)->()
    let isNilClosure:()->Bool
    
    var isNil:Bool {
        get {
            return isNilClosure()
        }
    }
    
    init<ConcreteObserver:DataObserver where ConcreteObserver.ObservedDataType == DataType>(_ dataObserver:ConcreteObserver){
        weak var observer = dataObserver;
        self.updateClosure = {
            (data:Data<DataType>) in
            observer?.updateWith(data)
        }
        
        self.isNilClosure = {
            return observer == nil
        }
    }
    
    func updateWith(data: Data<DataType>) {
        self.updateClosure(data)
    }
}


// A protocol for any object that wants to get notified when a Data<DataType> object is updated
protocol DataObserver:class {
    associatedtype ObservedDataType
    func updateWith(data:Data<ObservedDataType>)
}


// A type eraser for Data<DataType> that can still retrieve the count (and in the future, if needed, can still retrieve values downcast to Any.  Needed for generic bindings like Table View Bindings which need to work with all data types without caring about what type they are
public struct AnyData {
    
    var count:Int {
        get {
            return countClosure()
        }
    }
    
    private var copyClosure:()->Any
    private var countClosure:()->Int
    
    
    init<DataType>(data:Data<DataType>) {
        self.countClosure = {
            return data.count
        }
        self.copyClosure = {
            return data.copy()
        }
    }
    
    func copy()-> Any {
        return self.copyClosure()
    }
}


// An observer of type erased data
protocol GenericDataObserver:class {
    func updateWith(data:AnyData)
}


// Act as a typed data observer, erase the type of the observed data, and pass it on to an untyped observer
private class GenericDataObserverConverter <DataType> : DataObserver {
    
    private var updateClosure:(Data<DataType>)->()
    
    func updateWith(data: Data<DataType>) {
        self.updateClosure(data)
    }
    
    init(data:Data<DataType>, observer:GenericDataObserver) {
        weak var weakObserver = observer
        self.updateClosure = {
            if let genericObserver = weakObserver {
                genericObserver.updateWith(AnyData(data: $0))
            }
        }
        data.add(self)
    }
}


// MARK: - Data Source Protocols and Classes -

// Base class for all SymbiOSis data sources. Responsible for retrieving, filtering and pushing data through to bindings and sometimes other data sources.
class DataSource : NSObject {
    // Does this data source allow itself to be injected with data from the previous view controller via segue?
    @IBInspectable var segueCanSet:Bool = true
    private var genericObservers = [AnyObject]()
    private var _initialized = false
}


// Type defining / constraining protocol that must be adopted by all Data Sources.
protocol DataSourceProtocol : TypeEraseableDataSource, GenericallyObservableDataSource, SegueCompatibleDataSource, InternallyInitializable {
    associatedtype DataType
    var data:Data<DataType> { get }
}

// Default internal initialization method.  Don't override.
extension InternallyInitializable where Self:DataSourceProtocol, Self:DataSource {
    func internalInitialize() {
        if (!_initialized) {
            if let initializable = self as? Initializable {
                initializable.initialize()
            }
            _initialized = true
        }
    }
}


protocol PageableDataSource {
    var moreDataAvailable:Bool { get }
    func loadMoreData()
}


protocol RefreshableDataSource {
    func refresh()
}


// Any Data Sources that support generically observable data (which is all of them) get an immplementation to wrap their typed Data<DataType> with a converter to allow untyped data observers.  Used by classes like Table View Bindings, which need to observe updates to all kinds of data source without caring about their type
protocol GenericallyObservableDataSource {
    func add(observer:GenericDataObserver)
}

// Default implementation
extension GenericallyObservableDataSource where Self:DataSourceProtocol, Self:DataSource {
    func add(observer:GenericDataObserver) {
        self.genericObservers.append(GenericDataObserverConverter(data: self.data, observer:observer))
    }
}


// Allows UIKit component subclasses or extensions to TableViewCell etc. to specify what data source should be used in any segues triggered by the component.  This allows the process of pushing data through a segue to the next scene to be automated
protocol SegueDataProvider:class {
    var segueDataSource:DataSource! { get }
}


// Allows a SegueDataProvider to specify a specific index in the data source which to push through the segue, as opposed to the full set of data.
protocol IndexedSegueDataProvider:SegueDataProvider {
    var dataIndex:UInt { get }
}


// A protocol that enables retrieving a data source for pushing through a segue that is created with only the value at the specified index
protocol SegueCompatibleDataSource {
    func getSegueDataSource(withSegueDataIndex index:UInt)->DataSource
}


// Default implementation for all DataSources
extension SegueCompatibleDataSource where Self:DataSourceProtocol, Self:DataSource {
    func getSegueDataSource(withSegueDataIndex index:UInt)->DataSource {
        let segueDataSource = AnyDataSource<DataType>()
        if index == UInt.max {
            segueDataSource.data.set(self.data.copy())
        }
        else {
            let indexPath = NSIndexPath(forRow: Int(index), inSection:0)
            if let data = self.data.get(indexPath) {
                segueDataSource.data.set(data)
            }
        }
        return segueDataSource
    }
}

// TypeEraseableDataSource protocol and default implementations are used to pass out and accept type-erased data, so that unconstrained / untyped code like view controllers and segue handlers can pass it between different data sources automatically
protocol TypeEraseableDataSource {
    var get:AnyData { get }
    func set(data:AnyData)
}

// Default implementation for all DataSources
extension TypeEraseableDataSource where Self:DataSourceProtocol, Self:DataSource {
    
    var get:AnyData {
        get {
            return AnyData(data: self.data)
        }
    }
    
    func set(data:AnyData) {
        if let matchingData = data.copy() as? [Self.DataType] {
            self.data.set(matchingData)
        }
    }
}


// A type-remembering concrete class that conforms to the DataSourceProtocol for use in declaring variable types, etc.
class AnyDataSource <DataType> : DataSource, DataSourceProtocol {
    let data:Data<DataType> = Data<DataType>()
}


// MARK: - Binding Protocols and Classes -

// The base protocol of all binding-like SymbiOSis components, including Bindings, BindingSets, TableViewBindings, and other specialized types of bindings
protocol BindingType:class {
    var dataIndexPath:NSIndexPath? { get set }
    func reset()
}


// Base class for all bindings, provides storage for composed elements (whether Bindings in a BindingSet, or the BindingArbitration in a single Binding)
public class Binding : UIView, BindingType {
    
    private var _composedBindings = [BindingType]()
    private var _initialized = false
    private var _bindingSetMember = false
    private var _explicitDataIndex = false
    
    var dataIndexPath:NSIndexPath? {
        didSet {
            for composedBinding in _composedBindings {
                composedBinding.dataIndexPath = dataIndexPath
            }
        }
    }
    
    func reset() {
        for composedBinding in _composedBindings {
            composedBinding.reset()
        }
    }
}


// The type-constrained / type-defined generic class that links a data source's data with a binding and its view. Enforces same types where important.
class BindingArbitration <DataType, ViewType:UIView, ConcreteBinding:Binding where ConcreteBinding:BindingProtocol, ConcreteBinding.ViewType == ViewType, ConcreteBinding.BindingDataSource.DataType == DataType, ConcreteBinding.BindingDataSource:DataSource> : BindingType, DataObserver {
    
    private weak var binding:ConcreteBinding?
    private var _viewStates = [ViewState]()
    
    var dataIndexPath:NSIndexPath? {
        didSet {
            if let concreteBinding = binding {
                for view in concreteBinding.views {
                    if let value = concreteBinding.dataSource.data.get(dataIndexPath) {
                        concreteBinding.update(view, value:value)
                    }
                }
            }
        }
    }
    
    func updateWith(data:Data<DataType>) {
        if let concreteBinding = binding {
            for view in concreteBinding.views {
                if let value = data.get(dataIndexPath) {
                    concreteBinding.update(view, value:value)
                }
            }
        }
    }
    
    
    init(binding:ConcreteBinding) {
        self.binding = binding;
        if let concreteBinding = self.binding {
            for view in concreteBinding.views {
                addViewStates(view, array: &_viewStates)
            }
            concreteBinding.dataSource.data.add(self)
        }
    }
    
    func addViewStates(view:UIView, inout array:[ViewState]) {
        for subview in view.subviews {
            addViewStates(subview, array: &array)
        }
        array.append(view.viewState)
    }
    
    func reset() {
        for viewState in _viewStates {
            viewState.view?.viewState = viewState
        }
    }
    
    
}


// The type-constrained / type-defined protocol that all Bindings must adopt and which powers static type checking
protocol BindingProtocol :class, InternallyInitializable, SegueDataProvider {
    associatedtype BindingDataSource:DataSourceProtocol
    associatedtype ViewType:UIView
    
    var dataSource:BindingDataSource! { get set }
    var views:[ViewType]! { get set }
    
    func update(view:ViewType, value:BindingDataSource.DataType)
}


// Default implementations to set up binding mediator on initialize, hide the binding, etc.  Also helps enforce that implementors both subclass Binding and adopt BindingProtocol.
extension InternallyInitializable where Self:BindingProtocol, Self:Binding, Self.BindingDataSource:DataSource {
    
    var segueDataSource:DataSource! {
        get {
            let segueSource = AnyDataSource<BindingDataSource.DataType>()
            if let index = dataIndexPath, let value = self.dataSource.data.get(index) {
                segueSource.data.set(value)
                return segueSource
            }
            return nil
        }
    }
    
    func internalInitialize() {
        if (!_initialized) {
            self.hidden = true
            self.frame = CGRectZero
            self.alpha = 0
            
            guard self.dataSource != nil else {
                fatalError("Binding \(self) does not have a DataSource outlet connected")
            }
            
            guard self.views != nil || _bindingSetMember == true else {
                fatalError("Binding \(self) does not have any views connected to the 'views' outlet collection")
            }
            
            if self.views != nil {
                if let initializable = self as? Initializable {
                    initializable.initialize()
                }
                let arbitration = BindingArbitration(binding:self)
                arbitration.dataIndexPath = self.dataIndexPath
                _composedBindings.append(BindingArbitration(binding:self))
                if (!_explicitDataIndex) {
                    self.dataIndexPath = self.dataIndexPath ?? NSIndexPath(forRow: 0, inSection: 0)
                }
            }
            _initialized = true
        }
    }
    
    func reset() {
        for composedBinding in _composedBindings {
            composedBinding.reset()
        }
    }
}


// MARK: - Binding Set Protocols and Classes -

// Protocol that must be adopted by all binding sets.  Create generate foundation for type matching the data source and child bindings
protocol BindingSetProtocol:class, InternallyInitializable, Initializable, BindingType, SegueDataProvider {
    associatedtype BindingSetDataSource:DataSourceProtocol
    var dataSource:BindingSetDataSource! { get set }
}

// Base class for all binding sets.  Provides storage and a type constrained method to add child bindings that use the same-type data source
public class BindingSet : Binding {
    
    private func associate<ViewType:UIView, ConcreteDataSource:DataSourceProtocol, ConcreteBinding:Binding where ConcreteBinding:BindingProtocol, ConcreteBinding.BindingDataSource == ConcreteDataSource, ConcreteBinding.ViewType == ViewType, ConcreteDataSource:DataSource>(dataSource dataSource:ConcreteDataSource!, withbinding binding:ConcreteBinding, andOutlet outlet:[ViewType]!) {
        binding.dataSource = dataSource
        binding.views = outlet
        binding._bindingSetMember = true
        binding._explicitDataIndex = _explicitDataIndex
        binding.dataIndexPath = dataIndexPath
        binding.internalInitialize()
        _composedBindings.append(binding)
    }
}

// Default implementations to add initialization, segue data source creation, and a convenience method for associating child bindings with the data source
extension InternallyInitializable where Self:BindingSetProtocol, Self:BindingSet, Self.BindingSetDataSource:DataSource {
    
    var segueDataSource:DataSource! {
        get {
            let segueSource = AnyDataSource<BindingSetDataSource.DataType>()
            if let value = self.dataSource.data.get(dataIndexPath) {
                segueSource.data.set(value)
                return segueSource
            }
            return nil
        }
    }
    
    func associate<ViewType:UIView, ConcreteBinding:BindingProtocol where ConcreteBinding.ViewType == ViewType, Self.BindingSetDataSource == ConcreteBinding.BindingDataSource, ConcreteBinding:Binding>(binding binding:ConcreteBinding, withOutlet views:[ViewType]!) {
        self.associate(dataSource: self.dataSource, withbinding: binding, andOutlet: views)
    }
    
    func internalInitialize() {
        if (!_initialized) {
            self.hidden = true
            self.frame = CGRectZero
            self.alpha = 0
            guard self.dataSource != nil else {
                fatalError("BindingSet \(self) does not have a DataSource outlet connected")
            }
            self.initialize()
            guard self._composedBindings.count > 0 else {
                fatalError("BindingSet \(self) did not associate any bindings with views. Please ensure your 'initialize' method calls 'self.associate()' for at least one binding and outlet collection of views.")
            }
            _initialized = true
        }
    }
}


// MARK: - Table View Binding Protocols and Classes -

// Protocol used for all TableView Bindings (simple, sectioned etc.) to require a data source and a table view, plus a function to update when the data source data updates
protocol TableViewBinding:class, InternallyInitializable, GenericDataObserver {
    associatedtype GenericDataSource:DataSource
    
    var dataSource:GenericDataSource! { get set }
    var tableView:UITableView! { get set }
    
    func update(table:UITableView, data:AnyData)
}

// Default implementation to hide the binding if add as a subview, and to start type-erased observation of the data source for updates.
extension TableViewBinding where Self:Binding {
    
    func internalInitialize() {
        if (!_initialized) {
            
            self.hidden = true
            self.frame = CGRectZero
            self.alpha = 0
            
            guard tableView != nil else {
                fatalError("SymbiOSis TableViewBinding has no UITableView connected to the 'tableView' outlet.")
            }
            
            if let initializable = self as? Initializable {
                initializable.initialize()
            }
            
            guard let genericallyObservableDataSource = self.dataSource as? GenericallyObservableDataSource else {
                fatalError("SymbiOSis TableViewBinding has no connected data source, or an invalid data source. Data sources must subclass 'DataSource' and conform to 'DataSourceProtocol'")
            }
            genericallyObservableDataSource.add(self)
            _initialized = true
        }
    }
    
    func updateWith(data: AnyData) {
        self.update(self.tableView, data: data)
    }
}

// Binding used for connecting single-section tables to a data source. Requires that the connected TableView has had a protoype cell created in Interface Builder and given a reuse identifier. Note that the Simple Table View Binding exclusively uses self-sizing prototype cells and supports only iOS 8 and later.  Whatever constraints are calculated for each cell at layout time will be the height for that cell's row
class SimpleTableViewBinding : Binding, TableViewBinding, UITableViewDataSource, UITableViewDelegate, Initializable {
    
    private var _data:AnyData = AnyData(data: Data<Any>())
    private var _originalSeparatorStyle:UITableViewCellSeparatorStyle!
    
    @IBOutlet var dataSource:DataSource!
    @IBOutlet var tableView:UITableView!
    @IBOutlet var cellSelectionResponders:[TableCellSelectionResponder]!
    
    func update(tableView:UITableView, data:AnyData) {
        _data = data
        let currentOffset = tableView.contentOffset
        tableView.separatorStyle = _originalSeparatorStyle
        tableView.reloadData()
        tableView.contentOffset = currentOffset
        loadMoreDataIfAppropriate()
    }
    
    func initialize() {
        tableView.estimatedRowHeight = 50
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.delegate = self
        tableView.dataSource = self
        _originalSeparatorStyle = tableView.separatorStyle
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _data.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let identifier = (tableView.valueForKey("nibMap") as? Dictionary<NSString, NSObject>)?.keys.first as? String else {
            fatalError("There are no prototype cells created for the SymbiOSis SimpleTableViewBinding to retrieve from the UITableView. Please make sure there is a prototype cell and that you have given it a reuse identifer")
        }
        return tableView.dequeReusableCell(withIdentifier: identifier, dataIndexPath: indexPath)
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        loadMoreDataIfAppropriate()
    }
    
    func loadMoreDataIfAppropriate() {
        if let pageableDataSource = dataSource as? PageableDataSource where (tableView.contentSize.height - tableView.contentOffset.y <= tableView.frame.height) {
            if pageableDataSource.moreDataAvailable {
                pageableDataSource.loadMoreData()
            }
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let responders = cellSelectionResponders {
            for responder in responders {
                responder.tableView(tableView, selectedCell: tableView.cellForRowAtIndexPath(indexPath)!, indexPath: indexPath)
            }
        }
    }
}


// MARK: - Responders - 

class Responder:NSObject, InternallyInitializable {
    
    weak var viewController:ViewController!
    
    func internalInitialize() {
        if let initializable = self as? Initializable {
            initializable.initialize()
        }
    }
}

class ActionResponder : Responder {
    @IBAction func performActionWith(sender:AnyObject) {
        //override in subclasses
    }
}

class TableCellSelectionResponder:Responder {
    func tableView(tableView:UITableView, selectedCell:UITableViewCell, indexPath:NSIndexPath) {
        //override in subclasses
    }
}


// MARK: - SymbiOSis Components -

// Use as the custom class for all scenes in a storyboard, as as a superclass in the unlikely event you would want to add logic into the VC directly within a SymbiOSis scene
class ViewController: UIViewController, InternallyInitializable {
    
    private var _initialized = false
    
    lazy var topLevelObjects:[NSObject] = {
        var array = [NSObject]()
        if let objects = self.valueForKey("topLevelObjectsToKeepAliveFromStoryboard") as? [NSObject] {
            for object in objects {
                array.append(object)
            }
        }
        return array
        }()
    
    lazy var dataSources:[DataSource] = {
        var array = [DataSource]()
        for object in self.topLevelObjects {
            if let dataSource = object as? DataSource {
                array.append(dataSource)
            }
        }
        return array
        }()
    
    lazy var internalInitializables:[InternallyInitializable] = {
        var array = [InternallyInitializable]()
        for object in self.topLevelObjects {
            if let initializable = object as? InternallyInitializable {
                array.append(initializable)
            }
        }
        return array
        }()
    
    func internalInitialize() {
        if (!_initialized) {
        if let initializable = self as? Initializable {
            initializable.initialize()
        }
        for internalInitializable in self.internalInitializables {
            if let responder = internalInitializable as? Responder {
                responder.viewController = self
            }
            internalInitializable.internalInitialize()
        }
            _initialized = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        internalInitialize()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let dataProvider = sender as? SegueDataProvider {
            if let dataSource = dataProvider.segueDataSource as? TypeEraseableDataSource, let destination = segue.destinationViewController as? ViewController {
                var _ = destination.view
                destination.setDataSourcesFromDataSource(dataSource)
            }
            else {
                print("SymbiOSis Warning: Segueing to a non-SymbiOSis View Controller class -- is this intentional?  All Storyboard view controllers should be of the custom class 'ViewController' or a subclass")
            }
        }
        if let tableCell = sender as? UITableViewCell {
            tableCell.setSelected(false, animated: true)
        }
    }
    
    func setDataSourcesFromDataSource(dataSource:TypeEraseableDataSource) {
        for possibleTarget in self.dataSources {
            if possibleTarget.segueCanSet, let settableTarget = possibleTarget as? TypeEraseableDataSource {
                settableTarget.set(dataSource.get)
            }
        }
    }
}


// Use as a class or superclass for any buttons that trigger segues and should send data from the current view controller to the next view controller through the segue
public class SegueButton : UIButton, IndexedSegueDataProvider {
    
    private var _dataSourceStorage:DataSource!
    
    @IBInspectable var dataIndex:UInt = UInt.max
    
    @IBOutlet var segueDataSource:DataSource! {
        get {
            if let dataSource = self._dataSourceStorage as? SegueCompatibleDataSource {
                return dataSource.getSegueDataSource(withSegueDataIndex: self.dataIndex)
            }
            fatalError("SegueButton was used to trigger a segue, but has no DataSource connected to its segueDataSource outlet. If you don't want to have a data source for this segue, use a normal UIButton subclass rather than a SegueButton")
        }
        set {
            _dataSourceStorage = newValue
        }
    }
}


// MARK: - UIKit Extensions -

// Add methods to work with bindings in UITableViewCells
extension UITableViewCell : BindingType, SegueDataProvider {
    
    private var bindings:[Binding] {
        get {
            var bindingsForView = [Binding]()
            self.populateBindings(self, array: &bindingsForView)
            return bindingsForView
        }
    }
    
    private func populateBindings(view:UIView, inout array:[Binding]) {
        for subview in view.subviews {
            if let binding = subview as? Binding {
                array.append(binding)
            }
            populateBindings(subview, array: &array)
        }
    }
    
    var dataIndexPath:NSIndexPath? {
        set {
            for binding in bindings {
                binding.dataIndexPath = newValue
            }
        }
        get {
            return bindings.first?.dataIndexPath
        }
    }
    
    func reset() {
        for binding in bindings {
            binding._explicitDataIndex = true
            if let initializable = binding as? InternallyInitializable {
                initializable.internalInitialize()
            }
            binding.reset()
        }
    }
    
    var segueDataSource:DataSource! {
        get {
            if let binding = bindings.first as? SegueDataProvider, let dataSource = binding.segueDataSource {
                return dataSource
            }
            return nil
        }
    }
}


// Add method to assign an IndexPath to bindings in a dequeued cell and reset bindings on dequeue (which is the equivalent of the the work normally done in prepareForReuse()
public extension UITableView {
    
    func dequeReusableCell(withIdentifier identifier:String, dataIndexPath:NSIndexPath) -> UITableViewCell {
        let cell = self.dequeueReusableCellWithIdentifier(identifier, forIndexPath: dataIndexPath)
        cell.frame = CGRect(x: 0, y: 0, width: CGRectGetWidth(self.bounds), height: self.estimatedRowHeight)
        cell.contentView.frame = cell.frame
        cell.layoutIfNeeded()
        cell.reset()
        cell.dataIndexPath = dataIndexPath
        cell.layoutIfNeeded()
        return cell
    }
}


// Thin classes that capture the initial state of views that are connected to bindings in reusable cells.  They are used to restore the original properties of the view as they were defined in the storyboard before setting new values.  Part of the mechanism that replaces prepareForReuse()
class ViewState : NSObject {
    weak var view:UIView?
    var frame:CGRect!
    var bounds:CGRect!
    var clipsToBounds:Bool!
    var backgroundColor:UIColor!
    var alpha:CGFloat!
    var hidden:Bool!
    var contentMode:UIViewContentMode!
    var tintColor:UIColor!
    var tintAdjustmentMode: UIViewTintAdjustmentMode!
    var userInteractionEnabled:Bool!
    
    var layerBackgroundColor:UIColor?
    var layerCornerRadius:CGFloat!
    var layerBorderWidth:CGFloat!
    var layerBorderColor:UIColor?
}

class LabelViewState : ViewState {
    var text:String!
    var font:UIFont!
    var textColor:UIColor!
    var shadowColor:UIColor!
    var shadowOffset:CGSize!
    var textAlignment:NSTextAlignment!
    var lineBreakMode:NSLineBreakMode!
    var attributedText:NSAttributedString!
    var highlightedTextColor:UIColor!
    var highlighted:Bool!
    var enabled:Bool!
    var numberOfLines:Int!
    var adjustsFontSizeToFitWidth:Bool!
    var baselineAdjustment:UIBaselineAdjustment!
    var minimumScaleFactor:CGFloat!
    var preferredMaxLayoutWidth:CGFloat!
}


class ImageViewState : ViewState {
    
    var image:UIImage!
    var highlightedImage:UIImage!
    var highlighted:Bool!
    var animationImages:[UIImage]!
    var highlightedAnimationImages:[UIImage]!
    var animationDuration:NSTimeInterval!
    var animationRepeatCount:Int!
}


class ButtonViewState : ViewState {
    var enabled:Bool!
    var contentEdgeInsets:UIEdgeInsets!
    var titleEdgeInsets:UIEdgeInsets!
    var reversesTitleShadowWhenHighlighted:Bool!
    var imageEdgeInsets:UIEdgeInsets!
    var adjustsImageWhenHighlighted:Bool!
    var adjustsImageWhenDisabled:Bool!
    var showsTouchWhenHighlighted:Bool!
    var stateTitles = [UInt : String]()
    var stateTitleColors = [UInt : UIColor]()
    var stateTitleShadowColors = [UInt : UIColor]()
    var stateImages = [UInt : UIImage]()
    var stateBackgroundImages = [UInt : UIImage]()
    var stateAttributedTitles = [UInt : NSAttributedString]()
}


// Extensions to get and set ViewStates for common components used in reusable cells.
extension UIView {
    
    var viewState:ViewState {
        get {
            var viewState:ViewState!
            
            if self is UILabel {
                viewState = LabelViewState()
            }
                
            else if self is UIImageView {
                viewState = ImageViewState()
            }
                
            else if self is UIButton {
                viewState = ButtonViewState()
            }
                
            else {
                viewState = ViewState()
            }
            
            viewState.view = self
            viewState.clipsToBounds = self.clipsToBounds
            viewState.backgroundColor = self.backgroundColor
            viewState.alpha = self.alpha
            viewState.hidden = self.hidden
            viewState.contentMode = self.contentMode
            viewState.tintColor = self.tintColor
            viewState.tintAdjustmentMode = self.tintAdjustmentMode
            viewState.userInteractionEnabled = self.userInteractionEnabled
            viewState.layerBackgroundColor = (self.layer.backgroundColor != nil) ? UIColor(CGColor: self.layer.backgroundColor!) : nil
            viewState.layerCornerRadius = self.layer.cornerRadius
            viewState.layerBorderWidth = self.layer.borderWidth
            viewState.layerBorderColor = (self.layer.borderColor != nil) ? UIColor(CGColor: self.layer.borderColor!) : nil
            
            return viewState;
            
        }
        set {
            self.clipsToBounds = newValue.clipsToBounds;
            self.backgroundColor = newValue.backgroundColor;
            self.alpha = newValue.alpha;
            self.hidden = newValue.hidden;
            self.contentMode = newValue.contentMode;
            self.tintColor = newValue.tintColor;
            self.tintAdjustmentMode = newValue.tintAdjustmentMode;
            self.userInteractionEnabled = newValue.userInteractionEnabled;
            if self.layer.self === CALayer.self {
                self.layer.backgroundColor = newValue.layerBackgroundColor?.CGColor;
                self.layer.borderColor = newValue.layerBorderColor?.CGColor;
            }
            self.layer.cornerRadius = newValue.layerCornerRadius;
            self.layer.borderWidth = newValue.layerBorderWidth;
            
            self.setNeedsLayout()
        }
    }
}

extension UILabel {
    
    override var viewState:ViewState {
        get {
            let viewState = super.viewState as! LabelViewState
            viewState.text = self.text
            viewState.font = self.font
            viewState.textColor = self.textColor
            viewState.shadowColor = self.shadowColor
            viewState.shadowOffset = self.shadowOffset
            viewState.textAlignment = self.textAlignment
            viewState.lineBreakMode = self.lineBreakMode
            viewState.attributedText = self.attributedText
            viewState.highlightedTextColor = self.highlightedTextColor
            viewState.highlighted = self.highlighted
            viewState.enabled = self.enabled
            viewState.numberOfLines = self.numberOfLines
            viewState.adjustsFontSizeToFitWidth = self.adjustsFontSizeToFitWidth
            viewState.baselineAdjustment = self.baselineAdjustment
            viewState.minimumScaleFactor = self.minimumScaleFactor
            viewState.preferredMaxLayoutWidth = self.preferredMaxLayoutWidth
            
            return viewState;
        }
        set {
            let labelViewState = newValue as! LabelViewState
            self.text = labelViewState.text
            self.font = labelViewState.font
            self.textColor = labelViewState.textColor
            self.shadowColor = labelViewState.shadowColor
            self.shadowOffset = labelViewState.shadowOffset
            self.textAlignment = labelViewState.textAlignment
            self.lineBreakMode = labelViewState.lineBreakMode
            self.attributedText = labelViewState.attributedText
            self.highlightedTextColor = labelViewState.highlightedTextColor
            self.highlighted = labelViewState.highlighted
            self.enabled = labelViewState.enabled
            self.numberOfLines = labelViewState.numberOfLines
            self.adjustsFontSizeToFitWidth = labelViewState.adjustsFontSizeToFitWidth
            self.baselineAdjustment = labelViewState.baselineAdjustment
            self.minimumScaleFactor = labelViewState.minimumScaleFactor
            self.preferredMaxLayoutWidth = labelViewState.preferredMaxLayoutWidth
            super.viewState = labelViewState
        }
    }
}


extension UIImageView {
    override var viewState:ViewState {
        get {
            let viewState = super.viewState as! ImageViewState
            viewState.image = self.image
            viewState.highlightedImage = self.highlightedImage
            viewState.highlighted = self.highlighted
            viewState.animationImages = self.animationImages
            viewState.highlightedAnimationImages = self.highlightedAnimationImages
            viewState.animationDuration = self.animationDuration
            viewState.animationRepeatCount = self.animationRepeatCount
            
            return viewState;
        }
        set {
            let imageViewState = newValue as! ImageViewState
            self.image = imageViewState.image
            self.highlightedImage = imageViewState.highlightedImage
            self.highlighted = imageViewState.highlighted
            self.animationImages = imageViewState.animationImages
            self.highlightedAnimationImages = imageViewState.highlightedAnimationImages
            self.animationDuration = imageViewState.animationDuration
            self.animationRepeatCount = imageViewState.animationRepeatCount
            super.viewState = imageViewState
        }
    }
}


extension UIButton {
    override var viewState:ViewState {
        
        get {
            let viewState = super.viewState as! ButtonViewState
            viewState.enabled = self.enabled
            viewState.contentEdgeInsets = self.contentEdgeInsets
            viewState.titleEdgeInsets = self.titleEdgeInsets
            viewState.reversesTitleShadowWhenHighlighted = self.reversesTitleShadowWhenHighlighted
            viewState.imageEdgeInsets = self.imageEdgeInsets
            viewState.adjustsImageWhenHighlighted = self.adjustsImageWhenHighlighted
            viewState.adjustsImageWhenDisabled = self.adjustsImageWhenDisabled
            viewState.showsTouchWhenHighlighted = self.showsTouchWhenHighlighted
            
            readTo(&viewState.stateTitles, titleColors: &viewState.stateTitleColors, titleShadowColors: &viewState.stateTitleShadowColors, images: &viewState.stateImages, backgroundImages: &viewState.stateBackgroundImages, attributedTitles: &viewState.stateAttributedTitles, state: .Normal)
            readTo(&viewState.stateTitles, titleColors: &viewState.stateTitleColors, titleShadowColors: &viewState.stateTitleShadowColors, images: &viewState.stateImages, backgroundImages: &viewState.stateBackgroundImages, attributedTitles: &viewState.stateAttributedTitles, state: .Disabled)
            readTo(&viewState.stateTitles, titleColors: &viewState.stateTitleColors, titleShadowColors: &viewState.stateTitleShadowColors, images: &viewState.stateImages, backgroundImages: &viewState.stateBackgroundImages, attributedTitles: &viewState.stateAttributedTitles, state: .Highlighted)
            readTo(&viewState.stateTitles, titleColors: &viewState.stateTitleColors, titleShadowColors: &viewState.stateTitleShadowColors, images: &viewState.stateImages, backgroundImages: &viewState.stateBackgroundImages, attributedTitles: &viewState.stateAttributedTitles, state: .Selected)

            return viewState
        }
        
        set {
            let buttonViewState = newValue as! ButtonViewState
            self.enabled = buttonViewState.enabled
            self.contentEdgeInsets = buttonViewState.contentEdgeInsets
            self.titleEdgeInsets = buttonViewState.titleEdgeInsets
            self.reversesTitleShadowWhenHighlighted = buttonViewState.reversesTitleShadowWhenHighlighted
            self.imageEdgeInsets = buttonViewState.imageEdgeInsets
            self.adjustsImageWhenHighlighted = buttonViewState.adjustsImageWhenHighlighted
            self.adjustsImageWhenDisabled = buttonViewState.adjustsImageWhenDisabled
            self.showsTouchWhenHighlighted = buttonViewState.showsTouchWhenHighlighted
            
            writeFrom(buttonViewState.stateTitles, titleColors: buttonViewState.stateTitleColors, titleShadowColors: buttonViewState.stateTitleShadowColors, images: buttonViewState.stateImages, backgroundImages: buttonViewState.stateBackgroundImages, attributedTitles: buttonViewState.stateAttributedTitles, state: .Normal)
            writeFrom(buttonViewState.stateTitles, titleColors: buttonViewState.stateTitleColors, titleShadowColors: buttonViewState.stateTitleShadowColors, images: buttonViewState.stateImages, backgroundImages: buttonViewState.stateBackgroundImages, attributedTitles: buttonViewState.stateAttributedTitles, state: .Disabled)
            writeFrom(buttonViewState.stateTitles, titleColors: buttonViewState.stateTitleColors, titleShadowColors: buttonViewState.stateTitleShadowColors, images: buttonViewState.stateImages, backgroundImages: buttonViewState.stateBackgroundImages, attributedTitles: buttonViewState.stateAttributedTitles, state: .Highlighted)
            writeFrom(buttonViewState.stateTitles, titleColors: buttonViewState.stateTitleColors, titleShadowColors: buttonViewState.stateTitleShadowColors, images: buttonViewState.stateImages, backgroundImages: buttonViewState.stateBackgroundImages, attributedTitles: buttonViewState.stateAttributedTitles, state: .Selected)
        }
    }
    
    func readTo(inout titles:[UInt : String], inout titleColors:[UInt : UIColor], inout titleShadowColors:[UInt : UIColor], inout images:[UInt : UIImage], inout backgroundImages:[UInt : UIImage], inout attributedTitles:[UInt : NSAttributedString], state:UIControlState) {
        if let title = self.titleForState(state) {
            titles[state.rawValue] = title
        }
        if let titleColor = self.titleColorForState(state) {
            titleColors[state.rawValue] = titleColor
        }
        if let titleShadowColor = self.titleShadowColorForState(state) {
            titleShadowColors[state.rawValue] = titleShadowColor
        }
        if let image = self.imageForState(state) {
            images[state.rawValue] = image
        }
        if let backgroundImage = self.backgroundImageForState(state) {
            backgroundImages[state.rawValue] = backgroundImage
        }
        if let attributedTitle = self.attributedTitleForState(state) {
            attributedTitles[state.rawValue] = attributedTitle
        }
    }

    func writeFrom(titles:[UInt : String], titleColors:[UInt : UIColor], titleShadowColors:[UInt : UIColor], images:[UInt : UIImage], backgroundImages:[UInt : UIImage], attributedTitles:[UInt : NSAttributedString], state:UIControlState) {
        self.setTitle(titles[state.rawValue], forState: state)
        self.setTitleColor(titleColors[state.rawValue], forState: state)
        self.setTitleShadowColor(titleShadowColors[state.rawValue], forState: state)
        self.setImage(images[state.rawValue], forState: state)
        self.setBackgroundImage(backgroundImages[state.rawValue], forState: state)
        self.setAttributedTitle(attributedTitles[state.rawValue], forState: state)
    }
}


// MARK: - SymbiOSis-provided base classes and helpers

// A binding superclass to correctly autosize an image view in a self-sizing tableviewcell, etc. ahead of time, so it doesn't have the wrong layout after the image asynchronously loads or "jump" to a new size after scrolling off and on screen.
class DynamicImageBinding : Binding {
    
    static private let PhotoCache:NSCache = NSCache()
    @IBOutlet var views:[UIImageView]!
    var timestamp = NSDate.timeIntervalSinceReferenceDate()
    
    func setImage(imageView: UIImageView, fromURL url:NSURL, withSize size:CGSize) {
        let calculatedSize = CGSizeMake(size.width > 0 ? size.width: imageView.frame.size.width, size.height > 0 ? size.height: imageView.frame.size.height)
        UIGraphicsBeginImageContextWithOptions(calculatedSize, false, UIScreen.mainScreen().nativeScale)
        imageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        guard let cachedImage = DynamicImageBinding.PhotoCache.objectForKey(url.absoluteString + NSStringFromCGSize(calculatedSize)) as? UIImage else {
            let task = NSURLSession.sharedSession().dataTaskWithURL(url) {
                [requestStamp = timestamp](data, response, error) in
                if let imageData = data {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        if let image = UIImage(data:imageData) {
                            UIGraphicsBeginImageContextWithOptions(calculatedSize, false, 0.0)
                            image.drawInRect(CGRectMake(0, 0, calculatedSize.width, calculatedSize.height))
                            let newImage = UIGraphicsGetImageFromCurrentImageContext()
                            DynamicImageBinding.PhotoCache.setObject(newImage, forKey: url.absoluteString + NSStringFromCGSize(calculatedSize))
                            if requestStamp == self.timestamp {
                                imageView.image = newImage
                            }
                        }
                    })
                }
            }
            task.resume()
            return
        }
        imageView.image = cachedImage
    }
    
    override func reset() {
        timestamp = NSDate.timeIntervalSinceReferenceDate()
        super.reset()
    }
}

class ImageBinding : Binding {
    static private let PhotoCache:NSCache = NSCache()
    @IBOutlet var views:[UIImageView]!
    
    func setImage(imageView:UIImageView, fromURL:NSURL) {
        if let cached = ImageBinding.PhotoCache.objectForKey(fromURL.absoluteString) as? UIImage {
            imageView.image = cached
            return
        }
        let task = NSURLSession.sharedSession().dataTaskWithURL(fromURL) {(data, response, error) in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if let imageData = data, let image = UIImage(data:imageData) {
                    ImageBinding.PhotoCache.setObject(image, forKey: fromURL.absoluteString)
                    imageView.image = image
                }
            })
        }
        task.resume()
    }
}

// A base class or dumb container for NSURL data
class NSURLDataSource : DataSource, DataSourceProtocol {
    let data = Data<(NSURL)>()
}

// A general DataSource that observes any NSURL-based DataSource for updates, and when the observed DataSource is updated, gets the first URL in the DataSource and retrieves a JSON dictionary from that DataSource
class JSONFromNSURLDataSource : DataSource, DataSourceProtocol, DataObserver, Initializable {
    let data = Data<[NSObject: AnyObject]>()
    
    @IBOutlet var urlDataSource:NSURLDataSource!
    
    func initialize() {
        if let dataSourceToObserve = urlDataSource {
            dataSourceToObserve.data.add(self)
        }
    }
    
    func updateWith(data: Data<NSURL>) {
        if let url = data.first {
            let task = NSURLSession.sharedSession().dataTaskWithURL(url) {(responseData, response, error) in
                if let jsonData = responseData, let json = (try? NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.MutableContainers)) as? [NSObject: AnyObject] {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.data.set(json)
                    })
                }
            }
            task.resume()
        }
    }
}
