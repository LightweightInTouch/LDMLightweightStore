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
    
    XCTAssertThrows([store setField:nil byValue:nil]);
    
    XCTAssertThrows([store setField:nil byValue:@""]);
    
    [store setField:itemProperty byValue:nil];
    
    XCTAssertNil([store fieldByName:itemProperty]);
    
    NSDictionary *testValue = @{@"test" : @"value"};
    
    [store setField:itemProperty byValue:testValue];
    
    XCTAssert([[store fieldByName:itemProperty] isEqualToDictionary:testValue]);
}

- (void)generalTestForSubscriptionAndPolicy:(LDMLightweightStorePolicy)policy {
    NSString *itemProperty = @"item";
    LDMLightweightStore *store = [LDMLightweightStore storeWithPolicy: LDMLightweightStorePolicyKeychain andOptions:@{ LDMLightweightStoreOptionsStoreScopeNameKey:@"scope",  LDMLightweightStoreOptionsAllFieldsArrayKey:@[itemProperty]}];
    
    self.stores[self.stores.count] = store;
    
    // setItem:forKey
    // itemForKey:
    // removeItemForKey:
    {
        // nil key
        XCTAssertNoThrow([store setItem:nil forKey:nil]);

        XCTAssertNoThrow([store setItem:itemProperty forKey:nil]);
        
        // nil value
        [store setItem:nil forKey:itemProperty];
        
        XCTAssertNil([store itemForKey:itemProperty]);
        
        // general value
        NSDictionary *testValue = @{@"test" : @"value"};
        
        [store setItem:testValue forKey:itemProperty];
        
        XCTAssert([[store itemForKey:itemProperty] isEqualToDictionary:testValue]);
        
        // remove item
        [store removeItemForKey:itemProperty];
        
        XCTAssertNil([store itemForKey:itemProperty]);
    }
    
    // subscription
    {
        // nil key        
        XCTAssertNoThrow(store[nil] = nil);

        XCTAssertNoThrow(store[nil] = itemProperty);
        
        // nil value
        store[itemProperty] = nil;
        
        XCTAssertNil(store[itemProperty]);
        
        // general value
        NSDictionary *testValue = @{@"test" : @"value"};
        
        store[itemProperty] = testValue;
        
        XCTAssert([store[itemProperty] isEqualToDictionary:testValue]);
    }
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
    [self generalTestForSubscriptionAndPolicy:LDMLightweightStorePolicyKeychain];
    [self testAggressiveDataInput:LDMLightweightStorePolicyKeychain];
}

- (void)testDefaults {
    [self generalTestForPolicy:LDMLightweightStorePolicyDefaults];
    [self generalTestForSubscriptionAndPolicy:LDMLightweightStorePolicyDefaults];
    [self testAggressiveDataInput:LDMLightweightStorePolicyDefaults];
}

- (void)testMemory {
    [self generalTestForPolicy:LDMLightweightStorePolicyMemory];
    [self generalTestForSubscriptionAndPolicy:LDMLightweightStorePolicyMemory];
    [self testAggressiveDataInput:LDMLightweightStorePolicyMemory];
}

@end
