//
//  SSPictureManagerView.m
//  SSPictureManagerDemo
//
//  Created by Sherry on 2018/5/24.
//  Copyright © 2018年 Sherry. All rights reserved.
//

#import "SSPictureManagerView.h"
#import <Masonry/Masonry.h>
#import "NSObject+SSBindValue.h"

static NSString *_imageIndexKey = @"imageIndexKey";


@interface SSPictureManagerView()
{
    NSMutableArray *_currentImages;   //图片数据源
    NSUInteger _currentIndex;//当前index
    BOOL _autoLayout;                       //自动布局
    NSMutableArray *_currentImageViews;
    CGPoint _startPoint; //保存开始的位置
    CGPoint _imagePoint;//记录image变换的位置
    NSUInteger _currentTag;//记录图片未改之前的tag 为了删掉images数组里的元素
}
@end

@implementation SSPictureManagerView

-(instancetype)init{
    if(self = [super init]) {
        _autoLayout = YES;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        _currentIndex = 0;
        //默认值赋值
        _maxCount = 6;
        _column = 4;
        _currentImageViews = [[NSMutableArray alloc] init];
        _currentImages = [[NSMutableArray alloc] init];
        _duration = .5;
        
    }
    return self;
}

//预加载
- (void)prepareForLoad{
    [self initAddButton];
}

#pragma mrak - 搭建视图
- (void)initContentView:(NSArray *)images{
    NSInteger row = 0;// i/count;
    NSInteger column = 0;  //i%count;
    CGFloat imageWidth = (self.bounds.size.width-((_column-1)*_columnSpace))/_column;
    CGFloat imageHeight = (self.bounds.size.width - _rowSpace)/_column;

    for (NSUInteger i = _currentIndex; i < images.count; i++) {
        //行
        row = i/_column;
        //列
        column = i%_column;
        //当前index
        _currentIndex ++;
        
        //imageview
        UIImageView *imagev = [[UIImageView alloc] initWithFrame:CGRectMake(column*(imageWidth+_columnSpace), row*imageHeight, imageWidth, imageHeight-_rowSpace)];
        UIImage *image = _currentImages[i];
        [image bindValue:@"i" forKey:_imageIndexKey];
        imagev.image = image;
        imagev.userInteractionEnabled = YES;
        imagev.tag = i;
        [self addSubview:imagev];
        [_currentImageViews addObject:imagev];
        
        //添加手势
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longRecognizerAction:)];
        longPress.minimumPressDuration = _duration;
        [imagev addGestureRecognizer:longPress];
    }
     [self updateAddButtonPoint];
    [self updateViewHeight];
}

//添加图片按钮
-(void)initAddButton{
    [self layoutIfNeeded];
    CGFloat imageWidth = (self.bounds.size.width-((_column-1)*_columnSpace))/_column;
    CGFloat imageHeight = (self.bounds.size.width - _rowSpace)/_column;
    UIButton *addbt = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, imageWidth, imageHeight-_rowSpace)];
    addbt.backgroundColor = [UIColor colorWithWhite:0 alpha:.1];
    [addbt setImage:[UIImage imageNamed:@"addImage@2x.png"] forState:UIControlStateNormal];
    addbt.imageView.contentMode = UIViewContentModeScaleToFill;
    _addButton = addbt;
    [self addSubview:addbt];
    [self updateViewHeight];
}

#pragma mark - 手势触动的方法
//长按
- (void)longRecognizerAction:(UILongPressGestureRecognizer *)sender{
    UIImageView *imageV = (UIImageView *)sender.view;
    //长按以后添加平移手势
    if (sender.state == UIGestureRecognizerStateBegan) {
        [self bringSubviewToFront:imageV];
        _currentTag = imageV.tag;
        _startPoint = [sender locationInView:imageV];
        _imagePoint = imageV.center;
        
        //放大视图
        imageV.transform = CGAffineTransformMakeScale(1.1, 1.1);
        if (_longRecognizerAction) {
            _longRecognizerAction(sender);
        }
    }else if (sender.state == UIGestureRecognizerStateChanged){
        //移动的过程
        CGPoint newPoint = [sender locationInView:imageV];
        CGFloat deltaX = newPoint.x - _startPoint.x;
        CGFloat deltaY = newPoint.y - _startPoint.y;
        imageV.center = CGPointMake(imageV.center.x + deltaX, imageV.center.y + deltaY);
        NSInteger fromIndex = imageV.tag;
        NSInteger toIndex = [self judgeMoveByButtonPoint:imageV.center moveButton:imageV];
        if (toIndex < 0) {
            return;
        } else {
            imageV.tag = toIndex;
            // 向后移动
            if (fromIndex - toIndex < 0) {
                for (NSInteger i = fromIndex; i < toIndex; i ++) {
                    UIImageView *nextBtn = _currentImageViews[i+1];
                    // 改变按钮中心点的位置
                    CGPoint temp = nextBtn.center;
                    [UIView animateWithDuration:0.5 animations:^{
                        nextBtn.center = _imagePoint;
                    }];
                    _imagePoint = temp;
                    // 交换tag值
                    nextBtn.tag = i;
                }
                [self sortArray];
            } else if (fromIndex - toIndex > 0) {
                // 向前移动
                for (NSInteger i = fromIndex; i > toIndex; i --) {
                    UIImageView *beforBtn = _currentImageViews[i - 1];
                    CGPoint temp = beforBtn.center;
                    [UIView animateWithDuration:0.5 animations:^{
                        beforBtn.center = _imagePoint;
                    }];
                    _imagePoint = temp;
                    beforBtn.tag = i;
                }
                [self sortArray];
            }
        }
    }else{
        if (_longRecognizerAction) {
            _longRecognizerAction(sender);
        }
        CGPoint point = [sender locationInView:self.superview];
        BOOL contine = NO;
        if(_selectCompletion){
          contine =  _selectCompletion(imageV,point);
        }
        if (!contine) {
            imageV.center = _imagePoint;
        }
        imageV.transform = CGAffineTransformIdentity;
    }
}

