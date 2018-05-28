//
//  ViewController.m
//  SSPictureManagerDemo
//
//  Created by Sherry on 2018/5/24.
//  Copyright © 2018年 Sherry. All rights reserved.
//

#import "ViewController.h"
#import "SSPictureManagerView.h"
#import <Masonry.h>

//屏幕宽高
#define SScreenWidth [UIScreen mainScreen].bounds.size.width
#define SScreenHeight [UIScreen mainScreen].bounds.size.height

@interface ViewController ()
{
    SSPictureManagerView *_pictureManagerView;
    NSMutableArray *_sourceImages;
    UILabel *_deleteLabel;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _sourceImages = [[NSMutableArray alloc] init];
    [self deleteView];
    //搭建图片管理视图
    SSPictureManagerView *pictureVC = [[SSPictureManagerView alloc] initWithFrame:CGRectMake(0, 100, SScreenWidth, SScreenHeight-100)];
    pictureVC.maxCount = 16;
    pictureVC.columnSpace = 10;
    pictureVC.rowSpace = 15;
    pictureVC.duration = .35;
    _pictureManagerView = pictureVC;
    [pictureVC.addButton addTarget:self action:@selector(clickAction:) forControlEvents:UIControlEventTouchUpInside];
    pictureVC.selectCompletion = ^BOOL(UIImageView *imageView, CGPoint currentPoint) {
        if (currentPoint.y >=SScreenHeight-100) {
            [_sourceImages removeAllObjects];
            [_pictureManagerView deleteImageView:imageView];
            return YES;
        }
        return NO;
    };
    //长按开始
    pictureVC.longRecognizerAction = ^(UILongPressGestureRecognizer *longpress) {
        if (longpress.state== UIGestureRecognizerStateBegan) {
            [self start];
        }else if(longpress.state== UIGestureRecognizerStateEnded){
            [self stop];
        }
    };
    [self.view addSubview:pictureVC];
    [pictureVC mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.offset(0);
        make.top.offset(100);
        make.bottom.offset(0);
    }];
}

//加载删除按钮
- (void)deleteView{
    UILabel *view = [[UILabel alloc] initWithFrame:CGRectMake(0,SScreenHeight , SScreenWidth, 100)];
    view.backgroundColor = [UIColor redColor];
    _deleteLabel = view;
    view.textColor = [UIColor whiteColor];
    view.text = @"拖到此处删除";
    view.textAlignment = NSTextAlignmentCenter;
    view.font = [UIFont systemFontOfSize:15];
    [self.view addSubview:view];
}

#pragma mark - 按钮点击事件
//添加图片
- (void)clickAction:(UIButton *)sender{
    [_sourceImages addObjectsFromArray:@[[UIImage imageNamed:@"testImage@2x.png"],[UIImage imageNamed:@"testImage@2x.png"],[UIImage imageNamed:@"testImage@2x.png"]]];
    [_pictureManagerView addImages:_sourceImages];
}

#pragma Mark- 动画开始与结束
//开始
- (void)start{
    CGRect rect = _deleteLabel.frame;
    rect.origin.y = SScreenHeight-100;
    [UIView animateWithDuration:.35 animations:^{
        _deleteLabel.frame = rect;
    }];
}

//结束
- (void)stop{
    CGRect rect = _deleteLabel.frame;
    rect.origin.y = SScreenHeight+100;
    [UIView animateWithDuration:.35 animations:^{
        _deleteLabel.frame = rect;
    }];
}


@end
