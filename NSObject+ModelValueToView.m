//
//  NSObject+ModelValueToView.m
//  111
//
//  Created by cai on 16/1/7.
//  Copyright © 2016年 蔡晶. All rights reserved.
//

#import "NSObject+ModelValueToView.h"
#import <objc/runtime.h>


//后缀列表
NSString *const TextField = @"TextField";
NSString *const TextView  = @"TextView";
NSString *const Label     = @"Label";
NSString *const Button    = @"Button";
NSString *const ImageView = @"ImageView";
//拼接字符串 中间以ADD 隔开
NSString *const addMark    = @"ADD";

typedef NS_OPTIONS(NSInteger, CJPropertType) {
    
    CJPropertTypeNone    = 1>>0,
    CJPropertTypeAdd     = 1>>1,
    CJPropertTypePostfix = 1>>2

};



@implementation NSObject (ModelValueToView)


- (void)getValueFromModel:(id)model{
    if(!model || !self) return;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-variable"
    NSMutableArray *modelPropertyNameArray          = [model filterPropertys];
    NSMutableArray *ViewOrOtherPropertyNameArray    = [self filterPropertys];
    NSMutableArray *ViewOrOtherPropertyAttsArray    = [self attributesPropertys];
    NSMutableArray *viewOrOtherIvarNamesArray       = [self filterIvarNames];
    NSMutableArray *viewOrtherIvarTypeEncodings     = [self filterIvarTypeEncodings];
#pragma clang diagnostic pop
    if (modelPropertyNameArray.count == 0 || ViewOrOtherPropertyNameArray.count == 0 ) return;
    //all name
    for (NSUInteger i= 0; i < ViewOrOtherPropertyNameArray.count; i ++) {
        
        __block  NSString *ViewOrOtherPropertyName = ViewOrOtherPropertyNameArray[i];
        NSString *ViewOrOtherPropertyAtts          = ViewOrOtherPropertyAttsArray[i];
        NSString *viewOrOtherIvarTypeEncodeing     = viewOrtherIvarTypeEncodings[i];
        //+
        
        CJPropertyInfo *propertyInfo = [[CJPropertyInfo alloc] initWithPropertyName:ViewOrOtherPropertyName propertyTypeEncoding:viewOrOtherIvarTypeEncodeing propertyAttribute:ViewOrOtherPropertyAtts];
        
        if (propertyInfo.isReadonly && !propertyInfo.isTypeOfUI) continue ;
        
         //check model property name
        [modelPropertyNameArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            {
                NSLog(@"idx --- %ld",idx);
                NSString *modelPropertyName = (NSString *)obj;
                //ViewOrOtherPropertyName contains modelPropertyName ?:
                if ([propertyInfo.propertyName rangeOfString:modelPropertyName].location != NSNotFound) {
                    SEL viewOrOtherSel = NSSelectorFromString(modelPropertyName);
                    //responds ?:
                    if ([model respondsToSelector:viewOrOtherSel] ) {
                        //getValue
                        NSMethodSignature *signature = [model methodSignatureForSelector:viewOrOtherSel];
                        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
                        [invocation setTarget:model];
                        [invocation setSelector:viewOrOtherSel];
                        [invocation invoke];
                        
                        if ([propertyInfo.propertyTypeEncoding containsString:@"@"]) {
                            NSObject *returnValue = nil;
                            [invocation getReturnValue:&returnValue];
                            
                            if (propertyInfo.isTypeOfUI && propertyInfo.isHasPostfix && propertyInfo.isCorrectNameType) {
                                
                                NSString *totalString = propertyInfo.isHasAddMark ? [self getValueByInvationWithSelName:propertyInfo.modelProertyList target:model] :[NSString stringWithFormat:@"%@",returnValue] ;
                                
                                if (propertyInfo.propertPostfixType == CJPropertPostfixTypeLabel) {
                                    UILabel *label = [self valueForKey:propertyInfo.propertyName];
                                    label.text = totalString ;
                                    
                                }
                                if (propertyInfo.propertPostfixType == CJPropertPostfixTypeButton) {
                                    UIButton *btn = [self valueForKey:propertyInfo.propertyName];
                                    [btn setTitle:totalString forState:UIControlStateNormal];
                                    
                                }
                                if ( propertyInfo.propertPostfixType == CJPropertPostfixTypeImageView) {
                                    UIImageView *imageView = [self valueForKey:propertyInfo.propertyName];
                                    imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@",returnValue]];
                                    
                                }
                                if ( propertyInfo.propertPostfixType == CJPropertPostfixTypeTextField) {
                                    UITextField *textField = [self valueForKey:propertyInfo.propertyName];
                                    textField.text =totalString;
                                    
                                }
                                if ( propertyInfo.propertPostfixType == CJPropertPostfixTypeTextView) {
                                    UITextView *textView = [self valueForKey:propertyInfo.propertyName];
                                    textView.text = totalString;
                                   
                                }
                            }else{
                                // another (!UI) object. exmp:  system classes like 'NSNumber','NSDictionary','NSArray','NSString' or others like 'CJSHUAIGE',defined by yourself.
                                NSString *firstLetterUp = [[propertyInfo.propertyName substringToIndex:1] uppercaseString];
                                ViewOrOtherPropertyName = [ propertyInfo.propertyName stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:firstLetterUp];
                                ViewOrOtherPropertyName = [[@"set" stringByAppendingString:ViewOrOtherPropertyName] stringByAppendingString:@":"];
                                SEL setMethod = NSSelectorFromString(ViewOrOtherPropertyName);
                                if (propertyInfo.propertPostfixType == CJPropertPostfixTypeNSString) {
                                    NSString *totalString = propertyInfo.modelProertyList.count > 1 ? [self getValueByInvationWithSelName:propertyInfo.modelProertyList target:model] :[NSString stringWithFormat:@"%@",returnValue] ;
                                    [self performSelectorOnMainThread:setMethod withObject:totalString waitUntilDone:[NSThread isMainThread]];
                                }else{

                                    [self performSelectorOnMainThread:setMethod withObject:returnValue waitUntilDone:[NSThread isMainThread]];
                                    
                                }
                                
                            }
                        }
                    }
                }
            }
        }];
    }
}







