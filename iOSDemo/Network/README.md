# HttpClient


+ HttpClient is a easy-to-use, high efficiency and simplify Http request class.I reference SVHTTPRequest and improve some features.meanwhile, I use Swift to rewrite it.
+ HttpClient是一个易于使用，高效率且简单的轻量级Http请求库。我参考了SVHTTPRequest同时也改进了一些功能，同时，我用Swift重写了它。

##Key Features 【关键特点】
* Inherit NSOperation.
 **继承于NSOperation。**
* Do not instantiated HttpClient class, use static HttpClient class funciton complete all Http requests.
**不需要实例化HttpClient类，只要用静态的HttpClient类函数来完成所有请求**

* Use block complete call-back, and can monitor download&upload process.
**使用block来完成回调，你也可以监视上传&下载进程**
* Support globle Http environment settings, and you can also customize http request.
**支持全局Http请求环境设置，同时你也可以个性化Http请求**

* Support cache feature by Url and clear cache.
**支持基于Url的缓存，可以清空缓存**

* Can cancel all request, cancel requeset by request token.
**可以根据token取消请求，也可以取消全部请求.**

* Support functional programming.
**支持函数式风格编程**

##Requirements 系统需求
+ XCode 7.3 and iOS 8.0(the lasted swift grammar)
+ Xcode 7.3 和 iOS8.0 （基于最新的Swift语法）

##Installation 【安装】
+ if you want to use cocopods, just pod 'HttpClient'.then use pod to install it.
**如果使用你想使用Cocoapods，直接pod 'HttpClient’，再用pod安装就行**
+ if you want to use file, just copy the HttpClient.swift to your project.
**如果你想使用文件，直接把HttpClient.swift 拷贝到你的项目即可**

##How To Use It  【如何使用】

###Setp1: configration the globle http environment（配置全局Http使用环境）
+ use the HttpClient setGlobal serious static functions to configration the http environment
**使用HttpClient静态的setGlobal系列方法来配置全局环境**

```swift
  HttpClient.setGlobalCachePolicy(NSURLRequestCachePolicy.UseProtocolCachePolicy) //set the GlobalCachePolicy
//设置全局的缓存策略
  HttpClient.setGlobalNeedSendParametersAsJSON(false) // set need set parameters as json
//设置是否以Json格式发送数据
  HttpClient.setGlobalUsername("yourUserName") //Set the global authentication username
//设置全局的认证用户名
  HttpClient.setGlobalPassword("123456") //Set the global authentication password
//设置全局的认证密码
  HttpClient.setGlobalTimeoutInterval(40) //Set the global Http request time out
//设置全局的请求超期时间
  HttpClient.setGlobalUserAgent("Firefox") // set useragent
//设置全局的UserAgeng
```
+ If you do not configration the http environment, the HttpClient will use the default config which are:
**当然，如果你不去做这些设置，HttpClient默认将会使用如下设置:**
```swift
  GlobalCachePolicy//(default value is NSURLRequestCachePolicy.UseProtocolCachePolicy ),
  GlobalCachePolicy//(默认是NSURLRequestCachePolicy.UseProtocolCachePolicy ),
  GlobalNeedSendParametersAsJSON//(the default value is false),
  GlobalNeedSendParametersAsJSON//(默认是 is false),
  GlobalTimeoutInterval//(the default value is 20), 
  GlobalTimeoutInterval//(默认是 is 20), 
  GlobalUserAgent//(the default value is HttpClient)  
  GlobalUserAgent//(默认是 is HttpClient) 
```
###Setp2 Use HttpClient static function to complete the request 使用HttpClient静态函数来完成请求
  + Call the HttpClient static function once is to creat a HttpClient instance, the initialize function is
**调用HttpClient静态函数会例化一个HttpClient类，HttpClient的构造方法为**
```swift
  private init(address:String,method:httpMethod,parameters:Dictionary<String,AnyObject>?, cache:Int,cancelToken:String?,queryPara:Dictionary<String,AnyObject>?, requestOptions:Dictionary<String,AnyObject>?,headerFields:Dictionary<String,AnyObject>?, progress:((progress:Float)->())?,completion:(response:AnyObject?,urlResponse:NSHTTPURLResponse?,error:NSError?)->()){}
```
+ you will note this is a private constructor. and so you can not call it directly.this is to let us usr the static functions，It contain all the critical parameters, let's see the parameters
**你会注意到这是一个私用构造器，我们不能直接调用这个构造器。这是为了让我们用静态函数,它包含了所有的重要的参数，让我们来看看这些参数**

