//
//  ALChatViewController.m
//  WeChat
//
//  Created by Arclin on 16/2/23.
//  Copyright © 2016年 sziit. All rights reserved.
//

#import "ALChatViewController.h"
#import "XMPPvCardTemp.h"
#import "HttpTool.h"
#import "UIImageView+WebCache.h"

@interface ALChatViewController ()<NSFetchedResultsControllerDelegate,UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    NSFetchedResultsController *_resultContr;
}
@property (weak, nonatomic) IBOutlet UITableView  *tableView;
@property (weak, nonatomic) IBOutlet UIButton *imageChoose;
@property (weak, nonatomic) IBOutlet UIButton *msgSend;
@property (weak, nonatomic) IBOutlet UITextField *textField;
/**
 *  输入框容器距离底部的约束
 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;

@end

@implementation ALChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // 添加键盘通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kbWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kbWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChange) name:UITextFieldTextDidChangeNotification object:nil];
    // 加载数据库的聊天数据
    // 1.上下文
    NSManagedObjectContext *msgContext = [ALXMPPTool sharedALXMPPTool].msgArchivingStorage.mainThreadManagedObjectContext;
    // 2.查询请求
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"XMPPMessageArchiving_Message_CoreDataObject"];

    // 过滤(当前登录用户 和 好友的聊天消息)
    NSString *loginUserJid = [ALXMPPTool sharedALXMPPTool].xmppStream.myJID.bare;
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"streamBareJidStr = %@ and bareJidStr = %@",loginUserJid,self.friendJid.bare];
    request.predicate = pre;
    
    // 设置时间排序
    NSSortDescriptor *timeSort = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES];
    request.sortDescriptors = @[timeSort];
    
    // 3.执行请求
    _resultContr = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:msgContext sectionNameKeyPath:nil cacheName:nil];
    _resultContr.delegate = self;
    NSError *err = nil;
    [_resultContr performFetch:&err];
    if (err) {
        ALLog(@"%@",err);
    }
    [self rollToBottom];
}

#pragma mark 数据库内容改变调用
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView reloadData];
    
    [self rollToBottom];
}
- (void)rollToBottom
{
    // 表格滚动到底部
    if (_resultContr.fetchedObjects.count > 1) {
        ALLog(@"%lu",_resultContr.fetchedObjects.count);
        NSIndexPath *lastIndex = [NSIndexPath indexPathForRow:_resultContr.fetchedObjects.count - 1 inSection:0];
        [self.tableView scrollToRowAtIndexPath:lastIndex atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}
// 监听textView的值的变化
- (void)textChange
{
    // 判断下textView有没有内容
    if (_textField.text.length) { // 有内容
        self.msgSend.hidden = NO;
        self.imageChoose.hidden = YES;
    }else{
        self.msgSend.hidden = YES;
        self.imageChoose.hidden = NO;
    }
}
#pragma mark -tableView DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _resultContr.fetchedObjects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
        static NSString *ID = @"ChatCell";
        UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:ID];
    
        // 获取聊天信息
        XMPPMessageArchiving_Message_CoreDataObject *msgObj = _resultContr.fetchedObjects[indexPath.row];
    
        // 判断消息的类型，有没有附件
        // 1. 获取原始的xml数据
        XMPPMessage *message = msgObj.message;
    
        // 获取附件的类型
        NSString *bodyType = [message attributeStringValueForName:@"bodyType"];
    
        if ([bodyType isEqualToString:@"image"]) { // 图片
            // 获取文件路径
            NSString *url = msgObj.body;
            // 显示图片
            UIImageView *imgV = [[UIImageView alloc] initWithFrame:CGRectMake(150, 0, 100, 100)];
            [imgV sd_setImageWithURL:[NSURL URLWithString:url]];
            [cell addSubview:imgV];
            
            // 清除循环应用导致的残留文字
            cell.textLabel.text = nil;
            
        }else{ // 纯文本
            cell.textLabel.text = msgObj.body;
            // 清除循环应用导致的残留文字
            cell.imageView.image = nil;
        }
    
        if (msgObj.thread) {
            NSData *imageData = [[ALXMPPTool sharedALXMPPTool].avatar photoDataForJID:self.friendJid];
            cell.imageView.image = [UIImage imageWithData:imageData];
        }else{
            NSData *imageData  = [ALXMPPTool sharedALXMPPTool].vCard.myvCardTemp.photo;
            cell.imageView.image = [UIImage imageWithData:imageData];
            
        }
       
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",msgObj.timestamp];
        
        return cell;

}

//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    static NSString *ID = @"ChatCell";
//    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:ID];
//    
//    // 获取聊天信息
//    XMPPMessageArchiving_Message_CoreDataObject *msgObj = _resultContr.fetchedObjects[indexPath.row];
//    
//    // 判断消息的类型，有没有附件
//    // 1. 获取原始的xml数据
//    XMPPMessage *message = msgObj.message;
//    
//    // 获取附件的类型
//    NSString *bodyType = [message attributeStringValueForName:@"bodyType"];
//    
//    if ([bodyType isEqualToString:@"image"]) { // 图片
//            // 2.遍历message的子节点
//            NSArray *child = message.children;
//            for (XMPPElement *note in child) {
//                // 获取节点的名字
//                UIImageView *imgV = [[UIImageView alloc] initWithFrame:CGRectMake(150, 0, 100, 100)];
//                if ([[note name] isEqualToString:@"attachment"]) {
//                    ALLog(@"获取到附件");
//                    // 获取附件字符串，然后转成NSData,再转成图片
//                    NSString *imgBase64Str = [note stringValue];
//                    NSData *imgData = [[NSData alloc] initWithBase64EncodedString:imgBase64Str options:0];
//                    UIImage *img = [UIImage imageWithData:imgData];
//                    imgV.contentMode = UIViewContentModeScaleAspectFill;
//                    imgV.clipsToBounds = YES;
//                    imgV.image = img;
//                    [cell addSubview:imgV];
//                }else{
//                    [imgV removeFromSuperview];
//                }
//            }
//    }else if([bodyType isEqualToString:@"sound"]){ // 音频
//    
//    }else{ // 纯文本
//        cell.textLabel.text = msgObj.body;
//    }
//
//    if (msgObj.thread) {
//        NSData *imageData = [[ALXMPPTool sharedALXMPPTool].avatar photoDataForJID:self.friendJid];
//        cell.imageView.image = [UIImage imageWithData:imageData];
//    }else{
//        NSData *imageData  = [ALXMPPTool sharedALXMPPTool].vCard.myvCardTemp.photo;
//        cell.imageView.image = [UIImage imageWithData:imageData];
//        
//    }
//   
//    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",msgObj.timestamp];
//    
//    return cell;
//}

#pragma mark 键盘的通知
#pragma mark 键盘出现
- (void)kbWillShow:(NSNotification *)noti
{
    // 显示的时候改变bottomContraint
    
    // 获取键盘高度
    CGFloat kbHeight = [noti.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    
    self.bottomConstraint.constant = kbHeight;
        
}
#pragma mark 键盘消失
- (void)kbWillHide:(NSNotification *)noti
{
    self.bottomConstraint.constant = 0;
}


#pragma mark 发送聊天数据
- (IBAction)sendBtnClick:(id)sender {
    [self sendMsg];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self sendMsg];
    return YES;
}
- (void)sendMsg
{
    if (self.textField.text) {
        NSString *txt = self.textField.text;
        // 怎么发聊天数据
        XMPPMessage *msg = [XMPPMessage messageWithType:@"chat" to:self.friendJid];
        [msg addBody:txt];
        [[ALXMPPTool sharedALXMPPTool].xmppStream sendElement:msg];
        
        // 清空输入框的文本
        self.textField.text = nil;
        self.msgSend.hidden = YES;
        self.imageChoose.hidden = NO;
    }
}

#pragma mark 文件发送（图片为例）
- (IBAction)imgChooseBtnClick:(id)sender {
    // 从图片库选取图片
    UIImagePickerController *imgPc = [[UIImagePickerController alloc] init];
    imgPc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imgPc.delegate = self;
    
    [self presentViewController:imgPc animated:YES completion:nil];

}
#pragma mark 用户选择的图片
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    UIImage *img = info[UIImagePickerControllerOriginalImage];
    
    // 发送附件
//    [self sendAttachmentWithData:UIImagePNGRepresentation(img) bodyType:@"image"];
    [self sendImg:img];
    
    // 隐藏图片选择控制器
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)sendImg:(UIImage *)img
{
    // 1.把文件上传到服务器
    /**
     *  >文件上传的路径
     *      http://localhost:8080/xmppfileupload/
     *  >文件上传的方法不是使用post，而是使用put   put: 文件上传的路径也就是文件下载的路径
     */
    // 1.1 定义文件名，user+时间戳
    NSDateFormatter *dateForm = [[NSDateFormatter alloc] init];
    dateForm.dateFormat = @"yyyyMMddHHmmss";
    NSString *currentTimeStr = [dateForm stringFromDate:[NSDate date]];
    
    NSString *fileName = [[ALAccount shareAccount].loginUser stringByAppendingString:currentTimeStr];
    
    // 1.2 拼接文件上传路径
    NSString *uploadPath = [@"http://localhost:8080/xmppfileupload/" stringByAppendingString:fileName];
    ALLog(@"%@",uploadPath);
    
    // 2.上传成功后，把文件路径发送给Openfire服务器
    HttpTool *httpTool = [[HttpTool alloc] init];
    // 图片上传的时候，以jpg格式上传
    // 因为文件服务器只接收jpg
    [httpTool uploadData:UIImageJPEGRepresentation(img, 0.75) url:[NSURL URLWithString:uploadPath] progressBlock:nil completion:^(NSError *error) {
        if (!error) {
            ALLog(@"上传成功");
            XMPPMessage *msg = [XMPPMessage messageWithType:@"chat" to:self.friendJid];
            [msg addAttributeWithName:@"bodyType" stringValue:@"image"];
            [msg addBody:uploadPath];
            
            [[ALXMPPTool sharedALXMPPTool].xmppStream sendElement:msg];
        }else{
            ALLog(@"上传失败");
        }
    }];
}

#pragma mark 发送附件
- (void)sendAttachmentWithData:(NSData *)data bodyType:(NSString *)bodyType{
    
    // 发送附件
    XMPPMessage *msg = [XMPPMessage messageWithType:@"chat" to:self.friendJid];
    
    [msg addAttributeWithName:@"bodyType" stringValue:bodyType];
    // 没有body则不识别为message，所以添加body
    [msg addBody:bodyType];
    
    // 把附件经过“base64编码”转成字符串
    NSString *base64Str = [data base64EncodedStringWithOptions:0];
    
    // 定义附件
    XMPPElement *attachment = [XMPPElement elementWithName:@"attachment" stringValue:base64Str];
    
    // 添加字节点
    [msg addChild:attachment];
    
    [[ALXMPPTool sharedALXMPPTool].xmppStream sendElement:msg];
}

#pragma mark 表格滚动，隐藏键盘
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
