//
//  CHTPerson.h
//  A8ContactTest
//
//  Created by cht on 16/7/5.
//  Copyright © 2016年 cht. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CHTPerson : NSObject

@property (nonatomic, copy) NSString *firstName;
@property (nonatomic, copy) NSString *middleName;
@property (nonatomic, copy) NSString *lastName;
@property (nonatomic, strong) NSMutableArray *phoneNumbers;

@end
