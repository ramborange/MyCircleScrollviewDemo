//
//  ViewController.m
//  MyCircleScrollviewDemo
//
//  Created by ramborange on 16/6/12.
//  Copyright © 2016年 ______MyCompanyName______. All rights reserved.
//

#import "ViewController.h"
#import "MyCustomView.h"

#define PAGE_NUM   5

@interface ViewController () <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollview;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

@property (strong, nonatomic) NSMutableArray *dataArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationController.navigationBar.translucent = NO;
    
    //设置scrollview的contentsize 这里我们只需要三个页面实现无限滚动
    _scrollview.contentSize = CGSizeMake(self.view.bounds.size.width*3, 0);
    
    //在scrollView上创建三个子视图，用来循环滚动
    for (int i=0; i<3; i++) {
        MyCustomView *view = [[MyCustomView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width*i, 0, self.view.bounds.size.width, self.view.bounds.size.height-64)];
        view.tag = 100+i;
        [_scrollview addSubview:view];
    }
    
    //scrollview开始设置偏移在中间位置 为了向两边循环
    [_scrollview setContentOffset:CGPointMake(self.view.bounds.size.width, 0) animated:NO];
    
    //初始化page control的状态
    [_pageControl setNumberOfPages:PAGE_NUM];
    [_pageControl setCurrentPage:0];
    
    //构造一个数据源数组  这里以NSNumber作为示范 代表数据在数组中的位置
    /***
     这里的 Page Numer可以为非0任何数
     **/
    _dataArray = [NSMutableArray array];
    if (PAGE_NUM) {
        for (int i=0; i<MAX(PAGE_NUM, 3); i++) {
            if (i>=PAGE_NUM) {
                [_dataArray addObject:_dataArray[i-1]];
            }else {
                [_dataArray addObject:@(i)];
            }
        }
        //调整第一个显示的数据
        [_dataArray insertObject:_dataArray[PAGE_NUM-1] atIndex:0];
        [_dataArray removeObjectAtIndex:PAGE_NUM];
    }
    
    //刷新一下UI 显示数据
    if (PAGE_NUM) {
        [self updateSubView];
    }
}

//当数组里的数组顺序发生改变时 更新数据
- (void)updateSubView {
    for (UIView *view in [_scrollview subviews]) {
        if ([view isKindOfClass:[MyCustomView class]]) {
            MyCustomView *customView = (MyCustomView *)view;
            //刷新UI数据
            customView.NoLabel.text = [_dataArray[view.tag-100] stringValue];
        }
    }
}

//当scrollview向前滚动 改变数据数组中的一次向前滚动一
- (void)updateDataSourceForward {
    if (PAGE_NUM==2) {
        //当数据只有两个时  滚动的情况就只有两个状态 1 0 1 和 0 1 0
        [_dataArray insertObject:_dataArray[1] atIndex:0];
        [_dataArray removeObjectAtIndex:3];
    }else {
        [_dataArray insertObject:_dataArray[0] atIndex:PAGE_NUM];
        [_dataArray removeObjectAtIndex:0];
    }
}

//当scrollview向后滚动 改变数据数组中的一次向后滚动一
- (void)updateDataSourceBack {
    if (PAGE_NUM==2) {
        //当数据只有两个时  滚动的情况就只有两个状态 1 0 1 和 0 1 0
        [_dataArray insertObject:_dataArray[1] atIndex:0];
        [_dataArray removeObjectAtIndex:3];
    }else {
        [_dataArray insertObject:_dataArray[PAGE_NUM-1] atIndex:0];
        [_dataArray removeObjectAtIndex:PAGE_NUM];
    }
}

#pragma mark - UIScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    float c = scrollView.contentOffset.x/self.view.bounds.size.width;//滚动视图偏移量比例
    int p = (int)c;//当前显示的视图序号
    float f = fabsf(c-p);//当前视图的偏移量
    
    MyCustomView *v1 = [self.view viewWithTag:100+p];//当前视图
    MyCustomView *v2 = [self.view viewWithTag:100+p+1];//即将出现的视图
    float scale1 = 1-f/10.0;//当前视图的大小变化
    float alpha1 = f/2.0;//当前视图的阴影变化
    float scale2 = 1-(1.0-f)/10.0;//即将出现的视图的大小变化
    float alpha2 = (1.0-f)/2.0;//即将出现视图的阴影变化
    v1.transform = CGAffineTransformMakeScale(scale1, scale1);//设置当前视图的大小缩放
    v1.backgroundColor = [UIColor colorWithWhite:0 alpha:alpha1];//设置当前视图的阴影透明度
    v2.transform = CGAffineTransformMakeScale(scale2, scale2);//设置即将出现视图的大小缩放
    v2.backgroundColor = [UIColor colorWithWhite:0 alpha:alpha2];//设置即将出现视图的阴影透明度
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (PAGE_NUM) {
        if (scrollView.contentOffset.x<_scrollview.bounds.size.width) {
            //视图向左边滚动 页面控制器页面索引-1
            if (_pageControl.currentPage<=0) {
                [_pageControl setCurrentPage:PAGE_NUM];
            }else {
                [_pageControl setCurrentPage:--_pageControl.currentPage];
            }
            //数据数组中的数据 也以闭环的形式向前滚动一个 视图向后退了一个
            [self updateDataSourceBack];
            
        }else if (scrollView.contentOffset.x>_scrollview.bounds.size.width) {
            if (_pageControl.currentPage>=PAGE_NUM-1) {
                [_pageControl setCurrentPage:0];
            }else {
                [_pageControl setCurrentPage:++_pageControl.currentPage];
            }
            //数据数组中的数据 也以闭环的形式向后滚动一个 视图向前进了一个
            [self updateDataSourceForward];
            
        }else {
            //不做任何改变
        }
        //更新数据
        [self updateSubView];
        
        [_scrollview setContentOffset:CGPointMake(self.view.bounds.size.width, 0) animated:NO];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
