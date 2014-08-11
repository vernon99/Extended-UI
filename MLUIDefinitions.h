
//
//  MLDefinitions.h
//  Extended UI
//
//  Created by Mikhail Larionov on 03/08/14
//
//

#define MLUI_DEVICE_IS_IPAD (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)

#define MLUI_DEVICE_IS_IPHONE_5 ([UIScreen mainScreen].bounds.size.height == 568.f)

#define MLUI_DEVICE_IN_RETINA_MODE                                            \
([[UIScreen mainScreen] respondsToSelector:@selector(scale)] && [UIScreen mainScreen].scale > 1)

#define IOS_NEWER_OR_EQUAL_TO_7 ( [ [ [ UIDevice currentDevice ] systemVersion ] floatValue ] >= 7.0 )

#define KEYBOARD_HEIGHT 216.f

#define SUPPRESS_PERFORM_SELECTOR_LEAK_WARNING(code)                    \
_Pragma("clang diagnostic push")                                        \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"")     \
code;                                                                   \
_Pragma("clang diagnostic pop")                                         \

CG_INLINE float vectorLength(CGPoint p) { return sqrt(p.x * p.x + p.y * p.y); }
CG_INLINE float distance2Vectors(CGPoint p1, CGPoint p2) {
    return sqrtf((p2.x-p1.x)*(p2.x-p1.x)+(p2.y-p1.y)*(p2.y-p1.y)); }