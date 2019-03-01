#line 1 "Tweak.xm"
#import <AVFlashlight.h>
#import <IOKit/hid/IOHIDEventSystem.h>
#import <IOKit/hid/IOHIDEventSystemClient.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AudioToolbox/AudioServices.h>
@interface SpringBoard: NSObject
-(BOOL) _handlePhysicalButtonEvent:(id)arg1;
-(void)applicationDidFinishLaunching:(id)application;
@end

@interface FBSystemService
+(id)sharedInstance;
-(void)exitAndRelaunch:(BOOL)arg1;
@end

OBJC_EXTERN IOHIDEventSystemClientRef IOHIDEventSystemClientCreate(CFAllocatorRef allocator);

static AVFlashlight *_sharedFlashlight; 

#define kIOHIDEventUsageVolumeUp 233 
#define kIOHIDEventUsageVolumeDown 234 

BOOL TweakEnabled = YES; 
BOOL vibrationEnabled = YES; 
BOOL downUp = NO;
BOOL upDown = NO;
BOOL powerisPressed = NO;
static NSInteger Gesture = 1; 
static NSInteger TimesPressed = 0; 

NSTimer *PowerPressed;
NSTimer *PowerTimer;


#include <substrate.h>
#if defined(__clang__)
#if __has_feature(objc_arc)
#define _LOGOS_SELF_TYPE_NORMAL __unsafe_unretained
#define _LOGOS_SELF_TYPE_INIT __attribute__((ns_consumed))
#define _LOGOS_SELF_CONST const
#define _LOGOS_RETURN_RETAINED __attribute__((ns_returns_retained))
#else
#define _LOGOS_SELF_TYPE_NORMAL
#define _LOGOS_SELF_TYPE_INIT
#define _LOGOS_SELF_CONST
#define _LOGOS_RETURN_RETAINED
#endif
#else
#define _LOGOS_SELF_TYPE_NORMAL
#define _LOGOS_SELF_TYPE_INIT
#define _LOGOS_SELF_CONST
#define _LOGOS_RETURN_RETAINED
#endif

@class SpringBoard; @class FBSystemService; @class AVFlashlight; 
static AVFlashlight* (*_logos_orig$_ungrouped$AVFlashlight$init)(_LOGOS_SELF_TYPE_INIT AVFlashlight*, SEL) _LOGOS_RETURN_RETAINED; static AVFlashlight* _logos_method$_ungrouped$AVFlashlight$init(_LOGOS_SELF_TYPE_INIT AVFlashlight*, SEL) _LOGOS_RETURN_RETAINED; static _Bool (*_logos_orig$_ungrouped$SpringBoard$_handlePhysicalButtonEvent$)(_LOGOS_SELF_TYPE_NORMAL SpringBoard* _LOGOS_SELF_CONST, SEL, UIPressesEvent *); static _Bool _logos_method$_ungrouped$SpringBoard$_handlePhysicalButtonEvent$(_LOGOS_SELF_TYPE_NORMAL SpringBoard* _LOGOS_SELF_CONST, SEL, UIPressesEvent *); static void _logos_method$_ungrouped$SpringBoard$timerEnd(_LOGOS_SELF_TYPE_NORMAL SpringBoard* _LOGOS_SELF_CONST, SEL); static void _logos_method$_ungrouped$SpringBoard$allowNothing(_LOGOS_SELF_TYPE_NORMAL SpringBoard* _LOGOS_SELF_CONST, SEL); static void _logos_method$_ungrouped$SpringBoard$flashL(_LOGOS_SELF_TYPE_NORMAL SpringBoard* _LOGOS_SELF_CONST, SEL); static void (*_logos_orig$_ungrouped$SpringBoard$applicationDidFinishLaunching$)(_LOGOS_SELF_TYPE_NORMAL SpringBoard* _LOGOS_SELF_CONST, SEL, id); static void _logos_method$_ungrouped$SpringBoard$applicationDidFinishLaunching$(_LOGOS_SELF_TYPE_NORMAL SpringBoard* _LOGOS_SELF_CONST, SEL, id); 
static __inline__ __attribute__((always_inline)) __attribute__((unused)) Class _logos_static_class_lookup$FBSystemService(void) { static Class _klass; if(!_klass) { _klass = objc_getClass("FBSystemService"); } return _klass; }
#line 34 "Tweak.xm"
void respringDevice() {
    [[_logos_static_class_lookup$FBSystemService() sharedInstance] exitAndRelaunch:YES];
}

