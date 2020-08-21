# ApiCall

#### Installation with Swift Package Manager

[Swift Package Manager(SPM)](https://swift.org/package-manager/) is Apple's dependency manager tool. It is now supported in Xcode 11. So it can be used in all appleOS types of projects. 

To install ApiCall package into your packages, add a reference to ApiCall and a targeting release version in the dependencies section in `Package.swift` file:

```swift
import PackageDescription

let package = Package(
    name: "YOUR_PROJECT_NAME",
    products: [],
    dependencies: [
        .package(url: "https://github.com/zainanjum100/ApiCall", from: "1.0.1")
    ]
)
```

To install ApiCall package via Xcode

 * Go to File -> Swift Packages -> Add Package Dependency...
 * Then search for https://github.com/zainanjum100/ApiCall
 * And choose the version you want

## Configuration in AppDelegate

 ```
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // you cann setup your server or base url here and also set header here
        let header = [
            "Content-Type":"application/json",
            "Accept" : "application/json",
            "Accept-Language": "en",
        ]
        Request.shared.setupVariables(baseUrl: "BASE_URL OR Server URL", header: header)
        return true
    }
```

## Usage with [Codable](https://developer.apple.com/documentation/swift/codable/ "Codable") 
### Language Model 

```
struct LanguageModel: Codable {
    let id: Int
    let name: String
    let isRtl: Int
    let languageCode: String
}
```
### JSON Parsing with Codable Example
```
Request.shared.requestApi([LanguageModel].self, method: .get, url: "url") { (response) in
                switch response{
                case .success(let JSON):
                    print("JSON")
                case.failure(let err):
                    debugPrint(err)
                }
            }
```
### Image upload with Codable response Example
```
Request.shared.uploadData(LanguageModel.self, method: .post, imageData: imgData, url: "url") { (response) in
            switch response{
            case .success(let JSON):
                  print("JSON")
            case.failure(let err):
                debugPrint(err)
            }
        }
```


