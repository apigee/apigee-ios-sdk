/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

//composite configuration keys
#define kAppConfigAppId @"instaOpsApplicationId"
#define kAppConfigAppUUID @"applicationUUID"
#define kAppConfigOrgUUID @"organizationUUID"
#define kAppConfigOrgName @"orgName"
#define kAppConfigAppName @"appName"
#define kAppConfigFullAppName @"fullAppName"
#define kAppConfigEnvironment @"environment"
#define kAppConfigAppOwner @"appOwner"
#define kAppConfigAppVersion @"appVersion"
#define kAppConfigDescription @"description"
#define kAppConfigCreatedDate @"createdDate"
#define kAppConfigLastModifiedDate @"lastModifiedDate"
#define kAppConfigGoogleId @"googleId"
#define kAppConfigAppleId @"appleId"

#define kAppConfigEnableDeviceLevelOverride @"deviceLevelOverrideEnabled"
#define kAppConfigEnableDeviceTypeOverride @"deviceTypeOverrideEnabled"
#define kAppConfigEnableABTesting @"abtestingOverrideEnabled"

#define kAppConfigDeviceLevel @"deviceLevelAppConfig"
#define kAppConfigDeviceType @"deviceTypeAppConfig"
#define kAppConfigABTesting @"abtestingAppConfig"
#define kAppConfigDefault @"defaultAppConfig"

#define kAppConfigABTestingPercentage @"abtestingPercentage"

#define kAppConfigMonitorDisabled @"monitoringDisabled"
#define kAppConfigDeviceNumberFilters @"deviceNumberFilters"
#define kAppConfigDeviceIdFilters @"deviceIdFilters"


#define kAppConfigModelRegexFilters @"deviceModelRegexFilters"
#define kAppConfigPlatformRegexFilters @"devicePlatformRegexFilters"
#define kAppConfigNetworkTypeRegexFilters @"networkTypeRegexFilters"
#define kAppConfigNetworkOperatorRegexFilters @"networkOperatorRegexFilters"

#define kAppConfigCustomUploadUrl @"customUploadUrl"
#define kAppConfigDeleted @"deleted"

//filter config keys
#define kAppConfigFilterId @"id"
#define kAppConfigFilterType @"filterType"
#define kAppConfigFilterValue @"filterValue"

//custom paramter keys
#define kAppConfigCustomParamId @"id"
#define kAppConfigCustomParamTag @"tag"
#define kAppConfigCustomParamKey @"paramKey"
#define kAppConfigCustomParamValue @"paramValue"

//network config keys
#define kAppConfigNetowrkConfigId @"id"
#define kAppConfigNetowrkHueristicCachingEnabled @"heuristicCachingEnabled"
#define kAppConfigNetowrkHueristicCoefficient @"heuristicCoefficient"
#define kAppConfigNetowrkHueristicDefaultLifeTime @"heuristicDefaultLifetime"
#define kAppConfigNetowrkSharedCache @"isSharedCache"
#define kAppConfigNetworkMaxCacheEntries @"maxCacheEntries"
#define kAppConfigNetowrkMaxObjectSize @"maxObjectSizeBytes"
#define kAppConfigNetowrkMaxUpdateRetries @"maxUpdateRetries"

//app monitor settings config keys
#define kAppConfigOverrideAppConfigId @"appConfigId"
#define kAppConfigOverrideConfigType @"appConfigType"
#define kAppConfigOverrideDescription @"description"
#define kAppConfigOverrideLastModifiedDate @"lastModifiedDate"
#define kAppConfigOverrideUrlRegex @"urlRegex"
#define kAppConfigOverrideEnableNetworkMonitor @"networkMonitoringEnabled"
#define kAppConfigOverrideLogLevel @"logLevelToMonitor"
#define kAppConfigOverrideEnableLogMonitor @"enableLogMonitoring"

#define kAppConfigOverrideCustomParams @"customConfigParameters"

#define kAppConfigOverrideNetowrkConfig @"cacheConfig"

#define kAppConfigOverrideEnableCaching @"cachingEnabled"
#define kAppConfigOverrideMonitorAllUrls @"monitorAllUrls"
#define kAppConfigOverrideCaptureSessionMetrics @"sessionDataCaptureEnabled"

#define kAppConfigOverrideCaptureBatterStatus @"batteryStatusCaptureEnabled"
#define kAppConfigOverrideCaptureIMEI @"imeicaptureEnabled"
#define kAppConfigOverrideObfuscateIMEI @"obfuscateIMEI"
#define kAppConfigOverrideCaptureDeviceId @"deviceIdCaptureEnabled"
#define kAppConfigOverrideCaptureDeviceModel @"deviceModelCaptureEnabled"
#define kAppConfigOverrideCaptureNetworkCarrier @"networkCarrierCaptureEnabled"
#define kAppConfigOverrideCaptureLocation @"locationCaptureEnabled"
#define kAppConfigOverrideCaptureLocationResolution @"locationCaptureResolution"
#define kAppConfigOverrideUploadWhenRoaming @"enableUploadWhenRoaming"
#define kAppConfigOverrideUploadWhenMobile @"enableUploadWhenMobile"
#define kAppConfigOverrideUploadInterval @"agentUploadInterval"
#define kAppConfigOverrideUploadIntervalSeconds @"agentUploadIntervalInSeconds"
#define kAppConfigOverrideSampleRate @"samplingRate"

#define kAppConfigOverrideFilters @"appConfigOverrideFilters"
