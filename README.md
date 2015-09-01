#LDMLightweightStore
This is a lightweight key-value store which could be useful if you have several settings in app and you don't know where you should place them

##Requirements
iOS 7 or later

##Features

- Easy to use
- Convenience setup

###What implemented?

- in-Memory dictionary store
- Defaults store
- Keychain store ( [UICKeyChainStore inside](https://github.com/kishikawakatsumi/UICKeyChainStore)
)
- Policy switching (move your data between stores)

##Installation
To install project use Cocoapods. (Recommended)

####CocoaPods

You can use [CocoaPods](http://cocoapods.org/?q=LDMLightweightStore).

```ruby
pod 'LDMLightweightStore'
```

##Usage

###Import

Import store into your project, just add 

```objective-c
#import<LDMLightweightStore/LDMLightweightStore.h>
```

###Examples

#### Storing device Id
Suppose, that you have sensitive data or setting.
Suppose, that you need an device id you generated by yourself or first-user-install option.

Let's see example:

```objective-c
# put device id 
NSString *deviceId = @"deviceId"; // not so obvious name, of course

// setup store in memory
LDMLightweightStore *store = 
[LDMLightweightStore storeWithPolicy:LDMLightweightStorePolicyMemory options:@{LDMLightweightStoreOptionsStoreScopeNameKey: @"app_settings", LDMLightweightStoreOptionsAllFieldsArrayKey: deviceId}];

[store setField:deviceId byValue:@"YOUR_DEVICE_ID"];

// and if you go to release:
[store switchPolicy:LDMLightweightStorePolicyDefaults];

// or more long-live:
[store switchPolicy:LDMLightweightStorePolicyKeychain];
```

#### Cleanup

```objective-c
[store tearDown]; // cleanup store

[store setField:deviceId byValue:nil]; // cleanup value for field +deviceId+
```

#### Switch policy

```objective-c
[store switchPolicy:LDMLightweightStorePolicyDefaults];
[store switchPolicy:LDMLightweightStorePolicyKeychain];
```

##Contact
Dmitry Lobanov gaussblurinc@gmail.com

##Licene
LDMLightweightStore is available under the MIT License.
See the [License](LICENSE) file for more info.