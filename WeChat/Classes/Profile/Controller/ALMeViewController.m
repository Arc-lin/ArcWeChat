//
//  ALMeViewController.m
//  WeChat
//
//  Created by Arclin on 16/2/16.
//  Copyright © 2016年 sziit. All rights reserved.
//

#import "ALMeViewController.h"
#import "XMPPvCardTemp.h"

@interface ALMeViewController ()

/**
 *  登录用户的头像
 */
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
/**
 *  微信号
 */
@property (weak, nonatomic) IBOutlet UILabel *wechatNumberLabel;

@end

@implementation ALMeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 显示头像和微信号
    
    // 从数据库里取用户信息
    // 获取登录用户信息的，使用电子名片模块
    XMPPvCardTemp *myvCard = [ALXMPPTool sharedALXMPPTool].vCard.myvCardTemp;
    
    // 获取头像
    if (myvCard.photo) {
        self.avatarImageView.image = [UIImage imageWithData:myvCard.photo];
    }
    
    // 微信号（显示用户名）
    // 为什么jid是空，原因是服务器返回的电子名片xmp数据没有jabberjid的节点
//    self.wechatNumberLabel.text = myvCard.jid.user; 此行不可行
    self.wechatNumberLabel.text = [@"微信号:" stringByAppendingString:[ALAccount shareAccount].loginUser];
}
- (IBAction)logoutBtnClick:(id)sender {
    
    // 注销
    [[ALXMPPTool sharedALXMPPTool] xmppLogout];

    // 注销的时候，把沙盒的登录状态设置为NO
    [ALAccount shareAccount].login = NO;
    [[ALAccount shareAccount] saveToSandBox];
    
    // 回登录的控制器
    [UIStoryboard showInitialVCWithName:@"Login"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




@end
