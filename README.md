# SymbiOSis
An MVVM-inspired framework for building apps with less code, less bugs, and in less time.

While MVVM championed the use of view models and bindings to create smaller and less complex view controllers, the existing implementations of MVVM on iOS have a lot of problems:

- View Controllers have to know the methods and properties of their view models, making them tightly coupled.  Which means that view models are hard to reuse.
- Trying to make view models behave as data sources for table views, collection views, etc. creates even more coupling to a single view controller.
- If view models are reused, then view controllers are forced to have the same presentation / formatting logic in order to make the reuse work.  Or, alternatively, each view models must become a massive class that serves multiple possible view controller use cases.
- There is still a lot of glue code for segues, IBActions, and more left inside view controllers which is both difficult to test, and impossible to reuse.

Symbiosis provides the following features and advantages:

- You never have to write custom view controllers, or view models, although your app will still use storyboards, scenes and segues as usual.
- You never have to write another UITableViewDataSource, UITableViewDelegate, or another UITableViewCell subclass, even though you maintain full control of UITableViews, their styling, headers and footers, prototype cells and content, right from the storyboard.
- SymbiOSis uses bindings and one-way immutable data for maximum safety and minimum bugs.  Change the value in a data source, and all labels, buttons, images, and other views bound to that data source are automatically and immediately updated. 
- SymbiOSis is designed to work seamlessly with Interface Builder and storyboards.  This allows views to be easily seen and modified, while being kept completely decoupled from business logic and other code.  Every component created using SymbiOSis can be wired up using only Interface Builder, (although you can also make connections via code if you wish)
- Use SymbiOSis as much or as little as you like.  There is no requirement to go “all-in”.  Instead, you can construct a single new view controller / scene using SymbiOSis, or convert existing scenes over gradually.
- The SymbiOSis architecture promotes maximum testability and reusability.  The code you write for your application using SymbiOSis is easy to test, and only needs to be tested once, while it can be reused as easily as dropping a component onto a storyboard and connecting outlets.
- The base SymbiOSis framework is designed to be extended in any way you need.  You can add or alter any functionality you wish.

## Installation with CocoaPods
Add `pod 'SymbiOSis'` to your project's Podfile and run `pod update`.

## Installation without CocoaPods
Download the .zip for this repo and add the entire "SymbiOSis" folder and all subfolders to your project in Xcode.

## Getting Started
This is a brief overview of the SymbiOSis framework and architecture.  More in-depth coverage of specific components will be added to the wiki.  

In addition to this guide, there is a full sample application that demonstrates how to build a data-driven iOS application using SymbiOSis.  The repo for that sample application is located here: 

https://github.com/daniel-hall/SymbiOSisDemoApp

Additionally, the code is fully documented in the header files, or in a more nicely formatted version here:
http://cocoadocs.org/docsets/SymbiOSis

### Key concepts
In MVVM, the role of the view model is to hold all the data that the view controller needs and perform any needed transformation on that data (such as formatting names or dates).  The view controller still acts as the recipient events, the manage of segues, etc. 

Symbiosis breaks these responsibilities into smaller and more explicit parts - specifically: data sources, bindings, and responders.

### Data Sources
In SymbiOSis, a data source holds either a data object, or an array of data objects.  A data source has only one piece of necessary work: to retrieve and / or filter data, and set that data to its “value” property.  Any time a data source’s “value” property changes, associated bindings will automatically update views to reflect the new value.

To create your own data source, you create a subclass of SYMDataSource, and override the ```-(void)awakeFromNib``` method with code to load the relevant data. For example:

	@interface PhotosDataSource : SYMDataSource
	
	@end
	
	@implementation PhotosDataSource
	
	-(void)awakeFromNib {
	 NSArray *arrayOfPhotos = //Download a bunch of photos from a server or service;
	 self.value = arrayOfPhotos;
	}
	
	@end

This is all that is required from a data source.

