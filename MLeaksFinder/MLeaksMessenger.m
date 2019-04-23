/**
 * Tencent is pleased to support the open source community by making MLeaksFinder available.
 *
 * Copyright (C) 2017 THL A29 Limited, a Tencent company. All rights reserved.
 *
 * Licensed under the BSD 3-Clause License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 *
 * https://opensource.org/licenses/BSD-3-Clause
 *
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */


#import "MLeaksMessenger.h"

static __weak UIAlertView *alertView;

@implementation MLeaksMessenger

static NSString * leakSavePath =  @"https://backend.luojilab.com/leak/leaksave";


+ (void)alertWithTitle:(NSString *)title message:(NSString *)message {
    [self alertWithTitle:title message:message delegate:nil additionalButtonTitle:nil];
}

+ (void)alertWithTitle:(NSString *)title
               message:(NSString *)message
              delegate:(id<UIAlertViewDelegate>)delegate
 additionalButtonTitle:(NSString *)additionalButtonTitle {
    [alertView dismissWithClickedButtonIndex:0 animated:NO];
    UIAlertView *alertViewTemp = [[UIAlertView alloc] initWithTitle:title
                                                            message:message
                                                           delegate:delegate
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:additionalButtonTitle, nil];
    //[alertViewTemp show];
    //弹出alert提示
    alertView = alertViewTemp;
    
    NSLog(@"%@: %@", title, message);
    NSLog(@"leak%@: %@", title, message);
    // 此处应该上报内存泄漏
    NSString*class_name= [self getClassName:message];
    NSString *leak_detail = [NSString stringWithFormat:@"%@", message];
    NSDictionary *params = @{@"class_name":class_name, @"pkg_name":@"com.luojilab.LuoJiFM-IOS",
                             @"pkg_ver":@"0.0.0", @"leak_detail":leak_detail,
                             @"os_version":@"12.0.1",@"device_name":@"iPhone X",@"uid":@"000000"};
    [self sendLeakResult:params];
}


/**
 *  发送内存泄漏数据到测试平台
 **/
+ (void)sendLeakResult:(NSDictionary *)params{
    
    NSLog(@"发送请求url=%@,params=%@",leakSavePath,params);
    NSDictionary *headers = @{ @"Content-Type": @"application/json"};
    NSData *postData = [NSJSONSerialization dataWithJSONObject:params options:0 error:nil];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:leakSavePath]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10.0];
    [request setHTTPMethod:@"POST"];
    [request setAllHTTPHeaderFields:headers];
    [request setHTTPBody:postData];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                    if (error) {
                                                        NSLog(@"leakerror%@", error);
                                                    } else {
                                                        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                                                        NSLog(@"leakresponse%@", httpResponse);
                                                    }
                                                }];
    [dataTask resume];
    
}


/**
 *  获取view名字作为ClassName
 **/
+ (NSString *)getClassName:(NSString *)str
{
    NSString *temp = [str stringByReplacingOccurrencesOfString:@" " withString:@""];
    temp = [temp stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    temp = [temp stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    temp=[temp stringByReplacingOccurrencesOfString:@"("withString:@""];
    temp=[temp stringByReplacingOccurrencesOfString:@")"withString:@""];
    NSArray *className = [temp componentsSeparatedByString:@","];
    return [className objectAtIndex:0];
}




///**
//*  发送内存泄漏数据到测试平台
//**/
//+ (void)sendLeakResult:(NSDictionary *)params{
//    // 请求头
//    // 请求参数字典
//    NSLog(@"发送请求url=%@,params=%@",leakSavePath,params);
//
//    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
//
//    NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST" URLString:leakSavePath parameters:params error:nil];
//    request.timeoutInterval = 10.f;
//    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
//    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
//
//    NSURLSessionDataTask *task = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
//        NSLog(@"-----leak responseObject-----",responseObject);
//        NSHTTPURLResponse * responses = (NSHTTPURLResponse *)task.response;
//        if (!error && responses.statusCode == 200) {
//            if ([responseObject isKindOfClass:[NSDictionary class]]) {
//                // 请求成功数据处理
//                NSString *codeStr = responseObject[@"code"];
//                if (codeStr == 0){
//                     NSLog(@"-----leak data send success!-----");
//                }
//            } else {
//
//            }
//        } else {
//            NSLog(@"请求失败error=%@", error);
//        }
//    }];
//
//}






@end
