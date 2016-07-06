//
//  ViewController.m
//  A8ContactTest
//
//  Created by cht on 16/7/5.
//  Copyright © 2016年 cht. All rights reserved.
//

#import "ViewController.h"

#import <AddressBook/AddressBook.h>
#import "CHTPerson.h"

@interface ViewController ()<UIAlertViewDelegate>



@end

@implementation ViewController{
    
    NSMutableArray *_peoples;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (IBAction)btn1Click:(id)sender {
    
    _peoples = [NSMutableArray new];
    
    [self getAllContacts];
    
}


- (IBAction)btn2Click:(id)sender {
    
    [self configAddressBook];
}

- (void)openWhatsApp{
    
    NSURL *whatsappURL = [NSURL URLWithString:@"whatsapp://send?text=Hello%2C%20World!"];
    if ([[UIApplication sharedApplication] canOpenURL: whatsappURL]) {
        [[UIApplication sharedApplication] openURL: whatsappURL];
    }
}

//添加联系人
- (void)addContactWithAddressBook:(ABAddressBookRef)addressBook{
    
    NSString * firstName = @"金刚狼";
    NSString * note = @"Added by Qfang App on 2016/07/05";
    NSString * phoneNum = @"13717115843";
    
    //电话存在，不存进通讯录
    if ([self isPhoneExist:phoneNum addressBook:addressBook]) {
        
        [self openWhatsApp];
        return;
    }
    
    //创建一条记录
    ABRecordRef recordRef= ABPersonCreate();
    ABRecordSetValue(recordRef, kABPersonFirstNameProperty, (__bridge CFTypeRef)(firstName), NULL);//添加名
    
    //kABPersonNoteProperty
    ABRecordSetValue(recordRef, kABPersonNoteProperty, (__bridge CFTypeRef)(note), NULL);//添加备注
    
    //号码
    ABMultiValueRef phone =ABMultiValueCreateMutable(kABMultiStringPropertyType);
    ABMultiValueAddValueAndLabel(phone, (__bridge CFTypeRef)(phoneNum),kABPersonPhoneMobileLabel, NULL);//添加移动号码0
    //⋯⋯ 添加多个号码
    
    ABRecordSetValue(recordRef, kABPersonPhoneProperty, phone, NULL);//写入全部号码进联系人
    
    //添加记录
    ABAddressBookAddRecord(addressBook, recordRef, NULL);
    
    //保存通讯录，提交更改
    ABAddressBookSave(addressBook, NULL);
    //释放资源
    CFRelease(recordRef);
    CFRelease(phone);

}

//联系人操作
- (void)configAddressBook{
    
    NSArray *statuses = @[@"kABAuthorizationStatusNotDetermined",@"kABAuthorizationStatusRestricted",@"kABAuthorizationStatusDenied",@"kABAuthorizationStatusAuthorized"];
    ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
    
    NSLog(@"status : %@",statuses[status]);
    
    if (status == kABAuthorizationStatusAuthorized){
        CFErrorRef *error = NULL;
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
        [self addContactWithAddressBook:addressBook];
        CFRelease(addressBook);
    }
    else if (status == kABAuthorizationStatusNotDetermined) {
        ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
        ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error){
            NSLog(@"granted:%d",granted);
            if (granted) {
                //用户允许访问通讯录
                CFErrorRef *error1 = NULL;
                ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error1);
                [self addContactWithAddressBook:addressBook];
                CFRelease(addressBook);
    
            } else {
                
                //用户拒绝访问通讯录
                NSLog(@"user denied");
                
            }
        });
    }
    else {
        //Restricted OR Denied
        
        NSString * title = @"請先允許此應用程式存取你的通訊錄";
        
        UIAlertView * al = [[UIAlertView alloc]initWithTitle:title message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"設定", nil];
        al.delegate = self;
        [al show];
        
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (1 == buttonIndex) {
        
        NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        
        if([[UIApplication sharedApplication] canOpenURL:url]) {
            
            NSURL *url =[NSURL URLWithString:UIApplicationOpenSettingsURLString];
            [[UIApplication sharedApplication] openURL:url];
        }
    }
}

