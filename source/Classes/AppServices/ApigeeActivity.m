#import "ApigeeActivity.h"

static NSString* ENTITY_TYPE     = @"activity";

static NSString *kTypeActivity   = @"activity";
static NSString *kTypePerson     = @"person";
static NSString *kTypeUser       = @"user";

static NSString *kKeyType        = @"type";
static NSString *kKeyVerb        = @"verb";
static NSString *kKeyCategory    = @"category";
static NSString *kKeyContent     = @"content";
static NSString *kKeyTitle       = @"title";
static NSString *kKeyActor       = @"actor";
static NSString *kKeyObject      = @"object";
static NSString *kKeyActorEmail  = @"email";
static NSString *kKeyActorUuid   = @"uuid";
static NSString *kKeyDisplayName = @"displayName";
static NSString *kKeyEntityType  = @"entityType";
static NSString *kKeyEntityUuid  = @"entityUUID";

// the way they have set up the object info
enum
{
    kApigeeActivityNoObject = 0,
    kApigeeActivityObjectEntity = 1,
    kApigeeActivityObjectContent = 2,
    kApigeeActivityObjectNameOnly = 3
};

@implementation ApigeeActivity
{
    // basic stats
    NSString *m_verb;
    NSString *m_category;
    NSString *m_content;
    NSString *m_title;
    
    // stats related to the actor
    NSString *m_actorUserName;
    NSString *m_actorDisplayName;
    NSString *m_actorUUID;
    NSString *m_actorEmail;
    
    // stats related to the object
    NSString *m_objectType;
    NSString *m_objectDisplayName;
    
    // for the object, either these must be set...
    NSString *m_entityType;
    NSString *m_entityUUID;
    
    // ...or this must be set
    NSString *m_objectContent;
    
    // or it will use the content field as the content for the object
    
    // tracking how the object is currently set up
    int m_objectDataType;
}

+ (BOOL)isSameType:(NSString*)type
{
    return [type isEqualToString:ENTITY_TYPE];
}

- (id)initWithDataClient:(ApigeeDataClient*)dataClient
{
    self = [super initWithDataClient:dataClient];
    if ( self )
    {
        m_objectDataType = kApigeeActivityNoObject;
        self.type = ENTITY_TYPE;
    }
    return self;
}

-(BOOL) setBasics: (NSString *)verb category:(NSString *)category content:(NSString *)content title:(NSString *)title
{
    // input validation
    if ( !verb || !category || !content || !title ) return NO;
    
    m_verb = verb;
    m_category = category;
    m_content = content;
    m_title = title;

    return YES;
}

-(BOOL) setActorInfo: (NSString *)actorUserName actorDisplayName:(NSString *)actorDisplayName actorUUID:(NSString *)actorUUID
{
    // input validation
    if ( !actorUserName || !actorDisplayName || !actorUUID ) return NO;
    
    m_actorUserName = actorUserName;
    m_actorDisplayName = actorDisplayName;
    m_actorUUID = actorUUID;
    m_actorEmail = nil;
    
    return YES;
}

-(BOOL) setActorInfo: (NSString *)actorUserName actorDisplayName:(NSString *)actorDisplayName actorEmail:(NSString *)actorEmail
{
    // input validation
    if ( !actorUserName || !actorDisplayName || !actorEmail ) return NO;
    
    m_actorUserName = actorUserName;
    m_actorDisplayName = actorDisplayName;
    m_actorEmail = actorEmail;
    m_actorUUID = nil;
    
    return YES;
}

-(BOOL)setObjectInfo: (NSString *)objectType displayName:(NSString *)displayName entityType:(NSString *)entityType entityUUID:(NSString *)entityUUID
{
    // input validation
    if ( !objectType || !displayName || !entityType || !entityUUID ) return NO;
    
    m_objectType = objectType;
    m_objectDisplayName = displayName;
    m_entityType = entityType;
    m_entityUUID = entityUUID;
    m_objectDataType = kApigeeActivityObjectEntity;
    
    // clear out the unused value
    m_objectContent = nil;
    
    return YES;
}