@end

@implementation CJPropertyInfo

- (instancetype)initWithPropertyName:(NSString *)propertyName propertyTypeEncoding:(NSString *)propertyTypeEncoding propertyAttribute:(NSString * _Nonnull)propertyAttribute{
    
    self = [super init];
    if (!self) {
        return nil;
    }
    if (!propertyName) {
        @throw [NSException exceptionWithName:@"核实参数" reason:@"缺少重要参数" userInfo:nil];
    }
    self.propertyName         = propertyName;
    self.propertyTypeEncoding = propertyTypeEncoding;
    self.propertyAttribute    = propertyAttribute;
    
    
    self.isHasPostfix = [self propertyHasPostfix:propertyName];
    self.isHasAddMark = [self.propertyName containsString:addMark];
    self.isReadonly   = [propertyAttribute containsString:@"R"];
    self.isTypeOfUI   = [propertyAttribute containsString:@"UI"];

    
    self.modelProertyList     = [self countOfAddMarks:propertyName];
    self.propertPostfixType   = [self getTheFuckingType];
    
    NSUInteger modelPropertyTotallength = 0;
    for (NSUInteger i = 0; i < self.modelProertyList.count; i ++) {
        NSString *str= self.modelProertyList[i];
        modelPropertyTotallength += str.length;
    }
    
    self.isCorrectNameType    = (propertyName.length == (self.modelProertyList.count - 1) *addMark.length + self.postfixName.length + modelPropertyTotallength);
    
    if (self.isHasPostfix && self.propertPostfixType == CJPropertPostfixTypeNone) {
        @throw [NSException exceptionWithName:@"核实参数" reason:@"类型不匹配,请检查" userInfo:nil];
    }
    
    
    
    return self;
    
}

- (CJPropertPostfixType)getTheFuckingType{
    
    if ([self.postfixName isEqualToString:Label] &&[self.propertyAttribute containsString:Label]) {
        return CJPropertPostfixTypeLabel;
    }
    if ([self.postfixName isEqualToString:Button] &&[self.propertyAttribute containsString:Button]) {
        return  CJPropertPostfixTypeButton;
    }
    if ([self.postfixName isEqualToString:ImageView] &&[self.propertyAttribute containsString:ImageView]) {
        return  CJPropertPostfixTypeImageView;
    }
    if ([self.postfixName isEqualToString:TextField] &&[self.propertyAttribute containsString:TextField]) {
        return  CJPropertPostfixTypeTextField;
    }
    if ([self.postfixName isEqualToString:TextView] &&[self.propertyAttribute containsString:TextView]) {
        return CJPropertPostfixTypeTextView;
    }
    if ([self.propertyAttribute containsString:@"NSString"]) {
        return CJPropertPostfixTypeNSString;
    }
    
    return CJPropertPostfixTypeNone;
}

