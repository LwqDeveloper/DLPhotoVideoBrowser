//
//  DLPhotoItemView.h
//  DLPhotoVideoBrowser
//
//  Created by jamelee on 2021/4/23.
//

#import <UIKit/UIKit.h>
#import "DLPhotoVideoModel.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <FLAnimatedImage/FLAnimatedImage.h>

@protocol DLPhotoItemViewDelegate <NSObject>

/// 点击图片
- (void)DLPhotoItemViewClick:(NSInteger)viewTag gesture:(UITapGestureRecognizer *)gesture;
/// 点击下载
- (void)DLPhotoItemViewDownload:(UIImage *)image url:(NSString *)url;

@end

@interface DLPhotoItemView : UIScrollView

@property (nonatomic, assign)id <DLPhotoItemViewDelegate> photoDelegate;

/// 初始化cell
- (instancetype)initWithItem:(DLPhotoVideoModel *)item;
/// 设置frame
@property (nonatomic, assign) CGRect              imageCellFrame;
/// 展示单位
@property (nonatomic, strong) DLPhotoVideoModel   *item;
/// 展示图
@property (nonatomic, strong) FLAnimatedImageView *mImageView;
/// 保存图片和视频按钮
@property (nonatomic, strong) UIButton            *saveButton;
/// 是否显示下载按钮
@property (nonatomic, assign) BOOL                showDownloadBtn;

@end
