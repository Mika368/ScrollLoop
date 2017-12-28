//
//  MikaScrollView.h
//  Scroll
//
//  Created by mika on 2017/12/28.
//  Copyright © 2017年 mika. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^TapImageBlock)(NSInteger index);

@interface MikaScrollView : UIView

@property (nonatomic, strong) TapImageBlock     tapImageBlock;//点击图片回调block
@property (nonatomic, strong) NSArray           *imagesArray;//图片数组
@property (nonatomic, assign) CGFloat           interval;//时间间隔
@property (nonatomic, assign) BOOL              autoScroll;//是否自动滚动（先设置时间间隔）
//计时器开始
- (void)began;
//计时器暂停
- (void)pause;

@end
