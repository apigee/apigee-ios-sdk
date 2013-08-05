#import <Foundation/Foundation.h>

#import "ApigeeEntity.h"

@interface ApigeeUser : ApigeeEntity

@property (strong, nonatomic) NSString* username;
@property (strong, nonatomic) NSString* firstname;
@property (strong, nonatomic) NSString* middlename;
@property (strong, nonatomic) NSString* lastname;
@property (strong, nonatomic) NSString* name;
@property (strong, nonatomic) NSString* email;
@property (strong, nonatomic) NSString* picture;
@property (assign, nonatomic) BOOL activated;
@property (assign, nonatomic) BOOL disabled;

- (id)initWithDataClient:(ApigeeDataClient*)dataClient;
- (id)initWithEntity:(ApigeeEntity*)entity;

+ (BOOL)isSameType:(NSString*)type;

@end