static void loadPrefs()
{
    NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.chmbr.volflash.plist"];
    if(prefs)
    {
        TweakEnabled = ( [prefs objectForKey:@"enabledSwitch"] ? [[prefs objectForKey:@"enabledSwitch"] boolValue] : TweakEnabled );
        vibrationEnabled = ( [prefs objectForKey:@"vibrateSwitch"] ? [[prefs objectForKey:@"vibrateSwitch"] boolValue] : vibrationEnabled );
        Gesture = ([prefs objectForKey:@"gesturepref"] ? [[prefs objectForKey:@"gesturepref"] integerValue] : Gesture);
    }
    [prefs release];
}

static __attribute__((constructor)) void _logosLocalCtor_f457c545(int __unused argc, char __unused **argv, char __unused **envp)
{
    loadPrefs();
}




static AVFlashlight* _logos_method$_ungrouped$AVFlashlight$init(_LOGOS_SELF_TYPE_INIT AVFlashlight* __unused self, SEL __unused _cmd) _LOGOS_RETURN_RETAINED {
  if (!_sharedFlashlight)
    {
      _sharedFlashlight = _logos_orig$_ungrouped$AVFlashlight$init(self, _cmd);
    }
	return _sharedFlashlight;
}




static _Bool _logos_method$_ungrouped$SpringBoard$_handlePhysicalButtonEvent$(_LOGOS_SELF_TYPE_NORMAL SpringBoard* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, UIPressesEvent * arg1) {

	int type = arg1.allPresses.allObjects[0].type;
  int force = arg1.allPresses.allObjects[0].force;

  if (type == 102 && force == 1)
	{
    loadPrefs();
		if (downUp && TweakEnabled)
			{
        if(Gesture == 2) {
          if(vibrationEnabled) {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
          }
          if (_sharedFlashlight.flashlightLevel > 0)
            {
              [_sharedFlashlight turnPowerOff];
            }
          else
            {
             [_sharedFlashlight setFlashlightLevel: 1.0 withError:nil];
            }
        }
			}
		else
			{
				upDown = YES;
			}
    if(Gesture == 7 && TweakEnabled) {
      PowerPressed = [[NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(flashL) userInfo:nil repeats:NO] retain];
      powerisPressed = YES;
    }
	}

  if(type == 102 && force == 0)
  {
    if (PowerPressed != nil)
    {
      [PowerPressed invalidate];
      PowerPressed = nil;
    }
      powerisPressed = NO;
  }
  if (type == 103 && force == 1)
	{
    loadPrefs();
	 	if (upDown && TweakEnabled)
	    {
        if(Gesture == 2) {
          if(vibrationEnabled) {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
          }
          if (_sharedFlashlight.flashlightLevel > 0)
            {
              [_sharedFlashlight turnPowerOff];
            }
          else
            {
             [_sharedFlashlight setFlashlightLevel: 1.0 withError:nil];
            }
        }
	    }
	  else
	    {
	      downUp = YES;
	    }
      if(Gesture == 8 && TweakEnabled) {
        PowerPressed = [[NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(flashL) userInfo:nil repeats:NO] retain];
        powerisPressed = YES;
      }
	}

  if (type == 103 && force == 0){
    if (PowerPressed != nil)
    {
      [PowerPressed invalidate];
      PowerPressed = nil;
    }
      powerisPressed = NO;
  }
  if(type == 104 && force == 1)
		{
        if(Gesture == 3 && TweakEnabled)
        {
            PowerPressed = [[NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(flashL) userInfo:nil repeats:NO] retain];
            powerisPressed = YES;

        }
        if(Gesture == 4 && TweakEnabled)
        {
          PowerTimer = [[NSTimer scheduledTimerWithTimeInterval:1.2 target:self selector:@selector(timerEnd) userInfo:nil repeats:NO] retain];
          TimesPressed += 1;
          if(TimesPressed == 2)
          {
            if(vibrationEnabled) {
              AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            }
            if (_sharedFlashlight.flashlightLevel > 0)
              {
                [_sharedFlashlight turnPowerOff];
              }
            else
              {
               [_sharedFlashlight setFlashlightLevel: 1.0 withError:nil];
              }
              if (PowerTimer != nil)
              {
                [PowerTimer invalidate];
                PowerTimer = nil;
              }
              TimesPressed = 0;
          }

        }
        if (Gesture == 5 && TweakEnabled)
        {
          PowerTimer = [[NSTimer scheduledTimerWithTimeInterval:1.8 target:self selector:@selector(timerEnd) userInfo:nil repeats:NO] retain];
          TimesPressed += 1;
          if(TimesPressed == 3)
          {
            if(vibrationEnabled) {
              AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            }
            if (_sharedFlashlight.flashlightLevel > 0)
              {
                [_sharedFlashlight turnPowerOff];
              }
            else
              {
               [_sharedFlashlight setFlashlightLevel: 1.0 withError:nil];
              }
              if (PowerTimer != nil)
              {
                [PowerTimer invalidate];
                PowerTimer = nil;
              }
              TimesPressed = 0;
          }
        }
		}

  if(type == 104 && force == 0)
    {
      if (PowerPressed != nil)
      {
        [PowerPressed invalidate];
        PowerPressed = nil;
      }
        powerisPressed = NO;
    }
  if(type == 101 && force == 1)
  {
    if(Gesture == 6 && TweakEnabled)
    {

      PowerTimer = [[NSTimer scheduledTimerWithTimeInterval:1.8 target:self selector:@selector(timerEnd) userInfo:nil repeats:NO] retain];
      TimesPressed += 1;

      if(TimesPressed == 3)
      {
        if(vibrationEnabled) {
          AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        }
        if (_sharedFlashlight.flashlightLevel > 0)
          {
            [_sharedFlashlight turnPowerOff];
          }
        else
          {
           [_sharedFlashlight setFlashlightLevel: 1.0 withError:nil];
          }

        if (PowerTimer != nil)
        {
          [PowerTimer invalidate];
          PowerTimer = nil;
        }
        TimesPressed = 0;
      }
    }
  }
  [NSTimer scheduledTimerWithTimeInterval: 0.5 target: self selector: @selector (allowNothing) userInfo: nil repeats:NO];

  return _logos_orig$_ungrouped$SpringBoard$_handlePhysicalButtonEvent$(self, _cmd, arg1);
}


 static void _logos_method$_ungrouped$SpringBoard$timerEnd(_LOGOS_SELF_TYPE_NORMAL SpringBoard* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd) {
  TimesPressed = 0;
}

 static void _logos_method$_ungrouped$SpringBoard$allowNothing(_LOGOS_SELF_TYPE_NORMAL SpringBoard* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd) {
  downUp = NO;
  upDown = NO;
  loadPrefs();
}

 static void _logos_method$_ungrouped$SpringBoard$flashL(_LOGOS_SELF_TYPE_NORMAL SpringBoard* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd) {
  if(vibrationEnabled) {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
  }
  if (_sharedFlashlight.flashlightLevel > 0)
    {
      [_sharedFlashlight turnPowerOff];
    }
  else
    {
     [_sharedFlashlight setFlashlightLevel: 1.0 withError:nil];
    }
}



