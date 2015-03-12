//
//  AFatherModel.m
//  AndreaArlexFramework
//
//  Created by Arlexovincy on 14/11/14.
//  Copyright (c) 2014年 Arlexovincy. All rights reserved.
//

#import "AFatherModel.h"
#import <objc/runtime.h>
#import <objc/message.h>

@implementation AFatherModel

+ (AFatherModel *)autoParseObjectWithJson:(NSDictionary *)json
{
    if (json) {
        AFatherModel *model = [[[self class] alloc] init];
        [model parseObjectWithJson:json];
        return model;
    }
    
    return nil;
}

#pragma mark- 解析json，将其转换为实体类
- (void)parseObjectWithJson:(NSDictionary *)json
{
    if (json) {
        
        NSDictionary *propertyDic = [self getAllProperties];
        
        [json enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            
            NSNumber *num = [propertyDic objectForKey:key];
            
            if (num && obj && [NSNull null] != obj) {
                YMFPropertyType pType = [num integerValue];
                
                switch (pType) {
                    case YMFPropertyTypeBOOL:
                    case YMFPropertyTypeNSInteger:
                    case YMFPropertyTypeDouble:
                    case YMFPropertyTypeCGFloat:
                    case YMFPropertyTypeLong:
                    {
                        if (![obj isKindOfClass:[NSNumber class]]) {
                            NSLog(@"属性类型不匹配,属性:%@,值:%@,类型:%@",key,obj,NSStringFromClass([obj class]));
                        }
                    }
                        break;
                    case YMFPropertyTypeNSString:
                    {
                        if (![obj isKindOfClass:[NSString class]]) {
                            NSLog(@"属性类型不匹配,属性:%@,值:%@,类型:%@",key,obj,NSStringFromClass([obj class]));
                        }
                    }
                        break;
                    case YMFPropertyTypeNSArray:
                        //待完善
                        break;
                    case YMFPropertyTypeNSData:
                        break;
                    case YMFPropertyTypeObject:
                        break;
                    default:
                        break;
                }
                
                if(self.expandParsingProgress){
                    id tObj = self.expandParsingProgress(key,obj);
                    
                    if (tObj) {
                        [self setValue:tObj forKeyPath:key];
                    }
                    else{
                        [self setValue:obj forKeyPath:key];
                    }
                }
                else
                    [self setValue:obj forKeyPath:key];
            }
        }];
    }
}

#pragma mark- 获取对应的所以property信息  属性的name -> 对应的类型
- (NSDictionary *)getAllProperties
{
    u_int count;
    NSMutableDictionary *mDic = [NSMutableDictionary dictionary];
    Class cls = [self class];
    
    while ([cls isSubclassOfClass:[AFatherModel class]]) {
        objc_property_t *properties = class_copyPropertyList(cls, &count);
        
        for (int i = 0; i < count ; i++)
        {
            const char* propertyName = property_getName(properties[i]);
            const char *type = property_getAttributes(properties[i]);
            
            NSString * typeString = [NSString stringWithUTF8String:type];
            NSString * nameString = [NSString stringWithUTF8String: propertyName];
            
            NSArray * attributes = [typeString componentsSeparatedByString:@","];
            
            if (attributes && attributes.count > 0 ) {
                
                NSString * typeAttribute = [attributes objectAtIndex:0];
                
                if (typeAttribute && typeAttribute.length >= 1) {
                    NSString * propertyType = [typeAttribute substringFromIndex:1];
                    const char *rawPropertyType = [propertyType UTF8String];
                    YMFPropertyType pType = YMFPropertyTypeUnkown;
                    
                    if (strcmp(rawPropertyType, @encode(float)) == 0) {
                        //it's a float
                        pType = YMFPropertyTypeCGFloat;
                    } else if (strcmp(rawPropertyType, @encode(NSUInteger)) == 0) {
                        //it's an int
                        pType = YMFPropertyTypeNSInteger;
                    } else if (strcmp(rawPropertyType, @encode(int)) == 0) {
                        //it's an int
                        pType = YMFPropertyTypeNSInteger;
                    } else if (strcmp(rawPropertyType, @encode(double)) == 0) {
                        pType = YMFPropertyTypeDouble;
                    }
                    else if (strcmp(rawPropertyType, @encode(BOOL)) == 0) {
                        pType = YMFPropertyTypeBOOL;
                    }
                    else if (strcmp(rawPropertyType, "@\"NSString\"") == 0) {
                        pType = YMFPropertyTypeNSString;
                    }
                    else if (strcmp(rawPropertyType, "@\"NSData\"") == 0) {
                        pType = YMFPropertyTypeNSData;
                    }
                    else if (strcmp(rawPropertyType, @encode(id)) == 0) {
                        //it's some sort of object
                        pType = YMFPropertyTypeObject;
                    }
                    else if (strcmp(rawPropertyType, "@\"NSArray\"") == 0) {
                        pType = YMFPropertyTypeNSArray;
                    }
                    else if(strcmp(rawPropertyType, @encode(long)) == 0){
                        pType = YMFPropertyTypeLong;
                    }
                    
                    if (pType != YMFPropertyTypeUnkown) {
                        [mDic setObject:@(pType) forKey:nameString];
                    }
                }
            }
        }
        
        free(properties);
        
        cls = [cls superclass];
    }
    
    return mDic;
}

@end
