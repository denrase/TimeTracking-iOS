#Overtime: A TimeTracking Client for iOS

![Screenshot](https://github.com/denrase/TimeTracking-iOS/blob/master/screenshot.PNG)

This is the iOS client for the [TimeTracking](https://github.com/mbrugger/timetracking) webservice build by [Marting Brugger](https://github.com/mbrugger). It consists of a universal iOS app and a watchOS app. You can start and end your workday, and see your worked and paused time.

The app is written in Swift only, uses [Carthage](https://github.com/Carthage/Carthage) for dependency management, [Alamofire](https://github.com/Alamofire/Alamofire) for network communication, and a shared framework for data syncing between watch and phone.

## Building

If necessary, update to the latest version of Carthage.

Clone the repository, then run `carthage update`, opening the generated Xcode workspace.

## Licence

Licensed under MIT.