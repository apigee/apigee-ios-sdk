//
//  ApigeeFunctions.h
//  ApigeeAppMonitor
//
//  Copyright (c) 2012 Apigee. All rights reserved.
//

#ifndef ApigeeMonitoringClient_ApigeeFunctions_h
#define ApigeeMonitoringClient_ApigeeFunctions_h

/*!
 @struct server_response_metrics
 @abstract Record for storing all performance metrics associated with a single
    network call
 @field start_time The time when the network call is started.
 @field end_time The time when the network call ends.
 @field url The URL for the network request.
 @field host The server (host) for the network request.
 @field port The port associated with the network request.
 @field protocol The protocol associated with the network request.
 @field service The service associated with the network request.
 @field response_size The response size of the server's response payload.
 @field http_status_code The status code for the request (if HTTP or HTTPS)
 @field error_occurred 1 if an error occurred, 0 otherwise
 @field transactionDetails Human readable details of any error that may have occurred
 */
typedef struct
{
    CFTimeInterval start_time;
    CFTimeInterval end_time;
    char *url;
    char *host;
    uint16_t port;
    char *protocol;
    char *service;
    uint32_t response_size;
    uint16_t http_status_code;
    int error_occurred;
    char *transactionDetails;
} server_response_metrics;


//******************************************************************************
/*!
 @functiongroup Network Performance Metrics Functions
 */
//******************************************************************************

/*!
 @abstract Initialize a network performance metrics record with default values
 @param metrics the record to initialize
 */
void Apigee_initialize_server_response_metrics(server_response_metrics *metrics);

/*!
 @abstract Cleans up any dynamically allocated memory in metrics record
 @param metrics the record to clean up
 */
void Apigee_free_server_response_metrics(server_response_metrics *metrics);

/*!
 @abstract Assigns the URL for the metrics record
 @param metrics the record that is receiving the value
 @param url the value being assigned
 */
void Apigee_assign_server_metrics_url(server_response_metrics *metrics, const char *url);

/*!
 @abstract Assigns the server (host) for the metrics record
 @param metrics the record that is receiving the value
 @param host the value being assigned
 */
void Apigee_assign_server_metrics_host(server_response_metrics *metrics, const char *host);

/*!
 @abstract Assigns the protocol (e.g. "http") for the metrics record
 @param metrics the record that is receiving the value
 @param protocol the value being assigned
 */
void Apigee_assign_server_metrics_protocol(server_response_metrics *metrics, const char *protocol);

/*!
 @abstract Assigns the service (everything is URL after the host) for the metrics record
 @param metrics the record that is receiving the value
 @param service the value being assigned
 */
void Apigee_assign_server_metrics_service(server_response_metrics *metrics, const char *service);

/*!
 @abstract Assigns the transaction details for the metrics record
 @param metrics the record that is receiving the value
 @param details the value being assigned
 */
void Apigee_assign_server_metrics_transaction_details(server_response_metrics *metrics, const char *details);

/*!
 @abstract Records the network performance metrics for the specified record
 @param metrics the metrics record to record
 */
void Apigee_record_server_response_metrics(const server_response_metrics *metrics);


//******************************************************************************
/*!
 @functiongroup Logging Functions
 */
//******************************************************************************

/*!
 @abstract Logs an assert (critical) error
 @param tag the component or layer associated with the error
 @param message the error message to log
 */
void Apigee_log_assert(const char *tag, const char *message);

/*!
 @abstract Logs an error
 @param tag the component or layer associated with the error
 @param message the error message to log
 */
void Apigee_log_error(const char *tag, const char *message);

/*!
 @abstract Logs a warning log message
 @param tag the component or layer associated with the message
 @param message the message to log
 */
void Apigee_log_warning(const char *tag, const char *message);

/*!
 @abstract Logs an info log message
 @param tag the component or layer associated with the message
 @param message the message to log
 */
void Apigee_log_info(const char *tag, const char *message);

/*!
 @abstract Logs a debug log message
 @param tag the component or layer associated with the message
 @param message the message to log
 */
void Apigee_log_debug(const char *tag, const char *message);

/*!
 @abstract Logs a verbose log message
 @param tag the component or layer associated with the message
 @param message the message to log
 */
void Apigee_log_verbose(const char *tag, const char *message);

/*!
 @abstract Determines whether assert (critical) errors are being captured
 @return 1 if they're being captured, 0 otherwise
 */
int Apigee_is_logging_assert();