static void _logos_method$_ungrouped$SpringBoard$applicationDidFinishLaunching$(_LOGOS_SELF_TYPE_NORMAL SpringBoard* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, id application) {
  _logos_orig$_ungrouped$SpringBoard$applicationDidFinishLaunching$(self, _cmd, application);
  loadPrefs();
}

void ioEventHandler(void *target, void *refcon, IOHIDEventQueueRef queue, IOHIDEventRef event) {
    static BOOL volumeUpPressed = NO;
    static BOOL volumeDownPressed = NO;

    if (IOHIDEventGetType(event) == kIOHIDEventTypeKeyboard) {
        int keyDown = IOHIDEventGetIntegerValue(event, kIOHIDEventFieldKeyboardDown);
        int button = IOHIDEventGetIntegerValue(event, kIOHIDEventFieldKeyboardUsage);
        switch (button) {
            case kIOHIDEventUsageVolumeUp:
                volumeUpPressed = keyDown;
                break;
            case kIOHIDEventUsageVolumeDown:
                volumeDownPressed = keyDown;
                break;
            default:
                break;
        }
        if (volumeUpPressed && volumeDownPressed) {
          loadPrefs();
          if(TweakEnabled)
          {
            if(Gesture == 1) {
              if(vibrationEnabled) {
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
              }
              if (_sharedFlashlight.flashlightLevel > 0)
                {
                  [_sharedFlashlight turnPowerOff];
                }
              else
                {
                 [_sharedFlashlight setFlashlightLevel: 1.0 withError:nil];
                }
            }
          }
	}
    }
}

