//
//  ApigeeFunctions.m
//  ApigeeAppMonitor
//
//  Copyright (c) 2012 Apigee. All rights reserved.
//

#include <stdio.h>
#include <string.h>

#import "ApigeeFunctions.h"
#import "ApigeeMonitoringClient.h"
#import "ApigeeActiveSettings.h"
#import "ApigeeLogger.h"
#import "UIDevice+Apigee.h"
#import "ApigeeOpenUDID.h"
#import "ApigeeCustomConfigParam.h"
#import "ApigeeNetworkEntry.h"
#import "ApigeeQueue+NetworkMetrics.h"


ApigeeMonitoringClient* Apigee_monitoring_client();
ApigeeActiveSettings* Apigee_active_settings();
void Apigee_assign_server_metrics_string(char **metrics_variable,
                                       const char *metrics_value);
int valid_seconds_time(CFTimeInterval secondsTime);
int have_string_value(const char *value);
int have_non_empty_string_value(const char *value);


ApigeeMonitoringClient* Apigee_monitoring_client()
{
    return [ApigeeMonitoringClient sharedInstance];
}

ApigeeActiveSettings* Apigee_active_settings()
{
    ApigeeMonitoringClient *monitoringClient = Apigee_monitoring_client();
    if (monitoringClient) {
        return monitoringClient.activeSettings;
    } else {
        return nil;
    }
}

CFTimeInterval Apigee_get_current_system_time()
{
    return CACurrentMediaTime();
}

/**************************  server metrics  **********************************/
void Apigee_initialize_server_response_metrics(server_response_metrics *metrics)
{
    memset(metrics,0,sizeof(server_response_metrics));
}

void Apigee_free_server_response_metrics(server_response_metrics *metrics)
{
    if (metrics->url) {
        free(metrics->url);
        metrics->url = NULL;
    }
    
    if (metrics->host) {
        free(metrics->host);
        metrics->host = NULL;
    }
    
    if (metrics->protocol) {
        free(metrics->protocol);
        metrics->protocol = NULL;
    }
    
    if (metrics->service) {
        free(metrics->service);
        metrics->service = NULL;
    }
    
    if (metrics->transactionDetails) {
        free(metrics->transactionDetails);
        metrics->transactionDetails = NULL;
    }
}

void Apigee_assign_server_metrics_string(char **metrics_variable,
                                       const char *metrics_value)
{
    if (metrics_variable) {
        
        if (*metrics_variable) {
            free(*metrics_variable);
            *metrics_variable = NULL;
        }

        size_t metrics_value_length = 0;
        
        if (metrics_value) {
            metrics_value_length = strlen(metrics_value);
            *metrics_variable = malloc(metrics_value_length+1);
            memcpy(*metrics_variable,metrics_value,metrics_value_length+1);
        }
    }
}

void Apigee_assign_server_metrics_url(server_response_metrics *metrics,
                                    const char *url)
{
    Apigee_assign_server_metrics_string(&metrics->url, url);
}

void Apigee_assign_server_metrics_host(server_response_metrics *metrics,
                                     const char *host)
{
    Apigee_assign_server_metrics_string(&metrics->host, host);
}

void Apigee_assign_server_metrics_protocol(server_response_metrics *metrics,
                                         const char *protocol)
{
    Apigee_assign_server_metrics_string(&metrics->protocol, protocol);
}

void Apigee_assign_server_metrics_service(server_response_metrics *metrics,
                                        const char *service)
{
    Apigee_assign_server_metrics_string(&metrics->service, service);
}

void Apigee_assign_server_metrics_transaction_details(server_response_metrics *metrics,
                                                    const char *details)
{
    Apigee_assign_server_metrics_string(&metrics->transactionDetails, details);
}

int have_string_value(const char *value)
{
    return (value != NULL);
}

int valid_seconds_time(CFTimeInterval secondsTime)
{
    return secondsTime > 0;
}

int have_non_empty_string_value(const char *value)
{
    if (value != NULL) {
        return strlen(value) > 0;
    } else {
        return 0;
    }
}