/*!
 @abstract Determines whether errors are being captured
 @return 1 if they're being captured, 0 otherwise
 */
int Apigee_is_logging_error();

/*!
 @abstract Determines whether warning messages are being captured
 @return 1 if they're being captured, 0 otherwise
 */
int Apigee_is_logging_warning();

/*!
 @abstract Determines whether info messages are being captured
 @return 1 if they're being captured, 0 otherwise
 */
int Apigee_is_logging_info();

/*!
 @abstract Determines whether debug messages are being captured
 @return 1 if they're being captured, 0 otherwise
 */
int Apigee_is_logging_debug();

/*!
 @abstract Determines whether verbose messages are being captured
 @return 1 if they're being captured, 0 otherwise
 */
int Apigee_is_logging_verbose();

/*!
 @abstract Retrieves the numeric value of the current log level
 @return numeric value of current log level
 */
int Apigee_logging_level();

/*!
 @abstract Retrieves the numeric value of the assert log level
 @return numeric value of assert log level
 */
int Apigee_logging_level_assert();

/*!
 @abstract Retrieves the numeric value of the error log level
 @return numeric value of error log level
 */
int Apigee_logging_level_error();

/*!
 @abstract Retrieves the numeric value of the warning log level
 @return numeric value of warning log level
 */
int Apigee_logging_level_warning();

/*!
 @abstract Retrieves the numeric value of the info log level
 @return numeric value of info log level
 */
int Apigee_logging_level_info();

/*!
 @abstract Retrieves the numeric value of the debug log level
 @return numeric value of debug log level
 */
int Apigee_logging_level_debug();

/*!
 @abstract Retrieves the numeric value of the verbose log level
 @return numeric value of verbose log level
 */
int Apigee_logging_level_verbose();


//******************************************************************************
/*!
 @functiongroup Device Metadata Functions
 */
//******************************************************************************

/*!
 @abstract Retrieves the device identifier for the current device
 @return the device identifier
 */
const char* Apigee_get_device_identifier();

/*!
 @abstract Retrieves the device model (human readable) for the current device
 @return the device model
 */
const char* Apigee_get_device_model();

/*!
 @abstract Retrieves the 'raw' (as reported) device model for the current device
 @return the device model
 */
const char* Apigee_get_device_raw_model();

/*!
 @abstract Retrieves the device battery level
 @return battery level for the device
 @discussion the value from this function is not meaningful when running on simulator
 */
int Apigee_get_device_battery_level();


//******************************************************************************
/*!
 @functiongroup Time Management Functions
 */
//******************************************************************************

/*!
 @abstract Retrieves the time of the last known network transmission (of any kind) within the application
 @return time of last known network transmission
 */
CFTimeInterval Apigee_get_time_last_network_transmission();

/*!
 @abstract Retrieves the time of the last upload of metrics to server
 @return time of last metrics upload
 */
CFTimeInterval Apigee_get_time_last_upload();

/*!
 @abstract Retrieves current system time
 @return current system time
 */
CFTimeInterval Apigee_get_current_system_time();


//******************************************************************************
/*!
 @functiongroup Network Connectivity Functions
 */
//******************************************************************************

/*!
 @abstract Determines if device is currently network connected (any type)
 @return 1 if network connected, 0 otherwise
 */
int Apigee_connected();

/*!
 @abstract Determines if device is currently network connected via Wifi
 @return 1 if network connected via Wifi, 0 otherwise
 */
int Apigee_connected_via_wifi();

/*!
 @abstract Determines if device is currently network connected via cellular
 @return 1 if network connected via cellular, 0 otherwise
 */
int Apigee_connected_via_mobile();


//******************************************************************************
/*!
 @functiongroup Custom Configuration Functions
 */
//******************************************************************************

/*!
 @abstract Retrieves number of custom config parameters available in configuration data
 @return number of custom config parameters
 */
NSUInteger Apigee_number_custom_config_parameters();

/*!
 @abstract Retrieves the category for the specified (0-based) parameter
 @return category name for the parameter
 */
const char* Apigee_get_custom_config_category(int index);

/*!
 @abstract Retrieves the key for the specified (0-based) parameter
 @return key name for the parameter
 */
const char* Apigee_get_custom_config_key(int index);

/*!
 @abstract Retrieves the value for the specified (0-based) parameter
 @return value for the parameter
 */
const char* Apigee_get_custom_config_value(int index);


#endif