### Bindings
The second kind of component in the SymbiOSis framework is a binding.  The role of a binding is to convert or transform values from a data object to properties or values on a view object.  

For example, say there is a model object class called “Person” with properties like firstName, middleName, lastName, age, height, etc.  In different places within your application, you will want to populate various user interface elements based on that data.  Perhaps there should be a UILabel that presents the user’s full name (first, middle and last name).  There might be a control that looks like a vertical yardstick with a sliding indicator that indicates the user’s height. Bindings would read the relevant properties from the Person object, and configure the labels and controls appropriately.

A binding called “PersonHeightYardstickBinding” could look something like this:

	@interface PersonHeightYardstickBinding : SYMBinding
	 
	@property (nonatomic) Person *value; //override the SYMBinding value property definition with the specific type of data object
	 
	@property (nonatomic, weak) IBOutlet YardstickView *view; //override the SYMBinding view property definition with the specific type of view to be updated
	 
	@end
	
	@implementation PersonHeightYardstickBinding
	
	-(void)update {
	 [self.view setHeightInInches: self.value.height]; // remember that self.view is of the type YardstickView*, and self.value is of the type Person*, which give proper code completion and compiler checking here.
	}
	
	@end

The above is all the code that would need to be written.  The SYMBinding superclass handles monitoring the data source for changes, and calling the update method.  To use this binding, you would only need to add an instance of this PersonYardstickBinding to the storyboard along with an instance of a SYMDataSource that has a Person object as its value.  And of course, you would add a YardstickView to the scene and position it where you would want it.  From there, it’s only necessary to drag a connection from the binding’s “dataSource” outlet to the data source, and from the binding’s “view” outlet to the YardstickView.  From that point forward, any time the Person changes, the binding will update the YardStick view automatically to reflect the current height that should be displayed.

Note that with this particular architectural arrangement, the view itself does not know anything about how or where it gets its value.  These “dumb views” are ideally suited for easy reuse or repopulating with different values without requiring any modifications to code.

#### Binding Sets

It is very common for a data object (like the “Person” example above) to have many different possible bindings.  There might be bindings that populate labels with age, name, etc. as well as other bindings that set the background color of views to match a person’s favorite color, etc.  To simplify using and reusing bindings, it is encourage that you create “Binding Sets” to collect together related bindings.  

A binding set is a subclass of SYMBindingSet and has a data source just like a regular binding.  However, a binding set exposes many different view outlets or outlet collections and maps them to individual binding collected within the set.  This way, instead of having to place multiple bindings into the storyboard, e.g. PersonFirstNameLabelBinding, PersonFullNameLabelBinding, PersonAgeLabelBinding, and PersonHeightYardstickViewBinding, and then wiring all of them to the same data source and their respective views, you can instead place just a “PersonBindingSet” on the storyboard, connect it to a single Person data source, and then wire the binding set’s properties / outlets to each relevant view.  For example, the binding set would have outlets for firstNameLabel, fullNameLabel, ageLabel and yardstickView, and those would be connected in interface builder to the matching labels and views in the scene. 

### Responders
A responder in SymbiOSis encapsulates a single routine or method that runs in response to some user interaction.  Examples of things that responders might do are: closing a modal view controller when a “Done” bar button item is tapped, dialing a phone number or linking out to a web page when a button is touched, collecting information from text fields or controls on a screen and sending the values to a database, submitting analytics events in response to users tapping or interacting with specific items on the screen.

As much as possible, responders should be used instead of IBActions in view controllers (although responders can themselves contain IBActions).  The reason for this is reusability.  When a view controller is loaded up with IBActions  and code that responds to user interaction, that same code usually has to be copied and pasted or recreated inside other view controllers that have similar functionality.  But, when each behavior is instead encapsulated into a SYMResponder subclass, the behaviors can be reused anywhere again and again by just dropping the responder as a custom object into a storyboard, and  connecting it to a control event, bar button item, etc.  

