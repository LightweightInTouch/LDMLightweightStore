//
//  LDMLightweightStoreTests.m
//  LDMLightweightStoreTests
//
//  Created by Lobanov Dmitry on 31.08.15.
//  Copyright (c) 2015 lolgear. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <LDMLightweightStore/LDMLightweightStore.h>

@interface LDMLightweightStoreTests : XCTestCase

@property (nonatomic) NSMutableArray * stores;

@end

@implementation LDMLightweightStoreTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    
    [self.stores enumerateObjectsUsingBlock:^(LDMLightweightStore * obj, NSUInteger idx, BOOL *stop) {
        [obj tearDown];
    }];
    
    [super tearDown];
    
    
}

- (void)generalTestForPolicy:(LDMLightweightStorePolicy)policy {
    NSString *itemProperty = @"item";
    LDMLightweightStore *store = [LDMLightweightStore storeWithPolicy: LDMLightweightStorePolicyKeychain andOptions:@{ LDMLightweightStoreOptionsStoreScopeNameKey:@"scope",  LDMLightweightStoreOptionsAllFieldsArrayKey:@[itemProperty]}];
    
    // cleanup later
    self.stores[self.stores.count] = store;
    
    [store setField:itemProperty byValue:nil];
    
    XCTAssert([store fieldByName:itemProperty] == nil);
    
    [store setField:itemProperty byValue:@{}];
    
    XCTAssert([[store fieldByName:itemProperty] isEqualToDictionary:@{}]);
}

- (void)testAggressiveDataInput:(LDMLightweightStorePolicy)policy {
    
    // forgot scope name
    NSString *itemProperty = @"item";
    
    LDMLightweightStore *nilStore = [LDMLightweightStore storeWithPolicy: LDMLightweightStorePolicyKeychain andOptions:@{LDMLightweightStoreOptionsAllFieldsArrayKey:@[itemProperty]}];
    
    XCTAssertNil(nilStore);
    
    
    // forgot fields, switching policy should copy all fields
    LDMLightweightStore *noFieldsStore = [LDMLightweightStore storeWithPolicy:policy andOptions:@{LDMLightweightStoreOptionsStoreScopeNameKey:@"aggressive"}];
    
    self.stores[self.stores.count] = noFieldsStore;
    
    XCTAssertNotNil(noFieldsStore);
    
    NSString *fieldName = @"field";
    NSString *value = @"value";
    
    [noFieldsStore setField:fieldName byValue:value];
    
    LDMLightweightStorePolicy switchedPolicy = nil;
    
    if ([noFieldsStore isEqualToPolicy:LDMLightweightStorePolicyMemory]) {
        switchedPolicy = LDMLightweightStorePolicyDefaults;
    }
    
    if ([noFieldsStore isEqualToPolicy:LDMLightweightStorePolicyDefaults]) {
        switchedPolicy = LDMLightweightStorePolicyKeychain;
    }
    
    if ([noFieldsStore isEqualToPolicy:LDMLightweightStorePolicyKeychain]) {
        switchedPolicy = LDMLightweightStorePolicyMemory;
    }
    
    LDMLightweightStore *switchedStore = [noFieldsStore switchPolicy:switchedPolicy];
    
    XCTAssertNotNil(switchedStore);
    
    self.stores[self.stores.count] = switchedStore;
    
    NSLog(@"current scope is: %@", switchedStore.currentScopedStore);
    
    // copy whole information dictionary
    XCTAssert([[switchedStore fieldByName:fieldName] isEqualToString:value]);
}

- (void)testKeychain {
    [self generalTestForPolicy:LDMLightweightStorePolicyKeychain];
    [self testAggressiveDataInput:LDMLightweightStorePolicyKeychain];
}

- (void)testDefaults {
    [self generalTestForPolicy:LDMLightweightStorePolicyDefaults];
    [self testAggressiveDataInput:LDMLightweightStorePolicyDefaults];
}

- (void)testMemory {
    [self generalTestForPolicy:LDMLightweightStorePolicyMemory];
    [self testAggressiveDataInput:LDMLightweightStorePolicyMemory];
}

@end
