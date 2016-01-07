//
//  NSObject+ModelValueToView.h
//
//  Created by cai on 16/1/7.
//  Copyright © 2016年 蔡晶. All rights reserved.
//
//           1                      2    注:自己的属性前缀与model的属性名一致(1与2一致)
/*例 model.property <----> self.(property)Label/propertyButton/propertyImageView
 
 *后缀请遵循 Label & Button & ImageView
 
 */

#import <Foundation/Foundation.h>

@interface NSObject (ModelValueToView)


- (void)getValueFromModel:(id)model;


@end
@interface NSObject (GetPropertyName)


- (NSMutableArray *)filterPropertys;

- (NSMutableArray *)propertsAttributes;

@end
