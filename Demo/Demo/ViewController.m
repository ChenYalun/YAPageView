//
//  ViewController.m
//  Demo
//
//  Created by Chen,Yalun on 2019/8/7.
//  Copyright © 2019 Chen,Yalun. All rights reserved.
//

#import "ViewController.h"
#import "YAPageView.h"
#import "SDWebImage/UIImageView+WebCache.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    YAPageView *pageView = [[YAPageView alloc] initWithFrame:CGRectMake(0, 200, self.view.bounds.size.width, 200) pageWidth:320 pageInset:10];
    /*
     // local image list.
    pageView.imageArray = @[
                            [UIImage imageNamed:@"1"],
                            [UIImage imageNamed:@"2"],
                            [UIImage imageNamed:@"3"],
                            [UIImage imageNamed:@"4"],
                            [UIImage imageNamed:@"5"],
    ];
    */
    
    pageView.configImageHandler = ^(UIImageView *imageView, NSURL *url) {
        [imageView sd_setImageWithURL:url];
    };
    
    // The demo image is too large...
    pageView.imageURLArray = @[
                           [NSURL URLWithString:@"https://picsum.photos/id/230/350/200"],
                           [NSURL URLWithString:@"https://picsum.photos/id/231/350/200"],
                           [NSURL URLWithString:@"https://picsum.photos/id/232/350/200"],
                           [NSURL URLWithString:@"https://picsum.photos/id/233/350/200"],
                           [NSURL URLWithString:@"https://picsum.photos/id/234/350/200"],
                           [NSURL URLWithString:@"https://picsum.photos/id/235/350/200"]
    ];
    
    
    __weak typeof(self) weakSelf = self;
    pageView.tapHandler = ^(NSUInteger idx, UIImage *img, NSURL *url) {
        __strong typeof(weakSelf) self = weakSelf;
        NSLog(@"self = %@, index = %lu, url = %@", self, (unsigned long)idx, url);
        [self.navigationController popViewControllerAnimated:YES];
    };
    
    pageView.timeInterval = 3.f;
    [self.view addSubview:pageView];
}
@end
