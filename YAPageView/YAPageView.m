//
//  YAPageView.m
//  YAPageView <https://github.com/ChenYalun/YAPageView>
//
//  Created by Chen,Yalun on 2019/8/2.
//  Copyright © 2019 Chen,Yalun. All rights reserved.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import "YAPageView.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wobjc-designated-initializers"

// 重写UIScrollView的事件响应方法 pointInside:withEvent:
@interface YAPageInnerScrollView : UIScrollView
@end
@implementation YAPageInnerScrollView
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {return YES;}
@end



//#define kLeft (_currentIndex - 1 + _imageArray.count) % _imageArray.count
//#define kRight (_currentIndex + 1) % _imageArray.count
#define kCount (_configImageHandler ? _imageURLArray.count : _imageArray.count)
#define kLeft (_currentIndex == 0 ? kCount - 1 : _currentIndex - 1)
#define kRight (_currentIndex == kCount - 1 ? 0 : _currentIndex + 1)

@interface YAPageView() <UIScrollViewDelegate>
@property (nonatomic, assign) BOOL leftLock;
@property (nonatomic, assign) BOOL rightLock;
@property (nonatomic, assign) CGFloat pageWidth;
@property (nonatomic, assign) CGFloat pageInset;
@property (nonatomic, assign) NSUInteger currentIndex;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, copy)   NSArray <UIImageView *> *pageArray;
@end
@implementation YAPageView

- (instancetype)initWithFrame:(CGRect)frame
                    pageWidth:(CGFloat)pageWidth
                    pageInset:(CGFloat)pageInset {
    if (self = [super initWithFrame:frame]) {
        if (pageWidth == 0) {
            [[NSException exceptionWithName:NSInvalidArgumentException reason:@"page width can not be 0" userInfo:nil] raise];
        }
        if (pageInset <= 0) {
            [[NSException exceptionWithName:NSInvalidArgumentException reason:@"page inset can not be <= 0" userInfo:nil] raise];
        }
        _pageWidth = pageWidth;
        _pageInset = pageInset;
        _scrollView = ({
            UIScrollView *scrollView = [YAPageInnerScrollView new];
            scrollView.pagingEnabled = YES;
            scrollView.showsHorizontalScrollIndicator = NO;
            scrollView.showsVerticalScrollIndicator = NO;
            scrollView.clipsToBounds = NO;
            scrollView.delegate = self;
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
            [scrollView addGestureRecognizer:tap];
            scrollView;
        });
        CGFloat x = (CGRectGetWidth(frame) - pageWidth) * 0.5; // 保持对称性
        _scrollView.frame = (CGRect){x, 0, pageWidth + pageInset, CGRectGetHeight(frame)};
        [self addSubview:_scrollView];
    }
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    if (newSuperview == nil) { // 视图从父视图移除时, 销毁定时器
        [_timer invalidate];
        _timer = nil;
    }
}

- (void)refresh {
    if (self.configImageHandler) {
        self.configImageHandler(self.pageArray[0], self.imageURLArray[kLeft]);
        self.configImageHandler(self.pageArray[1], self.imageURLArray[_currentIndex]);
        self.configImageHandler(self.pageArray[2], self.imageURLArray[kRight]);
    } else {
        self.pageArray[0].image = self.imageArray[kLeft];
        self.pageArray[1].image = self.imageArray[_currentIndex];
        self.pageArray[2].image = self.imageArray[kRight];
    }
    CGFloat x = self.scrollView.contentOffset.x;
    CGFloat width = self.pageWidth + self.pageInset;
    if (x == 0) {
        x = width;
    } else {
        x += x > width ? -width : width;
    }
    [self.scrollView setContentOffset:CGPointMake(x, 0)];
}

