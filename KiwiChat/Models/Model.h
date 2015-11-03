//
//  Model.h
//  kiwi-chat
//
//  Created by mconintet on 10/18/15.
//  Copyright © 2015 mconintet. All rights reserved.
//

#import "S3OModel.h"

@interface Model : S3OModel

- (BOOL)save;
- (BOOL)remove;

@end
