//
//  ViewController.m
//  LDMLightweightStore
//
//  Created by Lobanov Dmitry on 31.08.15.
//  Copyright (c) 2015 lolgear. All rights reserved.
//

#import "ViewController.h"
#import <LDMLightweightStore/LDMLightweightStore.h>
@interface ViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UILabel *memoryLabel;
@property (weak, nonatomic) IBOutlet UILabel *defaultsLabel;
@property (weak, nonatomic) IBOutlet UILabel *keychainLabel;

@property (strong, nonatomic) LDMLightweightStore *memoryStore;
@property (strong, nonatomic) LDMLightweightStore *defaultsStore;
@property (strong, nonatomic) LDMLightweightStore *keychainStore;

@property (strong, nonatomic, readonly) NSString *storedStringFieldName;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // gesture recognizer
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] init];
    [gestureRecognizer addTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:gestureRecognizer];
    
    // text field
    self.textField.delegate = self;
    
    // setup stores
    NSArray *allFields = @[self.storedStringFieldName];
    NSString *scope = @"LDMLightweightStoreTestAppScope";
    
    NSDictionary *options = @{
                              LDMLightweightStoreOptionsStoreScopeNameKey:scope,
                              LDMLightweightStoreOptionsAllFieldsArrayKey:allFields
                              };
    
    self.memoryStore = [LDMLightweightStore storeWithPolicy:LDMLightweightStorePolicyMemory andOptions:options];
    
    self.defaultsStore = [LDMLightweightStore storeWithPolicy:LDMLightweightStorePolicyDefaults andOptions:options];
    
    self.keychainStore = [LDMLightweightStore storeWithPolicy:LDMLightweightStorePolicyKeychain andOptions:options];
    
    NSDictionary *dictionary = @{};
    [self updateLabels];
}

#pragma mark - Getters
- (NSString *)storedStringFieldName {
    return @"storedStringFieldName";
}

#pragma mark - Labels Updates
- (BOOL)isStringInvisible:(NSString*)string{
    return (!string)||([[NSNull null] isEqual:string])||([string isEqualToString:@""]);
}

- (NSString *)takeVisibleString:(NSString *)string orAlternative:(NSString *)alternative {
    return [self isStringInvisible:string] ? alternative : string;
}

- (void)updateLabel:(UILabel *)label byStoredValue:(NSString *)storedValue withDescription:(NSString *)description{
    label.text = [[description stringByAppendingString:@" value: "] stringByAppendingString:[self takeVisibleString:storedValue orAlternative:@"empty!"]];
}

- (void)updateLabels {
    [self updateLabel:self.memoryLabel byStoredValue:[self.memoryStore fieldByName:self.storedStringFieldName] withDescription:@"Memory"];
    [self updateLabel:self.defaultsLabel byStoredValue:[self.defaultsStore fieldByName:self.storedStringFieldName] withDescription:@"Defaults"];
    [self updateLabel:self.keychainLabel byStoredValue:[self.keychainStore fieldByName:self.storedStringFieldName] withDescription:@"Keychain"];
}

#pragma mark - Actions

- (IBAction)copyToMemory:(id)sender {
    [self.memoryStore setField:self.storedStringFieldName byValue:self.textField.text ];
    [self updateLabels];
}

- (IBAction)copyToDefaults:(id)sender {
    [self.defaultsStore setField:self.storedStringFieldName byValue:self.textField.text ];
    [self updateLabels];
}

- (IBAction)copyToKeychain:(id)sender {
    [self.keychainStore setField:self.storedStringFieldName byValue:self.textField.text ];
    [self updateLabels];
}

- (IBAction)resetAll:(id)sender {
    [self.memoryStore tearDown];
    [self.defaultsStore tearDown];
    [self.keychainStore tearDown];
    [self updateLabels];
}

#pragma mark - Text Field
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self dismissKeyboard];
    return YES;
}

#pragma mark - Keyboard
- (void) dismissKeyboard {
    [self.textField resignFirstResponder];
}

@end