- (void)refreshForTransform3DWithOffsetX:(CGFloat)offsetX {
    if (!self.enableTransform3D) return;
    CGFloat width = self.pageInset * 0.5 + self.pageWidth;
    CGFloat h = 0.4; // 0.8 ~ 1.2
    CGFloat off = (offsetX > width) ? offsetX - width : width - offsetX;
    CGFloat scale = off / width * h;
    CGFloat maxScale = 1 + h * 0.5;
    CGFloat minScale = 1 - h * 0.5;
    self.pageArray[0].layer.transform = CATransform3DMakeScale(1, minScale + scale, 1);
    self.pageArray[1].layer.transform = CATransform3DMakeScale(1, maxScale - scale, 1);
    self.pageArray[2].layer.transform = CATransform3DMakeScale(1, minScale + scale, 1);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetX = self.scrollView.contentOffset.x;
    [self refreshForTransform3DWithOffsetX:offsetX];
    
    CGFloat width = CGRectGetWidth(self.scrollView.frame);
    // Turn left.
    if (offsetX > 2 * (width - self.pageInset)) self.rightLock = NO;
    if (!self.leftLock && offsetX < width - 2 * self.pageInset) {
        self.leftLock = YES;
        _currentIndex = kLeft;
        [self refresh];
    }
    // Turn right.
    if (offsetX < 2 * self.pageInset) self.leftLock = NO;
    if (!self.rightLock && offsetX > width + 2 * self.pageInset) {
        self.rightLock = YES;
        _currentIndex = kRight;
        [self refresh];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (self.timeInterval != 0) {
        [self.timer invalidate];
        _timer = nil;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self setTimeInterval:_timeInterval];
}

- (void)handleTapGesture:(UITapGestureRecognizer *)tap {
    CGFloat pointX = [tap locationInView:tap.view].x;
    NSUInteger idx = _currentIndex;
    if (pointX < self.pageWidth + self.pageInset) {
        idx = kLeft;
    } else if (pointX > 2 * self.pageWidth + self.pageInset) {
        idx = kRight;
    }
    if (self.tapHandler) self.tapHandler(idx, _imageArray[idx], _imageURLArray[idx]);
}

- (void)setImageArray:(NSArray<UIImage *> *)imageArray {
    if (imageArray.count < 3) return;
    _imageArray = imageArray;
    [self refresh];
}

- (void)setImageURLArray:(NSArray<NSURL *> *)imageURLArray {
    if (imageURLArray.count < 3) return;
    _imageURLArray = imageURLArray;
    [self refresh];
}

- (void)setTimeInterval:(CGFloat)timeInterval {
    _timeInterval = timeInterval;
    [_timer invalidate];
    _timer = nil;
    [NSRunLoop.currentRunLoop addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)setEnableTransform3D:(BOOL)enableTransform3D {
    _enableTransform3D = enableTransform3D;
    if (enableTransform3D) {
        [self refreshForTransform3DWithOffsetX:self.pageWidth + self.pageInset];
    }
}

- (NSArray <UIImageView *> *)pageArray {
    if (!_pageArray) {
        UIImageView *(^block)(void) = ^(void) {
            UIImageView *imageView = [UIImageView new];
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.clipsToBounds = YES;
            return imageView;
        };
        _pageArray = @[block(), block(), block()];
        CGFloat pageX = self.pageWidth + self.pageInset;
        CGFloat height = CGRectGetHeight(self.frame);
        [_pageArray enumerateObjectsUsingBlock:^(UIImageView *obj, NSUInteger idx, BOOL *stop) {
            obj.frame = CGRectMake(idx * pageX, 0, self.pageWidth, height);
            [self.scrollView addSubview:obj];
        }];
        self.scrollView.contentSize = CGSizeMake(_pageArray.count * pageX, height);
    }
    return _pageArray;
}

- (NSTimer *)timer {
    if (!_timer) {
        _timer = [NSTimer timerWithTimeInterval:_timeInterval repeats:YES block:^(NSTimer *timer) {
            [self.scrollView setContentOffset:CGPointMake(CGRectGetWidth(self.scrollView.frame) * 2, 0) animated:YES];
        }];
    }
    return _timer;
}
@end

#pragma clang diagnostic pop
