//
//  AppDelegate.swift
//  SymbiOSis-Alpha
//
//  Created by Daniel Hall on 10/7/15.
//  Copyright © 2015 Daniel Hall. All rights reserved.
//

import Foundation
import UIKit
import SafariServices

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        let credential = NSURLCredential(user: "", password: "1dhlFRohyKr8HNWV2NKpTO3ITcuZ0L293b1RkaIZlNtlUdGVWN11XTrQwN==".deobfuscated, persistence: .ForSession)
        let protectionSpace = NSURLProtectionSpace(host: "api.datamarket.azure.com", port: 443, protocol: "https", realm: nil, authenticationMethod: nil)
        NSURLCredentialStorage.sharedCredentialStorage().setDefaultCredential(credential, forProtectionSpace:protectionSpace)
        return true
    }
}

// MARK: - DataSources -

struct BingImage {
    let title:String
    let description:String
    let thumbImage:NSURL
    let thumbWidth:Int
    let thumbHeight:Int
    let image:NSURL
    let link:NSURL
    
    init(jsonDictionary:[NSObject: AnyObject]) {
        let allowedCharacters =  NSCharacterSet(charactersInString:" \'\"#%<>@\\^`{|}").invertedSet
        description = jsonDictionary["DisplayUrl"] as! String
        title = jsonDictionary["Title"] as! String
        thumbWidth = Int(jsonDictionary["Thumbnail"]!["Width"] as! String)!
        thumbHeight = Int(jsonDictionary["Thumbnail"]!["Height"] as! String)!
        thumbImage = NSURL(string:(jsonDictionary["Thumbnail"]!["MediaUrl"] as! String).stringByAddingPercentEncodingWithAllowedCharacters(allowedCharacters)!)!
        image = NSURL(string:(jsonDictionary["MediaUrl"] as! String).stringByAddingPercentEncodingWithAllowedCharacters(allowedCharacters)!)!
        link = NSURL(string:(jsonDictionary["SourceUrl"] as! String).stringByAddingPercentEncodingWithAllowedCharacters(allowedCharacters)!)!
    }
}

class BingSearchURLDataSource:NSURLDataSource, PageableDataSource {
    
    var colorList = [("Blue", UIColor(red:0.149, green:0.631, blue:0.808, alpha:1)), ("Green",UIColor(red:0.2, green:0.698, blue:0.125, alpha:1)), ("Purple", UIColor(red:0.675, green:0.204, blue:1, alpha:1)), ("Yellow", UIColor(red:0.922, green:0.827, blue:0.251, alpha:1))]
    
    var currentPage = 0
    
    var searchTerm:String = "" {
        didSet {
            let cleanSearch = searchTerm.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!
            let baseString = "https://api.datamarket.azure.com/Bing/Search/v1/Image?$format=json&Query=%27"
            var urlArray = [NSURL]()
            for (color, _) in colorList {
                urlArray.append(NSURL(string: baseString + color + "%20" + cleanSearch + "%27")!)
            }
            self.data.set(urlArray)
        }
    }
    
    var moreDataAvailable:Bool {
        get {
            return currentPage < 20  // Allow a maximum of 20 pages of data
        }
    }
    
    func loadMoreData() {
        if let currentURLString = self.data.get(NSIndexPath(forRow: 0, inSection: 0))?.absoluteString where currentPage < 7 {
            var stringWithoutStart = currentURLString
            if let index = currentURLString.rangeOfString("&$skip=")?.first {
                stringWithoutStart = currentURLString.substringToIndex(index)
            }
            currentPage += 1
            self.data.set(NSURL(string:stringWithoutStart + "&$skip=" + "\(currentPage*100)")!) // Pages consist of 100 results each
        }
    }
}

class BingImageDataSource:DataSource, DataSourceProtocol {
    let data = Data<BingImage>()
}

class BingImageFromJSONDataSource: BingImageDataSource, DataObserver, Initializable, PageableDataSource {
    @IBOutlet var jsonDataSource:JSONFromNSURLDataSource!
    var bingURLDataSource:BingSearchURLDataSource?
    var loading:Bool = false
    
    var moreDataAvailable:Bool {
        get {
            return !loading && (bingURLDataSource?.moreDataAvailable ?? false)
        }
    }
    
    func loadMoreData() {
        loading = true
        bingURLDataSource?.loadMoreData()
    }
    
    func initialize() {
        if let dataSourceToObserve = jsonDataSource {
            dataSourceToObserve.data.add(self)
            
            if let urlSource = dataSourceToObserve.urlDataSource as? BingSearchURLDataSource {
                bingURLDataSource = urlSource
            }
        }
    }
    
    func updateWith(data: Data<[NSObject: AnyObject]>) {
        var arrayOfImages = [BingImage]()
        if let responseData = data.get(NSIndexPath(forRow: 0, inSection: 0))?["d"] as? [NSObject: AnyObject], let arrayOfJSONItems = responseData["results"] as? [[NSObject: AnyObject]] {
            for item in arrayOfJSONItems {
                arrayOfImages.append(BingImage(jsonDictionary: item))
            }
            self.data.set(self.data.copy() + arrayOfImages)
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.15 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()){
                self.loading = false
            }
        }
    }
}

// MARK: - Bindings -

