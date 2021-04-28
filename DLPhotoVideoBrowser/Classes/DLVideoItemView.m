//
//  DLVideoItemView.m
//  DLPhotoVideoBrowser
//
//  Created by jamelee on 2021/4/23.
//

#import "DLVideoItemView.h"

@interface DLVideoItemView () <DLVideoImageLayerDelegate>

@end

@implementation DLVideoItemView

- (instancetype)initWithItem:(DLPhotoVideoModel *)item {
    if (self = [super init]){
        self.frame = [UIScreen mainScreen].bounds;
        _item = item;
    
        AVPlayerItem *playerItem;
        if ([[NSFileManager defaultManager] fileExistsAtPath:_item.videoLocalPath]) {
            playerItem = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:_item.videoLocalPath]];
        } else {
            playerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:_item.videoPath]];
        }
        _player = [AVPlayer playerWithPlayerItem:playerItem];
        _playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
        _playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
        _playerLayer.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        [self.layer addSublayer:_playerLayer];
        _playerLayer.player = _player;

        //播放完成通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayDidEnd) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
        _mVideoImagelayer = [[DLVideoImageLayer alloc] initWithItem:_item];
        _mVideoImagelayer.videoUrl = _item.videoPath;
        _mVideoImagelayer.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_mVideoImagelayer];
        _mVideoImagelayer.image = _item.fromImage;
        _mVideoImagelayer.layerDelegate = self;
        _mVideoImagelayer.image = nil;
    }
    return self;
}


//设置frame
- (void)setVideoViewFrame:(CGRect)videoViewFrame {
    _videoViewFrame = videoViewFrame;
    self.frame = _videoViewFrame;
    _mVideoImagelayer.frame = self.bounds;
    _playerLayer.frame = self.bounds;
    
    [_mVideoImagelayer setNewFrameWithDeviceoRientation];
}

- (void)setShowType:(DLBrowserShowType)showType {
    _showType = showType;
    
    switch (_showType) {
            //未展示
        case DLBrowserShowTypeNone: {
            
        }
            break;
            //放大展示
        case DLBrowserShowTypeZoomout: {
            [_player play];
            [self addPeriodicTime];
            self.mVideoImagelayer.status = DLVideoLayerStatusPlay;
        }
            break;
            //滚动展示
        case DLBrowserShowTypeScroll: {
            
        }
            break;
            //滚动隐藏
        case DLBrowserShowTypeHidden: {
            [self moviePlayDidEnd];
        }
            break;
        default:
            break;
    }
}

//获取播放的时间
- (void)addPeriodicTime {
    
    __block DLVideoItemView *weakSelf = self;
    [_player addPeriodicTimeObserverForInterval:CMTimeMake(1, 30) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        if (!weakSelf) {
            return;
        }
        weakSelf.mVideoImagelayer.currentTime = CMTimeGetSeconds(time);
        weakSelf.mVideoImagelayer.totalTime = CMTimeGetSeconds(weakSelf.player.currentItem.asset.duration);
        if (!weakSelf.mVideoImagelayer.totalTime) {
            weakSelf.mVideoImagelayer.totalTime = 0;
        }
        [weakSelf.mVideoImagelayer setPeriodicTimeAndProgress];
    }];
}

//播放完成
- (void)moviePlayDidEnd {
    [_player seekToTime:CMTimeMake(0, 1) completionHandler:^(BOOL finished) {
        [self.player pause];
        self.mVideoImagelayer.status = DLVideoLayerStatusDone;
    }];
}

//图层按钮点击回调 返回100   中间播放50  左下角播放10
- (void)DLVideoImageLayerButtonClick:(UIButton *)sender item:(DLPhotoVideoModel *)item {
    if (sender.tag == 100) {
        [_player seekToTime:CMTimeMake(0, 1) completionHandler:^(BOOL finished) {
            [self.player pause];
            self.mVideoImagelayer.status = DLVideoLayerStatusDone;
            if (self.videoDelegate && [self.videoDelegate respondsToSelector:@selector(DLVideoViewBackButtonClickWithViewTag:)]){
                [self.videoDelegate DLVideoViewBackButtonClickWithViewTag:self.tag];
            }
        }];
    } if (sender.tag == 1000) {
        if (self.videoDelegate && [self.videoDelegate respondsToSelector:@selector(DLVideoViewDownloadButtonClickWithViewTag:model:)]){
            [self.videoDelegate DLVideoViewDownloadButtonClickWithViewTag:self.tag model:item];
        }
    } else {
        if (sender.tag == 50 || sender.tag == 10){
            if (sender.selected == NO){
                [_player pause];
            } else {
                [_player play];
                [self addPeriodicTime];
            }
        }
    }
}

