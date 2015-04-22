//
// UICollectionView+SymbiOSis.h
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


#import <UIKit/UIKit.h>

/** Category for passing through an index for bindings inside UICollectionViewCells */
@interface UICollectionView (SymbiOSis)

/** Behaves identically to the standard dequeueReusableCellWithReuseIdentifier:forIndexPath: method on a UICollectionView, with the addition of an extra parameter that sets the index that bindings inside the cell should use for retrieving their specific value from the data source 
* @param identifier Same as in [UICollectionView dequeueReusableCellWithReuseIdentifier:forIndexPath:] method
* @param indexPath Same as in [UICollectionView dequeueReusableCellWithReuseIdentifier:forIndexPath:] method
* @param dataSourceIndexPath The index path that should be used to retrieve this cell's value from the data source.
* @return a UICollectionViewCell or subclass.
*/
-(id)dequeueReusableCellWithReuseIdentifier:(NSString *)identifier forIndexPath:(NSIndexPath *)indexPath withDataSourceIndexPath:(NSIndexPath *)dataSourceIndexPath;

@end
