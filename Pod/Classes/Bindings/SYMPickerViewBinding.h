//
//  SYMPickerViewBinding.h
//  Pods
//
//  Created by Dan Hall on 4/9/15.
//
//

#import "SYMBinding.h"
#import "SYMDataProviderProtocol.h"

@interface SYMPickerViewBinding : SYMBinding <UIPickerViewDataSource, UIPickerViewDelegate, SYMDataProviderProtocol>

/** Override and re-type of the superclass's value property to specify an array data source value */
@property (nonatomic, strong) NSArray *value;

/** If using a SYMForwardDataThroughSegueResponder, the value that is pushed through the segue will be set on any data source in the destination scene that has a matching dataIdentifier value. */
@property (nonatomic, copy) IBInspectable NSString *dataIdentifier;

/** Override and re-type of the superclass's view property to specify a UITableView */
@property (nonatomic, weak) IBOutlet UIPickerView *view;

/** A comma-separated string containing the values that the picker should display, if not using a linked data source **/
@property (nonatomic, copy) IBInspectable NSString *pickerValues;

@property (nonatomic, strong) IBOutletCollection(UILabel) NSArray* pickerLabels;


@end
