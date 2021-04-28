//
//  DLPhotoItemView.m
//  DLPhotoVideoBrowser
//
//  Created by jamelee on 2021/4/23.
//

#import "DLPhotoItemView.h"
#import <Photos/PHPhotoLibrary.h>

@interface DLPhotoItemView () <UIScrollViewDelegate>

@end

@implementation DLPhotoItemView

- (instancetype)initWithItem:(DLPhotoVideoModel *)item {
    if (self = [super init]){
        self.delegate = self;
        self.bouncesZoom = YES;
        self.maximumZoomScale = 3;
        self.multipleTouchEnabled = YES;
        self.alwaysBounceVertical = YES;
        self.alwaysBounceHorizontal = NO;
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.frame = [UIScreen mainScreen].bounds;
        
        _item = item;
        
        _mImageView = [[FLAnimatedImageView alloc] init];
        _mImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_mImageView];
        _mImageView.userInteractionEnabled = YES;
        
        [_mImageView sd_setImageWithURL:[NSURL URLWithString:_item.imageRemotePath] placeholderImage:_item.fromImage options:SDWebImageRetryFailed];
        _mImageView.contentMode = _item.contentMode;
        
        UITapGestureRecognizer* gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(GestureRecognizerPressed:)];
        gesture.numberOfTapsRequired = 1;
        gesture.numberOfTouchesRequired = 1;
        [_mImageView addGestureRecognizer:gesture];
        
        _saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _saveButton.frame = CGRectMake(self.bounds.size.width -15 -36, self.bounds.size.height -30 -36 -[[UIApplication sharedApplication] statusBarFrame].size.height, 36, 36);
        [_saveButton setImage:[DLPhotoVideoModel pathForResourceName:@"browser_download" suffix:@"png"] forState:UIControlStateNormal];
        [_saveButton addTarget:self action:@selector(saveButtonTap) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_saveButton];
    }
    return self;
}

/// 点击下载按钮
- (void)saveButtonTap {
    if ([self.photoDelegate respondsToSelector:@selector(DLPhotoItemViewDownload:url:)]) {
        [self.photoDelegate DLPhotoItemViewDownload:self.mImageView.image url:self.item.imageRemotePath];
    }
}

/// 设置frame
- (void)setImageCellFrame:(CGRect)imageCellFrame{
    _imageCellFrame = imageCellFrame;
    self.frame = _imageCellFrame;
    _mImageView.frame = CGRectMake(self.bounds.origin.x, self.bounds.origin.y -47, self.bounds.size.width, self.bounds.size.height);
}

/// 滚动触发
- (void)layoutSubviews {
    [super layoutSubviews];
}

/// 缩放
- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    UIView *subView = _mImageView;
    
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    subView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX, scrollView.contentSize.height * 0.5 + offsetY);
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return _mImageView;
}

//点击回收 10+
- (void)GestureRecognizerPressed:(UITapGestureRecognizer *)sender{
    _saveButton.hidden = YES;
    if (_photoDelegate && [_photoDelegate respondsToSelector:@selector(DLPhotoItemViewClick:gesture:)]){
        [_photoDelegate DLPhotoItemViewClick:self.tag gesture:sender];
    }
}

@end
