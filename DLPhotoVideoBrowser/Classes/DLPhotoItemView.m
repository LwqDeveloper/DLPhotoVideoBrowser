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
        
        if (@available(iOS 11.0, *)) {
            [[UIScrollView appearance] setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentNever];
        }
        
        _item = item;
        
        _mImageView = [[FLAnimatedImageView alloc] init];
        _mImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_mImageView];
        _mImageView.userInteractionEnabled = YES;
        
        if (_item.imageLocal) {
            _mImageView.image = _item.imageLocal;
        }
        if (_item.imageRemotePath.length > 0) {
            [_mImageView sd_setImageWithURL:[NSURL URLWithString:_item.imageRemotePath] placeholderImage:_item.fromImage options:SDWebImageRetryFailed];
        }
        _mImageView.contentMode = _item.contentMode;
        
        UITapGestureRecognizer* gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(GestureRecognizerPressed:)];
        gesture.numberOfTapsRequired = 1;
        gesture.numberOfTouchesRequired = 1;
        [_mImageView addGestureRecognizer:gesture];
        
        _saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _saveButton.frame = CGRectMake(self.bounds.size.width -15 -36, self.bounds.size.height -30 -36 -[[UIApplication sharedApplication] statusBarFrame].size.height, 36, 36);
        [_saveButton setImage:[DLPhotoVideoModel pathForResourceName:@"browser_download" suffix:@"png"] forState:UIControlStateNormal];
        [_saveButton addTarget:self action:@selector(saveButtonTap) forControlEvents:UIControlEventTouchUpInside];
        _saveButton.hidden = YES;
        [self addSubview:_saveButton];
    }
    return self;
}

- (void)setShowDownloadBtn:(BOOL)showDownloadBtn {
    _showDownloadBtn = showDownloadBtn;
    
    self.saveButton.hidden = !showDownloadBtn;
}

/// ??????????????????
- (void)saveButtonTap {
    if ([self.photoDelegate respondsToSelector:@selector(DLPhotoItemViewDownload:url:)]) {
        [self.photoDelegate DLPhotoItemViewDownload:self.mImageView.image url:self.item.imageRemotePath];
    }
}

/// ??????frame
- (void)setImageCellFrame:(CGRect)imageCellFrame{
    _imageCellFrame = imageCellFrame;
    self.frame = _imageCellFrame;
    _mImageView.frame = self.bounds;
}

/// ????????????
- (void)layoutSubviews {
    [super layoutSubviews];
}

/// ??????
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

//???????????? 10+
- (void)GestureRecognizerPressed:(UITapGestureRecognizer *)sender{
    _saveButton.hidden = YES;
    if (_photoDelegate && [_photoDelegate respondsToSelector:@selector(DLPhotoItemViewClick:gesture:)]){
        [_photoDelegate DLPhotoItemViewClick:self.tag gesture:sender];
    }
}

@end
