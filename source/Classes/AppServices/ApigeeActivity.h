/*
 * Copyright 2014 Apigee Corporation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import <Foundation/Foundation.h>

#import "ApigeeEntity.h"

/*!
 @class ApigeeActivity
 @abstract Class representing data associated with an activity
 @see ApigeeEntity ApigeeEntity
 */
@interface ApigeeActivity : ApigeeEntity

/*!
 @abstract Compares the specified type name to the type name for ApigeeActivity
 @param type the type name to compare with
 @return boolean indicating whether the specified type name is the same as
 the type name for ApigeeActivity
 */
+ (BOOL)isSameType:(NSString*)type;

/*!
 @abstract
 @param dataClient
 @see ApigeeDataClient ApigeeDataClient
 */
- (id)initWithDataClient:(ApigeeDataClient*)dataClient;

/*!
 @abstract Sets the basic information needed for an activity
 @param verb the action being taken
 @param category The type of activity it is
 @param content The content of this activity. The format is defined by the category
 @param title The title of this category.
 @return boolean indicating whether the method succeeded or not
 @discussion In order for an activity to be valid, you must call setBasics and
    one of the setActor functions. In all cases, the return value will be YES
    if the function succeeded and NO if there was a problem with the set. A
    response of NO will usually mean you sent nil for a required field.
 */
-(BOOL) setBasics:(NSString *)verb
         category:(NSString *)category
          content:(NSString *)content
            title:(NSString *)title;

/*!
 @abstract
 @param actorUserName The username of the entity doing this activity
 @param actorDisplayName The visible name of the entity doing this activity
 @param actorUUID The UUID of the actor doing this activity
 @return
 */
-(BOOL) setActorInfo:(NSString *)actorUserName
    actorDisplayName:(NSString *)actorDisplayName
           actorUUID:(NSString *)actorUUID;

/*!
 @abstract
 @param actorUserName The username of the entity doing this activity
 @param actorDisplayName The visible name of the entity doing this activity
 @param actorEmail The email of the actor doing this activity
 @return
 */
-(BOOL) setActorInfo:(NSString *)actorUserName
    actorDisplayName:(NSString *)actorDisplayName
          actorEmail:(NSString *)actorEmail;

/*!
 @abstract
 @param objectType the type of the object associated with this activity
 @param displayName The visible name of the object associated with this activity
 @param entityType the entity type of this object within UserGrid. The actual type that it is stored under
 @param entityUUID The uuid of the object associated with this activity
 @return
 @discussion Associating an object with the Activity is optional. You don't
    have to supply an object at all.
 */
-(BOOL)setObjectInfo:(NSString *)objectType
         displayName:(NSString *)displayName
          entityType:(NSString *)entityType
          entityUUID:(NSString *)entityUUID;

/*!
 @abstract Similar to setObjectInfo:displayName:entityType:entityUUID:, but it
    takes an arbitrary object content (which can be new and unique) instead of
    an already-defined object
 @param objectType
 @param displayName
 @param objectContent
 @return
 */
-(BOOL)setObjectInfo:(NSString *)objectType
         displayName:(NSString *)displayName
       objectContent:(NSString *)objectContent;

/*!
 @abstract Similar to the other two setObjectInfo: methods, but simply has the
    type and displayName. In this case, the "content" value supplied in
    setBasics will be used as the object content.
 @param objectType
 @param displayName
 @return
 */
-(BOOL)setObjectInfo:(NSString *)objectType
         displayName:(NSString *)displayName;

/*!
 @abstract Determines if the instance was properly set up
 @return YES if this is properly set up. NO if it has not been properly set up
 */
-(BOOL)isValid;

/*!
 @internal
 @abstract turn this object in to an NSDictionary
 @discussion Used internally by ApigeeClient
 */
-(NSDictionary *)toNSDictionary;

/*!
 @internal
 */
-(void)setProperties:(NSDictionary*)dictProperties;

@end