class BingImageTitleBinding : Binding, BindingProtocol {
    @IBOutlet var dataSource:BingImageDataSource!
    @IBOutlet var views:[UILabel]!
    
    func update(view: UILabel, value: BingImage) {
        view.text = value.title
    }
}

class BingImageDescriptionBinding : Binding, BindingProtocol {
    @IBOutlet var dataSource:BingImageDataSource!
    @IBOutlet var views:[UILabel]!
    
    func update(view: UILabel, value: BingImage) {
        view.text = value.description
    }
}

class BingImageThumbnailBinding : DynamicImageBinding, BindingProtocol {
    @IBOutlet var dataSource:BingImageDataSource!
    
    func update(view: UIImageView, value: BingImage) {
        let aspect = CGFloat(value.thumbHeight)/CGFloat(value.thumbWidth)
        let currentWidth = view.frame.size.width
        let targetSize = CGSizeMake(currentWidth, CGFloat(currentWidth * aspect))
        self.setImage(view, fromURL: value.thumbImage, withSize: targetSize)
    }
}

class BingImageFullImageBinding : Binding, BindingProtocol {
    @IBOutlet var dataSource:BingImageDataSource!
    @IBOutlet var views:[UIImageView]!
    
    func update(view: UIImageView, value: BingImage) {
        let task = NSURLSession.sharedSession().dataTaskWithURL(value.image) {(data, response, error) in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if let imageData = data, let image = UIImage(data:imageData) {
                    view.image = image
                }
                else {
                    view.image = UIImage(named: "missing")
                }
            })
        }
        task.resume()
    }
}

class BingImageBindingSet : BindingSet, BindingSetProtocol {
    @IBOutlet var dataSource:BingImageDataSource!
    @IBOutlet var titleLabels:[UILabel]!
    @IBOutlet var descriptionLabels:[UILabel]!
    @IBOutlet var thumbnailImageViews:[UIImageView]!
    @IBOutlet var fullImageViews:[UIImageView]!
    
    func initialize() {
        associate(binding: BingImageTitleBinding(), withOutlet: titleLabels)
        associate(binding: BingImageDescriptionBinding(), withOutlet: descriptionLabels)
        associate(binding: BingImageThumbnailBinding(), withOutlet: thumbnailImageViews)
        associate(binding: BingImageFullImageBinding(), withOutlet: fullImageViews)
    }
}

// MARK: - Responders -

class BingSearchTermResponder:Responder, UITextFieldDelegate, Initializable {
    @IBOutlet var textField:UITextField!
    @IBOutlet var dataSource:BingSearchURLDataSource!
    @IBOutlet var buttons:[UIButton]!
    
    func initialize() {
        textField.delegate = self
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.update), name: UITextFieldTextDidChangeNotification, object: textField)
        for index in 0..<buttons.count {
            buttons[index].setTitle(dataSource.colorList[index].0, forState: UIControlState.Normal)
            buttons[index].setTitleColor(dataSource.colorList[index].1, forState: UIControlState.Normal)
            buttons[index].enabled = false
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func update() {
        dataSource.searchTerm = textField.text ?? ""
        for index in 0..<buttons.count {
            buttons[index].setTitle(dataSource.colorList[index].0 + " " + dataSource.searchTerm, forState: UIControlState.Normal)
            buttons[index].enabled = dataSource.searchTerm.characters.count > 0
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}

class BingImageOpenLinkInSafariResponder : ActionResponder {
    @IBOutlet var bingImageDataSource:BingImageDataSource!
    
    override func performActionWith(sender:AnyObject) {
        if let dataSource = bingImageDataSource, let bingImage = dataSource.data.first {
            let safariViewController = SFSafariViewController(URL:bingImage.link)
            viewController.presentViewController(safariViewController, animated: true, completion: nil)
        }
    }
}

extension String {
    var deobfuscated:String {
        get {
            var result = self
            for index in 0.stride(to: result.characters.count-1, by: 2) {
                let firstRange = result.startIndex.advancedBy(index)...result.startIndex.advancedBy(index)
                let secondRange = result.startIndex.advancedBy(index+1)...result.startIndex.advancedBy(index+1)
                let firstSubstring = result.substringWithRange(firstRange)
                let secondSubstring = result.substringWithRange(secondRange)
                result = result.stringByReplacingCharactersInRange(firstRange, withString: secondSubstring)
                result = result.stringByReplacingCharactersInRange(secondRange, withString: firstSubstring)
            }
            result = String(data:NSData(base64EncodedString: result, options: NSDataBase64DecodingOptions(rawValue: 0))!, encoding:NSUTF8StringEncoding)!
            for index in 0...result.characters.count/2 {
                let firstRange = result.startIndex.advancedBy(index)...result.startIndex.advancedBy(index)
                let secondRange = result.startIndex.advancedBy(result.characters.count-1-index)...result.startIndex.advancedBy(result.characters.count-1-index)
                let firstSubstring = result.substringWithRange(firstRange)
                let secondSubstring = result.substringWithRange(secondRange)
                result = result.stringByReplacingCharactersInRange(firstRange, withString: secondSubstring)
                result = result.stringByReplacingCharactersInRange(secondRange, withString: firstSubstring)
            }
            return result
        }
    }
}