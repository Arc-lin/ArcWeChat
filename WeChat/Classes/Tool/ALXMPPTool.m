//
//  ALXMPPTool.m
//  WeChat
//
//  Created by Arclin on 16/2/17.
//  Copyright © 2016年 sziit. All rights reserved.
//

#import "ALXMPPTool.h"
#import "XMPPFramework.h"

/* 用户登录流程
 1.初始化XMPPStream
 2.连接服务器（传一个JID）
 3.连接成功，接着发送密码
 4.发送一个 "在线消息" 请求给服务器,默认登录成功是不在线的 -> 可以通知其他用户你上线
 */
@interface ALXMPPTool ()<XMPPStreamDelegate>{
    
    XMPPStream *_xmppStream; // 与服务器交互的核心类
    
    XMPPResultBlock _resultBlock; // 结果回调block
}
/**
 *   1.初始化XMPPStream
 */
- (void)setUpStream;
/**
 *   2.连接服务器（传一个JID）
 */
- (void)connectToHost;
/**
 *   3.连接成功，接着发送密码
 */
- (void)sendPwdToHost;
/**
 *  4.发送一个 "在线消息" 请求给服务器
 */
- (void)sendOnline;
/**
 *  发送"离线"消息
 */
- (void)sendOffline;
/**
 *  与服务器断开连接
 */
- (void)disconnectFromHost;
@end

@implementation ALXMPPTool

singleton_implementation(ALXMPPTool)

#pragma mark - 私有方法
- (void)setUpStream
{
    // 创建XMPPStream对象
    _xmppStream = [[XMPPStream alloc] init];
    
    // 设置代理 - 所有的代理方法都将在子线程被调用
    [_xmppStream addDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    
}

- (void)connectToHost
{
    // 初始化
    if (!_xmppStream) {
        [self setUpStream];
    }
    
    // 1.设置登录用户的JID
    // resource 用户登陆客户端设备登录的类型
    NSString *user = [ALAccount shareAccount].user;
    //    NSString *user = [[NSUserDefaults standardUserDefaults] objectForKey:@"user"];
    XMPPJID *myJid = [XMPPJID jidWithUser:user domain:@"arclin.local" resource:@"iphone"];
    _xmppStream.myJID = myJid;
    
    // 2.设置主机地址
    _xmppStream.hostName = @"127.0.0.1";
    
    // 3.设置主机端口号
    _xmppStream.hostPort = 5222;
    
    // 4.发起连接
    NSError *error = nil;
    // 缺少必要的参数时就回发起连接失败 ？ 没有设置JID
    [_xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error];
    if (error) {
        NSLog(@"%@",error);
    }else{
        NSLog(@"发起连接成功");
    }
    
}

- (void)disconnectFromHost
{
    [_xmppStream disconnect];
}

- (void)sendPwdToHost
{
    NSError *error = nil;
    //    NSString *pwd = [[NSUserDefaults standardUserDefaults] objectForKey:@"pwd"];
    NSString *pwd = [ALAccount shareAccount].pwd;
    [_xmppStream authenticateWithPassword:pwd error:nil];
    if (error) {
        NSLog(@"%@",error);
    }else{
        NSLog(@"发送密码成功");
    }
}

- (void)sendOnline
{
    // XMPP框架，已经把所有的指令封装成对象
    XMPPPresence *presence = [XMPPPresence presence];
    NSLog(@"%@",presence);
    [_xmppStream sendElement:presence];
}

- (void)sendOffline
{
    XMPPPresence *offline = [XMPPPresence presenceWithType:@"unavailable"];
    [_xmppStream sendElement:offline];
}
#pragma mark - XMPPStream的代理
#pragma mark 连接建立成功
- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
    [self sendPwdToHost];
}

#pragma mark 登录成功
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    [self sendOnline];
    
    // 回调resultBlock
    if(_resultBlock){
        _resultBlock(XMPPResultTypeLoginSuccess);
    }
}

#pragma mark 登录失败
- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error
{
    NSLog(@"失败 %@",error);
    // 回调resultBlock
    if(_resultBlock){
        _resultBlock(XMPPResultTypeLoginFailure);
    }
}

#pragma mark - 公共方法

#pragma mark 用户登录
- (void)xmppLogin:(XMPPResultBlock)resultBlock
{
    // 不管什么情况，把以前的连接断开
    [_xmppStream disconnect];
    
    // 保存resultBlock
    _resultBlock = resultBlock;
    
    // 连接服务开始登录的操作
    [self connectToHost];
}

#pragma mark 用户注销
- (void)xmppLogout
{
    // 1. 发送"离线消息"给服务器
    [self sendOffline];
    // 2. 断开与服务器的连接
    [self disconnectFromHost];
}
@end
