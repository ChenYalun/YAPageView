//
//  YAPageView.h
//  Aaron
//
//  Created by Chen,Yalun on 2019/8/2.
//  Copyright © 2019 Chen,Yalun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YAPageView : UIView
@property (nonatomic, strong, readonly) UIScrollView *scrollView; ///< 内部UIScrollView
@property (nonatomic, assign, readonly) CGFloat pageWidth;        ///< 页面宽度
@property (nonatomic, assign, readonly) CGFloat pageInset;        ///< 页面间距
@property (nonatomic, copy) NSArray <UIView *> *pageViewArray;    ///< page视图数组

- (instancetype)initWithFrame:(CGRect)frame
                    pageWidth:(CGFloat)pageWidth
                    pageInset:(CGFloat)pageInset NS_DESIGNATED_INITIALIZER;
@end

