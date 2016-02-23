//
//  LDMLightweightStore.h
//  LDMLightweightStore
//
//  Created by Lobanov Dmitry on 31.08.15.
//  Copyright (c) 2015 lolgear. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NSString* LDMLightweightStorePolicy;
extern LDMLightweightStorePolicy LDMLightweightStorePolicyDefaults;
extern LDMLightweightStorePolicy LDMLightweightStorePolicyKeychain;
extern LDMLightweightStorePolicy LDMLightweightStorePolicyMemory;

extern NSString* const LDMLightweightStoreOptionsStoreScopeNameKey;
extern NSString* const LDMLightweightStoreOptionsAllFieldsArrayKey;

@interface LDMLightweightStore : NSObject

#pragma mark - Instantiation
- (instancetype) initWithOptions:(NSDictionary *)options;

#pragma mark - Accessors
@property (nonatomic, strong, readonly) NSDictionary *options;
@property (nonatomic, copy, readonly) NSString *storeScopeName;
@property (nonatomic, strong, readonly) NSArray *allFields;
@property (nonatomic, strong, readonly) NSArray *necessaryFields;
@property (nonatomic, copy, readonly) NSMutableDictionary *currentScopedStore;
@property (nonatomic, copy, readonly) id storeEntity;

#pragma mark - Load
- (void)setUp;
- (void)tearDown;

#pragma mark - Getters / Setters
- (void)setField:(id<NSCopying>)name byValue:(id<NSCopying>)value;
- (id)fieldByName:(id<NSCopying>)name;

@end

@interface LDMLightweightStore (Subscription)

/*
 Getters and Setters
 Unlike NSDictionary accessor methods, lightweight store methods
 * -setField:byValue
 * -fieldByName:
 should work nil-safe.
 
 Their opponents are item manipulation methods
 * -setItem:forKey:
 * -itemForKey:
 * -removeItemForKey:
 
 They are used in subsciption interface implementation and should work as 'expected' with nil values like setting nil means deletion and should be handled separately.
 */

#pragma mark - Subscription
- (id)objectForKeyedSubscript:(id<NSCopying>)key;
- (void)setObject:(id)obj forKeyedSubscript:(id<NSCopying>)key;

- (void)setItem:(id)item forKey:(id<NSCopying>)key;
- (id)itemForKey:(id<NSCopying>)key;
- (void)removeItemForKey:(id<NSCopying>)key;

@end

@interface LDMLightweightStore (Cluster)

@property (nonatomic, readonly) LDMLightweightStorePolicy policy;

- (BOOL)isEqualToPolicy:(LDMLightweightStorePolicy)policy;

+ (instancetype)storeWithPolicy:(LDMLightweightStorePolicy)policy andOptions:(NSDictionary *)options;

+ (instancetype)store:(LDMLightweightStore*)store switchPolicy:(LDMLightweightStorePolicy)policy;
- (instancetype)switchPolicy:(LDMLightweightStorePolicy)policy;

@end