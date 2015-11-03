//
//  font_icon.h
//  KiwiChat
//
//  Created by mconintet on 10/28/15.
//  Copyright © 2015 mconintet. All rights reserved.
//

#ifndef font_icon_h
#define font_icon_h

#import "UIView+Snapshot.h"

#define FONT_NAME @"font_icon"

#define FONT_NSSTRING(utf8CharCode)                  \
    ({                                               \
        unichar c = (unichar)utf8CharCode;           \
        [NSString stringWithCharacters:&c length:1]; \
    })

#define FONT_UIIMAGE(utf8CharCode, fontSize, color)                 \
    ({                                                              \
        UILabel* label = [[UILabel alloc] init];                    \
        label.font = [UIFont fontWithName:FONT_NAME size:fontSize]; \
        label.textColor = UICOLOR_FROM_RGB(color);                  \
        label.text = FONT_NSSTRING(utf8CharCode);                   \
        [label sizeToFit];                                          \
        UIImage* image = [label snapshot];                          \
        image;                                                      \
    })

#define FONT_ICON_COMMENT 0xe800
#define FONT_ICON_USER 0xe801
#define FONT_ICON_USER_ADD 0xe802
#define FONT_ICON_DOT_3 0xe803
#define FONT_ICON_CAMERA 0xe804
#define FONT_ICON_MOBILE 0xe806
#define FONT_ICON_MONITOR 0xe807
#define FONT_ICON_COG 0xe808
#define FONT_ICON_CIRCLE 0xe809
#define FONT_ICON_WIFI 0xe80a

#endif /* font_icon_h */
