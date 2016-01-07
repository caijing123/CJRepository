//
//  NSObject+ModelValueToView.m
//  111
//
//  Created by cai on 16/1/7.
//  Copyright © 2016年 蔡晶. All rights reserved.
//

#import "NSObject+ModelValueToView.h"
#import <objc/runtime.h>

@implementation NSObject (ModelValueToView)
- (void)getValueFromModel:(id)model{
    
    
    NSMutableArray *modelPropertyNameArray = [model filterPropertys];
    NSMutableArray *ViewOrOtherPropertyNameArray = [self filterPropertys];
    for (NSInteger i= 0; i < (NSInteger)modelPropertyNameArray.count; i ++) {
        NSString *str = ViewOrOtherPropertyNameArray[i];
        for (NSString *name1 in modelPropertyNameArray) {
            if ([str containsString:name1]) {
                SEL viewOrOtherSel = NSSelectorFromString(name1);
                if ([model respondsToSelector:viewOrOtherSel] ) {
                    NSMethodSignature *signature = [model methodSignatureForSelector:viewOrOtherSel];
                    
                    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
                    [invocation setTarget:model];
                    [invocation setSelector:viewOrOtherSel];
                    [invocation invoke];
                    NSObject *returnValue = nil;
                    [invocation getReturnValue:&returnValue];
                    
                    if ([str containsString:@"Label"]) {
                        UILabel *label = [self valueForKey:str];
                        label.text = [NSString stringWithFormat:@"%@",returnValue];
                    }
                    if ([str containsString:@"Button"]) {
                        UIButton *btn = [self valueForKey:str];
                        [btn setTitle:[NSString stringWithFormat:@"%@",returnValue] forState:UIControlStateNormal];
                    }
                    if ([str containsString:@"ImageView"]) {
                        UIImageView *imageView = [self valueForKey:str];
                        imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@",returnValue]];
                    }
                }
            }
        }
    }
    
}




@end


@implementation NSObject (GetPropertyName)


- (NSMutableArray *)filterPropertys
{
    NSMutableArray *props = [NSMutableArray array];
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList([self class], &outCount);
    for (i = 0; i<outCount; i++)
    {
        const char* char_f =property_getName(properties[i]);
        NSString *propertyName = [NSString stringWithUTF8String:char_f];
        [props addObject:propertyName];
    }
    free(properties);
    return props;
}

- (NSMutableArray *)propertsAttributes{
    NSMutableArray *props = [NSMutableArray array];
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList([self class], &outCount);
    for (i = 0; i<outCount; i++)
    {
        const char* char_f =property_getAttributes(properties[i]);
        NSString *propertyName = [NSString stringWithUTF8String:char_f];
        [props addObject:propertyName];
    }
    free(properties);
    return props;
    
}

@end