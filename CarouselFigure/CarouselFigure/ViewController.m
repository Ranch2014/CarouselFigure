//
//  ViewController.m
//  CarouselFigure
//
//  Created by 焦相如 on 6/28/16.
//  Copyright © 2016 jaxer. All rights reserved.
//

#import "ViewController.h"

#define kImageCount 5
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

@interface ViewController () <UIScrollViewDelegate>
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) NSTimer *timer;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //添加图片
    for (int i=0; i<kImageCount; i++) {
        NSString *str = [NSString stringWithFormat:@"%d", i+1];
        UIImage *image = [UIImage imageNamed:str];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.scrollView.bounds];
        imageView.image = image;
        [self.scrollView addSubview:imageView];
    }
    
    //计算 imageView 的位置
    [self.scrollView.subviews enumerateObjectsUsingBlock:^(UIImageView *imageView, NSUInteger idx, BOOL *stop){
        CGRect frame = imageView.frame;
        frame.origin.x = idx * frame.size.width;
        imageView.frame = frame;
    }];
    
    self.pageControl.currentPage = 0; //初始分页为0
    
    [self startTimer];
}

/** 启动时钟 */
- (void)startTimer
{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:2.0
                                                  target:self
                                                selector:@selector(updateTimer)
                                                userInfo:nil
                                                 repeats:YES];
}

- (void)updateTimer
{
    int page = (self.pageControl.currentPage + 1) % kImageCount;
    self.pageControl.currentPage = page;
    [self pageChanged:self.pageControl];
}

/** 图片偏移 */
- (void)pageChanged:(UIPageControl *)pageControl
{
    CGFloat x = pageControl.currentPage * self.scrollView.bounds.size.width;
    [self.scrollView setContentOffset:CGPointMake(x, 0) animated:YES];
}

#pragma mark - getter

- (UIScrollView *)scrollView
{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.frame = CGRectMake(10, 20, kScreenWidth-20, (kScreenWidth-20) * 0.75);
        [self.view addSubview:_scrollView];
        
        //高度为0, 只水平滚动 (若数字较大，则可上下拖动)
        _scrollView.contentSize = CGSizeMake(kImageCount * (kScreenWidth-20), 0);
        _scrollView.bounces = NO; //取消弹簧效果
        _scrollView.showsHorizontalScrollIndicator = NO; //水平滚动条
        _scrollView.showsVerticalScrollIndicator = NO; //竖直滚动条
        _scrollView.pagingEnabled = YES; //分页显示(图片整个显示)
        _scrollView.delegate = self;
    }
    return _scrollView;
}

- (UIPageControl *)pageControl
{
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc] init];
        _pageControl.numberOfPages = kImageCount; //总页数
        CGSize size = [_pageControl sizeForNumberOfPages:5];
        _pageControl.bounds = CGRectMake(0, 0, size.width, size.height); //控件尺寸
        _pageControl.center = CGPointMake(self.view.center.x, (kScreenWidth-20) * 0.75 - 20); //中心点位置
        _pageControl.pageIndicatorTintColor = [UIColor grayColor]; //指示器颜色
        _pageControl.currentPageIndicatorTintColor = [UIColor whiteColor]; //当前的颜色
        [self.view addSubview:_pageControl];
        
        [_pageControl addTarget:self
                         action:@selector(pageChanged:)
               forControlEvents:UIControlEventValueChanged]; //点击没反应？？？
    }
    return _pageControl;
}

#pragma mark - UIScrollView delegate

//滚动停止时调用
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSLog(@"%@", NSStringFromCGPoint(scrollView.contentOffset));
    int page = scrollView.contentOffset.x / scrollView.bounds.size.width;
    self.pageControl.currentPage = page;
}

//用户抓住时停止计时
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.timer invalidate];
}

//松手继续计时
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self startTimer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
