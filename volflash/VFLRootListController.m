#import "VFLRootListController.h"



@implementation VFLRootListController
- (instancetype)init {
    self = [super init];

    if (self) {
        HBAppearanceSettings *appearanceSettings = [[HBAppearanceSettings alloc] init];
        appearanceSettings.tintColor = [UIColor colorWithRed:0.1f green:0.1f blue:0.1f alpha:1];
        appearanceSettings.tableViewCellSeparatorColor = [UIColor colorWithWhite:0 alpha:0];
        self.hb_appearanceSettings = appearanceSettings;
    }

    return self;
}
- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"Root" target:self] retain];
	}

	return _specifiers;
}


- (void)myTwitter:(id)arg1 {
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter://"]]) [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"twitter://user?screen_name=Cemre_Suler"]];
    else [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/Cemre_Suler"]];
}

-(void)sourceCode:(id)arg1 {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/CemreSuler/VolFlash"]];
}
-(void)donation:(id)arg1 {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://paypal.me/CemreSuler"]];
}
-(void)respring{
    pid_t respringID;
    char *argv[] = {"/usr/bin/killall", "backboardd", NULL};
    posix_spawn(&respringID, argv[0], NULL, NULL, argv, NULL);
    waitpid(respringID, NULL, WEXITED);
}

@end