- (BOOL)propertyHasPostfix:(NSString *)propertyName{
    
    BOOL i = NO;
    NSArray *arr = @[Label,Button,TextField,TextView,ImageView];
    for (NSString * postfix in arr) {
        if ([propertyName hasSuffix:postfix]) {
            self.postfixName = postfix;
            i = YES;
        }
    }
    
    
    return i;
}

- (NSArray *)countOfAddMarks:(NSString *)propertyName{
//    NSInteger i = 0;
    NSMutableArray *stringArr = [[propertyName componentsSeparatedByString:addMark] mutableCopy];
    NSString *lastString ;
    for (NSString *str in stringArr) {
        for (NSString *postfix in @[Label,Button,TextField,TextView,ImageView]) {
            if (self.isHasPostfix) {
                NSRange range = [str rangeOfString:postfix];
                if (range.location  != NSNotFound) {
                    lastString =  [str substringWithRange:NSMakeRange(0, str.length - postfix.length)];
                    //标准是最后一位，所以不会有什么
                    [stringArr replaceObjectAtIndex:stringArr.count - 1  withObject:lastString];

                }
            }
        }
    }
    return [stringArr copy];
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

- (NSMutableArray *)attributesPropertys{
    NSMutableArray *attributes = [NSMutableArray array];
    unsigned int outCount, i;
    objc_property_t *atts = class_copyPropertyList([self class], &outCount);
    for (i = 0; i < outCount; i ++) {
        const char* char_f = property_getAttributes(atts[i]);
        NSString *propertyAtts = [NSString stringWithUTF8String:char_f];
        [attributes addObject:propertyAtts];
    }
    
    free(atts);
    return  attributes;
}

- (NSMutableArray *)filterIvarNames{
    
    NSMutableArray *ivars = [NSMutableArray array];
    unsigned int outCount,i;
    Ivar *ivar = class_copyIvarList([self class], &outCount);
    for (i = 0; i < outCount ; i ++) {
        const char* char_f = ivar_getName(ivar[i]);
        [ivars addObject:[NSString stringWithUTF8String:char_f]];
        
    }
    free(ivar);
    return ivars;
}
- (NSMutableArray *)filterIvarTypeEncodings{
    
    NSMutableArray *ivars = [NSMutableArray array];
    unsigned int outCount,i;
    Ivar *ivar = class_copyIvarList([self class], &outCount);
    
    for (i = 0; i < outCount ; i ++) {
        const char* char_f = ivar_getTypeEncoding(ivar[i]);
//   returnType ptrdiff_t是C/C++标准库中定义的一个与机器相关的数据类型。ptrdiff_t类型变量通常用来保存两个指针减法操作的结果。ptrdiff_t定义在stddef.h（cstddef）这个文件内。ptrdiff_t通常被定义为long int类型。
        [ivars addObject:[NSString stringWithUTF8String:char_f]];
        
    }
    free(ivar);
    return ivars;
}


- (NSString *)getValueByInvationWithSelName:(NSArray<NSString *> *)selName target:(nonnull id)target{
    NSString *str1 = @"";
    for (NSUInteger i = 0; i < selName.count; i ++) {
        SEL viewOrOtherSel = NSSelectorFromString(selName[i]);
        NSMethodSignature *signature = [target methodSignatureForSelector:viewOrOtherSel];
        if (!signature) {
            NSLog(@"selName [i] === %@",selName[i]);
            @throw [NSException exceptionWithName:@"核实参数" reason:@"model参数名有误，或者拼接参数错误 ,请仔细检查后重试" userInfo:nil];
        }
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
        [invocation setTarget:target];
        [invocation setSelector:viewOrOtherSel];
        [invocation invoke];
        NSString *str= nil;
        [invocation getReturnValue:&str];
        if (str) {
            str1 = [str1 stringByAppendingString:str];
        }else{
            @throw [NSException exceptionWithName:@"核实参数" reason:@"model参数名有误，或者参数不存在实例，请仔细检查后重试" userInfo:nil];
        }
        
    }
    
    return str1;
}


@end