#pragma mark - 添加或者删除图片
//添加图片
- (void)addImages:(NSArray *)images{
    for (UIImage *image in images) {
        if (_currentImages.count<_maxCount) {
            [_currentImages addObject:image];
        }
    }
    [self initContentView:_currentImages];
}

//删除图片
- (void)deleteImageView:(UIImageView *)imageView{
    _currentIndex -= 1;
    for (NSInteger i = imageView.tag+1; i < _currentImageViews.count; i ++) {
        UIImageView *nextBtn = _currentImageViews[i];
        // 改变按钮中心点的位置
        CGPoint temp = nextBtn.center;
        [UIView animateWithDuration:0.5 animations:^{
            nextBtn.center = _imagePoint;
        }];
        _imagePoint = temp;
    }
    [_currentImageViews removeObject:imageView];
    [_currentImageViews enumerateObjectsUsingBlock:^(UIImageView *imageV, NSUInteger idx, BOOL * _Nonnull stop) {
        imageV.tag = idx;
    }];
    [_currentImages removeObjectAtIndex:_currentTag];

    [imageView removeFromSuperview];
    [self sortArray];
    [UIView animateWithDuration:0.5 animations:^{
        [self updateAddButtonPoint];
        [self updateViewHeight];
    }];
}

#pragma 更新frame
//跟新self的高度
- (void)updateViewHeight{
//    CGFloat imageHeight = (self.bounds.size.width - _rowSpace)/_column;
//    //行
//    NSUInteger row = _currentImageViews.count/_column;
    // 更新一下高度
    if (_autoLayout) {
        [self mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@(_addButton.frame.origin.y+_addButton.frame.size.height));
        }];
    }else{
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.bounds.size.width, _addButton.frame.origin.y+_addButton.frame.size.height);
    }
}

//更新添加按钮point
-(void)updateAddButtonPoint{
    //行
    NSUInteger row = (_currentImageViews.count)/_column;
    //列
    NSUInteger column = (_currentImageViews.count)%_column;
    CGFloat imageWidth = (self.bounds.size.width-((_column-1)*_columnSpace))/_column;
    CGFloat imageHeight = (self.bounds.size.width - _rowSpace)/_column;
    if (_currentImageViews.count == _maxCount) {
        UIImageView *imagev = _currentImageViews[_currentImageViews.count-1];
        _addButton.frame =imagev.frame;
    }else{
        _addButton.frame = CGRectMake(column*(imageWidth+_columnSpace), row*imageHeight, imageWidth, imageHeight-_rowSpace);
    }
    if (_currentImageViews.count == _maxCount) {
        _addButton.hidden = YES;
    }else{
        _addButton.hidden = NO;
    }
}

#pragma mark - 私有方法
- (void)sortArray
{
    // 对已改变按钮的数组进行排序
    [_currentImageViews sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        UIImageView *temp1 = (UIImageView *)obj1;
        UIImageView *temp2 = (UIImageView *)obj2;
        return temp1.tag > temp2.tag;    //将tag值大的按钮向后移
    }];
}

- (NSInteger)judgeMoveByButtonPoint:(CGPoint)point moveButton:(UIImageView *)imageView
{
    /**
     * 判断移动按钮的中心点是否包含了所在按钮的中心点如果是将i返回
     */
    for (NSInteger i = 0; i < _currentImageViews.count; i++) {
        UIImageView *imagev = _currentImageViews[i];
        if (!imageView || imagev != imageView) {
            if (_currentImageViews.count==_maxCount || i<_currentImages.count) {
                if (CGRectContainsPoint(imagev.frame, point)) {
                    return i;
                }
            }
        }
    }
    return -1;
}


@end
