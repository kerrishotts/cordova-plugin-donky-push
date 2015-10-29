#!/usr/bin/env node
module.exports = function(context) {


  function getProjectName(configXml){
    return configXml.match(/<name>([^<]+)</i)[1];
  }

  var apiKeyPrefeferenceRegExp = /<preference name="DONKY_API_KEY" value="([^"]+)" \/>/;

  var fs = context.requireCordovaModule('fs'),
      path = context.requireCordovaModule('path');

  var configXmlFile = path.resolve(context.opts.projectRoot, "config.xml");

  if (!fs.existsSync(configXmlFile)) {
    throw new Error('Unable to find config.xml');
  }

  fs.readFile(configXmlFile, 'utf8', function (err,configXml) {
    if (err) {
      throw new Error('Unable to read config.xml: ' + err);
    }

    var matches = configXml.match(apiKeyPrefeferenceRegExp);
    if (!matches) {
      throw new Error('API key preference not found in config.xml. Please add it in the form: <preference name="DONKY_API_KEY" value="{YOUR_API_KEY}" />');
    }
    var apiKey = matches[1];
    var keyString = "\n      <string>"+apiKey+"</string>\n    ";

    var projectName = getProjectName(configXml);

    var plistFile = path.resolve(context.opts.projectRoot, "platforms", "ios", projectName, projectName+"-Info.plist");
    if (!fs.existsSync(plistFile)) {
      throw new Error('Unable to find .plist');
    }

    fs.readFile(plistFile, 'utf8', function (err,plistXml) {
      if (err) {
        throw new Error('Unable to read .plist: ' + err);
      }

      var arrayRegExp = /<key>DonkyApiKey<\/key>[\s\S.]*<array>([\s\S.]*)<\/array>/;
      var arrayRegExpMatches = plistXml.match(arrayRegExp);
      plistXml = plistXml.replace(arrayRegExpMatches[0], arrayRegExpMatches[0].replace(arrayRegExpMatches[1], keyString));

      fs.writeFile(plistFile, plistXml, 'utf8', function (err) {
        if (err) throw new Error('Unable to write to .plist: ' + err);
        if(context.opts.verbose) console.log("Successfully wrote Donky API key from config.xml to iOS .plist");
      })
    });
  });

};