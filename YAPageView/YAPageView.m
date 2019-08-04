//
//  YAPageView.m
//  Aaron
//
//  Created by Chen,Yalun on 2019/8/2.
//  Copyright © 2019 Chen,Yalun. All rights reserved.
//

#import "YAPageView.h"

// 重写UIScrollView的事件响应方法 pointInside:withEvent:
@interface YAPageInnerScrollView : UIScrollView
@end
@implementation YAPageInnerScrollView
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {return YES;}
@end



#define kSelfHeight CGRectGetHeight(self.frame)
#define kSelfWidth  CGRectGetWidth(self.frame)
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wobjc-designated-initializers"
@implementation YAPageView
- (instancetype)initWithFrame:(CGRect)frame
                    pageWidth:(CGFloat)pageWidth
                    pageInset:(CGFloat)pageInset {
    self = [super initWithFrame:frame];
    if (self) {
        _scrollView = ({
            UIScrollView *scrollView = [YAPageInnerScrollView new];
            scrollView.pagingEnabled = YES;
            scrollView.showsHorizontalScrollIndicator = NO;
            scrollView.showsVerticalScrollIndicator = NO;
            scrollView.clipsToBounds = NO;
            scrollView;
        });
        [self addSubview:_scrollView];
        [self configPageViewWithPageWidth:pageWidth pageInset:pageInset];
    }
    return self;
}

- (void)configPageViewWithPageWidth:(CGFloat)pageWidth pageInset:(CGFloat)pageInset {
    _pageWidth = pageWidth;
    _pageInset = pageInset;
    CGFloat x = (kSelfWidth - pageWidth) * 0.5; // 保持对称性
    self.scrollView.frame = CGRectMake(x, 0, pageWidth + pageInset, kSelfHeight);
}

- (void)setPageViewArray:(NSArray<UIView *> *)pageViewArray {
    _pageViewArray = pageViewArray;
    // 移除原先的所有子视图
    [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    CGFloat pageX = self.pageWidth + self.pageInset;
    [pageViewArray enumerateObjectsUsingBlock:^(UIView *obj, NSUInteger idx, BOOL *stop) {
        obj.frame = CGRectMake(idx * pageX, 0, self.pageWidth, kSelfHeight);
        [self.scrollView addSubview:obj];
    }];
    self.scrollView.contentSize = CGSizeMake(pageViewArray.count * pageX, kSelfHeight);
}
@end

#pragma clang diagnostic pop
