//
//  AFatherModel.h
//  AndreaArlexFramework
//
//  Created by Arlexovincy on 14/11/14.
//  Copyright (c) 2014年 Arlexovincy. All rights reserved.
//

/***********************使用说明***********************/
//该类是用于把json对象转换成实体类的
//注意需要建立一个实体类，继承本类，然后类的属性必须与json的属性
//保持一致
/*****************************************************/

#import <Foundation/Foundation.h>

//属性类型
typedef NS_ENUM(NSInteger, YMFPropertyType) {
    YMFPropertyTypeUnkown = 0,
    YMFPropertyTypeNSString,
    YMFPropertyTypeCGFloat,
    YMFPropertyTypeNSInteger,
    YMFPropertyTypeLong,
    YMFPropertyTypeDouble,
    YMFPropertyTypeBOOL,
    YMFPropertyTypeNSData,
    YMFPropertyTypeNSArray,
    YMFPropertyTypeObject,
};

//拓展解析
typedef id (^YMFExpandParseingProgress)(id key,id obj);

@interface AFatherModel : NSObject

//拓展，子类实现自定义解析
@property (nonatomic,readonly) YMFExpandParseingProgress expandParsingProgress;


+ (AFatherModel *)autoParseObjectWithJson:(NSDictionary *)json;

/**
 *  解析json，将其转换为实体类
 *
 *  @param json json
 */
- (void)parseObjectWithJson:(NSDictionary *)json;

@end
