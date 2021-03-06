#import <AVFlashlight.h>
#import <IOKit/hid/IOHIDEventSystem.h>
#import <IOKit/hid/IOHIDEventSystemClient.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AudioToolbox/AudioServices.h>
#import <sys/types.h>
#import <sys/sysctl.h>

extern "C" void AudioServicesPlaySystemSoundWithVibration(SystemSoundID inSystemSoundID, id unknown, NSDictionary *options);

@interface SpringBoard: NSObject
-(BOOL) _handlePhysicalButtonEvent:(id)arg1;
-(void)applicationDidFinishLaunching:(id)application;
- (void)hapticFeedback;
- (BOOL)is6S;
- (NSString*)platform;
@end

@interface FBSystemService
+(id)sharedInstance;
-(void)exitAndRelaunch:(BOOL)arg1;
@end

OBJC_EXTERN IOHIDEventSystemClientRef IOHIDEventSystemClientCreate(CFAllocatorRef allocator);

static AVFlashlight *_sharedFlashlight; //Define the Flashlight

#define kIOHIDEventUsageVolumeUp 233 //Define the volume up button
#define kIOHIDEventUsageVolumeDown 234 //Define the volume down button

BOOL TweakEnabled = YES; //Default
BOOL vibrationEnabled = YES; //Default
BOOL downUp = NO;
BOOL upDown = NO;
BOOL powerisPressed = NO;
static NSInteger Gesture = 1; //Default
static NSInteger TimesPressed = 0; //Power Button is Pressed 0 times

NSTimer *PowerPressed;
NSTimer *PowerTimer;

void respringDevice() {
    [[%c(FBSystemService) sharedInstance] exitAndRelaunch:YES];
}
void hapticVibe(){
        NSMutableDictionary* VibrationDictionary = [NSMutableDictionary dictionary];
        NSMutableArray* VibrationArray = [NSMutableArray array ];
        [VibrationArray addObject:[NSNumber numberWithBool:YES]];
        [VibrationArray addObject:[NSNumber numberWithInt:30]]; //vibrate for 50ms
        [VibrationDictionary setObject:VibrationArray forKey:@"VibePattern"];
        [VibrationDictionary setObject:[NSNumber numberWithInt:1] forKey:@"Intensity"];
        AudioServicesPlaySystemSoundWithVibration(4095,nil,VibrationDictionary);
}
static int const UITapticEngineFeedbackPop = 1002;
@interface UITapticEngine : NSObject
- (void)actuateFeedback:(int)arg1;
- (void)endUsingFeedback:(int)arg1;
- (void)prepareUsingFeedback:(int)arg1;
@end
@interface UIDevice (Private)
-(UITapticEngine*)_tapticEngine;
@end
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

%ctor
{
    loadPrefs();
}


%hook AVFlashlight
-(id)init
{
  if (!_sharedFlashlight)
    {
      _sharedFlashlight = %orig;
    }
	return _sharedFlashlight;
}
%end

%hook SpringBoard
-(_Bool) _handlePhysicalButtonEvent:(UIPressesEvent *)arg1
{

	int type = arg1.allPresses.allObjects[0].type;
  int force = arg1.allPresses.allObjects[0].force;

  if (type == 102 && force == 1)
	{
    loadPrefs();
		if (downUp && TweakEnabled)
			{
        if(Gesture == 2) {
          if(vibrationEnabled) {
          [self hapticFeedback];
          }
          if (_sharedFlashlight.flashlightLevel > 0)
            {
              [_sharedFlashlight setFlashlightLevel: 0.0 withError:nil];
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
          [self hapticFeedback];
          }
          if (_sharedFlashlight.flashlightLevel > 0)
            {
              [_sharedFlashlight setFlashlightLevel: 0.0 withError:nil];
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
            [self hapticFeedback];
            }
            if (_sharedFlashlight.flashlightLevel > 0)
              {
                [_sharedFlashlight setFlashlightLevel: 0.0 withError:nil];
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
            [self hapticFeedback];
            }
            if (_sharedFlashlight.flashlightLevel > 0)
              {
                [_sharedFlashlight setFlashlightLevel: 0.0 withError:nil];
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
        [self hapticFeedback];
        }
        if (_sharedFlashlight.flashlightLevel > 0)
          {
            [_sharedFlashlight setFlashlightLevel: 0.0 withError:nil];
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

  return %orig;
}

%new - (void) timerEnd
{
  TimesPressed = 0;
}
%new - (void) allowNothing
{
  downUp = NO;
  upDown = NO;
  loadPrefs();
}
%new - (void) flashL
{
  if(vibrationEnabled) {
  [self hapticFeedback];
  }
  if (_sharedFlashlight.flashlightLevel > 0)
    {
      [_sharedFlashlight setFlashlightLevel: 0.0 withError:nil];
    }
  else
    {
     [_sharedFlashlight setFlashlightLevel: 1.0 withError:nil];
    }
}
%new
- (NSString *)platform {
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = (char *) malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithUTF8String:machine];
    free(machine);
    return platform;
}
%new
- (BOOL)is6S {
	return ([[[self platform] substringToIndex: 8] isEqualToString:@"iPhone8,"]);
}
%new
- (void)hapticFeedback {
	if ([self is6S]) {
		if ([[UIDevice currentDevice] respondsToSelector:@selector(_tapticEngine)]) {
        	UITapticEngine *tapticEngine = [UIDevice currentDevice]._tapticEngine;
        	if (tapticEngine) {
            [tapticEngine actuateFeedback:UITapticEngineFeedbackPop];
        	}
		}
	}
	else {
        hapticVibe();
    }
}

%end
%hook SpringBoard
-(void)applicationDidFinishLaunching:(id)application {
  %orig;
  loadPrefs();
}


%end


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

                      hapticVibe();

              }
              if (_sharedFlashlight.flashlightLevel > 0)
                {
                  [_sharedFlashlight setFlashlightLevel: 0.0 withError:nil];
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


%ctor {
    ioHIDClient = IOHIDEventSystemClientCreate(kCFAllocatorDefault);
    ioHIDRunLoopScedule = CFRunLoopGetMain();
    IOHIDEventSystemClientScheduleWithRunLoop(ioHIDClient, ioHIDRunLoopScedule, kCFRunLoopDefaultMode);
    IOHIDEventSystemClientRegisterEventCallback(ioHIDClient, ioEventHandler, NULL, NULL);
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)respringDevice, CFSTR("com.chmbr.volflash/respring"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
}

%dtor {
    IOHIDEventSystemClientUnregisterEventCallback(ioHIDClient);
    IOHIDEventSystemClientUnscheduleWithRunLoop(ioHIDClient, ioHIDRunLoopScedule, kCFRunLoopDefaultMode);
}
