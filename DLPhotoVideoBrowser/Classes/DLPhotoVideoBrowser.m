//
//  DLPhotoVideoBrowser.m
//  DLPhotoVideoBrowser
//
//  Created by jamelee on 2021/4/23.
//

#import "DLPhotoVideoBrowser.h"

@interface DLPhotoVideoBrowser () <UIScrollViewDelegate, DLVideoItemViewDelegate, DLPhotoItemViewDelegate>

@end

@implementation DLPhotoVideoBrowser

- (instancetype)initWithGroupItems:(NSArray *)groupItems currentIndex:(NSInteger)currentIndex{
    if (self = [super init]) {
        self.backgroundColor = [UIColor clearColor];
        self.frame = [UIScreen mainScreen].bounds;
        
        _groupItems = groupItems;
        _currentIndex = currentIndex;
        _currentPage = _currentIndex;
        _currentItem = _groupItems[_currentIndex];
        _deviceTransform = NO;
        _width = [UIScreen mainScreen].bounds.size.width;
        _height = [UIScreen mainScreen].bounds.size.height;
        _deviceOrientation = UIDeviceOrientationUnknown;
        
        //屏幕旋转监听
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange) name:UIDeviceOrientationDidChangeNotification object:nil];
        
        _backView = [[UIView alloc] initWithFrame:self.bounds];
        _backView.backgroundColor = [UIColor blackColor];
        [self addSubview:_backView];
        _backView.alpha = 0.01;

        _mScrollView = [[UIScrollView alloc] init];
        _mScrollView.frame = self.bounds;
        _mScrollView.delegate = self;
        _mScrollView.scrollsToTop = NO;
        _mScrollView.pagingEnabled = YES;
        _mScrollView.alwaysBounceHorizontal = _groupItems.count > 1;
        _mScrollView.showsHorizontalScrollIndicator = NO;
        _mScrollView.showsVerticalScrollIndicator = NO;
        _mScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _mScrollView.delaysContentTouches = NO;
        _mScrollView.canCancelContentTouches = YES;
        _mScrollView.backgroundColor = [UIColor clearColor];
        [self addSubview:_mScrollView];
        
        
        _mScrollView.contentSize = CGSizeMake(_mScrollView.bounds.size.width * self.groupItems.count, _mScrollView.bounds.size.height);
        _mScrollView.contentOffset = CGPointMake(_mScrollView.bounds.size.width * _currentIndex, 0);
        
        for (int i = 0; i < _groupItems.count; ++i) {
            DLPhotoVideoModel *item = _groupItems[i];
            if (item.itemType == DLBrowserItemTypeImage) {
                DLPhotoItemView *imageCell = [[DLPhotoItemView alloc] initWithItem:item];
                imageCell.tag = 100 +i;
                imageCell.photoDelegate = self;
                [_mScrollView addSubview:imageCell];
                if (i == _currentIndex) {
                    _fromImgView = item.fromImgView;
                    _fristImgView = item.fromImgView;
                    imageCell.imageCellFrame =  [_mScrollView convertRect:_fromImgView.frame fromView:_fromImgView.superview];
                    _fromImgView.hidden = YES;
                } else {
                    imageCell.imageCellFrame = CGRectMake(i*_mScrollView.bounds.size.width, 0, _mScrollView.bounds.size.width, _mScrollView.bounds.size.height);
                }
            } else {
                DLVideoItemView *videoView = [[DLVideoItemView alloc] initWithItem:item];
                videoView.tag = 100 +i;
                videoView.videoDelegate = self;
                [_mScrollView addSubview:videoView];
                videoView.showType = DLBrowserShowTypeNone;
                if (i == _currentIndex) {
                    _fromImgView = item.fromImgView;
                    _fristImgView = item.fromImgView;
                    videoView.videoViewFrame =  [_mScrollView convertRect:_fromImgView.frame fromView:_fromImgView.superview];
                    _fromImgView.hidden = YES;
                } else {
                    videoView.videoViewFrame = CGRectMake(i*_mScrollView.bounds.size.width, 0, _mScrollView.bounds.size.width, _mScrollView.bounds.size.height);
                }
            }
        }
    }
    return self;
}

