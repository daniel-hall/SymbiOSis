# SymbiOSis

### Storyboard Driven Development

Perhaps the easiest, fastest and most sustainable way to create iOS apps, SymbiOSis is a framework that allows you to organize your code into small, testable, reusable components that are connected together using Interface Builder.

- Eliminate almost 100% of typical iOS boilerplate code in view controllers, table view data sources and delegates, segues, and more
- No more writing view controller subclasses
- No more creating UITableViewDataSources and Delegates to use table views - just bind the table directly to your data in the Storyboard
- No more manual prepareForSegue code
- No more custom UITableViewCell subclasses
- Compiler and Interface Builder enforcement of bindings between the correct kinds of data and the correct kinds of views

Included in this project is a full sample application that allows you to search for pictures of objects in different colors and view details about them. This sample application has:

- Zero lines of boilerplate code. Every line is useful business logic instead of tedious setup code, establishing delegates, or subclassing UIKit components.
- Around 200 lines of code total, the rest is handled by the SymbiOSis framework
- Seamless, automatic paged data retrieval from Bing search APIs
- Self-sizing UITableView cells
- Zero UIViewController subclasses
- Zero UITableViewCell subclasses
- Zero UITableViewDataSource and UITableViewDelegate code

The entire SymbiOSis framework is contained in the single "SymbiOSis.swift" file. To experiment with SymbiOSis-Alpha in your own applications, simply copy and include "SymbiOSis.swift" into your own Xcode project

## More Information

For more information on how SymbiOSis works and why, see original blog post at:

http://www.danielhall.io/the-problems-with-mvvm-on-ios
