//
//  ScrollableLabel.m
//  AELFExchange
//
//  Created by tng on 2019/1/15.
//  Copyright © 2019 aelf.io. All rights reserved.
//

#import "ScrollableLabel.h"
#import <ReactiveObjC/ReactiveObjC.h>

@interface ScrollableLabel ()

@property (nonatomic, strong) RACDisposable *disposable;

@end

@implementation ScrollableLabel

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    self.orientation = AnimationFromTop;
}

#pragma mark - Private Methods

- (void)startAnimation {
    [self.disposable dispose];
    
    @weakify(self);
    self.disposable = [[[RACSignal interval:4 onScheduler:[RACScheduler currentScheduler]] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSDate * _Nullable x) {
        @strongify(self);
        NSUInteger nextIndex = (self.currentIndex == self.rollText.count - 1) ? 0 : self.currentIndex + 1;
        NSString *text = self.rollText[nextIndex];
        if (self.formatter) {
            text = self.formatter(text);
        }
        [self setAnimationText:text];
        self.currentIndex = nextIndex;
    }];
    
}

- (void)setAnimationText:(NSString *)text {
    CATransition  *animation = [CATransition animation];
    animation.duration = 0.5;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.type = kCATransitionPush;
    animation.subtype = [self subType];
    
    [self.layer addAnimation:animation forKey:@"changeTextTransition"];
    self.text = text;
}

#pragma mark - Setter & Getter

- (void)setRollText:(NSArray<NSString *> *)rollText {
    _rollText = rollText;
    if (rollText.count > 1) {
        NSString * text = rollText.firstObject;
        if (self.formatter) {
            text = self.formatter(text);
        }
        self.text = text;
        self.currentIndex = 0;
        [self startAnimation];
    }else if (rollText.count == 1) {
        NSString *text = rollText.firstObject;
        if (self.formatter) {
            text = self.formatter(text);
        }
        self.text = text;
        self.currentIndex = 0;
        [self.disposable dispose];
    }else {
        [self.disposable dispose];
    }
}

- (NSString *)subType {
    if (self.orientation == AnimationFromTop) {
        return kCATransitionFromTop;
    }else if (self.orientation == AnimationFromBottom) {
        return kCATransitionFromBottom;
    }else if (self.orientation == AnimationFromLeft) {
        return kCATransitionFromLeft;
    }else if (self.orientation == AnimationFromRight) {
        return kCATransitionFromRight;
    }else {
        return kCATransitionFromBottom;
    }
}

@end
