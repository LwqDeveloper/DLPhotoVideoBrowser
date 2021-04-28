//
//  DLPhotoVideoModel.m
//  DLPhotoVideoBrowser
//
//  Created by jamelee on 2021/4/23.
//

#import "DLPhotoVideoModel.h"

@implementation DLPhotoVideoModel

+ (UIImage *)pathForResourceName:(NSString *)name suffix:(NSString *)suffix {
    UIImage *image = [UIImage imageNamed:name];
    if (image) return image;
    image = [UIImage imageWithContentsOfFile:name];
    if (image) return image;
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:name ofType:suffix];
    image = [UIImage imageWithContentsOfFile:imagePath];
    if (image) return image;
    // 获取当前的bundle,self只是在当前pod库中的一个类，也可以随意写一个其他的类
    NSBundle *currentBundle = [NSBundle bundleForClass:[self class]];
    // 获取当前bundle的名称
    NSString *currentBundleName = currentBundle.infoDictionary[@"CFBundleName"];
    // 获取图片的路径
    imagePath = [currentBundle pathForResource:name ofType:suffix inDirectory:[NSString stringWithFormat:@"%@.bundle",currentBundleName]];
    image = [UIImage imageWithContentsOfFile:imagePath];
    return image;
}

@end