//读取通讯录
- (void)getAllContacts{
    
    NSArray *statuses = @[@"kABAuthorizationStatusNotDetermined",@"kABAuthorizationStatusRestricted",@"kABAuthorizationStatusDenied",@"kABAuthorizationStatusAuthorized"];
    ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
    
    NSLog(@"status : %@",statuses[status]);
    
    if (status == kABAuthorizationStatusAuthorized){
        CFErrorRef *error = NULL;
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
        [self copyAddressBook:addressBook];
        CFRelease(addressBook);
    }
    else if (status == kABAuthorizationStatusNotDetermined) {
        ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
        ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error){
            NSLog(@"granted:%d",granted);
            if (granted) {
                CFErrorRef *error1 = NULL;
                ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error1);
                [self copyAddressBook:addressBook];
                CFRelease(addressBook);
//                [NVMContactManager postMainThreadNotification:NVMContactAccessAllowedNotification];
            } else {
//                [NVMContactManager postMainThreadNotification:NVMContactAccessDeniedNotification];
            }
        });
    }
    else {
        //        Restricted OR Denied
//        [NVMContactManager postMainThreadNotification:NVMContactAccessFailedNotification];

    }
}

- (BOOL)isPhoneExist:(NSString *)phoneNum addressBook:(ABAddressBookRef)addressBook{
    
    CFArrayRef records;
    if (addressBook) {
        // 获取通讯录中全部联系人
        records = ABAddressBookCopyArrayOfAllPeople(addressBook);
    }
    for (int i=0; i<CFArrayGetCount(records); i++) {
        ABRecordRef record = CFArrayGetValueAtIndex(records, i);
        CFTypeRef items = ABRecordCopyValue(record, kABPersonPhoneProperty);
        CFArrayRef phoneNums = ABMultiValueCopyArrayOfAllValues(items);
        if (phoneNums) {
            for (int j=0; j<CFArrayGetCount(phoneNums); j++) {
                NSString *phone = (NSString*)CFArrayGetValueAtIndex(phoneNums, j);
                if ([phone isEqualToString:phoneNum]) {
                    return YES;
                }
            }
        }
    }
    return NO;
}



