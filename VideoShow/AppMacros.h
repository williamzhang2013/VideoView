//
//  Macros.h
//  VideoShow
//
//  Created by chengkai.gan on 14-9-24.
//  Copyright (c) 2014年 energy. All rights reserved.
//

#ifndef VideoShow_Macros_h
#define VideoShow_Macros_h

/** 定义宏 */

//定义数据库文件名
#define DB_NAME @"VideoShow"

//服务器主机地址
#define SERVICE_HOST @"http://api.videoshowapp.com:8087"
// soap请求的wsdl请求地址
#define WSDL @"http://api.videoshowapp.com:8087/services/goodsservice.asmx/"

//解析json字符串内容键
#define KEY @"text"

//检索邮箱地址正确性
#define EMAIL_REGEX @"\\b([a-zA-Z0-9%_.+\\-]+)@([a-zA-Z0-9.\\-]+?\\.[a-zA-Z]{2,6})\\b"
//检索手机号的正则表达式
#define PHONE_REGEX @"^((13[0-9])|(147)|(15[^4,\\D])|(18[0,5-9]))\\d{8}$"

//instagram访问令牌
#define INSTAGRAM_TOKEN @"instagram_token"

#define instagram_id eb30e0b995c4431e98863cd73089d5a3
#define instagram_secret c0fb2d4986b94a6e9c5043809ac76ffa

//videoshow在facebook上的用户id,登陆后通过查看网页源码找到搜索USER_ID可以得到  100007924365289  测试用户id
#define FACEBOOK_USERID @"100006663420627"

//https://apps.twitter.com/app/new videoshowapp在 可以通过注册应用得到user id
#define TWITTER_USERID @"1706567557"


// Client id        eb30e0b995c4431e98863cd73089d5a3
// Client Secret 	c0fb2d4986b94a6e9c5043809ac76ffa
// Website URL 	http://www.videoshowapp.com
// Redirect URI 	http://www.videoshowapp.com

/////////////////////////////////开放平台//////////////////////////////
//友盟 old 53cf1d2856240bfc7e0936d8
#define umeng_key @"543e453bfd98c5c192003fa3"

//微信开放平台key
#define wechat_key @"wxf9928eaa00912b54"
#define wechat_secret @"ef82c74c032807b749889af245337a28"

// facebook开放平台key old=606029609517176
#define facebook_key @"305975129608846"

// 新浪开放平台
#define sina_key @"674397331"
#define sina_secret @"30c293bacc6b54efab32187e9834fe22"


#define youtube_key @"12254982715-ccgv8oc0gal55k0jp6g35r9igiunp7g1.apps.googleusercontent.com"
#define youtube_secret @"PYuqhZInf1ph5s4sGUgQ20ao"

#define sysVersion [[[UIDevice currentDevice] systemVersion] intValue]

#endif
