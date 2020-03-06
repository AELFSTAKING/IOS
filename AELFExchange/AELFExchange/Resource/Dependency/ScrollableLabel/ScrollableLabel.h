//
//  ScrollableLabel.h
//  AELFExchange
//
//  Created by tng on 2019/1/15.
//  Copyright © 2019 aelf.io. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ScrollableLabel : UILabel

typedef NS_ENUM(NSUInteger, AnimationOrientation) {
    AnimationFromLeft,
    AnimationFromRight,
    AnimationFromBottom,
    AnimationFromTop
};

@property (nonatomic, strong) NSArray<NSString *> *rollText;
@property (nonatomic, assign) NSUInteger currentIndex;
@property (nonatomic, assign) AnimationOrientation orientation;
@property (nonatomic, copy) NSString* (^formatter)(NSString *text);

@end

NS_ASSUME_NONNULL_END
