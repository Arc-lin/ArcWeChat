//
//  ALEditVCardViewController.m
//  WeChat
//
//  Created by Arclin on 16/2/19.
//  Copyright © 2016年 sziit. All rights reserved.
//

#import "ALEditVCardViewController.h"

@interface ALEditVCardViewController ()

@property (weak, nonatomic) IBOutlet UITextField *textField;

@end

@implementation ALEditVCardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置标题
    self.title = self.cell.textLabel.text;
    
    // 设置输入框默认数值
    self.textField.text = self.cell.detailTextLabel.text;
}
- (IBAction)saveBtnClick:(id)sender {
    // 1. 把cell的detailTextLabel的值更改
    self.cell.detailTextLabel.text = self.textField.text;
    
    // 重新布局，当detailLabel没有值的时候不会创建detailLabel,重新布局可以在有值的时候立马创建
    [self.cell layoutSubviews];
    
    // 2.当前控制器销毁
    [self.navigationController popViewControllerAnimated:YES];
    
    // 3.通知上一个控制器
    if ([self.delegate respondsToSelector:@selector(editVCardViewController:didFinishedSave:)]) {
        [self.delegate editVCardViewController:self didFinishedSave:sender];
    }
}
- (IBAction)cancelBtnClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
