//
//  reviewcode.m
//  reviewcode
//
//  Created by sunyanguo on 12/25/15.
//  Copyright © 2015 lvmama. All rights reserved.
//

#import "reviewcode.h"
#import <objc/runtime.h>
#import "NSObject_Extension.h"

void swizzleDVTTextStorage()
{
    Class IDESourceControlCommitWindowController = NSClassFromString(@"IDESourceControlCommitWindowController");
    Method fixAttributesInRange = class_getInstanceMethod(IDESourceControlCommitWindowController, @selector(windowDidLoad));
    Method swizzledFixAttributesInRange = class_getInstanceMethod(IDESourceControlCommitWindowController, @selector(mc_windowDidLoad));
    
    BOOL didAddMethod = class_addMethod(IDESourceControlCommitWindowController, @selector(windowDidLoad), method_getImplementation(swizzledFixAttributesInRange), method_getTypeEncoding(swizzledFixAttributesInRange));
    if (didAddMethod) {
        class_replaceMethod(IDESourceControlCommitWindowController, @selector(mc_windowDidLoad), method_getImplementation(fixAttributesInRange), method_getTypeEncoding(swizzledFixAttributesInRange));
    } else {
        method_exchangeImplementations(fixAttributesInRange, swizzledFixAttributesInRange);
    }
}

@interface reviewcode()

@property (nonatomic, strong, readwrite) NSBundle *bundle;
@end

@implementation reviewcode

+ (instancetype)sharedPlugin
{
    return sharedPlugin;
}

- (id)initWithBundle:(NSBundle *)plugin
{
    if (self = [super init]) {
        // reference to plugin's bundle, for resource access
        self.bundle = plugin;
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationLog:) name:nil object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didApplicationFinishLaunchingNotification:)
                                                     name:NSApplicationDidFinishLaunchingNotification
                                                   object:nil];
        swizzleDVTTextStorage();
    }
    return self;
}

- (void)didApplicationFinishLaunchingNotification:(NSNotification*)noti
{
    //removeObserver
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSApplicationDidFinishLaunchingNotification object:nil];
    
    // Create menu items, initialize UI, etc.
    // Sample Menu Item:
    NSMenuItem *menuItem = [[NSApp mainMenu] itemWithTitle:@"Edit"];
    if (menuItem) {
        [[menuItem submenu] addItem:[NSMenuItem separatorItem]];
        NSMenuItem *actionMenuItem = [[NSMenuItem alloc] initWithTitle:@"Do Action" action:@selector(doMenuAction) keyEquivalent:@""];
        //[actionMenuItem setKeyEquivalentModifierMask:NSAlphaShiftKeyMask | NSControlKeyMask];
        [actionMenuItem setTarget:self];
        [[menuItem submenu] addItem:actionMenuItem];
    }
}

// Sample Action, for menu item:
- (void)doMenuAction
{
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:@"Hello, World"];
    [alert runModal];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)notificationLog:(NSNotification *)notify
{
    if ([@"IDEIndexWillIndexWorkspaceNotification" isEqualToString:notify.name]) {
        NSLog(@"%@",notify.object);
    }
//    NSLog(@"%@",notify);

}

@end

@implementation NSWindowController(mc)

- (void)mc_windowDidLoad{
    [self mc_windowDidLoad];
    NSButton *pushButton = [[NSButton alloc] initWithFrame:NSMakeRect(100, 100, 100, 100)];
    pushButton.bezelStyle = NSRoundedBezelStyle;
    [pushButton  setTarget:self];
    [pushButton setTitle:@"review"];
    [pushButton setAction:@selector(buttonClick:)];
    NSView *vvvv = [[self.window.contentView subviews] objectAtIndex:0];
    [vvvv addSubview:pushButton];
    [[vvvv subviews] enumerateObjectsUsingBlock:^(__kindof NSView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[NSButton class]] && idx == 1 ) {
            pushButton.frame = NSMakeRect(obj.frame.origin.x-obj.frame.size.width*2-20, obj.frame.origin.y, obj.frame.size.width, obj.frame.size.height);
            pushButton.layer.borderWidth = 1;
            pushButton.layer.borderColor = [NSColor colorWithDeviceHue:0.02 saturation:0.97 brightness:0.9 alpha:1].CGColor;
        }
    }];
    
}

- (NSDictionary *)pppp:(id)obj {

    NSMutableDictionary *dictionaryFormat = [NSMutableDictionary dictionary];
    
    //  取得当前类类型
    Class cls = [obj class];
    
    unsigned int ivarsCnt = 0;
    //　获取类成员变量列表，ivarsCnt为类成员数量
    Ivar *ivars = class_copyIvarList(cls, &ivarsCnt);
    
    //　遍历成员变量列表，其中每个变量都是Ivar类型的结构体
    for (const Ivar *p = ivars; p < ivars + ivarsCnt; ++p)
    {
        Ivar const ivar = *p;
        
        //　获取变量名
        NSString *key = [NSString stringWithUTF8String:ivar_getName(ivar)];
        // 若此变量未在类结构体中声明而只声明为Property，则变量名加前缀 '_'下划线
        // 比如 @property(retain) NSString *abc;则 key == _abc;
        
        //　获取变量值
        id value;
        @try {
             value = [obj valueForKey:key];
        }
        @catch (NSException *exception) {
            
        }
        @finally {
            
        }
        //　取得变量类型
        // 通过 type[0]可以判断其具体的内置类型
        if (value)
        {
            [dictionaryFormat setObject:value forKey:key];
        }
    }
    return dictionaryFormat;
}

- (void)buttonClick:(id)sender {
    NSDictionary *dictionaryFormat = [self pppp:self];
    id checkedFilePathsTokenTemp = [dictionaryFormat objectForKey:@"_checkedFilePathsToken2"];
    dictionaryFormat = [self pppp:checkedFilePathsTokenTemp];
    id observedObjectTemp = [dictionaryFormat objectForKey:@"_observedObject"];
    dictionaryFormat = [self pppp:observedObjectTemp];
    NSArray *checkedFilePathsTemp = [dictionaryFormat objectForKey:@"_checkedFilePaths"];
    [checkedFilePathsTemp enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSDictionary *ddic = [self pppp:obj];
        NSString *path = [ddic objectForKey:@"_pathString"];
        NSLog(@"%@",path);
    }];
    
    /*
    NSView *fileListView = (NSView *)[dictionaryFormat objectForKey:@"_reviewFilesView"];
    [fileListView dumpWithIndent:@""];
    [[fileListView subviews] enumerateObjectsUsingBlock:^(__kindof NSView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSLog(@"%@",obj);
        [[obj subviews] enumerateObjectsUsingBlock:^(__kindof NSView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSLog(@"222:%@",obj);
            [[obj subviews] enumerateObjectsUsingBlock:^(__kindof NSView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSLog(@"333:%@",obj);
                [[obj subviews] enumerateObjectsUsingBlock:^(__kindof NSView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    NSLog(@"444:%@",obj);
                }];
            }];
        }];
    }];
     */
}
@end