//- dlvide

//进度条拖动回调
- (void)DLVideoImageLayerSliderEventValueChanged:(UISlider *)slider item:(DLPhotoVideoModel *)item {
    
//    CGFloat seconds = CMTimeGetSeconds(_player.currentItem.duration);
    _mVideoImagelayer.currentTime = slider.value;
    [_player seekToTime:CMTimeMake(slider.value,1)];
    [_mVideoImagelayer setPeriodicTimeAndProgress];
}

@end


@interface DLVideoImageLayer ()

@property (nonatomic, assign) BOOL isAll;

@end
//播放视频的图层 100%透明 添加所有控件和点击手势
@implementation DLVideoImageLayer

- (instancetype)initWithItem:(DLPhotoVideoModel *)item {
    if (self = [super init]){
        self.isAll = YES;
        self.frame = [UIScreen mainScreen].bounds;
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = YES;
        
        _item = item;
        _currentTime = 0;
        _totalTime = 0;
        
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(GestureRecognizerPressed:)];
        gesture.numberOfTapsRequired = 1;
        gesture.numberOfTouchesRequired = 1;
        [self addGestureRecognizer:gesture];
        //取消按钮
        _mBackButton = [UIButton buttonWithType:UIButtonTypeCustom];
         _mBackButton.frame = CGRectMake(0, 0, 60, 40);
        _mBackButton.hidden = YES;
        _mBackButton.tag = 100;
        [self addSubview:_mBackButton];
        [_mBackButton setImage:[DLPhotoVideoModel pathForResourceName:@"video_del_white" suffix:@"png"] forState:UIControlStateNormal];
        [_mBackButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_mBackButton addTarget:self action:@selector(buttonPressed:)   forControlEvents:UIControlEventTouchUpInside];
        //播放按钮
        _playCenterButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _playCenterButton.hidden = YES;
        _playCenterButton.bounds = CGRectMake(0, 0, 55, 55);
        _playCenterButton.tag  = 50;
        [self addSubview:_playCenterButton];
        [_playCenterButton setImage:[DLPhotoVideoModel pathForResourceName:@"video_play_big" suffix:@"png"] forState:UIControlStateNormal];
        [_playCenterButton setImage:[DLPhotoVideoModel pathForResourceName:@"video_out_big" suffix:@"png"] forState:UIControlStateSelected];
        [_playCenterButton addTarget:self action:@selector(buttonPressed:)   forControlEvents:UIControlEventTouchUpInside];
        
        _playLeftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _playLeftButton.bounds = CGRectMake(0, 0, 40, 40);
        _playLeftButton.hidden = YES;
        _playLeftButton.tag = 10;
        [self addSubview:_playLeftButton];
        [_playLeftButton setImage:[DLPhotoVideoModel pathForResourceName:@"video_play_small" suffix:@"png"] forState:UIControlStateNormal];
        [_playLeftButton setImage:[DLPhotoVideoModel pathForResourceName:@"video_out_small" suffix:@"png"] forState:UIControlStateSelected];
        [_playLeftButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_playLeftButton addTarget:self action:@selector(buttonPressed:)   forControlEvents:UIControlEventTouchUpInside];
        
        _playSlider = [UISlider new];
        _playSlider.bounds = CGRectMake(0, 0,self.bounds.size.width-165, 20);
        _playSlider.hidden = YES;
        _playSlider.minimumValue = 0;
        _playSlider.maximumValue = 1;
        [_playSlider setThumbImage:[DLPhotoVideoModel pathForResourceName:@"video_play_bar" suffix:@"png"] forState:UIControlStateNormal];
        _playSlider.value = 0;
        _playSlider.minimumTrackTintColor = [UIColor whiteColor];
        _playSlider.maximumTrackTintColor = [UIColor lightGrayColor];
        [_playSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        _playSlider.continuous = YES;
        [self addSubview:_playSlider];
        
        _currenTimeLab = [UILabel new];
        _currenTimeLab.bounds = CGRectMake(0, 0, 50, 25);
        _currenTimeLab.hidden = YES;
        _currenTimeLab.textColor = [UIColor whiteColor];
        _currenTimeLab.textAlignment = NSTextAlignmentCenter;
        _currenTimeLab.font = [UIFont systemFontOfSize:10];
        _currenTimeLab.text = @"00:00";
        [_currenTimeLab sizeToFit];
        [self addSubview:_currenTimeLab];
   
        _totalTimeLab = [UILabel new];
        _totalTimeLab.bounds = CGRectMake(0, 0, 50, 25);
        _totalTimeLab.textColor = [UIColor whiteColor];
        _totalTimeLab.hidden = YES;
        _totalTimeLab.textAlignment = NSTextAlignmentCenter;
        _totalTimeLab.font = [UIFont systemFontOfSize:10];
        _totalTimeLab.text = @"00:00";
        [_totalTimeLab sizeToFit];
        [self addSubview:_totalTimeLab];
        
        _saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _saveButton.tag = 1000;
        _saveButton.hidden = YES;
        _saveButton.frame = CGRectMake(0, 0, 36, 36);
        [_saveButton setImage:[DLPhotoVideoModel pathForResourceName:@"browser_download" suffix:@"png"] forState:UIControlStateNormal];
        [_saveButton addTarget:self action:@selector(buttonPressed:)   forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_saveButton];
        
        [self setNewFrameWithDeviceoRientation];
    }
    return self;
}