void Apigee_record_server_response_metrics(const server_response_metrics *metrics)
{
    // first, verify that we have required fields
    if ( !valid_seconds_time(metrics->start_time) ||
         !valid_seconds_time(metrics->end_time) ||
         (!have_non_empty_string_value(metrics->url) &&
         !have_non_empty_string_value(metrics->host)) ) {
        return;
    }
    
    ApigeeMonitoringClient *monitoringClient = Apigee_monitoring_client();
    
    if (!monitoringClient) {
        return;
    }
    
    if ([monitoringClient isPaused]) {
        NSLog(@"Not capturing network metrics -- paused");
        return;
    }
    
    // next, convert data types for Objective-C
    NSString *url;
    
    if (have_non_empty_string_value(metrics->url)) {
        url = [NSString stringWithUTF8String:metrics->url];
    } else {
        NSMutableString *nonHttpUrl = [[NSMutableString alloc] init];
        
        if (have_non_empty_string_value(metrics->protocol)) {
            [nonHttpUrl appendFormat:@"%s://", metrics->protocol];
        }
        
        [nonHttpUrl appendFormat:@"%s", metrics->host];

        if (metrics->port > 0) {
            [nonHttpUrl appendFormat:@":%d",
             metrics->port];
        }
        
        if (have_non_empty_string_value(metrics->service)) {
            [nonHttpUrl appendFormat:@"/%s", metrics->service];
        }
        
        url = nonHttpUrl;
    }

    ApigeeNetworkEntry *entry = [[ApigeeNetworkEntry alloc] init];
    [entry populateWithURLString:url];
    [entry populateStartTime:metrics->start_time ended:metrics->end_time];
    
    if (metrics->http_status_code > 0) {
        entry.httpStatusCode = [NSString stringWithFormat:@"%d",
                                metrics->http_status_code];
    } else {
        entry.httpStatusCode = nil;
    }
    
    if (metrics->response_size > 0) {
        entry.responseDataSize = [NSString stringWithFormat:@"%d",  // %ld??
                                  metrics->response_size];
    }
    
    if (metrics->error_occurred) {
        entry.numErrors = @"1";
    } else {
        entry.numErrors = @"0";
    }
    
    if (have_non_empty_string_value(metrics->transactionDetails)) {
        entry.transactionDetails =
            [NSString stringWithUTF8String:metrics->transactionDetails];
    }
    
    [monitoringClient recordNetworkEntry:entry];
}


/******************************  logging  *************************************/
void Apigee_log_assert(const char *tag, const char *message)
{
    NSString *theTag = nil;
    NSString *theMessage = nil;
    
    if (tag) {
        theTag = [NSString stringWithUTF8String:tag];
    }
    
    if (message) {
        theMessage = [NSString stringWithUTF8String:message];
    }
    
    ApigeeLogAssertMessage(theTag, theMessage);
}

void Apigee_log_error(const char *tag, const char *message)
{
    NSString *theTag = nil;
    NSString *theMessage = nil;
    
    if (tag) {
        theTag = [NSString stringWithUTF8String:tag];
    }
    
    if (message) {
        theMessage = [NSString stringWithUTF8String:message];
    }
    
    ApigeeLogErrorMessage(theTag, theMessage);
}

void Apigee_log_warning(const char *tag, const char *message)
{
    NSString *theTag = nil;
    NSString *theMessage = nil;
    
    if (tag) {
        theTag = [NSString stringWithUTF8String:tag];
    }
    
    if (message) {
        theMessage = [NSString stringWithUTF8String:message];
    }
    
    ApigeeLogWarnMessage(theTag, theMessage);
}

void Apigee_log_info(const char *tag, const char *message)
{
    NSString *theTag = nil;
    NSString *theMessage = nil;
    
    if (tag) {
        theTag = [NSString stringWithUTF8String:tag];
    }
    
    if (message) {
        theMessage = [NSString stringWithUTF8String:message];
    }
    
    ApigeeLogInfoMessage(theTag, theMessage);
}

void Apigee_log_debug(const char *tag, const char *message)
{
    NSString *theTag = nil;
    NSString *theMessage = nil;
    
    if (tag) {
        theTag = [NSString stringWithUTF8String:tag];
    }
    
    if (message) {
        theMessage = [NSString stringWithUTF8String:message];
    }
    
    ApigeeLogDebugMessage(theTag, theMessage);
}

void Apigee_log_verbose(const char *tag, const char *message)
{
    NSString *theTag = nil;
    NSString *theMessage = nil;
    
    if (tag) {
        theTag = [NSString stringWithUTF8String:tag];
    }
    
    if (message) {
        theMessage = [NSString stringWithUTF8String:message];
    }
    
    ApigeeLogVerboseMessage(theTag, theMessage);
}

int Apigee_logging_level()
{
    ApigeeActiveSettings *activeSettings = Apigee_active_settings();
    if (activeSettings) {
        return (int) activeSettings.logLevelToMonitor;
    } else {
        return 0;
    }
}

int Apigee_is_logging_assert()
{
    return (Apigee_logging_level() <= kApigeeLogLevelAssert);
}

int Apigee_is_logging_error()
{
    return (Apigee_logging_level() <= kApigeeLogLevelError);
}

int Apigee_is_logging_warning()
{
    return (Apigee_logging_level() <= kApigeeLogLevelWarn);
}

int Apigee_is_logging_info()
{
    return (Apigee_logging_level() <= kApigeeLogLevelInfo);
}

int Apigee_is_logging_debug()
{
    return (Apigee_logging_level() <= kApigeeLogLevelDebug);
}

int Apigee_is_logging_verbose()
{
    return (Apigee_logging_level() <= kApigeeLogLevelVerbose);
}

