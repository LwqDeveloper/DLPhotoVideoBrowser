//
//  DLPhotoVideoBrowser.h
//  DLPhotoVideoBrowser
//
//  Created by jamelee on 2021/4/23.
//

#import <UIKit/UIKit.h>
#import "DLPhotoVideoModel.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <FLAnimatedImage/FLAnimatedImage.h>
#import "DLPhotoItemView.h"
#import "DLVideoItemView.h"

@interface DLPhotoVideoBrowser : UIView

- (instancetype)initWithGroupItems:(NSArray *)groupItems currentIndex:(NSInteger)currentIndex;

@property (nonatomic, assign) CGFloat             height;
@property (nonatomic, assign) CGFloat             width;

//展示图数组
@property (nonatomic, strong) NSArray             *groupItems;
//当前展示的视图
@property (nonatomic, assign) NSInteger           currentIndex;
@property (nonatomic, assign) DLPhotoVideoModel   *currentItem;
@property (nonatomic, strong) UIImageView         *fromImgView;
//分页控制器
@property (nonatomic, assign) NSInteger           currentPage;
@property (nonatomic, strong) UIPageControl       *mPageController;
//第一张展示图
@property (nonatomic, strong) UIImageView         *fristImgView;

//半透明背景图
@property (nonatomic, strong) UIView              *backView;

//图片数组滚动视图
@property (nonatomic, strong) UIScrollView        *mScrollView;
//关闭当前视图
@property (nonatomic, copy  ) void(^dismissBlock)(void);

//屏幕是否正在旋转 旋转过程中滚动视图不能进行位移
@property (nonatomic, assign) BOOL                deviceTransform;
//屏幕在一定情况下不需要处理旋转操作
@property (nonatomic, assign) UIDeviceOrientation deviceOrientation;

//保存图片和视频按钮
@property (nonatomic, strong) UIButton            *saveButton;

/// 点击图片下载按钮
@property (nonatomic, copy  ) void(^savePhotoHandle)(UIImage *image, NSString *imageUrl);
/// 点击图片下载视频
@property (nonatomic, copy  ) void(^saveVideoHandle)(DLPhotoVideoModel *model);

@end