static IOHIDEventSystemClientRef ioHIDClient;
static CFRunLoopRef ioHIDRunLoopScedule;

static __attribute__((constructor)) void _logosLocalCtor_41bbe362(int __unused argc, char __unused **argv, char __unused **envp) {
    ioHIDClient = IOHIDEventSystemClientCreate(kCFAllocatorDefault);
    ioHIDRunLoopScedule = CFRunLoopGetMain();
    IOHIDEventSystemClientScheduleWithRunLoop(ioHIDClient, ioHIDRunLoopScedule, kCFRunLoopDefaultMode);
    IOHIDEventSystemClientRegisterEventCallback(ioHIDClient, ioEventHandler, NULL, NULL);
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)respringDevice, CFSTR("com.chmbr.volflash/respring"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
}

static __attribute__((destructor)) void _logosLocalDtor_385014b9(int __unused argc, char __unused **argv, char __unused **envp) {
    IOHIDEventSystemClientUnregisterEventCallback(ioHIDClient);
    IOHIDEventSystemClientUnscheduleWithRunLoop(ioHIDClient, ioHIDRunLoopScedule, kCFRunLoopDefaultMode);
}
static __attribute__((constructor)) void _logosLocalInit() {
{Class _logos_class$_ungrouped$AVFlashlight = objc_getClass("AVFlashlight"); MSHookMessageEx(_logos_class$_ungrouped$AVFlashlight, @selector(init), (IMP)&_logos_method$_ungrouped$AVFlashlight$init, (IMP*)&_logos_orig$_ungrouped$AVFlashlight$init);Class _logos_class$_ungrouped$SpringBoard = objc_getClass("SpringBoard"); MSHookMessageEx(_logos_class$_ungrouped$SpringBoard, @selector(_handlePhysicalButtonEvent:), (IMP)&_logos_method$_ungrouped$SpringBoard$_handlePhysicalButtonEvent$, (IMP*)&_logos_orig$_ungrouped$SpringBoard$_handlePhysicalButtonEvent$);{ char _typeEncoding[1024]; unsigned int i = 0; _typeEncoding[i] = 'v'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; _typeEncoding[i] = '\0'; class_addMethod(_logos_class$_ungrouped$SpringBoard, @selector(timerEnd), (IMP)&_logos_method$_ungrouped$SpringBoard$timerEnd, _typeEncoding); }{ char _typeEncoding[1024]; unsigned int i = 0; _typeEncoding[i] = 'v'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; _typeEncoding[i] = '\0'; class_addMethod(_logos_class$_ungrouped$SpringBoard, @selector(allowNothing), (IMP)&_logos_method$_ungrouped$SpringBoard$allowNothing, _typeEncoding); }{ char _typeEncoding[1024]; unsigned int i = 0; _typeEncoding[i] = 'v'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; _typeEncoding[i] = '\0'; class_addMethod(_logos_class$_ungrouped$SpringBoard, @selector(flashL), (IMP)&_logos_method$_ungrouped$SpringBoard$flashL, _typeEncoding); }MSHookMessageEx(_logos_class$_ungrouped$SpringBoard, @selector(applicationDidFinishLaunching:), (IMP)&_logos_method$_ungrouped$SpringBoard$applicationDidFinishLaunching$, (IMP*)&_logos_orig$_ungrouped$SpringBoard$applicationDidFinishLaunching$);} }
#line 341 "Tweak.xm"
