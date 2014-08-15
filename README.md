Extended UI
====

Helpful UIKit extensions for Objective C:
* MLUIDefinitions - useful macros to check whether device is in retina mode, is it iPad or iPhone 5, etc
* MLUIView+Coordinates - UIView category that implements direct originX/Y, width/height, centerX/Y, origin and size setters and getters
* MLUIColor+HexColor - UIColor category with colorWithHexString to use with standard hex encoding like 0xFFFFFF
* MLUICarouselView - custom scrollview with single item pagination and rotation loop, check extended description below

MLUICarouselView
====

Could be used both in xib or programmatically to create a scrolling view that has:
* Single item pagination. Position for the selected item is specified via `setSelectionFrame:` or by `initWithFrame:andSelectionFrame:`
* Looped infinite rotation for the array of UIViews provided with `setElements:`
* Custom block that is called for every visible view upon scrolling if set using the property `void(^)viewDidScrolledBlock(UIView* view, CGFloat visibility)`
* Current item index that can be accessed by the property `currentItem`

```objc
    NSMutableArray* elements = [NSMutableArray arrayWithObjects:view1, view2, view3, nil];
	MLUICarouselView* carousel = [[MLUICarouselView alloc] initWithFrame:frame];
	[carousel setSelectionFrame:_characterScrollView.frame];
    [carousel addElements:elements];
    carousel.viewDidScrolledBlock = ^(UIView* view, CGFloat visibility) {        
        view.alpha = visibility;
    };
    [self.view addSubview:carousel];
```

> N

Contributing
====

1. Fork it. 
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create new Pull Request