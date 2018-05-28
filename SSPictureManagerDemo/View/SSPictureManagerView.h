//
//  SSPictureManagerView.h
//  SSPictureManagerDemo
//  图片管理
//  Created by Sherry on 2018/5/24.
//  Copyright © 2018年 Sherry. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSPictureManagerView : UIView


/**
 最大显示数量 默认6张
 */
@property(nonatomic, assign)NSUInteger maxCount;

/**
 最大列数 一行多少个image 默认4个
 */
@property(nonatomic, assign)NSUInteger column;

/**
 列间距 默认0
 */
@property(nonatomic, assign)NSUInteger columnSpace;

/**
 行间距 默认0
 */
@property(nonatomic, assign)NSUInteger rowSpace;

/**
 长按图片持续时长 默认.5
 */
@property (nonatomic, assign)NSUInteger duration;

/**
 添加图片按钮
 */
@property (nonatomic, weak)UIButton *addButton;

/**
 图片拖拽的位置 如果什么都不执行返回No
 */
@property (nonatomic, copy)BOOL(^selectCompletion)(UIImageView *imageView,CGPoint currentPoint);

/**
 回传手势执行的方法  可通过此方法自行获取开始或者结束状态
 */
@property (nonatomic, copy) void(^longRecognizerAction)(UILongPressGestureRecognizer *longpress);

/**
 添加图片

 @param images 数据源
 */
- (void)addImages:(NSArray *)images;


/**
 删除图片

 @param imageView 需要删除的图片
 */
- (void)deleteImageView:(UIImageView *)imageView;



@end
