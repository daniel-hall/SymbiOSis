//
// SYMForwardDataThroughSegueResponder.m
//
// Copyright (c) 2015 Dan Hall
// Twitter: @_danielhall
// GitHub: https://github.com/daniel-hall
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.


#import "SYMForwardDataThroughSegueResponder.h"
#import "SYMDataSource.h"
#import "SYMViewController.h"


@interface SYMDataProviderToDataSourceBinding : NSObject

@property (nonatomic) SYMDataSource *dataSourceToUpdate;
@property (nonatomic) NSObject<SYMDataProviderProtocol> *dataProvider;

- (instancetype)initWithDataProvider:(NSObject <SYMDataProviderProtocol>*)dataProvider dataSource:(SYMDataSource *)dataSourceToUpdate;

@end


@implementation SYMDataProviderToDataSourceBinding


- (instancetype)initWithDataProvider:(NSObject <SYMDataProviderProtocol>*)dataProvider dataSource:(SYMDataSource *)dataSourceToUpdate {
    self = [super init];
    if (self) {
        _dataProvider = dataProvider;
        _dataSourceToUpdate = dataSourceToUpdate;
        if (self.dataProvider) {
            [self.dataProvider addObserver:self forKeyPath:NSStringFromSelector(@selector(sourceValue)) options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:nil];
        }
    }
    
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    [self update];
}

-(void)update {
    self.dataSourceToUpdate.value = self.dataProvider.sourceValue;
}

- (void)dealloc {
    [self.dataProvider removeObserver:self forKeyPath:NSStringFromSelector(@selector(sourceValue))];
}


@end



@interface SYMForwardDataThroughSegueResponder ()

@property (nonatomic) NSMutableArray *bindings;

@end



@implementation SYMForwardDataThroughSegueResponder


-(BOOL)handlesSegue:(UIStoryboardSegue *)segue {
    return [segue.identifier isEqualToString:self.segueIdentifier] && [segue.destinationViewController conformsToProtocol:@protocol(SYMDataSourcesOwner)];
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue {
    
    id <SYMDataSourcesOwner> destinationViewController = segue.destinationViewController;
    
    NSArray *destinationDataSources = [destinationViewController dataSourcesWithIdentifier:self.sourceDataProvider.dataIdentifier];

    self.sourceDataProvider.sourceValue = nil;
    
    for (SYMDataSource *dataSource in destinationDataSources) {
        SYMDataProviderToDataSourceBinding *binding = [[SYMDataProviderToDataSourceBinding alloc] initWithDataProvider:self.sourceDataProvider dataSource:dataSource];
        [self.bindings addObject:binding];
    }
}


-(NSMutableArray *)bindings {
    if (!_bindings) {
        _bindings = [NSMutableArray array];
    }
    
    return _bindings;
}

@end
