//
//  MikaScrollView.m
//  Scroll
//
//  Created by mika on 2017/12/28.
//  Copyright © 2017年 mika. All rights reserved.
//

#define Multiple_NUM 1000
#import "MikaScrollView.h"
#import "ScrollCollectionViewCell.h"

@interface MikaScrollView()<UICollectionViewDelegate,UICollectionViewDataSource,UIScrollViewDelegate>
@property (nonatomic, strong) UICollectionView          *collectionView;
@property (nonatomic, strong) NSMutableArray            *imagesCopyArr;//复制后的imgs
@property (nonatomic, strong) dispatch_source_t         timer;
@property (nonatomic, strong) UIPageControl             *pageControl;

@end

@implementation MikaScrollView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.imagesCopyArr = [NSMutableArray array];
        [self initSubViews];
    }
    return self;
}
#pragma mark - 初始化UICollectionView
- (void)initSubViews {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = CGSizeMake(self.frame.size.width, self.frame.size.height);
    layout.minimumLineSpacing = 0.0;
    layout.minimumInteritemSpacing = 0.0;
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) collectionViewLayout:layout];
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.pagingEnabled = YES;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.showsVerticalScrollIndicator = NO;
    [self.collectionView registerClass:[ScrollCollectionViewCell class] forCellWithReuseIdentifier:@"ScrollCollectionViewCellIdentifier"];
    [self addSubview:self.collectionView];
    [self.collectionView setContentOffset:CGPointMake(self.collectionView.frame.size.width*((Multiple_NUM/2)), 0)];
    
    self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, self.frame.size.height-30, self.frame.size.width, 30)];
    [self.pageControl addTarget:self action:@selector(clickPageController:event:) forControlEvents:UIControlEventTouchUpInside];
    self.pageControl.currentPage = 0;
    [self addSubview:self.pageControl];
}
//是否自动滚动
- (void)setAutoScroll:(BOOL)autoScroll {
    _autoScroll = autoScroll;
}
//滚动时间间隔
- (void)setInterval:(CGFloat)interval {
    _interval = interval;
}
//图片数组
- (void)setImagesArray:(NSArray *)imagesArray {
    _imagesArray = imagesArray;
    self.pageControl.numberOfPages = _imagesArray.count;
    for (int i = 0; i < Multiple_NUM; i++) {
        int K = (i%_imagesArray.count);
        [self.imagesCopyArr addObject:_imagesArray[K]];
    }
    [self.collectionView reloadData];
}
#pragma mark - 创建定时器
- (void)createTimer {
    if (!_autoScroll) {
        return;
    }
    dispatch_queue_t queue = dispatch_get_main_queue();
    self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, (ino64_t)(1.0*NSEC_PER_SEC));
    uint64_t interval = (uint64_t)(2.0*NSEC_PER_SEC);
    if (_interval) {
        interval = (uint64_t)(_interval*NSEC_PER_SEC);
    }
    dispatch_source_set_timer(self.timer, start, interval, 0);
    dispatch_source_set_event_handler(self.timer, ^{
        [self refreshOffSet];
    });
    dispatch_resume(self.timer);
}
#pragma mark - 刷新偏移量
- (void)refreshOffSet {
    NSInteger index = self.collectionView.contentOffset.x/self.collectionView.frame.size.width;
    if (index>Multiple_NUM/2.0 + _imagesArray.count) {
        [self.collectionView setContentOffset:CGPointMake(self.collectionView.frame.size.width*((Multiple_NUM/2))+self.collectionView.frame.size.width*(index%_imagesArray.count), 0) animated:NO];
        [self.collectionView setContentOffset:CGPointMake(self.collectionView.frame.size.width*((Multiple_NUM/2))+self.collectionView.frame.size.width*(index%_imagesArray.count+1), 0) animated:YES];
    }else{
        [self.collectionView setContentOffset:CGPointMake(self.collectionView.contentOffset.x+self.collectionView.frame.size.width, 0) animated:YES];
    }
    NSInteger ind = (NSInteger)(_collectionView.contentOffset.x/_collectionView.frame.size.width)%(_imagesArray.count)+1;
    if (ind==_imagesArray.count) {
        self.pageControl.currentPage = 0;
    }else{
        self.pageControl.currentPage = ind;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (!self.timer) {
        [self createTimer];
    }
}
#pragma mark - UICollectionView delegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.imagesCopyArr.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ScrollCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ScrollCollectionViewCellIdentifier" forIndexPath:indexPath];
    if (self.imagesCopyArr.count > indexPath.row) {
        cell.imageView.image = [UIImage imageNamed:self.imagesCopyArr[indexPath.row]];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger index = (NSInteger)(collectionView.contentOffset.x/collectionView.frame.size.width)%(_imagesArray.count);
    if (self.tapImageBlock) {
        self.tapImageBlock(index);
    }
}
#pragma mark - UIScrollView delegate
#pragma mark - 开始拖拽
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self pause];
}
#pragma mark - 手动拖拽结束
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self began];
    NSInteger index = scrollView.contentOffset.x/scrollView.frame.size.width;
    [scrollView setContentOffset:CGPointMake(scrollView.frame.size.width*((Multiple_NUM/2))+scrollView.frame.size.width*(index%_imagesArray.count), 0)];
    self.pageControl.currentPage = (index%_imagesArray.count);
}
#pragma mark - 点击pageControl事件
- (void)clickPageController:(UIPageControl *)pageController event:(UIEvent *)touchs{
    [self pause];
    UITouch *touch = [[touchs allTouches] anyObject];
    CGPoint p = [touch locationInView:self.pageControl];
    CGFloat centerX = pageController.center.x;
    CGFloat left = centerX-15.0*_imagesArray.count/2;
    [_pageControl setCurrentPage:(int ) (p.x-left)/15];
    NSInteger index = (p.x-left)/15;
    [self.collectionView setContentOffset:CGPointMake(self.collectionView.frame.size.width*((Multiple_NUM/2))+self.collectionView.frame.size.width*(index%_imagesArray.count), 0) animated:YES];
    [self performSelector:@selector(began) withObject:nil afterDelay:1.0];
}

//计时器开始
- (void)began {
    if (_autoScroll) {
        [self createTimer];
    }
}
//计时器暂停
- (void)pause {
    self.timer = nil;
}
//计时器释放
- (void)destory {
    self.timer = nil;
}
@end