-(BOOL)setObjectInfo: (NSString *)objectType displayName:(NSString *)displayName objectContent:(NSString *)objectContent
{
    // input validation
    if ( !objectType || !displayName || !objectContent ) return NO;
    
    m_objectType = objectType;
    m_objectDisplayName = displayName;
    m_objectContent = objectContent;
    m_objectDataType = kApigeeActivityObjectContent;
    
    // clear out the unused values
    m_entityType = nil;
    m_entityUUID = nil;
    
    return YES;
}

-(BOOL)setObjectInfo: (NSString *)objectType displayName:(NSString *)displayName
{
    // input validation
    if ( !objectType || !displayName ) return NO;
    
    m_objectType = objectType;
    m_objectDisplayName = displayName;
    m_objectDataType = kApigeeActivityObjectNameOnly;
    
    // we'll use m_content when the time comes. But we don't want to 
    // assume they've set it yet. They can call the setup functions in any order.
    m_objectContent = nil;
    m_entityType = nil;
    m_entityUUID = nil;
    
    return YES;
}

-(BOOL)isValid
{
    // if any of the required values are nil, it's not valid
    if ( !m_verb || !m_category || !m_content || !m_title || !m_actorUserName || !m_actorDisplayName )
    {
        return NO;
    }
    
    // either the uuid or the email of the user must be valid
    if ( !m_actorUUID && !m_actorEmail )
    {
        return NO;
    }
    
    // the object data requirements are based on the object setup
    switch ( m_objectDataType )
    {
        case kApigeeActivityObjectEntity:
        {
            if ( !m_objectType || !m_objectDisplayName || !m_entityType || !m_entityUUID ) return NO;
        }
        break;
            
        case kApigeeActivityObjectContent:
        {
            if ( !m_objectType || !m_objectDisplayName || !m_objectContent ) return NO;
        }
            break;
            
        case kApigeeActivityObjectNameOnly:
        {
            if ( !m_objectType || !m_objectDisplayName ) return NO;
        }
        break;
            
        // kApigeeActivityNoObject has no requirements.
    }
    
    // if we're here, we're valid.
    return YES;
}

- (BOOL)setValue:(id)valueObject forKey:(NSString*)key into:(NSMutableDictionary*)dict
{
    if (valueObject != nil) {
        [dict setValue:valueObject forKey:key];
        return YES;
    }
    
    return NO;
}

-(NSDictionary *)toNSDictionary
{
    NSMutableDictionary *ret = [NSMutableDictionary new];
    
    // add all the fields in
    [self setValue:kTypeActivity forKey:kKeyType into:ret];
    [self setValue:m_verb forKey:kKeyVerb into:ret];
    [self setValue:m_category forKey:kKeyCategory into:ret];
    [self setValue:m_content forKey:kKeyContent into:ret];
    [self setValue:m_title forKey:kKeyTitle into:ret];
    
    // make the actor's subdictionary
    NSMutableDictionary *actor = [NSMutableDictionary new];
    [self setValue:kTypePerson forKey:kKeyType into:actor];
    [self setValue:kTypeUser forKey:kKeyEntityType into:actor];
    [self setValue:m_actorDisplayName forKey:kKeyDisplayName into:actor];
    
    [self setValue:m_actorUUID forKey:kKeyActorUuid into:actor];
    [self setValue:m_actorEmail forKey:kKeyActorEmail into:actor];
    
    // add the actor to the main dict
    [self setValue:actor forKey:kKeyActor into:ret];
    
    if ( m_objectDataType != kApigeeActivityNoObject )
    {
        // there is an associated object. Prep a dict for it
        NSMutableDictionary *object = [NSMutableDictionary new];
        
        // these fields are involved in all cases
        [self setValue:m_objectType forKey:kKeyType into:object];
        [self setValue:m_objectDisplayName forKey:kKeyDisplayName into:object];
        
        if ( m_objectDataType == kApigeeActivityObjectContent )
        {
            [self setValue:m_objectContent forKey:kKeyContent into:object];
        }
        else if ( m_objectDataType == kApigeeActivityObjectNameOnly )
        {
            [self setValue:m_content forKey:kKeyContent into:object];
        }
        else if ( m_objectDataType == kApigeeActivityObjectEntity )
        {
            [self setValue:m_entityType forKey:kKeyEntityType into:object];
            [self setValue:m_entityUUID forKey:kKeyEntityUuid into:object];
        }
        
        // add to the dict
        [self setValue:object forKey:kKeyObject into:ret];
    }
    
    // done with the assembly
    return ret;
}

