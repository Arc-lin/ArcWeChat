//
//  ALAccount.h
//  WeChat
//
//  Created by Arclin on 16/2/16.
//  Copyright © 2016年 sziit. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ALAccount : NSObject

@property (nonatomic,copy) NSString *user;
@property (nonatomic,copy) NSString *pwd;
/**
 *  判断用户是否登录
 */
@property (nonatomic,assign,getter=isLogin)BOOL login;

+(instancetype)shareAccount;

/**
 *  保存最新的登录用户数据到沙盒里面去
 */
- (void)saveToSandBox;
@end
