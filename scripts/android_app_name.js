#!/usr/bin/env node

module.exports = function(context) {

  var fs = context.requireCordovaModule('fs'),
      path = context.requireCordovaModule('path');

  var platformRoot = path.join(context.opts.projectRoot, 'platforms/android');
  var manifestFile = path.join(platformRoot, 'AndroidManifest.xml');
  var applicationFile = path.join(platformRoot, 'src/cordova/plugin/DonkyApplication.java');
  var appPackage;

  if (fs.existsSync(manifestFile)) {
    fs.readFile(manifestFile, 'utf8', function (err, data) {
      if (err) {
        throw new Error('Unable to find AndroidManifest.xml: ' + err);
      }

      appPackage = data.match(/package="([^"]+)"/)[1];

      var appClass = 'cordova.plugin.DonkyApplication';

      if (data.indexOf(appClass) == -1) {
        var result = data.replace(/<application/g, '<application android:name="' + appClass + '"');
        fs.writeFile(manifestFile, result, 'utf8', function (err) {
          if (err) throw new Error('Unable to write into AndroidManifest.xml: ' + err);
        })
      }
    });
  }

  if (fs.existsSync(applicationFile)) {
    fs.readFile(applicationFile, 'utf8', function (err, data) {
      if (err) {
        throw new Error('Unable to find DonkyApplication.java: ' + err);
      }

      var importRegEx = /import .*\.R;/;

      data = data.replace(importRegEx, "import " + appPackage + ".R;");

      fs.writeFile(applicationFile, data, 'utf8', function (err) {
        if (err) throw new Error('Unable to write into DonkyApplication.java: ' + err);
      })
    });
  }


};