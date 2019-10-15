//
//  YAPageView.h
//  YAPageView <https://github.com/ChenYalun/YAPageView>
//
//  Created by Chen,Yalun on 2019/8/2.
//  Copyright © 2019 Chen,Yalun. All rights reserved.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import <UIKit/UIKit.h>

@interface YAPageView : UIView

/**
 Cyclic time interval. If it is not set, it will not play automatically.
 */
@property (nonatomic, assign) CGFloat timeInterval;

/**
 Default NO.
 */
@property (nonatomic, assign) BOOL enableTransform3D;

/**
 Local Pictures.
 */
@property (nonatomic, copy) NSArray <UIImage *> *imageArray;

/**
 Network picture URL array.
 */
@property (nonatomic, copy) NSArray <NSURL *> *imageURLArray;

/**
 You should set configImageHandler first, then imageURLArray.

 If you use SDWebImage, you can set it as follows:
 pageView.configImageHandler = ^(UIImageView *imageView, NSURL *url) {
     [imageView sd_setImageWithURL:url];
 };
 */
@property (nonatomic, copy) void (^configImageHandler)(UIImageView *imageView,NSURL *url);

/**
 Click callback. Url will be nil if it is for local image, also, img will be nil if it is for network picture.
 */
@property (nonatomic, copy) void (^tapHandler)(NSUInteger idx, UIImage *img, NSURL *url);

- (instancetype)initWithFrame:(CGRect)frame
                    pageWidth:(CGFloat)pageWidth
                    pageInset:(CGFloat)pageInset NS_DESIGNATED_INITIALIZER;
@end

