//
//  ALXMPPTool.h
//  WeChat
//
//  Created by Arclin on 16/2/17.
//  Copyright © 2016年 sziit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Singleton.h"
#import "XMPPFramework.h"

typedef enum{
    XMPPResultTypeLoginSuccess, // 登录成功
    XMPPResultTypeLoginFailure,  // 登录失败
    XMPPResultTypeRegisterSuccess, // 注册成功
    XMPPResultTypeRegisterFailure // 注册失败
}XMPPResultType;

/**
 *  与服务器交互的结果
 */
typedef void (^XMPPResultBlock)(XMPPResultType);

@interface ALXMPPTool : NSObject

singleton_interface(ALXMPPTool)


@property (nonatomic,strong,readonly) XMPPStream *xmppStream; // 与服务器交互的核心类
@property (nonatomic,strong,readonly) XMPPvCardTempModule *vCard; // 电子名片模块
@property (nonatomic,strong,readonly) XMPPvCardCoreDataStorage *vCardStorage; // 电子名片数据存储
@property (nonatomic,strong,readonly) XMPPMessageArchiving *msgArchiving; // 消息模块
@property (nonatomic,strong,readonly) XMPPMessageArchivingCoreDataStorage *msgArchivingStorage;// 消息数据存储

/**
 *  标识 连接到服务器 到底是 "登录连接" 还是 "注册连接"
 *  NO 代表登录操作  Yes 代表注册操作
 */
@property (nonatomic,assign,getter=isRegisterOperation) BOOL registerOperation;

@property (nonatomic,strong,readonly) XMPPvCardAvatarModule *avatar; // 电子名片的头像模块
@property (nonatomic,strong,readonly) XMPPRoster *roster; // 花名册
@property (nonatomic,strong,readonly) XMPPRosterCoreDataStorage *rosterStorage; // 花名册数据存储

/**
 *  XMPP用户登录
 */
- (void)xmppLogin:(XMPPResultBlock)resultBlock;

/**
 *  XMPP用户注册
 */
- (void)xmppRegister:(XMPPResultBlock)resultBlock;

/**
 *  用户注销
 */
- (void)xmppLogout;

@end
