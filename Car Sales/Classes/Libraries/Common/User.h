//
//  User.h
//  HeroPager
//
//  Created by Nick LEE on 3/1/12.
//  Copyright (c) 2012 HireVietnamese. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject

@property(nonatomic,assign) BOOL isIPhone5Screen;
@property(nonatomic,assign) BOOL isIPhone;
@property(nonatomic,assign) BOOL isPrefCoreData;

//check ws

//profile

@property(nonatomic,strong) NSMutableDictionary *dicQuery;

//settings
@property(nonatomic,assign) BOOL isLogin;

// method

-(void)login;
-(void)logout;

@end