int Apigee_logging_level_assert()
{
    return kApigeeLogLevelAssert;
}

int Apigee_logging_level_error()
{
    return kApigeeLogLevelError;
}

int Apigee_logging_level_warning()
{
    return kApigeeLogLevelWarn;
}

int Apigee_logging_level_info()
{
    return kApigeeLogLevelInfo;
}

int Apigee_logging_level_debug()
{
    return kApigeeLogLevelDebug;
}

int Apigee_logging_level_verbose()
{
    return kApigeeLogLevelVerbose;
}


/**************************  device management  *******************************/
const char* Apigee_get_device_identifier()
{
    NSString *apigeeDeviceId = [ApigeeOpenUDID value];
    if (apigeeDeviceId) {
        return [apigeeDeviceId UTF8String];
    } else {
        return NULL;
    }
}

const char* Apigee_get_device_model()
{
    NSString *platformModel = [UIDevice platformStringDescriptive];
    if (platformModel) {
        return [platformModel UTF8String];
    } else {
        return NULL;
    }
}

const char* Apigee_get_device_raw_model()
{
    NSString *platformRawModel = [UIDevice platformStringRaw];
    if (platformRawModel) {
        return [platformRawModel UTF8String];
    } else {
        return NULL;
    }
}

int Apigee_get_device_battery_level()
{
    return (100 * [[UIDevice currentDevice] batteryLevel]);
}

CFTimeInterval Apigee_get_time_last_network_transmission()
{
    ApigeeMonitoringClient *monitoringClient = Apigee_monitoring_client();
    if (monitoringClient) {
        return [monitoringClient timeLastNetworkTransmission];
    }
    
    return 0;
}

CFTimeInterval Apigee_get_time_last_upload()
{
    ApigeeMonitoringClient *monitoringClient = Apigee_monitoring_client();
    if (monitoringClient) {
        return [monitoringClient timeLastUpload];
    }
    
    return 0;
}


/*****************************  response time  ********************************/
/*
void Apigee_record_timing(const char *tag,
                        const char *domain,
                        const char *operation,
                        uint64_t start_time,
                        uint64_t end_time)
{
    //TODO: implement
}
*/

/***************************  event tracking  *********************************/
/*
void Apigee_record_event(const char *tag,
                       const char *domain,
                       const char *event,
                       const char *description,
                       uint64_t event_time)
{
    //TODO: implement
}
*/

/*********************  network connectivity status  **************************/
int Apigee_connected()
{
    ApigeeActiveSettings *activeSettings = Apigee_active_settings();
    if (activeSettings && (activeSettings.activeNetworkStatus != Apigee_NotReachable)) {
        return 1;
    }
    
    return 0;
}

int Apigee_connected_via_wifi()
{
    ApigeeActiveSettings *activeSettings = Apigee_active_settings();
    if (activeSettings && (activeSettings.activeNetworkStatus == Apigee_ReachableViaWiFi)) {
        return 1;
    }
    
    return 0;
}

int Apigee_connected_via_mobile()
{
    ApigeeActiveSettings *activeSettings = Apigee_active_settings();
    if (activeSettings && (activeSettings.activeNetworkStatus == Apigee_ReachableViaWWAN)) {
        return 1;
    }
    
    return 0;
}


/***********************  custom config parameters  ***************************/
NSUInteger Apigee_number_custom_config_parameters()
{
    ApigeeActiveSettings *activeSettings = Apigee_active_settings();
    if (activeSettings) {
        NSArray *settings = activeSettings.customConfigParams;
        return [settings count];
    } else {
        return 0;
    }
}

ApigeeCustomConfigParam* Apigee_custom_config_param_for_index(int index)
{
    ApigeeActiveSettings *activeSettings = Apigee_active_settings();
    if (activeSettings) {
        NSArray *settings = activeSettings.customConfigParams;
        if (settings) {
            return [settings objectAtIndex:index];
        } else {
            return NULL;
        }
    } else {
        return NULL;
    }
}

const char* Apigee_get_custom_config_category(int index)
{
    ApigeeCustomConfigParam *customConfigParm =
        Apigee_custom_config_param_for_index(index);
    if (customConfigParm) {
        return [customConfigParm.category UTF8String];
    }
    
    return NULL;
}

const char* Apigee_get_custom_config_key(int index)
{
    ApigeeCustomConfigParam *customConfigParm =
        Apigee_custom_config_param_for_index(index);
    if (customConfigParm) {
        return [customConfigParm.key UTF8String];
    }
    
    return NULL;
}

const char* Apigee_get_custom_config_value(int index)
{
    ApigeeCustomConfigParam *customConfigParm =
        Apigee_custom_config_param_for_index(index);
    if (customConfigParm) {
        return [customConfigParm.value UTF8String];
    }
    
    return NULL;
}