```swift
  address:String
  // the request address(请求地址，是个String),

  method:httpMethod
  //there is a enum, specifically request method(Http请求方式，是个枚举，参考httpMethod枚举)
  parameters:Dictionary<String,AnyObject>?

  // this is the request parameters, when you use get method.the parameters will be added to the url, and when you use the pose method. all the parameters will be wraped in the http post content (这个就是请求的参数了，是个<String,AnyObject>?的可空字典，如果你使用Get请求方式，这些参数会以key=value的形式添加到Url后面。如果你使用Post请求，所有参数都会放在Http content包里面 )

  cache:Int
  //if you need cache this url, you can set the cache time bigger than 0. it any work at Get method, in post method this feature can not work (这个是设置缓存，单位是秒。如果设置的数字大于0，那么这个Url的get请求会被缓存起来，时间是你设置的秒数，参数小于 等于0无效。Post请求这个参数也无效 )

  cancelToken:String?
  //this is the cancel token, if you want cancel this request, just call the static funtion HttpClient.cancelRequestWithIndentity(token:string)
(这个是取消的Token，这个字符串，如果你想取消请求，只要调用这个HttpClient.cancelRequestWithIndentity(token:string)函数就行 )

  queryPara:Dictionary<String,AnyObject>?
  // this parameter is special.  you can use it on this condition. when you use post method but also want to add some parameters to the url, then use this parameter(和parameters有点一不样，queryPara比较特别。它也是个可空的<String,AnyObject>字典，它只适合于这种场景：如果你使用Post请求，但是你也想在Url里面添加些key=value的参数，就使用这个参数 )

  requestOptions:Dictionary<String,AnyObject>?
  // this parameter let you personalization this request.make it not obey the global config. for instance, if you need set this request timeout . you need add timeout in the dictionary. and pass it to the request.
(requestOptions参数是你用来个性化请求用的，也是个它也是个可空的<String,AnyObject>字典。来使它不遵循全局的Http设置。比如说，你想设置该次请求的超期时间，那么你将超期时间加到字典里，再加上这个参数即可 )

  headerFields:Dictionary<String,AnyObject>?
  // the paramter is to set the Http request header. ( headerFields也是个可空的<String,AnyObject>字典，用来设置Http请求头)

  progress:((progress:Float)->())?
  // this is the upload&download progress ( progress是一个可空的block,是用来监视上传&下载进程)

  completion:(response:AnyObject?,urlResponse:NSHTTPURLResponse?,error:NSError?)->())
  // this is the completion call-back handler, response is a NSdata object, and you can fetch Http response info from urlResponse if error occur, the response will be nil and you can fetch the error info from error object ( completion 是一个可空的请求完成后的回调block, response实际是一个NSData对象，可以从urlResponse里获取Http response 的相关信息。如果有错误发生，那么error不为nil且response为nil，可以从error里面获取该次请求的错误，)

```
+ and the code above show all the Http request parameters. you can select the appropriate static function to send the Http request.
**上面的代码展示了所有的Http请求参数。你可以选择一个合适的静态函数来发送Http请求。**
```Swift
  public static func get(address:String,parameters:Dictionary<String,AnyObject>?,cache:Int,cancelToken:String?, queryPara:Dictionary<String,AnyObject>?, completion:(response:AnyObject?,urlResponse:NSHTTPURLResponse?,error:NSError?)->())
// this is the primary get static fun，It can complete the simple basic get request.
// 这是最主要的Get静态函数，可以完成最简单基本的get请求。
```

###Step3 Handle the callback block (处理回调block)
+ Once you choose the appropriate static function,add request parameters, the last thing is to handle the callback block,it's very simple.
**一旦你选择了最合适的静态函数，添加了请求参数后，最后一步就是处理回调block了，这里非常简单**
```swift
  HttpClient.get("http://www.baidu.com", parameters: nil, cache: 20, cancelToken: nil, completion: { (response, urlResponse, error) -> () in
				if error != nil{ 
					println("there is a error\(error)")
					return
				} // if error is not nil,then mean some error occur during the http request process,you must handle it.
				//如果error不是nil，说明http请求过程了发生了一些错误。你必须处理它。
				if let data = response as? NSData{
					if let result = NSString(data: data, encoding: NSUTF8StringEncoding){
					  println(result)
					}
				}
				//if error is nil, then handle the response.
				//没有错误，再直接处理reponse就行
			})

  First: check the error parameter, if error is not nil, handle the error and display the correct message to the user
第一步：检查error参数，如果error不是nil，处理这个错误再正确地向用户展示信息。
  Second: convert the response to the NSData, accord the request result, it can be a Image NSData , Text NSData or JSON.
第二步：将response转换成NSData，根据请求结果，它可能是Image的NSData，Text NSData或者JSON
  Third: convert the NSData to the Model or Object and use it
第三步，将NSData转换成Model或者JSON
```
+ Or you can also use functional programming style to complete http request
**同样你也可以使用函数式风格编程来完成Http请求**
```swift
let path: AnyObject? = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true).first
let myPath = (path as! NSString).stringByAppendingPathComponent("img.jpg")
let httpOption = [HttpClientOption.SavePath:myPath,HttpClientOption.TimeOut:NSNumber(int: 100)]
// comstmize the Http request 个性化Http请求
let para = ["a":"123"]
HttpClientManager.Get("http://img1.gamersky.com/image2015/09/20150912ge_10/gamersky_45origin_89_201591217486B7.jpg").addParams(para).cache(100).requestOptions(httpOption).progress({ (progress) -> () in
				print(progress)
			}).completion({ (response, urlResponse, error) -> () in
				if error != nil{
					print("there is a error\(error)")
					return
				}
				if let data = response as? NSData{
					if let result = UIImage(data: data){
						let tvc = ImgViewController()
						tvc.img = result
						self.navigationController?.pushViewController(tvc, animated: true)
					}
				}
				
			})
//Unlike commom static function, use HttpClientManager functional programming style is more friendly, you do not need set unnecessary parameters to nil.just use . grammar. but if you use Objectice-C, more 【】 will mill make more improper
//不像普通的静态函数，使用HttpClientManager的函数式风格编程更友好，你不需要将不需要的参数再设置成nil了。只要用.语法就可以了，不过如果你使用Objective-C的话，太多的【】可能会看起来比较乱
```
###Setp4 Other operation  【其他操作】
#####Cache the request:【缓存请求】
```swift
cache: 20,
```
 HttpClient can cache the request by url, just pass the number than bigger 0(this is  second unit) to the Cache parameter(only get httpmMehod will work), the HttpClient will cache this request automatically and store the cache as NSData to the APP's Cache fold.if  you use the same url to fire another http request, HttpClient will read all data from cache
