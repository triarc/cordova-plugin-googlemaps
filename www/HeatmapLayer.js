var argscheck = require('cordova/argscheck'),
    utils = require('cordova/utils'),
    common = require('./Common'),
    BaseClass = require('./BaseClass');

/*****************************************************************************
* HeatmapLayer Class
*****************************************************************************/    
var exec;
var HeatmapLayer = function(map, overlayId, data, _exec) {
  BaseClass.apply(this);
  exec = _exec;

  var self = this;
  Object.defineProperty(self, "id", {
     value: overlayId,
     writable: false
  });
  Object.defineProperty(self, "type", {
     value: "HeatmapLayer",
     writable: false
  });

  //-----------------------------------------------
  // Sets event listeners
  //-----------------------------------------------
  self.on("visible_changed", function() {
      var visible = self.get("visible");
      exec.call(self, null, self.errorHandler, self.getPluginName(), 'setVisible', [self.getId(), visible]);
  });

  self.on("data_changed", function() {
      var data = self.get("data");
      exec.call(self, null, self.errorHandler, self.getPluginName(), 'setData', [self.getId(), data]);
  });

  self.on("map_changed", function() {
      var map = self.get("map");
      exec.call(self, null, self.errorHandler, self.getPluginName(), 'setMap', [self.getId(), map]);
  });

  self.on("radius_changed", function() {
      var radius = self.get("radius");
      exec.call(self, null, self.errorHandler, self.getPluginName(), 'setRadius', [self.getId(), radius]);
  });

  self.on("gradient_changed", function() {
      var gradient = self.get("gradient");
      exec.call(self, null, self.errorHandler, self.getPluginName(), 'setGradient', [self.getId(), gradient]);
  });

}

utils.extend(HeatmapLayer, BaseClass);

HeatmapLayer.prototype.getPluginName = function() {
    return this.map.getId() + "-heatmaplayer";
};

HeatmapLayer.prototype.getHashCode = function() {
    return this.hashCode;
};

HeatmapLayer.prototype.getMap = function() {
    return this.map;
};

HeatmapLayer.prototype.getId = function() {
    return this.id;
};

HeatmapLayer.prototype.setData = function(data) {
    this.set('data', data);
};

HeatmapLayer.prototype.setRadius = function(radius) {
    this.set('radius', radius);
};

HeatmapLayer.prototype.setGradient = function(gradient) {
    this.set('gradient', gradient);
};

HeatmapLayer.prototype.setVisible = function(visible) {
    this.set('visible', visible);
};

HeatmapLayer.prototype.getVisible = function() {
    return this.get('visible');
};

module.exports = HeatmapLayer;