-(void)setProperties:(NSDictionary*)dictProperties
{
    Class clsNSString = [NSString class];
    Class clsNSDictionary = [NSDictionary class];
    id value;
    NSString *valueAsString;
    NSDictionary *valueAsDictionary;

    for( NSString *key in dictProperties ) {
        value = [dictProperties valueForKey:key];
        if ([value isKindOfClass:clsNSString]) {
            valueAsString = (NSString*) value;
            
            if ([key isEqualToString:kKeyVerb]) {
                m_verb = valueAsString;
            } else if ([key isEqualToString:kKeyCategory]) {
                m_category = valueAsString;
            } else if ([key isEqualToString:kKeyContent]) {
                m_content = valueAsString;
            } else if ([key isEqualToString:kKeyTitle]) {
                m_title = valueAsString;
            }
        } else if ([value isKindOfClass:clsNSDictionary]) {
            valueAsDictionary = (NSDictionary*) value;
            
            if ([key isEqualToString:kKeyActor]) {
                for (NSString *actorKey in valueAsDictionary) {
                    id actorValue = [valueAsDictionary valueForKey:actorKey];
                    
                    if ([actorValue isKindOfClass:clsNSString]) {
                        NSString *actorValueAsString = (NSString*) actorValue;
                        
                        if ([actorKey isEqualToString:kKeyDisplayName]) {
                            m_actorDisplayName = actorValueAsString;
                        } else if ([actorKey isEqualToString:kKeyActorEmail]) {
                            m_actorEmail = actorValueAsString;
                        } else if ([actorKey isEqualToString:kKeyActorUuid]) {
                            m_actorUUID = actorValueAsString;
                        }
                    }
                }
            } else if ([key isEqualToString:kKeyObject]) {
                for (NSString *objectKey in valueAsDictionary) {
                    id objectValue = [valueAsDictionary valueForKey:objectKey];
                    
                    if ([objectValue isKindOfClass:clsNSString]) {
                        NSString *objectValueAsString = (NSString*) objectValue;
                        
                        if ([objectKey isEqualToString:kKeyType]) {
                            m_objectType = objectValueAsString;
                        } else if ([objectKey isEqualToString:kKeyDisplayName]) {
                            m_objectDisplayName = objectValueAsString;
                        } else if ([objectKey isEqualToString:kKeyEntityType]) {
                            m_entityType = objectValueAsString;
                        } else if ([objectKey isEqualToString:kKeyEntityUuid]) {
                            m_entityUUID = objectValueAsString;
                        } else if ([objectKey isEqualToString:kKeyContent]) {
                            m_objectContent = objectValueAsString;
                        }
                    }
                }
            }
        }
    }
    
    // now see if we can classify the object data type
    m_objectDataType = kApigeeActivityNoObject;
    
    if (([m_objectType length] > 0) && ([m_objectDisplayName length] > 0) ) {
        
        if (([m_entityType length] > 0) && ([m_entityUUID length] > 0)) {
            m_objectDataType = kApigeeActivityObjectEntity;
            m_objectContent = nil;
        } else if ([m_objectContent length] > 0) {
            m_objectDataType = kApigeeActivityObjectContent;
            m_entityType = nil;
            m_entityUUID = nil;
        } else {
            m_objectDataType = kApigeeActivityObjectNameOnly;
            m_objectContent = nil;
            m_entityType = nil;
            m_entityUUID = nil;
        }
    }
}

@end
