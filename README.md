# YAPageView

<p align="center">
<a href="http://blog.chenyalun.com"><img src="https://img.shields.io/badge/Language-%20Objective--C%20-blue.svg"></a>
<a href="http://blog.chenyalun.com"><img src="https://img.shields.io/badge/platform-iOS-brightgreen.svg?style=flat"></a>
<a href="http://blog.chenyalun.com"><img src="http://img.shields.io/badge/license-MIT-orange.svg?style=flat"></a>
</p>



## Usage

+ Paged scrollView with custom paging width and inset, e.g:

#### Local image array

```objective-c
    YAPageView *pageView = [[YAPageView alloc] initWithFrame:CGRectMake(0, 200, kScreenWidth, 200) controller:self pageWidth:300 pageInset:20];
    pageView.imageArray = @[
        [UIImage imageNamed:@"1"],
        [UIImage imageNamed:@"2"],
        [UIImage imageNamed:@"3"],
        [UIImage imageNamed:@"4"],
    ];
```

#### Network image url array

```objective-c
    // If you use SDWebImage, you can set it as follows:
    pageView.configImageHandler = ^(UIImageView *imageView, NSURL *url) {
       [imageView sd_setImageWithURL:url];
    };
    
    pageView.imageURLArray = @[
        [NSURL URLWithString:@"https://picsum.photos/id/230/350/200"],
        [NSURL URLWithString:@"https://picsum.photos/id/231/350/200"],
        [NSURL URLWithString:@"https://picsum.photos/id/232/350/200"],
        [NSURL URLWithString:@"https://picsum.photos/id/233/350/200"],
        [NSURL URLWithString:@"https://picsum.photos/id/234/350/200"],
        [NSURL URLWithString:@"https://picsum.photos/id/235/350/200"]
    ];
```

#### Automatic Loop Play

```objective-c
    pageView.timeInterval = 3.f;
```
#### Click event callback

```objective-c
    __weak typeof(self) weakSelf = self;
    pageView.tapHandler = ^(NSUInteger idx, UIImage *img, NSURL *url) {
       __strong typeof(weakSelf) self = weakSelf;
       [self.navigationController popViewControllerAnimated:YES];
    };
```
## Demo
![](/Resource/demo.gif)

## Article

[开源项目：YAPageView](https://blog.chenyalun.com/2019/08/07/开源项目：YAPageView/)

## Author
[Yalun, Chen](http://chenyalun.com)

## License

YAScrollPlaceView is available under the MIT license. See the LICENSE file for more info.




