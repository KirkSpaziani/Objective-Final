//
//  $Id: NSObject+PSFinalMethods.h 2546 2014-12-08 03:05:29Z kirk $
//  PhilosophersStone
//
//  Created by Kirk Spaziani on 11/23/14.
//  Copyright (c) 2014 Spazcosoft, LLC. All rights reserved.
//
#import<Foundation/Foundation.h>

#define PSFinalClass(implClass) if([self class]!=[implClass class]){@throw [NSException exceptionWithName: NSInternalInconsistencyException reason: [NSString stringWithFormat: @"%@ attempted to extend final class %@", NSStringFromClass([self class]), NSStringFromClass([implClass class])] userInfo: nil];}
#define PSFinalClassInitialize(implClass) +(void)initialize{PSFinalClass(implClass)}


@interface NSObject(PSFinalMethods)

+(void)cacheFinalSelector:(SEL)selector parentClass:(Class)parentClass childClass:(Class)childClass;
-(void)verifyFinalMethod:(SEL)selector finalClass:(Class)finalClass runtimeClass:(Class)runtimeClass;

@end
