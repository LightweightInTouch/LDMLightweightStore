//
//  LDMLightweightStore.m
//  LDMLightweightStore
//
//  Created by Lobanov Dmitry on 31.08.15.
//  Copyright (c) 2015 lolgear. All rights reserved.
//

#import "LDMLightweightStore.h"

#import <UICKeyChainStore/UICKeyChainStore.h>
#import <CocoaLumberjack/CocoaLumberjack.h>

static DDLogLevel ddLogLevel = DDLogLevelVerbose;

LDMLightweightStorePolicy LDMLightweightStorePolicyDefaults = @"LDMLightweightStorePolicyDefaults";
LDMLightweightStorePolicy LDMLightweightStorePolicyKeychain = @"LDMLightweightStorePolicyKeychain";
LDMLightweightStorePolicy LDMLightweightStorePolicyMemory = @"LDMLightweightStorePolicyMemory";

NSString* const LDMLightweightStoreOptionsStoreScopeNameKey = @"LDMLightweightStoreOptionsStoreScopeNameKey";
NSString* const LDMLightweightStoreOptionsAllFieldsArrayKey = @"LDMLightweightStoreOptionsAllFieldsArrayKey";

@interface LDMLightweightStore ()

#pragma mark - Accessors
@property (nonatomic, copy) NSString *storeScopeName;
@property (nonatomic, strong) NSArray *allFields;

@end

@implementation LDMLightweightStore

#pragma mark -
- (NSArray *)necessaryFields {
    NSArray *allFields = self.currentScopedStore.allKeys;
    if (self.allFields.count) {
        allFields =
        [allFields filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id<NSCopying>evaluatedObject, NSDictionary *bindings) {
            return self.allFields && [self.allFields indexOfObject:evaluatedObject] != NSNotFound;
        }]];
    }
    return allFields;
}

#pragma mark - Instantiation
- (instancetype) initWithOptions:(NSDictionary *)options {
    self = [self init];
    
    _options = options;
    if (options) {
        NSString *scopeName = options[LDMLightweightStoreOptionsStoreScopeNameKey];
        
        if (!scopeName) {
            return nil;
        }
        
        _storeScopeName = scopeName;
        
        NSArray *allFields = options[LDMLightweightStoreOptionsAllFieldsArrayKey];
        _allFields = allFields;
    }
    
    return self;
}

#pragma mark - Load
- (void) setUp {
    
}

- (void) tearDown {
    
}


#pragma mark - Set/Get
- (void) setField:(NSString *)name byValue:(id)value {
    
}

- (id) fieldByName:(NSString *)name {
    return nil;
}
@end

@interface LDMLightweightStoreDefaults : LDMLightweightStore
@property (nonatomic, copy, readonly) NSUserDefaults *storeEntity;
@end

@implementation LDMLightweightStoreDefaults

- (NSUserDefaults *)storeEntity {
    return [NSUserDefaults standardUserDefaults];
}

- (NSMutableDictionary *)currentScopedStore {
    if (![self.storeEntity dictionaryForKey:self.storeScopeName]) {
        [self.storeEntity setObject:@{} forKey:self.storeScopeName];
        [self.storeEntity synchronize];
    }
    return [[self.storeEntity dictionaryForKey:self.storeScopeName] mutableCopy];
}

- (void) tearDown {
    [self.storeEntity removeObjectForKey:self.storeScopeName];
}

#pragma mark - Set/Get
- (void) setField:(id<NSCopying>)name byValue:(id<NSCopying>)value {
    NSMutableDictionary *dictionary = self.currentScopedStore;
    if (!value) {
        [dictionary removeObjectForKey:name];
    }
    else {
        dictionary[name] = value;
    }
    
    [self.storeEntity setObject:[dictionary copy] forKey:self.storeScopeName];
    [self.storeEntity synchronize];
}

- (id) fieldByName:(id<NSCopying>)name {
    return self.currentScopedStore[name];
}

@end

@interface LDMLightweightStoreKeychain : LDMLightweightStore
@property (nonatomic, copy, readonly) UICKeyChainStore *storeEntity;
@end

@implementation LDMLightweightStoreKeychain

- (UICKeyChainStore *)storeEntity {
    return [UICKeyChainStore keyChainStoreWithService:self.storeScopeName];
}

- (NSMutableDictionary *)currentScopedStore {
    
    if (![self.storeEntity dataForKey:self.storeScopeName]) {
        NSData * data = [NSKeyedArchiver archivedDataWithRootObject:@{}];
        [self.storeEntity setData:data forKey:self.storeScopeName];
    }
    
    
    NSMutableDictionary * dictionary =
    [[NSKeyedUnarchiver unarchiveObjectWithData:[self.storeEntity dataForKey:self.storeScopeName]] mutableCopy];
    return dictionary;
}

