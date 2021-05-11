//
//  CPDViewController.m
//  PROJECT
//
//  Created by PROJECT_OWNER on TODAYS_DATE.
//  Copyright (c) TODAYS_YEAR PROJECT_OWNER. All rights reserved.
//

#import "DLViewController.h"
#import <Masonry/Masonry.h>
#import <DLPhotoVideoBrowser/DLPhotoVideoBrowser.h>

@interface DLViewController () <UITableViewDelegate, UITableViewDataSource>

/// ui
@property (nonatomic, strong) UITableView *tableView;
/// ns
@property (nonatomic, strong) NSArray *datas;
/// ns
@property (nonatomic, strong) NSString *videoPath;

@end

@implementation DLViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.title = @"图片/视频浏览器";
        
    self.videoPath = @"http://img.jianaiba.com/chat/tv/6a/bc/98e8874314b830c5eacf4a347232.mp4";
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"视频" style:UIBarButtonItemStylePlain target:self action:@selector(videoPreTap)];
}

- (void)videoPreTap {
    NSMutableArray *items = [NSMutableArray array];
    for (NSString *url in @[self.videoPath]) {
        DLPhotoVideoModel *model = [[DLPhotoVideoModel alloc] init];
        model.itemType = DLBrowserItemTypeVideo;
        model.videoPath = url;
        [items addObject:model];
    }
    
    DLPhotoVideoBrowser *browser = [[DLPhotoVideoBrowser alloc] initWithGroupItems:items currentIndex:0];
//    browser.showDownloadBtn = NO;
    [browser setSaveVideoHandle:^(DLPhotoVideoModel *model) {
        NSLog(@"下载视频:%@", model.videoPath);
    }];
    [self.navigationController.view addSubview:browser];
}

#pragma mark - tableView delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableArray *items = [NSMutableArray array];
    for (NSString *url in self.datas) {
        DLPhotoVideoModel *model = [[DLPhotoVideoModel alloc] init];
        model.itemType = DLBrowserItemTypeImage;
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        model.fromImgView = [cell.contentView viewWithTag:100];
        model.imageRemotePath = url;
        model.contentMode = UIViewContentModeScaleAspectFill;
        [items addObject:model];
    }
    
    DLPhotoVideoBrowser *browser = [[DLPhotoVideoBrowser alloc] initWithGroupItems:items currentIndex:indexPath.row];
//    browser.showDownloadBtn = NO;
    [browser setSavePhotoHandle:^(UIImage *image, NSString *imageUrl) {
        NSLog(@"下载照片:%@", imageUrl);
    }];
    [self.navigationController.view addSubview:browser];

    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - tableView datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.datas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIde = @"cellIde";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIde];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIde];
        
        UIImageView *imv = [[UIImageView alloc] initWithFrame:CGRectZero];
        imv.tag = 100;
        [cell.contentView addSubview:imv];
        [imv mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(cell.contentView).offset(5);
            make.bottom.equalTo(cell.contentView).offset(-5);
            make.right.equalTo(cell.contentView).offset(-15);
            make.width.mas_equalTo(100);
        }];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%@%@%@", @(indexPath.row), @(indexPath.row), @(indexPath.row)];
    NSString *url = self.datas[indexPath.row];
    UIImageView *imv = [cell.contentView viewWithTag:100];
    [imv sd_setImageWithURL:[NSURL URLWithString:url]];
    return cell;
}


- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.tableFooterView = [UIView new];
        _tableView.backgroundColor = [UIColor clearColor];
    }
    return _tableView;
}

- (NSArray *)datas {
    if (!_datas) {
        _datas = @[
            @"https://b0-images.we-pj.net/chat_im/stg/20210329/1617013514746/E0065C9057D8463EAE4179DE12AB3D85.png",
            @"https://b0-images.we-pj.net/chat_im/stg/20210329/1617013685385/49464D449C5C48808AA60A0A7C62338A.png",
            @"https://b0-images.we-pj.net/chat_im/stg/20210329/1617013699214/397BE2B763674064B087C7AD82F53233.png",
            @"https://b0-images.we-pj.net/chat_im/stg/20210329/1617013702286/BD02C6CD2C754FC6A7201126C6C55C0B.png",
            @"https://b0-images.we-pj.net/chat_im/stg/20210329/1617013707341/20C8F82C9EF74118A285C5C4C5E1B74E.png",
            @"https://b0-images.we-pj.net/chat_im/stg/20210329/1617013708528/25732A14115A4CE5ACBF1B5C77C7EBAA.png",
            @"https://b0-images.we-pj.net/chat_im/stg/20210329/1617013883473/9C72E04124354A75A5F6B8C70E469B3D.png",
            @"https://b0-images.we-pj.net/chat_im/stg/20210329/1617013889676/F857921AB5C345579A1E9DEFBB853993.png",
            @"https://b0-images.we-pj.net/chat_im/stg/20210329/1617013893916/27F4EB64087B44D798CA646BA4264F8C.png"
        ];
    }
    return _datas;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
