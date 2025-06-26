# ABZ Test task

The test task for ABZ.agency I implemented in between of some other doings.

## Overview

The test task for ABZ agency. The application uses GET and POST requests.
The color scheme is located in the Assets and could be changed easily.
Typography with fonts used is located separately.

Overall structure of the project is rather simple

```
/project_fonts
/Models
/Views
    /Primitives
    /ViewModels
```

- Models group contains data object, network manager and other which would be used throughout the application.
- Views group contains screen views.
- Views/Primitives group contains reusable views like text fields, buttons and more.
- Views/ViewModels group contains view models for screen views.

## Configure the project

For you to be able to run the project you just need to select the proper development team in the project settings.

## Dependencies

1. SwiftyLab/MetaCodable
    This framework makes it easier to define codable structures and define coding/decoding rules.
2. vapor/multipart-kit
    This frameworks makes it a bit easier to work with multipart. Originally I thought I would just use decodable power of the library, but the photo upload didn't want to work automagically.
    I've implemented multipart myself previously, but decided to opt out from it this time around. 
3. marmelroy/PhoneNumberKit
    This framework provides pretty formatting for phone numbers. I was just devastated by the plain string of the phone number in the users list so I used this framework to prettify it a bit.

## Known issues

- Xcode 16.4 doesn't allow me to delete UI tests folder, it crashes right away. I know how to redact project manually but this time around I am too lazy to do anything about it.
- Only tests I implemented ware the partial coverage of the `NetworkManager`. I spent way too much time on this task already, so this time around I will not implement any more tests. I've prepared view models to be covered with tests tho.
- Validation for sign up fields is only done for email field as it being shown on mockups.
- Field errors are not cleaning up after changing something in them.
