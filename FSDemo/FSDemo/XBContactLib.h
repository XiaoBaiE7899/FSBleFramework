//
//  XBContactLib.h
//  FSDemo
//
//  Created by 林文圻 on 2022/5/13.
//  调用通讯录

#import <Foundation/Foundation.h>
#import <Contacts/Contacts.h>

extern CNAuthorizationStatus authContactStatus;

NS_ASSUME_NONNULL_BEGIN


@interface XBContactModel : NSObject

@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, copy) NSString *namePrefix;
@property (nonatomic, copy) NSString *givenName;
@property (nonatomic, copy) NSString *middleName;
@property (nonatomic, copy) NSString *familyName;
@property (nonatomic, copy) NSString *previousFamilyName;
@property (nonatomic, copy) NSString *nameSuffix;
@property (nonatomic, copy) NSString *nickname;
@property (nonatomic, copy) NSString *organizationName;
@property (nonatomic, copy) NSString *departmentName;
@property (nonatomic, copy) NSString *jobTitle;
@property (nonatomic, copy) NSString *phoneticgivenName;
@property (nonatomic, copy) NSString *phoneticMiddleName;
@property (nonatomic, copy) NSString *phoneticFamilyName;
@property (nonatomic, copy) NSString *phoneticOrganizationName;
@property (nonatomic, copy) NSString *birthday;
@property (nonatomic, copy) NSString *nonGregorianBirthday;
@property (nonatomic, copy) NSString *note;
@property (nonatomic, copy) NSString *imageData;
@property (nonatomic, copy) NSString *thumbnailImageData;
@property (nonatomic, copy) NSString *imageDataAvailable;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *phoneNumbers;
@property (nonatomic, copy) NSString *emailAddresses;
@property (nonatomic, copy) NSString *cPostalAddresses;
@property (nonatomic, copy) NSString *contactDates;
@property (nonatomic, copy) NSString *urlAddresses;
@property (nonatomic, copy) NSString *relations;
@property (nonatomic, copy) NSString *socialProfiles;
@property (nonatomic, copy) NSString *instantMessageAddresses;

+ (instancetype)contactModelWith:(CNContact *)contact;


@end


@interface XBContactLib : NSObject

// 所有通讯了
@property (nonatomic, strong) NSMutableArray *models;

// 请求访问权限
+ (void)requestAuthorizationAddressBook;


/// 获取通讯录数据
/// @param complete 数据回调  参数：授权状态，模型数组  :: 不允许访问，回调空数组
+ (void)addressBooks:(void(^)(CNAuthorizationStatus, NSArray *datas))complete;




@end

NS_ASSUME_NONNULL_END