- (void)setShowDownloadBtn:(BOOL)showDownloadBtn {
    _showDownloadBtn = showDownloadBtn;
    
    for (UIView *view in self.mScrollView.subviews) {
        if ([view isKindOfClass:[DLPhotoItemView class]]) {
            DLPhotoItemView *photoView = (DLPhotoItemView *)view;
            photoView.showDownloadBtn = showDownloadBtn;
        }
        if ([view isKindOfClass:[DLVideoItemView class]]) {
            DLVideoItemView *videoView = (DLVideoItemView *)view;
            videoView.showDownloadBtn = showDownloadBtn;
        }
    }
}

#pragma mark - DLPhotoItemViewImageDelegate 点击图片回收 10+
- (void)DLPhotoItemViewClick:(NSInteger)viewTag gesture:(UITapGestureRecognizer *)gesture{
    CGRect fromRect1 = [_mScrollView convertRect:_fromImgView.frame fromView:_fromImgView.superview];
    CGRect fromRect2 = [_mScrollView convertRect:_fristImgView.frame fromView:_fristImgView.superview];
    DLPhotoItemView *imageCell = [_mScrollView viewWithTag:viewTag];
    imageCell.saveButton.hidden = YES;

    [UIView animateWithDuration:0.3 animations:^{
        self.backView.alpha = 0.01;
        if (fromRect1.origin.y != 0) {
            imageCell.imageCellFrame = fromRect1;
        } else {
            imageCell.imageCellFrame = fromRect2;
            imageCell.alpha = 0.01;
        }
    } completion:^(BOOL finished) {
        self.fromImgView.hidden = NO;
        if (self.dismissBlock) {
            self.dismissBlock();
        } else {
            [self removeFromSuperview];
        }
    }];
}

- (void)DLPhotoItemViewDownload:(UIImage *)image url:(NSString *)url {
    if (self.savePhotoHandle) {
        self.savePhotoHandle(image, url);
    }
}

- (void)DLVideoViewDownloadButtonClickWithViewTag:(NSInteger)viewTag model:(DLPhotoVideoModel *)model {
    if (self.saveVideoHandle) {
        self.saveVideoHandle(model);
    }
}

#pragma mark - DLVideoItemViewImageDelegate 点击视频回收
- (void)DLVideoViewBackButtonClickWithViewTag:(NSInteger)viewTag {
    CGRect fromRect1 = [_mScrollView convertRect:_fromImgView.frame fromView:_fromImgView.superview];
    CGRect fromRect2 = [_mScrollView convertRect:_fristImgView.frame fromView:_fristImgView.superview];
    
    DLVideoItemView *videoView = [_mScrollView viewWithTag:viewTag];
    videoView.mVideoImagelayer.saveButton.hidden = YES;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.backView.alpha = 0.01;
        if (fromRect1.origin.y!=0) {
            videoView.videoViewFrame = fromRect1;
        } else {
            videoView.videoViewFrame = fromRect2;
            videoView.alpha = 0.01;
        }
    } completion:^(BOOL finished) {
        self.fromImgView.hidden = NO;
        if (self.dismissBlock) {
            self.dismissBlock();
        } else {
            [self removeFromSuperview];
        }
    }];
}

