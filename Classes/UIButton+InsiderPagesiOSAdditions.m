//
//  UIButton+InsiderPagesiOSAdditions.m
//  InsiderPages for iOS
//

#import "UIButton+InsiderPagesiOSAdditions.h"
#import "UIFont+InsiderPagesiOSAdditions.h"
#import "UIColor+InsiderPagesiOSAdditions.h"

@implementation UIButton (InsiderPagesiOSAdditions)

+ (UIButton *)cheddarBigButton {
	UIButton *button = [[self alloc] initWithFrame:CGRectZero];
	[button setBackgroundImage:[[UIImage imageNamed:@"big-button.png"] stretchableImageWithLeftCapWidth:6 topCapHeight:0] forState:UIControlStateNormal];
	[button setBackgroundImage:[[UIImage imageNamed:@"big-button-highlighted.png"] stretchableImageWithLeftCapWidth:6 topCapHeight:0] forState:UIControlStateHighlighted];
	[button setTitleColor:[UIColor colorWithRed:0.384 green:0.412 blue:0.455 alpha:1] forState:UIControlStateNormal];
	[button setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
	button.titleLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
	button.titleLabel.font = [UIFont cheddarFontOfSize:18.0f];
	return button;
}


+ (UIButton *)cheddarBigOrangeButton {
	UIButton *button = [[self alloc] initWithFrame:CGRectZero];
	[button setBackgroundImage:[[UIImage imageNamed:@"big-orange-button.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:0] forState:UIControlStateNormal];
	[button setBackgroundImage:[[UIImage imageNamed:@"big-orange-button-highlighted.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:0] forState:UIControlStateHighlighted];
	[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[button setTitleShadowColor:[UIColor colorWithWhite:0.0f alpha:0.2f] forState:UIControlStateNormal];
	button.titleLabel.font = [UIFont cheddarFontOfSize:20.0f];
	button.titleLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
	button.titleEdgeInsets = UIEdgeInsetsMake(-1.0f, 0.0f, 0.0f, 0.0f);
	return button;
}


+ (UIButton *)cheddarBigGrayButton {
	UIButton *button = [[self alloc] initWithFrame:CGRectZero];
	[button setBackgroundImage:[[UIImage imageNamed:@"big-gray-button.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:0] forState:UIControlStateNormal];
	[button setBackgroundImage:[[UIImage imageNamed:@"big-gray-button-highlighted.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:0] forState:UIControlStateHighlighted];
	[button setTitleColor:[UIColor cheddarSteelColor] forState:UIControlStateNormal];
	[button setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
	button.titleLabel.font = [UIFont cheddarFontOfSize:20.0f];
	button.titleLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
	button.titleEdgeInsets = UIEdgeInsetsMake(-1.0f, 0.0f, 0.0f, 0.0f);
	return button;
}


+ (UIButton *)cheddarBarButton {
	UIButton *button = [[self alloc] initWithFrame:CGRectZero];
	[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[button setTitleShadowColor:[UIColor colorWithWhite:0.0f alpha:0.2f] forState:UIControlStateNormal];
	[button setBackgroundImage:[[UIImage imageNamed:@"nav-button.png"] stretchableImageWithLeftCapWidth:6 topCapHeight:0] forState:UIControlStateNormal];
	[button setBackgroundImage:[[UIImage imageNamed:@"nav-button-highlighted.png"] stretchableImageWithLeftCapWidth:6 topCapHeight:0] forState:UIControlStateHighlighted];
	button.titleLabel.font = [UIFont cheddarFontOfSize:14.0f];
	button.titleLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
//	button.titleEdgeInsets = UIEdgeInsetsMake(-1.0f, 0.0f, 0.0f, 0.0f);
	return button;
}

@end
