//
//  PluginHeatmapLayer.m
//  cordova-googlemaps-plugin v2
//
//  Created by Pascal Bertschi.
//
//

#import "PluginHeatmapLayer.h"
#import <GoogleMaps/GoogleMaps.h>
#import "GMUHeatmapTileLayer.h"
#import "GMUWeightedLatLng.h"

@implementation PluginHeatmapLayer
- (void)pluginInitialize
{
    if (self.initialized) {
        return;
    }
    [super pluginInitialize];
}

- (void)pluginUnload
{
    NSString *pluginId = [NSString stringWithFormat:@"%@-heatmaplayer", self.mapCtrl.mapId];
    CDVViewController *cdvViewController = (CDVViewController*)self.viewController;
    [cdvViewController.pluginObjects removeObjectForKey:pluginId];
    [cdvViewController.pluginsMap setValue:nil forKey:pluginId];
    pluginId = nil;
}

-(void)setGoogleMapsViewController:(GoogleMapsViewController *)viewCtrl
{
    self.mapCtrl = viewCtrl;
}

- (NSMutableArray<GMUWeightedLatLng *>*) parseData:(NSDictionary *)json
{
    NSArray *data = [json objectForKey:@"data"];
    
    NSMutableArray<GMUWeightedLatLng *> *items = [[NSMutableArray alloc] init];
    if (data) {
        NSDictionary *latLng;
        for (int i = 0; i < data.count; i++) {
            latLng = [data objectAtIndex:i];
            GMUWeightedLatLng *item =
            [[GMUWeightedLatLng alloc] initWithCoordinate:CLLocationCoordinate2DMake([[latLng objectForKey:@"lat"] floatValue], [[latLng objectForKey:@"lng"] floatValue])
                                                intensity:1.0];
            items[i] = item;
        }
    }
    
    return items;
}

-(void)create:(CDVInvokedUrlCommand *)command
{
    PluginHeatmapLayer *self_ = self;
    
    NSDictionary *json = [command.arguments objectAtIndex:1];
    NSMutableArray<GMUWeightedLatLng *> *items = [self parseData: json];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        GMUHeatmapTileLayer *heatmapLayer = [[GMUHeatmapTileLayer alloc] init];
        
        NSString *idBase = [NSString stringWithFormat:@"%lu%d", command.hash, arc4random() % 100000];
        NSString *heatmapId = [NSString stringWithFormat:@"heatmaplayer_%@", idBase];
        [self.mapCtrl.objects setObject:heatmapLayer forKey: heatmapId];
        
        if ([json valueForKey:@"radius"]) {
            heatmapLayer.radius = [[json valueForKey:@"radius"] intValue];
        }
        
        heatmapLayer.weightedData = items;
        
        BOOL isVisible = YES;
        
        // Visible property
        NSString *visibleValue = [NSString stringWithFormat:@"%@",  json[@"visible"]];
        if ([@"0" isEqualToString:visibleValue]) {
            // false
            isVisible = NO;
            heatmapLayer.map = nil;
        } else {
            // true or default
            heatmapLayer.map = self.mapCtrl.map;
        }
        
        
        NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
        [result setObject:heatmapId forKey:@"id"];
        
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:result];
        [self_.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    });
    
}

-(void)remove:(CDVInvokedUrlCommand *)command
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        NSString *heatmapLayerId = [command.arguments objectAtIndex:0];
        GMUHeatmapTileLayer *heatmap = [self.mapCtrl.objects objectForKey:heatmapLayerId];
        
        heatmap.map = nil;
        heatmap = nil;
        [self.mapCtrl.objects removeObjectForKey:heatmapLayerId];
        
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}


/**
 * Set visibility
 * @params key
 */
-(void)setVisible:(CDVInvokedUrlCommand *)command
{
    
    [self.mapCtrl.executeQueue addOperationWithBlock:^{
        
        NSString *key = [command.arguments objectAtIndex:0];
        GMUHeatmapTileLayer *heatmap = [self.mapCtrl.objects objectForKey:key];
        Boolean isVisible = [[command.arguments objectAtIndex:1] boolValue];
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            if (isVisible) {
                heatmap.map = self.mapCtrl.map;
            } else {
                heatmap.map = nil;
            }
            
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }];
        
    }];
}

-(void)setRadius:(CDVInvokedUrlCommand *)command
{
    [self.mapCtrl.executeQueue addOperationWithBlock:^{
        NSString *key = [command.arguments objectAtIndex:0];
        GMUHeatmapTileLayer *heatmap = [self.mapCtrl.objects objectForKey:key];
        NSUInteger radius = [[command.arguments objectAtIndex:1] intValue];
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            heatmap.radius = radius;
            heatmap.map = heatmap.map;
            
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }];
    }];
}

-(void)setData:(CDVInvokedUrlCommand *)command
{
    [self.mapCtrl.executeQueue addOperationWithBlock:^{
        NSString *key = [command.arguments objectAtIndex:0];
        GMUHeatmapTileLayer *heatmap = [self.mapCtrl.objects objectForKey:key];
        NSDictionary* json = [command.arguments objectAtIndex:1];
        NSMutableArray<GMUWeightedLatLng *> *items = [self parseData:json];
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            heatmap.weightedData = items;
            heatmap.map = heatmap.map;
            
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }];
    }];
}

@end

