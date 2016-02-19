//
//  ALProfileViewController.m
//  WeChat
//
//  Created by Arclin on 16/2/18.
//  Copyright © 2016年 sziit. All rights reserved.
//

#import "ALProfileViewController.h"
#import "ALEditVCardViewController.h"
#import "XMPPvCardTemp.h"

@interface ALProfileViewController ()<ALEditVCardViewControllerDelegate>

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

#pragma mark 表格选择
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 根据cell不同tag进行相应的操作
    /**
     *  tag = 0 换头像
     *  tag = 1 进行到下一个控制器
     *  tag=  2 不做任何操作
     */
    
    // 获取cell
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    switch (selectedCell.tag) {
        case 0:
            
            break;
        case 1:
            [self performSegueWithIdentifier:@"toEditVcSegue" sender:selectedCell];
            break;
            
        case 2:
            
            break;
        default:
            break;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // 获取目标控制器
    id destVc = segue.destinationViewController;
    
    // 设置编辑电子名片控制器的cell属性
    if ([destVc isKindOfClass:[ALEditVCardViewController class]]) {
        ALEditVCardViewController *editVc = destVc;
        editVc.cell = sender;
        // 设置代理
        editVc.delegate = self;
    }
}

#pragma mark 编辑电子名片控制器的代理
- (void)editVCardViewController:(ALEditVCardViewController *)editVc didFinishedSave:(id)sender
{
    // 获取当前的电子名片
    XMPPvCardTemp *myVCard = [ALXMPPTool sharedALXMPPTool].vCard.myvCardTemp;
    
    // 重新设置myVCard里的属性
    myVCard.nickname = self.nicknameLabel.text;
    myVCard.orgName = self.orgNameLabel.text;
    if (self.departmentLabel.text) {
        myVCard.orgUnits = @[self.departmentLabel.text];
    }
    myVCard.title = self.titleLabel.text;
    myVCard.note = self.telLabel.text;
    myVCard.mailer = self.emailLabel.text;
    
    // 把数据保存到服务器
    // 内部实现原理是把整个电子名片重新上传了一遍，包括图片
    [[ALXMPPTool sharedALXMPPTool].vCard updateMyvCardTemp:myVCard];
    
    ALLog(@"修改成功");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