//刷新控件的位置
- (void)setNewFrameWithDeviceoRientation {
    CGFloat statusBarHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
    
    CGRect backBtnFrame = _mBackButton.frame;
    backBtnFrame.origin.x = 10;
    backBtnFrame.origin.y = statusBarHeight;
    _mBackButton.frame = backBtnFrame;
    
    CGRect playCenBtnFrame = _playCenterButton.frame;
    playCenBtnFrame.origin.x = self.bounds.size.width /2 -playCenBtnFrame.size.width /2;
    playCenBtnFrame.origin.y = self.bounds.size.height /2 -playCenBtnFrame.size.height /2;
    _playCenterButton.frame = playCenBtnFrame;
    
    CGRect playLefBtnFrame = _playLeftButton.frame;
    playLefBtnFrame.origin.x = 15;
    playLefBtnFrame.origin.y = self.bounds.size.height -10 -playLefBtnFrame.size.height;
    _playLeftButton.frame = playLefBtnFrame;

    CGRect playSliderFrame = _playSlider.frame;
    playSliderFrame.size.width = self.bounds.size.width -165;
    playSliderFrame.size.height = 20;
    playSliderFrame.origin.x = CGRectGetMaxX(_playLeftButton.frame) +45;
    playSliderFrame.origin.y = CGRectGetMidY(_playLeftButton.frame) -playSliderFrame.size.height /2;
    _playSlider.frame = playSliderFrame;
    
    CGRect currentTiLblFrame = _currenTimeLab.frame;
    currentTiLblFrame.origin.y = CGRectGetMidY(_playLeftButton.frame) -currentTiLblFrame.size.height /2;
    currentTiLblFrame.origin.y = CGRectGetMinX(_playSlider.frame) -10 -currentTiLblFrame.size.width;
    _currenTimeLab.frame = currentTiLblFrame;
   
    CGRect totalTimeLblFrame = _totalTimeLab.frame;
    totalTimeLblFrame.origin.y = CGRectGetMidY(_playLeftButton.frame) -totalTimeLblFrame.size.height /2;
    totalTimeLblFrame.origin.x = CGRectGetMaxY(_playSlider.frame) +10;
    _totalTimeLab.frame = totalTimeLblFrame;
    
    CGRect saveBtnFrame = _saveButton.frame;
    saveBtnFrame.origin.x = self.bounds.size.width -15 -saveBtnFrame.size.width;
    saveBtnFrame.origin.y = self.bounds.size.height -10 -saveBtnFrame.size.height -4;
    _saveButton.frame = saveBtnFrame;
}