- (void)layoutSubviews {
    if (_deviceTransform == YES)return;
    [UIView animateWithDuration:0.3 animations:^{
        self.backView.alpha = 1;
        if (self.currentItem.itemType == DLBrowserItemTypeImage) {
            DLPhotoItemView *imageCell = [self.mScrollView viewWithTag:100 +self.currentIndex];
            imageCell.imageCellFrame = self.mScrollView.bounds;
        } else {
            DLVideoItemView *videoView = [self.mScrollView viewWithTag:100 +self.currentIndex];
            videoView.videoViewFrame = self.mScrollView.bounds;
        }
    } completion:^(BOOL finished) {
        if (self.currentItem.itemType == DLBrowserItemTypeVideo) {
            DLVideoItemView *videoView = [self.mScrollView viewWithTag:100 +self.currentIndex];
            videoView.showType = DLBrowserShowTypeZoomout;
        }
    }];
}

//UISlider 和 UIScrollView手势冲突解决
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view = [super hitTest:point withEvent:event];
    if ([view isKindOfClass:[UISlider class]]) {
        _mScrollView.scrollEnabled = NO;
    } else {
        _mScrollView.scrollEnabled = YES;
    }
    return view;
}

//处理翻页 图片缩放需要回收 视频不需要
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGPoint offset = scrollView.contentOffset;
    CGFloat sizeWidth = (scrollView.contentSize.width/_groupItems.count);
    _currentPage = offset.x / sizeWidth;
    
    if (_currentPage != _currentIndex) {
        if (_currentItem.itemType == DLBrowserItemTypeImage) {
            DLPhotoItemView *imageCell = [_mScrollView viewWithTag:100 +_currentPage];
            if (imageCell.zoomScale>1)[imageCell setZoomScale:1 animated:YES];
        } else {
            DLVideoItemView *videoView = [_mScrollView viewWithTag:100 +_currentPage];
            videoView.showType = DLBrowserShowTypeHidden;
        }
        _currentIndex = _currentPage;
        _currentItem = _groupItems[_currentIndex];
        _fromImgView.hidden = NO;
        _fromImgView = _currentItem.fromImgView;
        _fromImgView.hidden = YES;
    }
}

//监听屏幕旋转 重新设计尺寸 支持三个方向
- (void)deviceOrientationDidChange {
    _deviceTransform = YES;
    UIDevice *device = [UIDevice currentDevice];
    switch (device.orientation) {
        case UIDeviceOrientationLandscapeLeft:
            NSLog(@"屏幕向左横置");
            if (_deviceOrientation == UIDeviceOrientationPortrait ||
               _deviceOrientation == UIDeviceOrientationLandscapeRight ||
               _deviceOrientation == UIDeviceOrientationUnknown) {
                [self landscapeLeft];
            }
            _deviceOrientation = UIDeviceOrientationLandscapeLeft;
            break;
        case UIDeviceOrientationLandscapeRight:
            NSLog(@"屏幕向右橫置");
            if (_deviceOrientation == UIDeviceOrientationLandscapeLeft ||
               _deviceOrientation == UIDeviceOrientationPortrait ||
               _deviceOrientation == UIDeviceOrientationUnknown) {
                [self landscapeRight];
            }
            _deviceOrientation = UIDeviceOrientationLandscapeRight;
            break;
        case UIDeviceOrientationPortrait:
            NSLog(@"屏幕直立");
            if (_deviceOrientation == UIDeviceOrientationLandscapeLeft ||
               _deviceOrientation == UIDeviceOrientationLandscapeRight) {
                [self portrait];
            }
            _deviceOrientation = UIDeviceOrientationPortrait;
            break;
        default:
            _deviceTransform = NO;
            break;
    }
}


//屏幕左转
- (void)landscapeLeft {
    [UIApplication sharedApplication].statusBarOrientation = UIInterfaceOrientationLandscapeLeft;
    [UIView animateWithDuration:0.2f animations:^{
        self.mScrollView.transform = CGAffineTransformMakeRotation(M_PI_2);
        self.mScrollView.frame = self.bounds;
        [self setScrollerViewLandscape];
        if (self.currentItem.itemType == DLBrowserItemTypeImage) {
            DLPhotoItemView *imageCell = self.mScrollView.subviews[self.currentIndex];
            if (imageCell.zoomScale>1)[imageCell setZoomScale:1 animated:NO];
        }
    } completion:^(BOOL finished) {
        self.deviceTransform = NO;
    }];
}

