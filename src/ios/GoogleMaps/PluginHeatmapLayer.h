//
//  PluginHeatmapLayer.h
//  cordova-googlemaps-plugin v2
//
//  Created by Pascal Bertschi.
//
//

#import "CordovaGoogleMaps.h"
#import "MyPlgunProtocol.h"
#import "PluginUtil.h"

@interface PluginHeatmapLayer : CDVPlugin<MyPlgunProtocol>
@property (nonatomic) BOOL initialized;

@property (nonatomic, strong) GoogleMapsViewController* mapCtrl;
- (void)create:(CDVInvokedUrlCommand*)command;
- (void)remove:(CDVInvokedUrlCommand *)command;
- (void)setVisible:(CDVInvokedUrlCommand *)command;
- (void)setRadius:(CDVInvokedUrlCommand *)command;

@end
