//
//  ApigeeFunctions.h
//  ApigeeAppMonitor
//
//  Created by Paul Dardeau on 11/23/12.
//  Copyright (c) 2012 Apigee. All rights reserved.
//

#ifndef ApigeeMonitoringClient_ApigeeFunctions_h
#define ApigeeMonitoringClient_ApigeeFunctions_h

typedef struct
{
    uint64_t start_time;
    uint64_t end_time;
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


/*  time  */
uint64_t Apigee_get_current_system_time();


/*  server metrics  */
void Apigee_initialize_server_response_metrics(server_response_metrics *metrics);
void Apigee_free_server_response_metrics(server_response_metrics *metrics);
void Apigee_assign_server_metrics_url(server_response_metrics *metrics, const char *url);
void Apigee_assign_server_metrics_host(server_response_metrics *metrics, const char *host);
void Apigee_assign_server_metrics_protocol(server_response_metrics *metrics, const char *protocol);
void Apigee_assign_server_metrics_service(server_response_metrics *metrics, const char *service);
void Apigee_assign_server_metrics_transaction_details(server_response_metrics *metrics, const char *details);
void Apigee_record_server_response_metrics(const server_response_metrics *metrics);


/*  logging  */
void Apigee_log_assert(const char *tag, const char *message);
void Apigee_log_error(const char *tag, const char *message);
void Apigee_log_warning(const char *tag, const char *message);
void Apigee_log_info(const char *tag, const char *message);
void Apigee_log_debug(const char *tag, const char *message);
void Apigee_log_verbose(const char *tag, const char *message);
int Apigee_is_logging_assert();
int Apigee_is_logging_error();
int Apigee_is_logging_warning();
int Apigee_is_logging_info();
int Apigee_is_logging_debug();
int Apigee_is_logging_verbose();
int Apigee_logging_level();
int Apigee_logging_level_assert();
int Apigee_logging_level_error();
int Apigee_logging_level_warning();
int Apigee_logging_level_info();
int Apigee_logging_level_debug();
int Apigee_logging_level_verbose();


/*  device management  */
const char* Apigee_get_device_identifier();
const char* Apigee_get_device_model();
const char* Apigee_get_device_raw_model();
int Apigee_get_device_battery_level();
uint64_t Apigee_get_time_last_network_transmission();
uint64_t Apigee_get_time_last_upload();


/*  network connectivity status  */
int Apigee_connected();
int Apigee_connected_via_wifi();
int Apigee_connected_via_mobile();


/*  custom config parameters  */
int Apigee_number_custom_config_parameters();
const char* Apigee_get_custom_config_category(int index);
const char* Apigee_get_custom_config_key(int index);
const char* Apigee_get_custom_config_value(int index);


#endif
