//
//  YAPageView.h
//  Aaron
//
//  Created by Chen,Yalun on 2019/8/2.
//  Copyright © 2019 Chen,Yalun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YAPageView : UIView

/**
 自动轮播时间间隔, 不设置则不自动轮播
 */
@property (nonatomic, assign) CGFloat timeInterval;

/**
 本地图片数组
 */
@property (nonatomic, copy) NSArray <UIImage *> *imageArray;

/**
 网络图片URL数组
 */
@property (nonatomic, copy) NSArray <NSURL *> *imageURLArray;

/**
 你应该先设置configImageHandler, 再设置imageURLArray.
 视图会根据configImageHandler, 将URL配置到UIImageView上.
 当设置imageURLArray后, imageArray将会失效.
 
 可以使用SDWebImage设置, 比如:
 pageView.configImageHandler = ^(UIImageView *imageView, NSURL *url) {
     [imageView sd_setImageWithURL:url];
 };
 */
@property (nonatomic, copy) void (^configImageHandler)(UIImageView *imageView,NSURL *url);

/**
 视图点击回调, 如果是本地图片, url会为空, 当然, 如果是网络图片, img会为空
 */
@property (nonatomic, copy) void (^tapHandler)(NSUInteger idx, UIImage *img, NSURL *url);

- (instancetype)initWithFrame:(CGRect)frame
                    pageWidth:(CGFloat)pageWidth
                    pageInset:(CGFloat)pageInset NS_DESIGNATED_INITIALIZER;
@end