- (void)copyAddressBook:(ABAddressBookRef)addressBook{
    
    [_peoples removeAllObjects];
    CFIndex numberOfPeople = ABAddressBookGetPersonCount(addressBook);
    CFArrayRef people = ABAddressBookCopyArrayOfAllPeople(addressBook);
    
    for ( int i = 0; i < numberOfPeople; i++){
        
        ABRecordRef person = CFArrayGetValueAtIndex(people, i);
        CHTPerson *contact = [CHTPerson new];
        NSString *firstName = (NSString *)CFBridgingRelease(ABRecordCopyValue(person, kABPersonFirstNameProperty));
        contact.firstName = firstName;
        NSString *middlename = (NSString*)CFBridgingRelease(ABRecordCopyValue(person, kABPersonMiddleNameProperty));
        contact.middleName = middlename;
        NSString *lastName = (NSString *)CFBridgingRelease(ABRecordCopyValue(person, kABPersonLastNameProperty));
        contact.lastName = lastName;
        
        NSMutableArray *phones = [NSMutableArray array];
        ABMultiValueRef phone = ABRecordCopyValue(person, kABPersonPhoneProperty);
        for (int k = 0; k<ABMultiValueGetCount(phone); k++)
        {
            NSString * personPhone = (NSString*)CFBridgingRelease(ABMultiValueCopyValueAtIndex(phone, k));
            [phones addObject:personPhone];
        }
        contact.phoneNumbers = phones.copy;
        CFRelease(phone);
        
        [_peoples addObject:contact];
        
        //        //读取middlename
        //        NSString *middlename = (NSString*)CFBridgingRelease(ABRecordCopyValue(person, kABPersonMiddleNameProperty));
        //        //读取prefix前缀
        //        NSString *prefix = (NSString*)CFBridgingRelease(ABRecordCopyValue(person, kABPersonPrefixProperty));
        //        //读取suffix后缀
        //        NSString *suffix = (NSString*)CFBridgingRelease(ABRecordCopyValue(person, kABPersonSuffixProperty));
        //        //读取nickname呢称
        //        NSString *nickname = (NSString*)CFBridgingRelease(ABRecordCopyValue(person, kABPersonNicknameProperty));
        //        //读取firstname拼音音标
        //        NSString *firstnamePhonetic = (NSString*)CFBridgingRelease(ABRecordCopyValue(person, kABPersonFirstNamePhoneticProperty));
        //        //读取lastname拼音音标
        //        NSString *lastnamePhonetic = (NSString*)CFBridgingRelease(ABRecordCopyValue(person, kABPersonLastNamePhoneticProperty));
        //        //读取middlename拼音音标
        //        NSString *middlenamePhonetic = (NSString*)CFBridgingRelease(ABRecordCopyValue(person, kABPersonMiddleNamePhoneticProperty));
        //        //读取organization公司
        //        NSString *organization = (NSString*)CFBridgingRelease(ABRecordCopyValue(person, kABPersonOrganizationProperty));
        //        //读取jobtitle工作
        //        NSString *jobtitle = (NSString*)CFBridgingRelease(ABRecordCopyValue(person, kABPersonJobTitleProperty));
        //        //读取department部门
        //        NSString *department = (NSString*)CFBridgingRelease(ABRecordCopyValue(person, kABPersonDepartmentProperty));
        //        //读取birthday生日
        //        NSDate *birthday = (NSDate*)CFBridgingRelease(ABRecordCopyValue(person, kABPersonBirthdayProperty));
        //        //读取note备忘录
        //        NSString *note = (NSString*)CFBridgingRelease(ABRecordCopyValue(person, kABPersonNoteProperty));
        //        //第一次添加该条记录的时间
        //        NSString *firstknow = (NSString*)CFBridgingRelease(ABRecordCopyValue(person, kABPersonCreationDateProperty));
        //        //        NSLog(@"第一次添加该条记录的时间%@\n",firstknow);
        //        //最后一次修改該条记录的时间
        //        NSString *lastknow = (NSString*)CFBridgingRelease(ABRecordCopyValue(person, kABPersonModificationDateProperty));
        //        //        NSLog(@"最后一次修改該条记录的时间%@\n",lastknow);
        //
        //        //获取email多值
        //        ABMultiValueRef email = ABRecordCopyValue(person, kABPersonEmailProperty);
        //        int emailcount = ABMultiValueGetCount(email);
        //        for (int x = 0; x < emailcount; x++)
        //        {
        //            //获取email Label
        //            NSString* emailLabel = (NSString*)CFBridgingRelease(ABAddressBookCopyLocalizedLabel(ABMultiValueCopyLabelAtIndex(email, x)));
        //            //获取email值
        //            NSString* emailContent = (NSString*)CFBridgingRelease(ABMultiValueCopyValueAtIndex(email, x));
        //        }
        //        CFRelease(email);
        //        //读取地址多值
        //        ABMultiValueRef address = ABRecordCopyValue(person, kABPersonAddressProperty);
        //        CFIndex count = ABMultiValueGetCount(address);
        //
        //        for(int j = 0; j < count; j++)
        //        {
        //            //获取地址Label
        //            NSString* addressLabel = (NSString*)CFBridgingRelease(ABMultiValueCopyLabelAtIndex(address, j));
        //            //获取該label下的地址6属性
        //            NSDictionary* personaddress =(NSDictionary*) CFBridgingRelease(ABMultiValueCopyValueAtIndex(address, j));
        //            NSString* country = [personaddress valueForKey:(NSString *)kABPersonAddressCountryKey];
        //            NSString* city = [personaddress valueForKey:(NSString *)kABPersonAddressCityKey];
        //            NSString* state = [personaddress valueForKey:(NSString *)kABPersonAddressStateKey];
        //            NSString* street = [personaddress valueForKey:(NSString *)kABPersonAddressStreetKey];
        //            NSString* zip = [personaddress valueForKey:(NSString *)kABPersonAddressZIPKey];
        //            NSString* coutntrycode = [personaddress valueForKey:(NSString *)kABPersonAddressCountryCodeKey];
        //        }
        //
        //        CFRelease(address);
        //        //获取dates多值
        //        ABMultiValueRef dates = ABRecordCopyValue(person, kABPersonDateProperty);
        //        CFIndex datescount = ABMultiValueGetCount(dates);
        //        for (int y = 0; y < datescount; y++)
        //        {
        //            //获取dates Label
        //            NSString* datesLabel = (NSString*)CFBridgingRelease(ABAddressBookCopyLocalizedLabel(ABMultiValueCopyLabelAtIndex(dates, y)));
        //            //获取dates值
        //            NSString* datesContent = (NSString*)CFBridgingRelease(ABMultiValueCopyValueAtIndex(dates, y));
        //        }
        //        CFRelease(dates);
        //        //获取kind值
        //        CFNumberRef recordType = ABRecordCopyValue(person, kABPersonKindProperty);
        //        if (recordType == kABPersonKindOrganization) {
        //            // it's a company
        //            //            NSLog(@"it's a company\n");
        //        } else {
        //            // it's a person, resource, or room
        //            //            NSLog(@"it's a person, resource, or room\n");
        //        }
        //
        //
        //        //获取IM多值
        //        ABMultiValueRef instantMessage = ABRecordCopyValue(person, kABPersonInstantMessageProperty);
        //        for (int l = 1; l < ABMultiValueGetCount(instantMessage); l++)
        //        {
        //            //获取IM Label
        //            NSString* instantMessageLabel = (NSString*)CFBridgingRelease(ABMultiValueCopyLabelAtIndex(instantMessage, l));
        //            //获取該label下的2属性
        //            NSDictionary* instantMessageContent =(NSDictionary*) CFBridgingRelease(ABMultiValueCopyValueAtIndex(instantMessage, l));
        //            NSString* username = [instantMessageContent valueForKey:(NSString *)kABPersonInstantMessageUsernameKey];
        //
        //            NSString* service = [instantMessageContent valueForKey:(NSString *)kABPersonInstantMessageServiceKey];
        //        }
        //        CFRelease(instantMessage);
        //        //读取电话多值
        //        ABMultiValueRef phone = ABRecordCopyValue(person, kABPersonPhoneProperty);
        //        for (int k = 0; k<ABMultiValueGetCount(phone); k++)
        //        {
        //            //获取电话Label≥
        //            NSString * personPhoneLabel = (NSString*)CFBridgingRelease(ABAddressBookCopyLocalizedLabel(ABMultiValueCopyLabelAtIndex(phone, k)));
        //            //获取該Label下的电话值
        //            NSString * personPhone = (NSString*)CFBridgingRelease(ABMultiValueCopyValueAtIndex(phone, k));
        //
        //        }
        //        CFRelease(phone);
        //
        //        //获取URL多值
        //        ABMultiValueRef url = ABRecordCopyValue(person, kABPersonURLProperty);
        //        for (int m = 0; m < ABMultiValueGetCount(url); m++)
        //        {
        //            //获取电话Label
        //            NSString * urlLabel = (NSString*)CFBridgingRelease(ABAddressBookCopyLocalizedLabel(ABMultiValueCopyLabelAtIndex(url, m)));
        //            //获取該Label下的电话值
        //            NSString * urlContent = (NSString*)CFBridgingRelease(ABMultiValueCopyValueAtIndex(url,m));
        //        }
        //        CFRelease(url);
        //        //读取照片
        //        NSData *imageData = (NSData*)CFBridgingRelease(ABPersonCopyImageData(person));
        
        
    }
    CFRelease(people);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
