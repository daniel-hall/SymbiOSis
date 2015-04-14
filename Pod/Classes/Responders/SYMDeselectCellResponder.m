//
//  SYMDeselectCellResponder.m
//  Pods
//
//  Created by Dan Hall on 4/6/15.
//
//

#import "SYMDeselectCellResponder.h"

@implementation SYMDeselectCellResponder

-(void)selectedCell:(id)cell atIndexPath:(NSIndexPath *)indexPath withValue:(id)value {
    [cell setSelected:NO animated:NO];
}

@end
