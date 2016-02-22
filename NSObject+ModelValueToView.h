//
//  NSObject+ModelValueToView.h
//
//  Created by cai on 16/1/7.
//  Copyright © 2016年 蔡晶. All rights reserved.
//

//一个model和自己写的类自动赋值的 导入头文件, [self getValueFromModel:model]; 然后所有的self.abc 与model.abc 或者self.abcLabel 会自动被赋值

//           1                      2    注:自己的属性前缀与model的属性名一致(1与2一致)
/*例 model.property <----> self.(property)Label/propertyButton/propertyImageView
 
 为了代码规范,UI类型的instanceType 后缀必须以.m中的一样
 
 支持拼接model中的NSString类型属性 例model有 model.str与model.cai ,so 接收方 object.strADDcai 即可 类似UIButton,UILabel后缀还是要加上
 
 支持常量拼接 exmp: model.i model.j   self.iADDj = model.i + model.j
 
 其他对象类型保持 model.abc与object.abc 属性名称一致即可
 
 
 */

typedef NS_ENUM(NSInteger ,CJPropertPostfixType) {
    
    CJPropertPostfixTypeNone = 0,
    CJPropertPostfixTypeLabel ,
    CJPropertPostfixTypeButton ,
    CJPropertPostfixTypeImageView ,
    CJPropertPostfixTypeTextField,
    CJPropertPostfixTypeTextView,
    CJPropertPostfixTypeNSString
    
};

#import <Foundation/Foundation.h>


@interface NSObject (ModelValueToView)


- (void)getValueFromModel:(nonnull id)model;


@end

@interface CJPropertyInfo : NSObject

@property (nonatomic, assign) BOOL isHasPostfix;

@property (nonatomic, assign) BOOL isHasAddMark;

@property (nonatomic, assign) BOOL isReadonly;

@property (nonatomic, assign) BOOL isTypeOfUI;

@property (nonatomic, assign) BOOL isCorrectNameType;

@property (nonatomic, assign) CJPropertPostfixType  propertPostfixType;

@property (nonatomic, strong, nonnull) NSString *propertyName;

@property (nonatomic, strong, nonnull) NSString *propertyTypeEncoding;

@property (nonatomic, strong, nonnull) NSString *propertyAttribute;

@property (nonatomic, strong, nullable) NSArray *modelProertyList;

@property (nonatomic, strong, nullable) NSString *postfixName;

- (_Nonnull instancetype )initWithPropertyName:(NSString * _Nonnull)propertyName propertyTypeEncoding:(NSString *_Nonnull)propertyTypeEncoding propertyAttribute:(NSString *_Nonnull)propertyAttribute;

@end



@interface NSObject (GetPropertyName)


- ( NSMutableArray * _Nonnull )filterPropertys;

- ( NSMutableArray * _Nonnull )attributesPropertys;

- ( NSMutableArray * _Nonnull)filterIvarNames;

- ( NSMutableArray * _Nonnull )filterIvarTypeEncodings;

- ( NSMutableArray * _Nonnull )filterMethods;

- ( NSString * _Nonnull )getValueByInvationWithSelName:(NSArray<NSString *> *_Nonnull)selName target:(nonnull id)target ;

- (nonnull id )getScalarValueByInvationWithPropertyName:(NSString *_Nonnull)propertyName target:(nonnull id)target andModelPropertyTypeEncode: (NSString * _Nonnull)ModelPropertyTypeEncode invocation:(NSInvocation *_Nonnull)invocation;

- (CGFloat )getScalarValueByInvationWithSelName:(NSArray<NSString *> *_Nonnull)selName target:(nonnull id)target;


@end
