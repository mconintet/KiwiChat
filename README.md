## About
Simple IM in Objective-C for iOS by using WebSocket.

## Server
It use [KiwiChat-Server](https://github.com/mconintet/KiwiChat-Server) as it's server side, so you should get the server's source code and Build&Run it before you run this client project.

## Installation
After you download source code you need to use [CocoaPods](https://cocoapods.org/) to install dependencies at first - run command line `pod install` under the source code directory.

## Run
You can run this project as any other Xcode project - just click the Bild&Run button, but don't forget to set your own server address before running:

```objc
// in AppDelegate.m file below line
#define KIWI_SERVER_ADDRESS @"ws://127.0.0.1:9876"
// replace it to
#define KIWI_SERVER_ADDRESS @"ws://your_server_address"
```

## Screenshot
![](https://raw.githubusercontent.com/mconintet/KiwiChat/master/screenshot.gif)

If you have an interest in code running in Browser, you can get them from [KiwiChat-Browser](https://github.com/mconintet/KiwiChat-Browser). Also, if you think this project is not too bad please give it a star :)