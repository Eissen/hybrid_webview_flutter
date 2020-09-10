//
//  Webview.m
//  hybrid_webview_flutter
//
//  Created by wangxu-mp on 2020/9/10.
//

#import "Webview.h"

#import <JavaScriptCore/JavaScriptCore.h>
@interface Webview() <UIWebViewDelegate,UIScrollViewDelegate>

@end

@implementation Webview {
    // 创建后的标识
    int64_t _viewId;
    UIWebView * _webView;
    //消息回调
    FlutterMethodChannel* _channel;
    BOOL htmlImageIsClick;
    NSMutableArray* mImageUrlArray;
    JSContext *_context;
}

-(instancetype)initWithWithFrame:(CGRect)frame viewIdentifier:(int64_t)viewId arguments:(id)args binaryMessenger:(NSObject<FlutterBinaryMessenger> *)messenger{
    if ([super init]) {
        if (frame.size.width==0) {
            frame=CGRectMake(frame.origin.x, frame.origin.y, [UIScreen mainScreen].bounds.size.width, 22);
        }
        _webView =[[UIWebView alloc] initWithFrame:frame];
        _webView.delegate=self;
        _webView.scrollView.delegate = self;
        _viewId = viewId;
        
        //创建context
        _context = [_webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
        //设置异常处理
        _context.exceptionHandler = ^(JSContext *context, JSValue *exception) {
            [JSContext currentContext].exception = exception;
            NSLog(@"exception:%@",exception);
        };
        
        //接收 初始化参数
        NSDictionary *dic = args;
        NSString *url = [dic valueForKey:@"url"];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
        [_webView loadRequest:request];
        
//        js 注入与回调 block
        _context[@"jsCallFlutter"] = ^(JSValue *values) {
            NSLog(@"%@ ===========", values);
        };
        _context[@"jsCallback"] = ^(JSValue *values) {
            
        };
        _context[@"callOCOnLoad"] = ^() {
            NSLog(@"window onload ========================== ");
        };
        [_context evaluateScript:@"window.onload = function(){callOCOnLoad()}"];
        
        // 注册flutter 与 ios 通信通道
        NSString* channelName = [NSString stringWithFormat:@"com.calcbit.hybridWebview_%lld", viewId];
        _channel = [FlutterMethodChannel methodChannelWithName:channelName binaryMessenger:messenger];
        __weak __typeof__(self) weakSelf = self;
        [_channel setMethodCallHandler:^(FlutterMethodCall *  call, FlutterResult  result) {
            [weakSelf onMethodCall:call result:result];
        }];
        
    }
    return self;
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:[NSNumber numberWithInt:200] forKey:@"code"];
    [dict setObject:@"webViewDidFinishLoad" forKey:@"message"];
    [_channel invokeMethod:@"finishLoad" arguments:dict];
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:[NSNumber numberWithInt:500] forKey:@"code"];
    [dict setObject:@"didFailLoadWithError" forKey:@"message"];
    [_channel invokeMethod:@"finishLoad" arguments:dict];
}


-(void)onMethodCall:(FlutterMethodCall*)call result:(FlutterResult)results{
    if ([[call method] isEqualToString:@"load"]) {
    }
}


- (nonnull UIView *)view {
    return _webView;
}


@end