- (void) tearDown {
    NSError * error = nil;
    [self.storeEntity removeItemForKey:self.storeScopeName error:&error];
    if (error) {
        DDLogDebug(@"error: %@", error);
    }
}

#pragma mark - Set/Get
- (void) setField:(id<NSCopying>)name byValue:(id<NSCopying>)value {
    NSMutableDictionary * dictionary = self.currentScopedStore;
    if (!value) {
        [dictionary removeObjectForKey:name];
    }
    else {
        dictionary[name] = value;
    }
    
    NSData * data =
    [NSKeyedArchiver archivedDataWithRootObject:dictionary];
    [self.storeEntity setData:data forKey:self.storeScopeName];
}

- (id) fieldByName:(id<NSCopying>)name {
    return self.currentScopedStore[name];
}

@end


static NSDictionary *staticDictionaryInMemory = nil;
@interface LDMLightweightStoreMemory : LDMLightweightStore
@property (nonatomic, copy, readonly) NSMutableDictionary *storeEntity;
@end

@implementation LDMLightweightStoreMemory

- (NSDictionary *)storeEntity {
    if (!staticDictionaryInMemory) {
        staticDictionaryInMemory = [[NSMutableDictionary alloc] init];
    }
    return staticDictionaryInMemory;
}

- (NSMutableDictionary *)currentScopedStore {
    if (!self.storeEntity[self.storeScopeName]) {
        self.storeEntity[self.storeScopeName] = [@{} mutableCopy];
    }
    return self.storeEntity[self.storeScopeName];
}

#pragma mark - Load
- (void) setUp {
}

- (void) tearDown {
    for (id<NSCopying> name in self.necessaryFields) {
        [self.currentScopedStore removeObjectForKey:name];
    }
}


#pragma mark - Set/Get
- (void) setField:(id<NSCopying>)name byValue:(id<NSCopying>)value {
    NSMutableDictionary *dictionary = self.currentScopedStore;
    
    if (!value) {
        [dictionary removeObjectForKey:name];
    }
    else {
        dictionary[name] = value;
    }
    
    self.storeEntity[self.storeScopeName] = dictionary;
}

- (id) fieldByName:(id<NSCopying>)name {
    return self.currentScopedStore[name];
}

@end

@implementation LDMLightweightStore (Cluster)

- (LDMLightweightStorePolicy) policy {
    LDMLightweightStorePolicy policy = nil;
    if (self.class == [LDMLightweightStoreDefaults class]) {
        policy = LDMLightweightStorePolicyDefaults;
    }
    
    if (self.class == [LDMLightweightStoreKeychain class]) {
        policy = LDMLightweightStorePolicyKeychain;
    }
    
    if (self.class == [LDMLightweightStoreMemory class]) {
        policy = LDMLightweightStorePolicyMemory;
    }
    
    return policy;
}

- (BOOL)isEqualToPolicy:(LDMLightweightStorePolicy)policy {
    return [self.policy isEqualToString:policy];
}

+ (instancetype) storeWithPolicy:(LDMLightweightStorePolicy)policy andOptions:(NSDictionary *)options {
    LDMLightweightStore *store = nil;
    
    if (policy == LDMLightweightStorePolicyDefaults) {
        store = [[LDMLightweightStoreDefaults alloc] initWithOptions:options];
    }
    
    else if (policy == LDMLightweightStorePolicyKeychain) {
        store = [[LDMLightweightStoreKeychain alloc] initWithOptions:options];
    }
    
    else if (policy == LDMLightweightStorePolicyMemory) {
        store = [[LDMLightweightStoreMemory alloc] initWithOptions:options];
    }
    
    return store;
}

+ (instancetype) store:(LDMLightweightStore*)store switchPolicy:(LDMLightweightStorePolicy)policy {
    if ([store isEqualToPolicy:policy]) {
        return store;
    }
    
    LDMLightweightStore *newStore = [LDMLightweightStore storeWithPolicy:policy andOptions:store.options];
    
    for (id<NSCopying>field in [store necessaryFields]) {
        [newStore setField:field byValue:[store fieldByName:field]];
    }
    
    [store tearDown];
    
    return newStore;
}

- (instancetype) switchPolicy:(LDMLightweightStorePolicy)policy {
    return [self.class store:self switchPolicy:policy];
}

@end
