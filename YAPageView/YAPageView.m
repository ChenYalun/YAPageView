//
//  YAPageView.m
//  Aaron
//
//  Created by Chen,Yalun on 2019/8/2.
//  Copyright © 2019 Chen,Yalun. All rights reserved.
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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetX = self.scrollView.contentOffset.x;
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
    if (imageArray.count == 0) return;
    _imageArray = imageArray;
    [self refresh];
}

- (void)setImageURLArray:(NSArray<NSURL *> *)imageURLArray {
    if (imageURLArray.count == 0) return;
    _imageURLArray = imageURLArray;
    [self refresh];
}

- (void)setTimeInterval:(CGFloat)timeInterval {
    _timeInterval = timeInterval;
    [_timer invalidate];
    _timer = nil;
    [NSRunLoop.currentRunLoop addTimer:self.timer forMode:NSRunLoopCommonModes];
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

- (void)dealloc {
    NSLog(@"dealloc");
}
@end

#pragma clang diagnostic pop

// 间距处理
// 无限循环处理
// 点击事件处理
// 自动轮播处理
// 定时器\视图循环引用处理
// 优化点总结: 取余运算 点击事件
