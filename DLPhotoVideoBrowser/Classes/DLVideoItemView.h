//
//  DLVideoItemView.h
//  DLPhotoVideoBrowser
//
//  Created by jamelee on 2021/4/23.
//

#import <UIKit/UIKit.h>
#import "DLPhotoVideoModel.h"
#import <AVFoundation/AVFoundation.h>

/// 当前视频界面的播放状态和控件需要展示的状态
typedef NS_ENUM(NSInteger, DLVideoLayerStatus) {
    DLVideoLayerStatusStop = 0,     /// 未播放静止（播放按钮）
    DLVideoLayerStatusStopAndBlank, /// 未播放静止+点击了空白处（所有控件）
    DLVideoLayerStatusPlay,         /// 播放中
    DLVideoLayerStatusPlayAndBlank, /// 播放中+点击了空白处（所有控件）
    DLVideoLayerStatusPause,        /// 播放暂停中（所有控件）
    DLVideoLayerStatusPauseAndBlank, /// 播放暂停+点击空白处
    DLVideoLayerStatusDone,         /// 播放完毕 （播放按钮）
    DLVideoLayerStatusDoneAndBlank, /// 播放完毕+点击空白处（所有控件）
};

@protocol DLVideoItemViewDelegate <NSObject>

/// 点击返回控件
- (void)DLVideoViewBackButtonClickWithViewTag:(NSInteger)viewTag;
/// 点击下载视频
- (void)DLVideoViewDownloadButtonClickWithViewTag:(NSInteger)viewTag model:(DLPhotoVideoModel *)model;

@end

@class DLVideoImageLayer;
@interface DLVideoItemView : UIView

- (instancetype)initWithItem:(DLPhotoVideoModel *)item;

@property (nonatomic, assign) id<DLVideoItemViewDelegate> videoDelegate;
/// 当前是视图展示状态
@property (nonatomic, assign) DLBrowserShowType         showType;
/// 播放状态
@property (nonatomic, assign) DLVideoLayerStatus      status;
/// 设置frame
@property (nonatomic, assign) CGRect                  videoViewFrame;
/// 展示单位
@property (nonatomic, strong) DLPhotoVideoModel        *item;
/// 展示图层
@property (nonatomic, strong) DLVideoImageLayer       *mVideoImagelayer;
/// 最新的视频
@property (nonatomic, strong) AVPlayer                *player;
@property (nonatomic, strong) AVPlayerLayer           *playerLayer;
/// 是否显示下载按钮
@property (nonatomic, assign) BOOL                showDownloadBtn;

@end

/**
 视频的图层 100%透明  可以展示帧图片  展示所有控件 添加点击事件
 */
@protocol DLVideoImageLayerDelegate <NSObject>

//点击图片
//- (void)DLVideoItemViewGesture:(UITapGestureRecognizer *)gesture;

// 点击按钮
- (void)DLVideoImageLayerButtonClick:(UIButton *)sender item:(DLPhotoVideoModel *)item;
// 拖动进度条
- (void)DLVideoImageLayerSliderEventValueChanged:(UISlider *)slider item:(DLPhotoVideoModel *)item;

@end

@interface DLVideoImageLayer : UIImageView

- (instancetype)initWithItem:(DLPhotoVideoModel *)item;

@property (nonatomic, assign) id<DLVideoImageLayerDelegate> layerDelegate;
/// 展示单位
@property (nonatomic, strong) DLPhotoVideoModel  *item;
/// 播放状态
@property (nonatomic, assign) DLVideoLayerStatus status;
/// 左上角返回按钮
@property (nonatomic, strong) UIButton           *mBackButton;
/// 视频中间播放暂停按钮
@property (nonatomic, strong) UIButton           *playCenterButton;
/// 左下角播放暂停按钮
@property (nonatomic, strong) UIButton           *playLeftButton;
/// 播放的当前时间
@property (nonatomic, strong) UILabel            *currenTimeLab;
/// 播放的总时长
@property (nonatomic, strong) UILabel            *totalTimeLab;
/// 播放进度条
@property (nonatomic, strong) UISlider           *playSlider;
/// 当前播放时间
@property (nonatomic, assign) NSTimeInterval     currentTime;
/// 总时间
@property (nonatomic, assign) NSTimeInterval     totalTime;
/// 保存图片和视频按钮
@property (nonatomic, strong) UIButton           *saveButton;
/// 视频地址
@property (nonatomic, assign) NSString           *videoUrl;
/// 是否显示下载按钮
@property (nonatomic, assign) BOOL                showDownloadBtn;

//根据屏幕旋转刷新控件的位置
- (void)setNewFrameWithDeviceoRientation;
//根据时间设置显示和进度条状态
- (void)setPeriodicTimeAndProgress;

@end
