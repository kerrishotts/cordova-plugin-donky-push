#!/usr/bin/env node
module.exports = function(context) {

  function log(msg){
    if(context.opts.verbose) console.log(msg);
  }

  function getProjectName(configXml){
    return configXml.match(/<name>([^<]+)</i)[1];
  }

  log("Running ios_inject_api_key.js in context '"+context.hook+"'");

  var apiKeyPreferenceRegExp = /<preference name="DONKY_API_KEY" value="([^"]+)" \/>/;

  var fs = context.requireCordovaModule('fs'),
      path = context.requireCordovaModule('path'),
      plist = context.requireCordovaModule('plist');

  var configXmlFile = path.resolve(context.opts.projectRoot, "config.xml");

  if (!fs.existsSync(configXmlFile)) {
    throw new Error('Unable to find config.xml');
  }

  fs.readFile(configXmlFile, 'utf8', function (err,configXml) {
    if (err) {
      throw new Error('Unable to read config.xml: ' + err);
    }

    log("Read config.xml: "+configXmlFile);

    var matches = configXml.match(apiKeyPreferenceRegExp);
    if (!matches) {
      throw new Error('API key preference not found in config.xml. Please add it in the form: <preference name="DONKY_API_KEY" value="{YOUR_API_KEY}" />');
    }
    var apiKey = matches[1];
    log("Found API Key: "+apiKey);

    var projectName = getProjectName(configXml);

    var plistFile = path.resolve(context.opts.projectRoot, "platforms", "ios", projectName, projectName+"-Info.plist");
    if (!fs.existsSync(plistFile)) {
      throw new Error('Unable to find .plist');
    }

    fs.readFile(plistFile, 'utf8', function (err,plistXml) {
      if (err) {
        throw new Error('Unable to read .plist: ' + err);
      }

      log("Read .plist: "+plistFile);

      var obj_plist = plist.parse(plistXml);
      obj_plist["DonkyApiKey"] = [apiKey];
      plistXml = plist.build(obj_plist);

      fs.writeFile(plistFile, plistXml, 'utf8', function (err) {
        if (err) throw new Error('Unable to write to .plist: ' + err);
        log("Successfully wrote Donky API key from config.xml to iOS .plist");
      })
    });
  });

};