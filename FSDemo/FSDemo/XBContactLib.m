//
//  XBContactLib.m
//  FSDemo
//
//  Created by 林文圻 on 2022/5/13.




#import "XBContactLib.h"

CNAuthorizationStatus authContactStatus;

@implementation XBContactModel

- (instancetype)init {
    if (self = [super init]) {
        NSLog(@"5.13通讯录模型初始化！！！");
        self.identifier               = @"";
        self.namePrefix               = @"";
        self.givenName                = @"";
        self.middleName               = @"";
        self.familyName               = @"";
        self.previousFamilyName       = @"";
        self.nameSuffix               = @"";
        self.nickname                 = @"";
        self.organizationName         = @"";
        self.departmentName           = @"";
        self.jobTitle                 = @"";
        self.phoneticgivenName        = @"";
        self.phoneticMiddleName       = @"";
        self.phoneticFamilyName       = @"";
        self.phoneticOrganizationName = @"";
        self.birthday                 = @"";
        self.nonGregorianBirthday     = @"";
        self.note                     = @"";
        self.imageData                = @"";
        self.thumbnailImageData       = @"";
        self.imageDataAvailable       = @"";
        self.imageDataAvailable       = @"";
        self.type                     = @"";
        self.phoneNumbers             = @"";
        self.emailAddresses           = @"";
        self.cPostalAddresses         = @"";
        self.contactDates             = @"";
        self.urlAddresses             = @"";
        self.relations                = @"";
        self.socialProfiles           = @"";
        self.instantMessageAddresses  = @"";
    }
    return self;
}

+ (instancetype)contactModelWith:(CNContact *)contact {
    NSLog(@"5.13 通讯录数据制作模型数据");
    XBContactModel *model = XBContactModel.new;
    return model;
}

@end

@implementation XBContactLib

+ (void)requestAuthorizationAddressBook {
    NSLog(@"5.13 通讯录授权");
    // 判断是否授权
    authContactStatus = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    switch (authContactStatus) {
        case CNAuthorizationStatusNotDetermined: { // 还没授权，需要授权
            [[[CNContactStore alloc] init] requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
            }];
        }
            break;
        case CNAuthorizationStatusRestricted: { // 已经被限制,家长控制
        }
            break;
        case CNAuthorizationStatusDenied: { // 拒绝访问
        }
            break;
        case CNAuthorizationStatusAuthorized: { // 允许访问
        }
        default:
            break;
    }
}

+ (void)addressBooks:(void (^)(CNAuthorizationStatus, NSArray * _Nonnull))complete {
    if (authContactStatus != CNAuthorizationStatusAuthorized) {
        complete(authContactStatus, @[]);
        return;
    }
    // MARK: 要先确定都需要获取什么数据
    NSArray*keysToFetch =@[CNContactGivenNameKey,CNContactFamilyNameKey,CNContactPhoneNumbersKey];
    CNContactFetchRequest *fetchRequest = [[CNContactFetchRequest alloc]initWithKeysToFetch:keysToFetch];
    CNContactStore *contactStore = [[CNContactStore alloc]init];
    [contactStore enumerateContactsWithFetchRequest:fetchRequest error:nil usingBlock:^(CNContact*_Nonnull contact,BOOL*_Nonnull stop) {
        NSLog(@"5.13  数据回调-----");
        
        XBContactModel *contactModel = [XBContactModel contactModelWith:contact];
        
        
        
        NSString*givenName = contact.givenName;
        
        NSString*familyName = contact.familyName;
        
        NSLog(@"5.13 调试数据 givenName=%@, familyName=%@", givenName, familyName);
        
        NSArray*phoneNumbers = contact.phoneNumbers;
        
        for(CNLabeledValue *labelValue in phoneNumbers) {
            NSString*label = labelValue.label;
            
            CNPhoneNumber *phoneNumber = labelValue.value;
            
            //    NSDictionary*contact =@{@"phone":phoneNumber.stringValue,@"user":FORMAT(@"%@%@",familyName,givenName)};
            //
            //    [contactArr addObject:contact];
            //
                NSLog(@"5.13 调试数据 label=%@, phone=%@", label, phoneNumber.stringValue);
            
        }
        
        //*stop = YES;// 停止循环，相当于break；
        
    }];
    
    NSLog(@"5.13 数据回调 结束-----");
    
}

- (void)zx {
    NSArray*keysToFetch =@[CNContactGivenNameKey,CNContactFamilyNameKey,CNContactPhoneNumbersKey];
    
    CNContactFetchRequest*fetchRequest = [[CNContactFetchRequest alloc]initWithKeysToFetch:keysToFetch];
    CNContactStore *contactStore = [[CNContactStore alloc]init];
    [contactStore enumerateContactsWithFetchRequest:fetchRequest error:nil usingBlock:^(CNContact*_Nonnull contact,BOOL*_Nonnull stop) {
        NSLog(@"-------------------------------------------------------");
        
        NSString*givenName = contact.givenName;
        
        NSString*familyName = contact.familyName;
        
        NSLog(@"givenName=%@, familyName=%@", givenName, familyName);
        
        NSArray*phoneNumbers = contact.phoneNumbers;
        
        for(CNLabeledValue *labelValue in phoneNumbers) {
            NSString*label = labelValue.label;
            
            CNPhoneNumber *phoneNumber = labelValue.value;
            
            //    NSDictionary*contact =@{@"phone":phoneNumber.stringValue,@"user":FORMAT(@"%@%@",familyName,givenName)};
            //
            //    [contactArr addObject:contact];
            //
                NSLog(@"label=%@, phone=%@", label, phoneNumber.stringValue);
            
        }
        
        //*stop = YES;// 停止循环，相当于break；
        
    }];
}

- (NSMutableArray *)models {
    if (_models) {
        _models = NSMutableArray.new;
    }
    return _models;
}



@end
