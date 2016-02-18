//
//  ALProfileViewController.m
//  WeChat
//
//  Created by Arclin on 16/2/18.
//  Copyright © 2016年 sziit. All rights reserved.
//

#import "ALProfileViewController.h"
#import "XMPPvCardTemp.h"

@interface ALProfileViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;// 头像
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;// 昵称
@property (weak, nonatomic) IBOutlet UILabel *wechatNumLabel;// 微信号

@property (weak, nonatomic) IBOutlet UILabel *orgNameLabel; // 公司
@property (weak, nonatomic) IBOutlet UILabel *departmentLabel;// 部门
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;// 职位
@property (weak, nonatomic) IBOutlet UILabel *telLabel;// 电话
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;// 邮箱

@end

@implementation ALProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 1. 它内部会去数据查找
    // 由于解析电子名片xml没有完善，有节点未解析，所以称为临时
    XMPPvCardTemp *myvCard = [ALXMPPTool sharedALXMPPTool].vCard.myvCardTemp;
    
    // 获取头像
    if (myvCard.photo) {
        self.avatarImageView.image = [UIImage imageWithData:myvCard.photo];
    }
    
    // 微信号（显示用户名）
    self.wechatNumLabel.text = [ALAccount shareAccount].loginUser;
    
    // 昵称
    self.nicknameLabel.text = myvCard.nickname;
    
    // 公司
    self.orgNameLabel.text = myvCard.orgName;
    
    // 部门
    if (myvCard.orgUnits.count > 0) {
        self.departmentLabel.text = myvCard.orgUnits[0];
    }
    
    // 职位
    self.titleLabel.text = myvCard.title;
    
//    self.telLabel.text = myvCard.telecomsAddresses[0];
    // 使用note充当电话
    self.telLabel.text = myvCard.note;
    
    // 邮箱
    // 使用mailer充当
    self.emailLabel.text = myvCard.mailer;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
