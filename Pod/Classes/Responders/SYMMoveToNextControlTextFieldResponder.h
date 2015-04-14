//
//  SYMMoveToNextTextFieldResponder.h
//  Pods
//
//  Created by Dan Hall on 4/13/15.
//
//

#import "SYMResponder.h"
#import <UIKit/UIKit.h>

@interface SYMMoveToNextControlTextFieldResponder : SYMResponder <UITextFieldDelegate>

@property (nonatomic, strong) IBOutletCollection(UIResponder) NSArray *nextResponders;

@end