**HttpClient可以由以url为key来缓存请求，只要传一个比0大的数据（这是一个的uint类型，表示秒）到缓存参数里（只有get请求才有效果）HttpClient自动缓存这个请求，将数据以NSData的形式保存在APP的Cacha文件夹里。如果你再次用该url请求，HttpClient会从Cacha文件夹里读取数据**
#####Clear the cache: 【清空缓存】
```swift
HttpClient.clearUrlCache("www.baidu.com") //if you can clear one specific cache, just pass the cache url
//如果你想根据Url来清空缓存，只要传Cache的url就行
HttpClient.clearCache() //call  clearCache（） clear all the url cache
//调用 clearCache（）来清空全部缓存
```
Not only set cache, you can clear the cache manually, call the static funtion clearUrlCache(url:String) and pass the url that you have set cache, you can call the static funtion clearCache() as well, it can clear all the cache file that the HttpClient created.
**不仅清空缓存，你还可以手动清空缓存，调用静态函数clearUrlCache(url:String)就行了，然后再传你设定缓存的url。你也可以调用静态函数clearCache()，它可以清空所有的HttpClient创建的缓存**

#####Cancel the request 【取消请求】
```swift
cancelToken: "cancel", //set the cancel token 设定取消的Token
HttpClient.cancelRequestWithIndentity("cancel")  //use cancel token to cancel 传入Token来取消请求
HttpClient.cancelAllRequests() //cancel all the request 取消所有请求
```
  Cancel http request while the http request is processing is a HttpClient's prime feature it's very simple. when you want to cancel a request, you must set the cancelToken parameter. can you'd better make the cancelToken is unique. then call the static funtion cancelRequestWithIndentity(token:String), pass the cancelToken to this funtion and the HttpClient will cancel this request. as a consequence the result block will not run.meanwhile, if you do not set the cancelToken, you can use the url to cancel the request, call the static funtion cancelRequestsWithPath(url:String) and pass the url. if you want cancel all the request, call the static funtion cancelAllRequests() the HttpClient will terminate all the request that is processing.
**HttpClient一个最主要特点就是可以在Http请求过程中取消请求。合理利用这个功能可以节省大量资源，它非常简单，当你想要取消一请求时，你必须设置该请求的Token，同时该Token最好是唯一的。再调用静态cancelRequestWithIndentity(token:String)，再把Token传进去，HttpClien将会取消这次请求。结果就是该次请求的回调block不会再执行。
如果你没有设置Token，你也可以用url来取消请求，调用静态函数cancelRequestsWithPath(url:String)来根据url取消请求。如果你想取消所有的请求，调用静态函数cancelAllRequests()，HttpClient将会取消所有正在请求的Request**
<br/>
#####customize the request:【个性化请求】
```swift
let myPath = "path" //declare a path, 声明一个路径
let httpOption = [HttpClientOption.SavePath:myPath,HttpClientOption.TimeOut:NSNumber(int: 100)] //declare Http request option 个性化Http请求字典
```
  After set the globel Http environment, for some http request you do not want to obey the globel http environment, you can customize the http request. there are some HttpClientOption you can set,please refer the struct HttpClientOption
  **在设置好全局Http环境后，有一些Http请求你并不想让它也使用全局的Http环境。你可以个性化该次请求，只要设置好HttpClientOption即可。参考HttpClientOption结构体。**
<br/>

#####Set username and password: 【设置用户名和密码】
some website need certificate,it need user provide the username and password.you can use the global static funtion set the global username and password or store the username and password in a dictionary then pass to a specifically request(I have't test this feature)
**有一些网站需要认证，它需要你提供用户名和密码，你可以用全局静态函数来设置全局的用户名和密码，或者在特定的请求中用个性化请求来传递用户名和密码（该功能我没有测试）**
##### More usage please refer the HttpClientDemo  【更多的使用方式请参考我的HttpClientDemo】
  
##Contact 
Any issue or problem please contact me:3421902@qq.com, I will be happy fix it.

**有任何问题或者Bug请联系我 3421902@qq.com,我会很高兴为你解决问题**


