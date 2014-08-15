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
@property (nonatomic) NSInteger elementCount;
@property (nonatomic) NSInteger totalElementCount;
@end

// Implementation
@implementation MLUICarouselView

#pragma mark - Initialization

- (void) initializeCarousel
{
    self.clipsToBounds = YES;
    
    // Setup scroll view
    _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    _scrollView.pagingEnabled = YES;
    _scrollView.scrollEnabled = YES;
    _scrollView.bounces = NO;
    _scrollView.clipsToBounds = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.delegate = self;
    _scrollView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [self addSubview:_scrollView];
    
    // Initialize variables
    _elementCount = 0;
    _totalElementCount = 0;
    _currentItem = 0;
}

- (instancetype) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
        [self initializeCarousel];
    
    return self;
}

- (instancetype) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
        [self initializeCarousel];
    
    return self;
}

- (instancetype) initWithFrame:(CGRect)frame andSelectionFrame:(CGRect)selection
{
    self = [self initWithFrame:frame];
    if (self)
        [self setSelectionFrame:selection];
    
    return self;
}

- (void) setSelectionFrame:(CGRect)selection
{
    if ( ! self.scrollView )
        return;
    
    _scrollView.frame = selection;
}

- (void) setElements:(NSArray*)elementsArray
{
    // Cleanup of the previously added elements and setup
    for ( UIView* subview in _scrollView.subviews )
        [subview removeFromSuperview];
    _elementsArray = [NSMutableArray array];
    _elementCount = elementsArray.count;
    _totalElementCount = _elementCount * 3;
    
    for ( NSInteger n = 0; n < _totalElementCount; n++ )
    {
        NSInteger index = n % _elementCount;
        UIView* element = elementsArray[index];
        
        // Creating deep copy of the view for all elements that are out of bounds
        if ( n >= _elementCount )
            element = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:element]];
        
        element.originX = _scrollView.width * n;
        [_elementsArray addObject:element];
        [_scrollView addSubview:element];
    }
    
    // Set scrollview content size
    _scrollView.contentSize = CGSizeMake(_scrollView.width * _totalElementCount, _scrollView.height);
    
    // Scroll to the default position
    [_scrollView scrollRectToVisible:CGRectMake(_scrollView.width * _elementCount,
                                                    0, _scrollView.width, _scrollView.height) animated:NO];
    [self updateViewsWithBlock];
}

- (void) setViewDidScrolledBlock:(MLUICarouselBlock)block
{
    _viewDidScrolledBlock = block;
    [self updateViewsWithBlock];
}

- (void) updateViewsWithBlock
{
    if ( ! _viewDidScrolledBlock )
        return;
    if ( _totalElementCount <= 0 )
        return;
    
    float indexOfPage = _scrollView.contentOffset.x / _scrollView.width;
    NSInteger currentPage = (NSInteger)indexOfPage;
    float scaleFactor = indexOfPage - floor(indexOfPage);
    NSInteger nextPage = currentPage + 1;
    if ( nextPage >= _totalElementCount )
        nextPage = 0;
    
    NSInteger firstVisibleElement = (_scrollView.contentOffset.x - _scrollView.originX) / _scrollView.width;
    if ( firstVisibleElement >= _totalElementCount )
        firstVisibleElement = _totalElementCount - 1;
    NSInteger lastVisibleElement = firstVisibleElement + ((NSInteger)(self.width / _scrollView.width))+1;
    if ( lastVisibleElement >= _totalElementCount )
        lastVisibleElement = _totalElementCount - 1;
    
    for ( NSInteger n = firstVisibleElement; n <= lastVisibleElement; n++ )
    {
        UIView* view = _elementsArray[n];
        CGFloat visibility = 0.0;
        if ( n % _elementCount == currentPage % _elementCount )
            visibility = 1.0 - scaleFactor;
        if ( n % _elementCount == nextPage % _elementCount )
            visibility = scaleFactor;
        _viewDidScrolledBlock( view, visibility );
    }
}

- (void) setCurrentItem:(NSInteger)currentItem
{
    [_scrollView scrollRectToVisible:CGRectMake(_scrollView.width * (_elementCount + currentItem),
                                                    0, _scrollView.width, _scrollView.height) animated:NO];
}

#pragma mark - UIView Overrides

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    return [self pointInside:point withEvent:event] ? _scrollView : nil;
}

#pragma mark - UIScrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ( _elementCount == 0 || ! _elementsArray )
        return;
    
    float indexOfPage = _scrollView.contentOffset.x / _scrollView.width;
    NSInteger currentPage = (NSInteger)indexOfPage;
    
    // Carousel looping
    if (currentPage < _elementCount)
        [_scrollView scrollRectToVisible:CGRectMake(_scrollView.contentOffset.x + _scrollView.width * _elementCount, 0, _scrollView.width, _scrollView.height) animated:NO];
    else if (currentPage >= self.elementCount*2 )
        [_scrollView scrollRectToVisible:CGRectMake( _scrollView.contentOffset.x - _scrollView.width * _elementCount, 0, _scrollView.width, _scrollView.height) animated:NO];
    
    // Cache selected orb to use later
    _currentItem = (NSInteger)(indexOfPage + 0.5) % _elementCount;
    
    // Call the block for visible items
    [self updateViewsWithBlock];
}

@end
