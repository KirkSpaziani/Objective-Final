//
//  $Id: NSObject+PSFinalMethods.m 2488 2014-11-23 19:44:47Z kirk $
//  PhilosophersStone
//
//  Created by Kirk Spaziani on 11/23/14.
//  Copyright (c) 2014 Spazcosoft, LLC. All rights reserved.
//
#import"NSObject+PSFinalMethods.h"
#import<objc/runtime.h>


@implementation NSObject(PSFinalMethods)

static const char *const kFinalMethodKey = "ps_final_method_key";

+(void)cacheFinalSelector:(SEL)selector parentClass:(Class)parentClass childClass:(Class)childClass {
	// Get the mapping object - Dictionary of ParentClass to Dictionary of Selector to Set of valid child Classes
	NSMutableDictionary *mapping = objc_getAssociatedObject([NSObject class], kFinalMethodKey);
	if(mapping == nil) {
		mapping = [NSMutableDictionary dictionary];
		objc_setAssociatedObject([NSObject class], kFinalMethodKey, mapping, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}
	
	NSString *parentClassName = NSStringFromClass(parentClass);
	NSString *childClassName = NSStringFromClass(childClass);
	
	// Get the selector -> children dictionary
	NSMutableDictionary *selectorToChildren = [mapping objectForKey: parentClassName];
	if(selectorToChildren == nil) {
		selectorToChildren = [NSMutableDictionary dictionary];
		[mapping setObject: selectorToChildren forKey: parentClassName];
	}
	
	// Get Set of valid children
	NSString *selectorName = NSStringFromSelector(selector);
	NSMutableSet *childrenClasses = [selectorToChildren objectForKey: selectorName];
	if(childrenClasses == nil) {
		childrenClasses = [NSMutableSet set];
		[selectorToChildren setObject: childrenClasses forKey: selectorName];
	}
	[childrenClasses addObject: childClassName];
}

-(void)verifyFinalMethod:(SEL)selector finalClass:(Class)finalClass runtimeClass:(Class)runtimeClass {
	if(finalClass == runtimeClass) {
		// If the runtime class isn't a child it can't violate final
		return;
	}
	
	if(class_getInstanceMethod(finalClass, selector) == NULL) {
		// Checks if finalClass or any superclasses don't actually implement the selector in question
		@throw [NSException exceptionWithName: NSInternalInconsistencyException
									   reason: @"'finalClass' must implement the method being tested against"
									 userInfo: nil];
	}
	
	// Check cache for final method
	NSDictionary *cache = objc_getAssociatedObject([NSObject class], kFinalMethodKey);
	if([[[cache objectForKey: NSStringFromClass(finalClass)] objectForKey: NSStringFromSelector(selector)] containsObject: NSStringFromClass(runtimeClass)]) {
		return;
	}
	
	Class currentClass = runtimeClass;
	while( (currentClass != nil) && (currentClass != finalClass) ) {
		unsigned int count;
		Method *methods = class_copyMethodList(currentClass, &count);
		for(unsigned int index = 0; index < count; ++index) {
			Method m = methods[index];
			if(sel_isEqual(method_getName(m), selector)) {
				NSString *errorReason = [NSString stringWithFormat: @"Method %@ is overridden by class %@ in violation of %@'s final declaration",
										 NSStringFromSelector(selector),
										 NSStringFromClass(currentClass),
										 NSStringFromClass(finalClass)];
				@throw [NSException exceptionWithName: NSInternalInconsistencyException
											   reason: errorReason
											 userInfo: nil];
			}
		}
		free(methods);
		currentClass = class_getSuperclass(currentClass);
	}
	
	[runtimeClass cacheFinalSelector: selector parentClass: finalClass childClass: runtimeClass];
}

@end
