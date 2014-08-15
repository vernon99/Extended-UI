//
//  MLUICarouselView.h
//  Extended-UI
//
//  Created by Mikhail Larionov on 8/14/14.
//  Copyright (c) 2014 Mikhail Larionov. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^MLUICarouselBlock)(UIView* view, CGFloat visibility);

@interface MLUICarouselView : UIView <UIScrollViewDelegate>

// Properties
@property NSInteger currentItem;
@property (nonatomic, copy) MLUICarouselBlock viewDidScrolledBlock;

// Initialization
- (id) init __attribute__((unavailable("use initWithFrame instead")));
- (id) initWithFrame:(CGRect)frame andSelectionFrame:(CGRect)selection;
- (void) setSelectionFrame:(CGRect)selection;

// Elements management
- (void) setElements:(NSArray*)elementsArray;

@end
