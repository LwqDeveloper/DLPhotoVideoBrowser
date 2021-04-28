//
//  DLPhotoVideoModel.h
//  DLPhotoVideoBrowser
//
//  Created by jamelee on 2021/4/23.
//

#import <Foundation/Foundation.h>

/// 展示图类型
typedef NS_ENUM(NSInteger, DLBrowserItemType) {
    DLBrowserItemTypeImage = 0,  ///图片
    DLBrowserItemTypeVideo,      /// 短视频
};

/// 图片展示状态
typedef NS_ENUM(NSInteger, DLBrowserShowType) {
    DLBrowserShowTypeNone = 0,  /// 未展示
    DLBrowserShowTypeZoomout,   /// 放大展示
    DLBrowserShowTypeScroll,    /// 滚动展示
    DLBrowserShowTypeHidden,    /// 滚动隐藏
};

@interface DLPhotoVideoModel : NSObject

// 图类型
@property (nonatomic, assign) DLBrowserItemType itemType;
// 需要展示的图片 图片视图
@property (nonatomic, strong) UIImage           *fromImage;
@property (nonatomic, strong) UIImageView       *fromImgView;
// 图片格式
@property (nonatomic, assign) UIViewContentMode contentMode;
// 短视频路径
@property (nonatomic, strong) NSString          *videoPath;
// 短视频本地路径
@property (nonatomic, strong) NSString          *videoLocalPath;
// 标签
@property (nonatomic, assign) NSInteger         itemTag;
// 文件名称
@property (nonatomic, strong) NSString          *imageRemotePath;

+ (UIImage *)pathForResourceName:(NSString *)name suffix:(NSString *)suffix;

@end
