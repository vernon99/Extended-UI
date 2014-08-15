//
//  MLUICarouselView.m
//  Extended-UI
//
//  Created by Mikhail Larionov on 8/14/14.
//  Copyright (c) 2014 Mikhail Larionov. All rights reserved.
//

#import "MLUICarouselView.h"
#import "MLUIView+Coordinates.h"

// Private declarations
@interface MLUICarouselView()
@property (nonatomic, strong) UIScrollView* scrollView;
@property (nonatomic, strong) NSMutableArray* elementsArray;
@property NSInteger elementCount;
@end

// Implementation
@implementation MLUICarouselView

#pragma mark - Initialization

- (void) initializeCarousel
{
    self.autoresizesSubviews = TRUE;
    self.clipsToBounds = TRUE;
    
    // Setup scroll view
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    self.scrollView.pagingEnabled = TRUE;
    self.scrollView.scrollEnabled = TRUE;
    self.scrollView.bounces = FALSE;
    self.scrollView.clipsToBounds = FALSE;
    self.scrollView.showsHorizontalScrollIndicator = FALSE;
    self.scrollView.showsVerticalScrollIndicator = FALSE;
    self.scrollView.delegate = self;
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [self addSubview:self.scrollView];
    
    // Initialize variables
    self.elementCount = 0;
    self.currentItem = 0;
}

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initializeCarousel];
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initializeCarousel];
    }
    return self;
}

- (id) initWithFrame:(CGRect)frame andSelectionFrame:(CGRect)selection
{
    self = [self initWithFrame:frame];
    if (self) {
        [self setSelectionFrame:selection];
    }
    return self;
}

- (void) setSelectionFrame:(CGRect)selection
{
    if ( ! self.scrollView )
        return;
    
    self.scrollView.frame = selection;
}

- (void) setElements:(NSArray*)elementsArray
{
    // Cleanup of the previously added elements and setup
    for ( UIView* subview in self.scrollView.subviews )
        [subview removeFromSuperview];
    self.elementsArray = [NSMutableArray array];
    self.elementCount = elementsArray.count;
    NSInteger totalCount = elementsArray.count * 3;
    
    for ( NSInteger n = 0; n < totalCount; n++ )
    {
        NSInteger index = n % elementsArray.count;
        UIView* element = elementsArray[index];
        
        // Creating deep copy of the view for all elements that are out of bounds
        if ( n >= elementsArray.count )
            element = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:element]];
        
        element.originX = self.scrollView.width * n;
        [self.elementsArray addObject:element];
        [self.scrollView addSubview:element];
    }
    
    // Set scrollview content size
    self.scrollView.contentSize = CGSizeMake(self.scrollView.width * totalCount, self.scrollView.height);
    
    // Scroll to the default position
    [self.scrollView scrollRectToVisible:CGRectMake(self.scrollView.width * self.elementCount,
                                                    0, self.scrollView.width, self.scrollView.height) animated:NO];
    [self scrollViewDidScroll:self.scrollView];
}

- (void) setViewDidScrolledBlock:(MLUICarouselBlock)block
{
    _viewDidScrolledBlock = block;
    [self scrollViewDidScroll:self.scrollView];
}

#pragma mark - UIView Overrides

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    return [self pointInside:point withEvent:event] ? self.scrollView : nil;
}

#pragma mark - UIScrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ( self.elementCount == 0 || ! self.elementsArray )
        return;
    
    float indexOfPage = self.scrollView.contentOffset.x / self.scrollView.width;
    NSInteger currentPage = (NSInteger)indexOfPage;
    
    // Carousel looping
    if (currentPage < self.elementCount) {
        [self.scrollView scrollRectToVisible:CGRectMake( self.scrollView.contentOffset.x + self.scrollView.width * self.elementCount, 0, self.scrollView.width, self.scrollView.height) animated:NO];
    }
    else if (currentPage >= self.elementCount*2 ) {
        [self.scrollView scrollRectToVisible:CGRectMake( self.scrollView.contentOffset.x - self.scrollView.width * self.elementCount, 0, self.scrollView.width, self.scrollView.height) animated:NO];
    }
    
    // Cache selected orb to use later
    self.currentItem = (NSInteger)(indexOfPage + 0.5) % self.elementCount;
    
    // Call the block for visible items
    if ( self.viewDidScrolledBlock )
    {
        float scaleFactor = indexOfPage - floor(indexOfPage);
        NSInteger nextPage = currentPage + 1;
        if ( nextPage >= self.elementCount * 3 )
            nextPage = 0;
        
        NSInteger firstVisibleElement = (self.scrollView.contentOffset.x - self.scrollView.originX) / self.scrollView.width;
        NSInteger lastVisibleElement = firstVisibleElement + ((NSInteger)(self.width / self.scrollView.width))+1;
        
        for ( NSInteger n = firstVisibleElement; n <= lastVisibleElement; n++ )
        {
            CGFloat visibility = 0.0;
            if ( n % self.elementCount == currentPage % self.elementCount )
                visibility = 1.0 - scaleFactor;
            if ( n % self.elementCount == nextPage % self.elementCount )
                visibility = scaleFactor;
            self.viewDidScrolledBlock( (UIView*)self.elementsArray[n], visibility );
        }
    }
}

@end
