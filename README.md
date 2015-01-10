# Objective-Final
Simulating the protection of Java's final or C#'s sealed keywords in Objective-C

This library allows marking a class as final - preventing it from being subclassed, or individual methods as final - preventing them from being overridden in a subclass.  These checks occur at runtime, not compile time in contrast to the Java and C# equivalents.  Using final allows stronger enforcement of a design and protection from having key methods accidentally overridden by subclasses.

Drawbacks include an initial performance hit to verify methods, syntax that's somewhat awkward for verifying methods, and due to the dynamic nature of the runtime, no way to eliminate runtime abuses that can circumvent this protection.

### Usage:

Include NSObject+PSFinalMethods.h/m in your project.  Importing the header in your prefix.pch is probably a good idea.

Marking a class as final will cause an NSInternalInconsistencyException to be thrown when the first message is sent to the offending subclass.  More specifically the check occurs in the +(void)initialize method.

Suppose we have a class called OMGShouldBeFinal.  To make that class final use one of the included macros 'PSFinalClass' or 'PSFinalClassInitialize' in the @implementation block

### Example 1 - Class implements +(void)intialize
```
@implementation OMGShouldBeFinal

+(void)initialize {
    PSFinalClass(OMGShouldBeFinal)
    if(self == [OMGShouldBeFinal class]) {
        // ... Regular Initialization here
    }
}
```

### Example 2 - Class doesn't implement +(void)initialize

```
@implmentation OMGShouldBeFinal

PSFinalClassIntialize(OMGShouldBeFinal)
```

Note that in Example 2 the macro will actually implement +(void)initialize, so if you want custom initialization logic, choose the method in Example 1.  You will get a call stack that looks similar to the following, note the 'reason' is useful:
```
2015-01-09 23:41:29.583 lonelydwarves[20128:1560768] *** Terminating app due to uncaught exception 'NSInternalInconsistencyException', reason: 'SKOverlayUpdateAnimation attempted to extend final class WRAnimation'
*** First throw call stack:
(
	0   CoreFoundation                      0x0000000109134f35 __exceptionPreprocess + 165
	1   libobjc.A.dylib                     0x0000000108dcdbb7 objc_exception_throw + 45
	2   lonelydwarves                       0x000000010654e043 +[WRAnimation initialize] + 243
	3   libobjc.A.dylib                     0x0000000108dce4d6 _class_initialize + 648
	4   libobjc.A.dylib                     0x0000000108dd76e1 lookUpImpOrForward + 351
	5   libobjc.A.dylib                     0x0000000108de40d3 objc_msgSend + 211
	6   lonelydwarves                       0x00000001064f8926 -[SKBattleController handleMagicCastEvent:] + 790
```
Objective-Final also supports final methods.  Upon initialization, we check to see if a method is implemented in a subclass, and fail if so.  Results are cached using objc_get/setAssociatedObject to aid in performance.  Make sure these checks are run by placing them in the class's designated initializer.

###Example 3 - Final Methods

```
-(instancetype)init {
    if(self = [super init]) {
        [self verifyFinalMethod: @selector(nameOfMethodToTest)
                     finalClass: [OMGShouldBeFinal class]
                   runtimeClass: [self class]];
    }

    return self;
}
```
