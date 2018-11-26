# iOSDemo

更新swift 4.2支持

因为我添加了FFMpeg和Opencv所以这个项目现在跑不起来。需要去
https://pan.baidu.com/disk/home?#/all?vmode=list&path=%2F%E5%BC%80%E5%8F%91
下载需要的文件才能跑起来
还有就是机器学习的mlmodel文件
https://developer.apple.com/machine-learning/build-run-models/，在里下载 ResNet50文件放到AL文件夹就行
因为新的Router组件API设计可能和MVVM框架不好集成，所以目前导航功能不能用
项目一： Novel小说 APP
![惯例的开场美图](http://upload-images.jianshu.io/upload_images/1281203-3f339ba854803865.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)



### 目前苹果更新了Swift4，更新xcode到10且支持Swift4.2
研究视频缓存功能

首先给大家直接上图，让大家能更直观看到这个APP的操作逻辑和布局。
![搜索阅读小说](https://raw.githubusercontent.com/DuckDeck/iOSDemo/master/Image/novel1.gif)

![小说书签](http://upload-images.jianshu.io/upload_images/1281203-4d0371c7c0658e24.gif?imageMogr2/auto-orient/strip)

首先给大家简单介绍上面的技术
#### Carthage
开发一个APP第三方库不是可缺少的，而目前最主流的iOS第三方库管理工具是`CocoaPods`，使用起来简单方便，而`Carthage` 就要轻量很多，它也要一个叫做 `Cartfile`描述文件，但 `Carthage `不会对我们的项目结构进行任何修改，更不多创建 `workspace`。它只是根据我们描述文件中配置的第三方库，将他们下载到本地，然后使用 `xcodebuild` 构建成 `framework` 文件。然后由我们自己将这些库集成到项目中。`Carthage` 使用的是一种非侵入性的哲学。
好了，下面就是怎么安装`Carthage`了，我使用的是`Homebrew`安装。假定你的Mac已经安装了`Homebrew`, 如果你没装`Homebrew`? 那么赶紧的，参考[Mac下使用国内镜像安装Homebrew](http://www.jianshu.com/p/6523d3eee50d)先安装好`Homebrew`。
再用下面的命令
```
brew update
brew install carthage
```
然后就等`Carthage`安装好就能用了,然后cd到你的项目根目录建立`Cartfile`文件
```
touch Catfile
```
然后就是编辑这个文件了，你可以用编辑器修改也能用vim，在Cartfile文件里面加入以下内容:
```
github "Alamofire/Alamofire" ~> 4.0
github "tid-kijyun/Kanna" ~> 2.1.0
github "youngsoft/TangramKit" ~> 1.0.0
github "onevcat/Kingfisher" ~> 3.10.0
github "hackiftekhar/IQKeyboardManager"
github "devSC/WSProgressHUD"
github "ReactiveX/RxSwift"
github "Moya/Moya"
github "devxoul/URLNavigator"
github "RxSwiftCommunity/RxDataSources"
```
这些都是这个小说APP需要用到的库
然后再使用命令
```
carthage update --platform iOS
```
这个时侯再去喝茶吧，要等好一会`Carthage`才能将这些库下载过来再奖其编译成动态库。
注意小说APP用了`MJRefresh`，但是好像`MJRefresh`好像不技术`Carthage`,我不想再用`Cocoapods`,于是直接将这个库的文件放到项目内里面了。等待`Carthage`编译完成后，你就可以在`项目目录->Carthage->Build->iOS`里面看到这些`framework`库了，把这些库拖到项目`target`的`General`的`Linked Frameworkds and Libraries`里面

![将这些库拖到项目里](http://upload-images.jianshu.io/upload_images/1281203-cc72abda0ea0abe6.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
注意，因为这里有些库需要依赖其他的库，所以也是要一并拖进来的。

再就是最后一步了设置`Build Phases`
选中你的工程` target`，到` 'Build Phases' tab`下，点击 '+' 选择` 'New Run Script Phase'`，创建一个`Script`，添加以下内容：
```
/usr/local/bin/carthage copy-frameworks
```
然后添加相应的内容到下面的 `'Input Files'` ：
```
$(SRCROOT)/Carthage/Build/iOS/Alamofire.framework
$(SRCROOT)/Carthage/Build/iOS/TangramKit.framework
......


```
![Build Phase](http://upload-images.jianshu.io/upload_images/1281203-312afa55b1fcadd4.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

这样就大功告成了，但是`Carthage`让人不爽的是每次`update`都会`Build`都会重新编译一次，非常费时间。我特地问了别人何解，他说如果添加新的库，将原先的库注释再使用命令`Update`就行，这样就不会将原先的库重新编译更多关于`Carthage`的内容，请看[Carthage 使用 / 如何给自己的项目添加 Carthage 支持](http://www.jianshu.com/p/f473c5ca2c8c)等文章。

### RXSwift 和 MVVM
`RXSwift`和`MVVM`包含的内容可就多了，可以大书特书。网上的文章也是特别多，这里就不做说明了。我只想说了下为什么要用`RXSwift`来实现iOS开发`MVVM`。众所周知，`MVVM`最核心理念的就是**数据双向绑定**，用触发一个`UI`事件后，通常会更新其对应的数据，经过某些逻辑处理后，再更新数据来驱动UI更新，通常不用手动调用代码的方式直接操作`UI`。遗憾的是，相对于其他两个平台，`iOS`对`MVVM`理念的支持最差的。对于`Android`，`Web`开发者来说，很难想象使用代码生成UI然后再绑定到`ViewModel`这样的操作，繁琐又低效。更别说iOS本身不提供绑定方法，也没有响应式的API和控件属性，现加上很多控件都是以`Delegate`的方式来设置样式和提供数据的。这样使得用`MVVM`很难适用在`iOS`开发上。而`RXSwift`的出现使得`Swift`语言具有响应式编程的能力，再加上`RXCocoa`封装了很多的`Cocoa UI`控件，使得它们的关键属性都有了响应式特性。这样就可以轻松将各种`UI`控件的属性或者事件绑定到`ViewModel`的属性和命令上，再通过响应式的API来操作数据，使得iOS开发更为高效和直观了。

当然，使用`RXSwift`和`MVVM`来开发APP缺点也不能忽视，主要有下面几点：
- 调试和`Debug`难度大了不少。堆栈数据不再像以前那么直观了,很难找到正确的调试位置。
- 开发者的不适应。基于响应式编程的`MVVM`开发框架和平时使用`MVC`开发框架完全是两回事，在数据处理，`UI`操作等开发方式完全不同，你需要重新学习`RXSwift`，`RXCocoa`和其他的`RX`库，提升了学习成本。
- API支持不完整。可能有少量的`UI`控件属性没有封装，或者有一些第三方库不支持，这些都需要自己权衡和处理。

总之目前`iOS`最好的`MVVM`解决方案就是搭配`RXSwift`的一系统库来开发，基本满足了目前的开发需要。如果项目复杂不高，或者只是个人开发，可以使用这套方案，但如果需要开发大型商业项目，或者你的团队不熟悉`MVVM`，那么还是用传统的`MVC`方案更稳妥一些。

### Moya
`Moya`是要和`RXSwift`，`Alamofire`和`ObjectMapper`搭配一起使用的，`Moya`可以十分简洁优雅的帮你完成网络请求。先上代码：
```
import Moya
enum APIManager {                    //先定义一个枚举，里面规定了这些请求的名称和参数
    case GetSearch(String,Int)          //搜索小说，如果参数多，建议传字典
    case GetSection(String)              //获取小说章节
    case GetNovel(String)                //获取小说内容
}
extension APIManager:TargetType{       // 扩展APIManager，让它实现Moya的TargetType协议
    var baseURL: URL{                         //获取BaseURL，一般来说，同一个项目BaseURL是相同的，但会根据使用CDN或者使用一些第三方服务而有不同
        switch self {
        case .GetSearch(_, _):
            return URL(string: "http://zhannei.baidu.com")!    //搜索小说使用此域名
        case .GetSection(_),.GetNovel(_):
            return URL(string: "http://www.37zw.net")!       //获取小说章节和内容使用此域名
        }
    }
    var path: String{                                      //获取BaseURL后面的路径
        switch self {
        case .GetSearch(_, _):                        //搜索小说使用此路径
            return "/cse/search"
        case .GetSection(let path),.GetNovel(let path):  //获取小说章节和内容用自定义路径
            return path
        }
    }
    var method: Moya.Method {              //这三个请求都用Get请求
        return .get
    }
    var parameterEncoding: ParameterEncoding {  //这三个请求都用默认编码
        return URLEncoding.default
    }
    var sampleData: Data {                          //这里是当API还没有开发好时自定义一些模拟数据
        return "".data(using: String.Encoding.utf8)!
    }
    var task: Moya.Task {                      //如果要设置请求参数，可以在这个属性里设置
        switch self {
         case .GetSearch(let key, let index):        //设置搜索的Key和index页码
            let params = ["q":key,
                          "p":index,
                          "isNeedCheckDomain":1,
                          "jump":"1",
                          "s":"2041213923836881982"] as [String : Any]
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
            
        case .GetSection(_),.GetNovel(_): //这两个不需要其他参数
            return .requestPlain
        }
    }
    var validate: Bool {   //是否需要执行 Alamofire 验证
        return false
    }
    var headers: [String : String]?{        //设置HTTP 的Head内容，这里看后台的需求了
        return nil
    }
}
```
从上面的代码看出，我写 了三个请求接口。基本上相似的功能都可以写在同一个枚举里面。然后再设置请求方式，请求参数等数据就OK了

下一步就是发送请求了
```
let provider = RxMoyaProvider<APIManager>()   //定义一个provider

provider.request(.GetSection(url))                  //发送获取小说章节的请求
.filterSuccessfulStatusCodes()                          //过滤失败的状态码
.mapSectionInfo()                                            //转换成Model
.subscribe({ [weak self] (str) in                        //订阅这个Observable
            switch(str){
            case let .success(result):        //处理成功 数据
                self!.currentSection.sectionContent = result.data as! String
                self?.arrSection.value += [self!.currentSection]
                self?.pageIndex += 1
                self!.currentSection = self!.arrSectionUrl![self!.pageIndex]
            case let  .error(err):     //处理失败情况
                Log(message: err)
               GrandCue.toast(err.localizedDescription)
            }
        }).addDisposableTo(self.bag)
```

没错，处理请求请求就是这么简单。你可以添加各种中间件来处理数据，非常方便。

`ObjectMapper`在这里并没有用到，因为这个APP抓取的是`HTML`网页，而不是`JSON`。所以我使用`Kana`来解析`HTML`
```
extension PrimitiveSequence where TraitType == SingleTrait, ElementType == Response{  //扩展PrimitiveSequence，然后里面的方法就可以用来处理Moyo返回的数据了
    func mapSectionInfo() -> Single<ResultInfo> {   //将HTML解析成ResultModel
        var result = ResultInfo()
        return flatMap { res -> Single<ResultInfo> in
            let code  = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.GB_18030_2000.rawValue))
            let str = String(data: res.data, encoding: String.Encoding(rawValue: code))
            guard let doc =  HTML(html: str!, encoding: .utf8) else{
                result.code = 10
                result.message = "解析HTML错误"
                return Single.just(result)
            }
            let divs =  doc.xpath("//div[@id='list']").first!.css("dl > dd")
            if divs.count <= 0{
                result.data = [SectionInfo]()
                return Single.just(result)
            }
            var arrSections = [SectionInfo]()
            for link in divs{
                let section = SectionInfo()
                section.sectionName = link.css("a").first?.text ?? ""
                section.sectionUrl = link.css("a").first?["href"] ?? ""
                section.id = section.sectionUrl.hash
                arrSections.append(section)  
            }
            result.data = arrSections
            return Single.just(result)
        }
    }
}
```
相比于`JSON`处理`HTML`更麻烦一些，好在`Model`的字段并不多，所以不都需要写很多代码。

### Router
最后再介绍`Router`，用了`MVVM`框架，再用`iOS`的传统导航方式就不合适了。因为导航这样的处理还是要放在`ViewModel`里面的，而`ViewModel`并不继承`ViewController`。而且`navigationController`会耦合各个页面的参数，增加修改成本。使用`Router`可以很好地解决这些问题。

小说`APP`我使用了`URLNavigator`，它是一个轻量级的`iOS` 路由库。它提供了一个优雅的方式来处理导航，使用起来也很简单。
```
extension NovelContentViewController:URLNavigable{
    convenience init?(navigation: Navigation) {
        guard let dict = navigation.navigationContext as? [String:Any] else { return nil }
        self.init()
       novelInfo = dict["novelInfo"] as? NovelInfo
       currentSection = dict["currentSection"] as? SectionInfo
       arrSectionUrl = dict["arrSectionUrl"] as? [SectionInfo]
    }
}
```
首先让需要导航的页面实现URLNavigable协议，实现init方法。

然后写一个初始化RouterMap的类
```
import UIKit
import URLNavigator
struct  NavigationMap{
    static func initialize(){
        Navigator.map(Routers.bookmark, BookmarkViewController.self) //注册这三个页面实现导航
        Navigator.map(Routers.sectionList, SectionListViewController.self)
        Navigator.map(Routers.novelContent, NovelContentViewController.self)
    }
}

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        ......
        NavigationMap.initialize()  //在APPDelegate注册
        ......
        return .true
    }
```

在`AppDelegate`的`Launch`方法里注册后就可以使用了，比如点击了小说的某一章节导航到小说内容页面
```
tb.rx.itemSelected.subscribe(onNext: { (index) in
            guard  let section = wkself?.modelObserable.value[index.row] else{
                return
            }
            let dict = ["novelInfo":wkself!.novelInfo.value,"currentSection":section,"arrSectionUrl":wkself!.modelObserable.value] as [String : Any]   //设置导航的参数
            Navigator.push(Routers.novelContent, context: dict, from: nil, animated: true)    //发起导航
        }, onError: nil, onCompleted: nil, onDisposed: nil).addDisposableTo(bag)
```

上面就是这个APP的主要的技术点了，下面将重点讲`RXSwift`和`MVVM`。
###  ViewController和ViewModel怎么互动
以首页为例，和以前一样，`ViewController`只生成`UI`和布局。小说搜索页面比较简单，直接用代码生成即可。

##### 接下来分析这个页面需要绑定哪些控件和属性

- 首页最核心的内容就是显示搜索出来的小说了，那么自然`UITableView`成为了交互的核心，对于这种情况，我们可以在`ViewModel`里直接声明一个`UITableView`对象来引用`ViewController`的`TableView`，然后这在里面进行各种绑定属性的命令操作。
- 网络请求也是在`ViewModel`里面完成，所以需要声明一个`RxMoyaProvider`对象用来请求网络，它是`APIManager`的泛型。
- 小说的搜索结果需要保存在一个数组里，这里我使用了 `Variable<[NovelInfo]>`类型来保存。它是一个可观察的数组，当对数组操作时，绑定了该数组的`TableView`会根据数组的变化更新`Table`的`Cell`
- 小说搜索还支持下拉刷新和下拉加载更多，这里使用了`PublishSubject<Bool>`类型来实现，它是一个命令，使用`Bool`来区分操作类型
- 搜索框`UITextField`的`text`属性绑定了`ViewModel`的`key`属性，当有输入文字发生改变时，`key`也会跟随更新，在这里我让它驱动`keyStr`更新。
- 搜索按钮也需要绑定一个搜索事件，在这里我用`Driver<Void>`类型来绑定`UIButon`的点击事件
- 最后就是更新`UITableView`刷新状态了，`Variable<RefreshStatus>(.none)`驱动`UITableView`更新刷新状态
所以根据上面的情况，可以写出以下代码。
其实写`ViewModel`在最开始的情况下，很难列举出全部的属性和命令，都是后面一步一步加上去的。
```
       var bag : DisposeBag = DisposeBag()
       let provider = RxMoyaProvider<APIManager>(requestClosure:MoyaProvider.myRequestMapping)
       var modelObserable = Variable<[NovelInfo]> ([])
       var refreshStateObserable = Variable<RefreshStatus>(.none)  //绑定到Table的刷新显示状态
       let requestNewDataCommond =  PublishSubject<Bool>()  //绑定到MJRefresh的上拉刷新和下拉加载更多事件
       var pageIndex = 0                 
       var tb : UITableView
       var key :Driver<String>                                 // key和搜索输入框绑定 
       var keyStr = Variable<String>.init("")            //搜索key变量，被key驱动
       var searchCommand :Driver<Void>              //搜索命令，和键盘事件，搜索按钮点击事件绑定
```

##### 在ViewController里面加入ViewModel并绑定相关事件

```
 var vm : NovelSearchViewModel?    //声明对应的ViewModel
    
    override func viewDidLoad() {
        super.viewDidLoad()
         weak var wkself = self
        ......
        vm = NovelSearchViewModel(input: (tb,txtSearch.rx.text.orEmpty.asDriver(),btnSearch.rx.tap.asDriver()))  //实例化该ViewModel，传入必要参数
        
        txtSearch.rx.controlEvent([.editingDidEndOnExit]).subscribe(onNext: {
            wkself?.tb.mj_header.beginRefreshing()          //绑定搜索事件到上拉刷新
        }, onError: nil, onCompleted: nil, onDisposed: nil).addDisposableTo(vm!.bag)

        
        tb.mj_header = MJRefreshNormalHeader(refreshingBlock: {
            wkself?.vm?.requestNewDataCommond.onNext(true)      //绑定下拉刷新事件
        })
        
        tb.mj_footer = MJRefreshAutoNormalFooter(refreshingBlock: {
            wkself?.vm?.requestNewDataCommond.onNext(false)   /绑定下拉加载更多事件
        })
        ......
}
```
##### 最后在ViewModel处理绑定事件和数据逻辑。
```
     func bind(){
          weak var wkself = self
          tb.register(NovelTbCell.self, forCellReuseIdentifier: cellID)        注册UITableViewCell
          tb.tableFooterView = UIView()
          modelObserable.asObservable().bind(to: tb.rx.items(cellIdentifier: cellID, cellType: NovelTbCell.self)){ row , model , cell in
                cell.novelIndo = model
          }.addDisposableTo(bag)        //将列表数据绑定到Table的单元格上面
        
        tb.rx.itemSelected.subscribe(onNext: { (index) in      //Table的单元格点击事件
            guard  let novel = wkself?.modelObserable.value[index.row] else{
                return
            }
            Navigator.push(Routers.sectionList, context: novel, from: nil, animated: true)    //跳转到小说章节列表页面
        }, onError: nil, onCompleted: nil, onDisposed: nil).addDisposableTo(bag)
        
        requestNewDataCommond.subscribe { [weak self](event) in
           Tool.hiddenKeyboard()
            if event.element!{
                self?.pageIndex = 0
                self?.provider.request(.GetSearch(self!.keyStr.value,self!.pageIndex)).filterSuccessfulStatusCodes().mapNovelInfo().subscribe({ (str) in   //使用Moya发起网络请求，网络请求的相关参数都在APIManager中设置好了
                    switch(str){
                    case let .success(result):
                            self?.modelObserable.value = result.data! as! [NovelInfo]  //更新数据，这个赋值操作可以触发UITableView更新数据
                            self?.refreshStateObserable.value = .endHeaderRefresh
                    case let  .error(err):
                        Log(message: err)
                        self?.refreshStateObserable.value = .endHeaderRefresh
                        GrandCue.toast(err.localizedDescription)
                    }
                }).addDisposableTo(self!.bag)
            }
            else{
               
            }
        }.addDisposableTo(bag)
        
        searchCommand.drive(onNext: {
            refreshStateObserable.value = .beginHeaderRefresh     //搜索命令触发MJRefresh下拉刷新
        }, onCompleted: nil, onDisposed: nil).addDisposableTo(bag)
       
        refreshStateObserable.asObservable().subscribe(onNext: { (status) in  //订阅刷新状态，刷新状态改变，将触发MJRefresh相关操作
            switch(status){
            case .beginHeaderRefresh:
                wkself?.tb.mj_header.beginRefreshing()
            case .endHeaderRefresh:
                wkself?.tb.mj_header.endRefreshing()
                wkself?.tb.mj_footer.resetNoMoreData()
            case .beginFooterRefresh:
                wkself?.tb.mj_footer.beginRefreshing()
            case .endFooterRefresh:
                wkself?.tb.mj_footer.endRefreshing()
            case .noMoreData:
                wkself?.tb.mj_footer.endRefreshingWithNoMoreData()
            default:
                break
            }
        }, onError: nil, onCompleted: nil, onDisposed: nil).addDisposableTo(bag)
      }

```

从上面的代码可以看出，主要是处理`UITableView`相关事件，为`Table`提供数据和单元格点击事件，并且修改`MJRefresh`状态。

上面就是`ViewMode`和`ViewControlle`交互三部曲：
- 在`ViewModel`定义需要绑定的属性和一些逻辑操作属性
- 添加`ViewModel`到`ViewController`并传递需要绑定的属性，并且同时将想着事件绑定到`ViewModel`的命令上
- 最后就是在`ViewModel`里更新逻辑，在修改属性(数据)的同时，也会更新`UI`。


##### AI项目

需要下载
MLMODEL文件