//屏幕右转
- (void)landscapeRight{
    [UIApplication sharedApplication].statusBarOrientation = UIInterfaceOrientationLandscapeRight;
    [UIView animateWithDuration:0.2f animations:^{
        self.mScrollView.transform = CGAffineTransformMakeRotation(- M_PI_2);
        self.mScrollView.frame = CGRectMake(0, 0, self.bounds.size.width, self.height);
        [self setScrollerViewLandscape];
        
        if (self.currentItem.itemType == DLBrowserItemTypeImage) {
            DLPhotoItemView *imageCell = self.mScrollView.subviews[self.currentIndex];
            if (imageCell.zoomScale>1)[imageCell setZoomScale:1 animated:NO];
        }
    } completion:^(BOOL finished) {
        self.deviceTransform = NO;
    }];
}

//屏幕正向直立
- (void)portrait{
    [UIApplication sharedApplication].statusBarOrientation = UIInterfaceOrientationPortrait;
    [UIView animateWithDuration:0.2f animations:^{
        self.mScrollView.transform = CGAffineTransformMakeRotation(0);
        self.mScrollView.frame = self.bounds;
        [self setScrollerViewRestore];
        
        if (self.currentItem.itemType == DLBrowserItemTypeImage) {
            DLPhotoItemView *imageCell = self.mScrollView.subviews[self.currentIndex];
            if (imageCell.zoomScale>1) [imageCell setZoomScale:1 animated:NO];
        }
    } completion:^(BOOL finished) {
        self.deviceTransform = NO;
    }];
}

//横屏 设置滚动视图的内容部分和图片
- (void)setScrollerViewLandscape {
    _mScrollView.contentSize = CGSizeMake(_mScrollView.bounds.size.height*_groupItems.count, 0);
    _mScrollView.contentOffset = CGPointMake(_mScrollView.bounds.size.height * _currentIndex, 0);
    for (NSInteger i = 0; i < _groupItems.count; i ++) {
        DLPhotoVideoModel *item = _groupItems[i];
        if (item.itemType == DLBrowserItemTypeImage) {
            DLPhotoItemView *imageCell = [_mScrollView viewWithTag:100 +i];
            imageCell.imageCellFrame = CGRectMake(i*_mScrollView.bounds.size.width, 0, _mScrollView.bounds.size.width, _mScrollView.bounds.size.height);
        } else {
            DLVideoItemView *videoView = [_mScrollView viewWithTag:100 +i];
            videoView.videoViewFrame = CGRectMake(i*_mScrollView.bounds.size.width, 0, _mScrollView.bounds.size.width, _mScrollView.bounds.size.height);
        }
    }
}

//屏幕直立恢复frame
- (void)setScrollerViewRestore {
    _mScrollView.contentSize = CGSizeMake(_mScrollView.bounds.size.width*_groupItems.count, _mScrollView.bounds.size.height);
    _mScrollView.contentOffset = CGPointMake(_mScrollView.bounds.size.width * _currentIndex, 0);
    for (NSInteger i = 0; i < _groupItems.count; i ++) {
        DLPhotoVideoModel *item = _groupItems[i];
        if (item.itemType == DLBrowserItemTypeImage) {
            DLPhotoItemView *imageCell = [_mScrollView viewWithTag:100 +i];
            imageCell.imageCellFrame = CGRectMake(i*_mScrollView.bounds.size.width, 0, _mScrollView.bounds.size.width, _mScrollView.bounds.size.height);
        } else {
            DLVideoItemView *videoView = [_mScrollView viewWithTag:100 +i];
            videoView.videoViewFrame = CGRectMake(i*_mScrollView.bounds.size.width, 0, _mScrollView.bounds.size.width, _mScrollView.bounds.size.height);
        }
    }
}


@end