//根据时间设置显示和进度条状态
- (void)setPeriodicTimeAndProgress {
    _playSlider.minimumValue = 0;
    _playSlider.maximumValue = _totalTime;
    _playSlider.value = _currentTime;
    
    //当前播放的时间
    NSDate *detaildate=[NSDate dateWithTimeIntervalSince1970:_currentTime];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"mm:ss"];
    _currenTimeLab.text =  [dateFormatter stringFromDate: detaildate];
    [_currenTimeLab sizeToFit];
    
    CGRect currenTimeLblFrame = _currenTimeLab.frame;
    currenTimeLblFrame.origin.y = CGRectGetMidY(_playLeftButton.frame) -currenTimeLblFrame.size.height /2;
    currenTimeLblFrame.origin.x = CGRectGetMinX(_playSlider.frame) -10 -currenTimeLblFrame.size.width;
    _currenTimeLab.frame = currenTimeLblFrame;
    
    //视频的总时间
    NSDate *detaildate2=[NSDate dateWithTimeIntervalSince1970:_totalTime];
    NSDateFormatter *dateFormatter2 = [[NSDateFormatter alloc] init];
    [dateFormatter2 setDateFormat:@"mm:ss"];
    _totalTimeLab.text =  [dateFormatter2 stringFromDate: detaildate2];
    [_totalTimeLab sizeToFit];
    
    CGRect totalTimeLblFrame = _totalTimeLab.frame;
    totalTimeLblFrame.origin.y = CGRectGetMidY(_playLeftButton.frame) -totalTimeLblFrame.size.height /2;
    totalTimeLblFrame.origin.x = CGRectGetMaxY(_playSlider.frame) +10;
    _totalTimeLab.frame = totalTimeLblFrame;
}

//点击图层
- (void)GestureRecognizerPressed:(UITapGestureRecognizer *)gesture {
    self.isAll = !self.isAll;
    if (self.isAll) {
        _mBackButton.hidden = YES;
        _playLeftButton.hidden = YES;
        _playSlider.hidden = YES;
        _currenTimeLab.hidden = YES;
        _totalTimeLab.hidden = YES;
        _saveButton.hidden = YES;
    } else {
        _mBackButton.hidden = NO;
        _playLeftButton.hidden = NO;
        _playSlider.hidden = NO;
        _currenTimeLab.hidden = NO;
        _totalTimeLab.hidden = NO;
        _saveButton.hidden = NO;
    }
}

//返回100  中间播放暂停50  左下角播放暂停10
- (void)buttonPressed:(UIButton *)sender {
    if (sender.tag == 50 || sender.tag == 10) {
        if (sender.selected) {
            _playCenterButton.selected = NO;
            _playLeftButton.selected = NO;
            _playCenterButton.hidden = NO;
        } else {
            _playCenterButton.selected = YES;
            _playLeftButton.selected = YES;
            _playCenterButton.hidden = YES;
        }
    } else if (sender.tag == 100) {
        _mBackButton.hidden = YES;
        _playLeftButton.hidden = YES;
        _playSlider.hidden = YES;
        _currenTimeLab.hidden = YES;
        _totalTimeLab.hidden = YES;
    }
    if (_layerDelegate && [_layerDelegate respondsToSelector:@selector(DLVideoImageLayerButtonClick:item:)]){
        [_layerDelegate DLVideoImageLayerButtonClick:sender item:_item];
    }
}

//播放进度控制
- (void)sliderValueChanged:(UISlider *)slider {
    NSLog(@"当前值：%f",slider.value);
    if (_layerDelegate && [_layerDelegate respondsToSelector:@selector(DLVideoImageLayerSliderEventValueChanged:item:)]){
        [_layerDelegate DLVideoImageLayerSliderEventValueChanged:slider item:_item];
    }
}

- (void)setStatus:(DLVideoLayerStatus)status {
    _status = status;
    switch (_status) {
            //未播放静止（播放按钮）
        case DLVideoLayerStatusStop: {
        }
            break;
            //未播放静止+点击了空白处（所有控件）
        case DLVideoLayerStatusStopAndBlank: {
        }
            break;
            //播放中
        case DLVideoLayerStatusPlay: {
            _playCenterButton.selected = YES;
            _playLeftButton.selected = YES;
        }
            break;
            //播放中+点击了空白处（所有控件）
        case DLVideoLayerStatusPlayAndBlank: {
        }
            break;
            //播放暂停中（所有控件）
        case DLVideoLayerStatusPause: {
        }
            break;
            //播放暂停+点击空白处
        case DLVideoLayerStatusPauseAndBlank: {
        }
            break;
            //播放完毕 （播放按钮）
        case DLVideoLayerStatusDone: {
            _playCenterButton.selected = NO;
            _playLeftButton.selected = NO;
        }
            break;
            //播放完毕+点击空白处（所有控件）
        case DLVideoLayerStatusDoneAndBlank: {
        }
            break;
            
        default:
            break;
    }
}

@end
