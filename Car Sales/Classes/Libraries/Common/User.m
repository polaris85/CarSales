//
//  User.m
//  HeroPager
//
//  Created by Nick LEE on 3/1/12.
//  Copyright (c) 2012 HireVietnamese. All rights reserved.
//

#import "User.h"
#import "Define.h"

@interface User()
-(BOOL) checkScreenIPhone5;
@end

@implementation User

@synthesize isIPhone5Screen = _isIPhone5Screen;

- (id)init
{
    self = [super init];
    if (self) {
        self.isIPhone5Screen = [self checkScreenIPhone5];
        _dicQuery = [[NSMutableDictionary alloc] init];
    }
    return self;
}


-(BOOL) checkScreenIPhone5{
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
        if([UIScreen mainScreen].bounds.size.height == 568.0){
            NSLog(@"init app with iPhone 5 screen");
            return YES;
        }
        else{
            NSLog(@"init app with iPhone default screen");
            return NO;
        }
    }else{
        NSLog(@"init app with iPhone default screen");
        return NO;
    }
}

-(void)login{
    _isLogin = YES;
}
-(void)logout{
    _isLogin = NO;
}



@end
