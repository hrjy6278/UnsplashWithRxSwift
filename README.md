# Unsplash App

## 기술 스택
### 사용언어 : Swift
### 아키텍처 : MVVM
### 의존성 도구: SPM(Swift Package Manager)
### 라이브러리: Alamofire, Kingfisher, RxSwift, RxCocoa, RxDataSource
### 기타 
- StoryBoard를 쓰지않고 UIKit 코드로 구현 
- OAuth2를 이용한 유저 권한 획득
- OAuth2 유저 토큰 저장시 `KeyChain` 활용
- 유저에게 보여줄 Message를 `UIAlertController` 활용하여 구현
- RESTful `GET`, `POST`, `DELETE` 사용
- RxSwift를 이용한 `ViewModel` 과 `View`의 Binding 구현
- RxDataSource 를 이용한 `TableView` DataSource 구현

---
## 동작구현
### OAuth2를 활용한 로그인, 로그아웃 구현

![login](https://user-images.githubusercontent.com/71247008/147352191-d3d16444-7c08-42bd-8d96-a7f4b145cbb4.gif)

---
### 검색결과 좋아요 프로필과 동기화
![like](https://user-images.githubusercontent.com/71247008/147352077-e91e820c-615c-499d-b973-c8699ff4a633.gif)

---
### 검색결과 스크롤 구현
![scroll](https://user-images.githubusercontent.com/71247008/147355446-05915e4d-b7aa-435c-bc92-2a546bee128b.gif)

---
<br>

## 폴더별 간단한 구현 내용
### KeyChain

<details>
<summary>구현내용</summary>
    
- 키체인을 활용하여 값을 저장하거나, 꺼낼 수 있게 끔 구현하였습니다. 기본 Query는 `KeyChainQueryable` Protocol을 활용하여 의존성 주입을 받도록 구현하였습니다.
- `KeyChainStoreDelegate` Protocol을 구현하고 해당 메서드내에 Value가 삭제될때 `delegate` 를 통해 알려주게 됩니다.
- Unit Test를 진행해 검증을 하였습니다.
</details>


---
### Supporting
#### Protocol 

<details>
<summary>구현내용</summary>
    
- `HierarchySetupable`은 코드로 UIKit을 작성할때 addSubView와 layout부분의 순서를 헷갈리지 말라고 정의해두었습니다. 
두개의 메서드(`setupViewHierarchy`, `setupLayout`)를 구현하고 `setupView()` 를 실행하기만 하면 순서를 생각하지 않고 코드로 편하게 작성할 수 있습니다.
- `KeyChainQueryable`은 KeyChain에 쓰일 `query`를 주입받기 위하여 선언해 놓은 프로토콜입니다.
- `TabBarImageInfo`은 tabBarController에 View들을 등록할때 이미지 이름을 저장해놓기 위해 선언한 프로토콜입니다.
</details>

#### Extension

- Extension은 구현되있는 타입에 메서드나, 프로퍼티를 추가한 부분을 분리하여 저장해두었습니다. 

---

### NetworkService
- 네트워크에 필요한 코드들이 모여있는 곳 입니다.
<details>
<summary>Unsplash Network</summary>
    
- `UnsplashAPIManager`는 unsplash 서버와 전반적인 통신을 구현한 타입입니다. 네트워크 부분의 핵심 로직이라고 볼 수 있습니다. 
`sessionManager`라는 프로퍼티를 만들고 `interceptor` 타입을 만든 뒤 `Session`을 만듭니다.
- `UnsplashParameter`는 Unsplash와 통신할때 HTTP Header들의 내용들을 작성해 둔 곳 입니다. 지금 다시 보니, 이 부분은 OAuth2에 더 어울리는 것 같습니다.
- `UnsplashInterceptor`은 Alamofire의 프로토콜 중 하나로 그중 adapt 메서드는 네트워크 통신 시작하기 전에 호출되는 메서드입니다. 
이때 request의 header에 유저 token이 있으면 header에 token을 넣어주고, 아니면 clientID를 넣어주도록 하였습니다.
- `UnsplashRouter`는 url들이 모여있는 곳 입니다. baseURL, path, parameter를 나눠 각각의 서버 통신 url을 case에 맞게끔 작성하여 헷갈리지 않도록 하였습니다.
</details>

#### OAuth

<details>
<summary>구현내용</summary>
    
- `TokenManager`는 OAuth2를 이용해 서버로 부터 토큰을 받았을때 KeyChain에 저장하고 꺼내는 용도로 만들었습니다.(전반적인 CRUD)
여기서 키체인의 델리게이트를 채택하고 구현하여 키가 삭제되었을때 `Notification`을 보내도록 하였습니다.
- `TokenQuery`는 KeyChain에 쓰일 `query`를 구현한 부분입니다. `KeyChainQueryable`를 채택하고 구현하여 기본적인 query를 작성하였습니다.
- `UnsplashAccessToken`은 서버로 부터 Token을 받았을때 Json 형식을 파싱할 타입입니다.
</details>

---

### Model
- Model에 있는 타입들은 각각 unsplash서버로 부터 통신하고 Json으로 받아온 data들을 파싱하는 타입들이 모여있습니다.

---

### Controller
#### UnsplashTabbarController
- 탭바와 Navigation 영역을 담당하는 컨트롤러 입니다. Navigation bar의 Login, Logout 버튼의 로직을 담고 있습니다.

#### ImageListDataSource
- 이미지를 보여주는 List의 View들이 모여있는 곳입니다. 재사용성을 위하여 
tableView의 DataSource 부분을 따로 분리하여 해당 폴더에 넣어 주었습니다.

#### Profile
- 탭바의 프로필 영역을 보여주는 View와 Controller가 있습니다. 
imageListDataSource를 채택한 테이블 뷰가 Controller에 선언되어있습니다.

#### Login
- 로그인이 안되어있을때 탭바 프로필에 보여질 Login Controller와, OAuth2를 이용하여 서버와 통신하는 컨트롤러(Oauth2ViewController)가 있습니다.
- Oauth2ViewController는 ASWebAuthenticationSession 채택해 사용자가 서버와 통신하는 브라우저가 열리게끔 구현하였습니다.

#### Search
- 탭바의 검색 영역입니다. `SearchViewController` 에서는 searchBar를 구현하고, 검색 로직을 담고 있습니다.
- 해당 컨트롤러에 `tableView`를 구현하였고 dataSource는 `ImageListDataSource` 입니다.


## 해결하지 못한점
- 탭바에 네비게이션과 관련한 코드가 있어서 책임에 위반되는 행위가 아닌가 싶은 생각이 든다. 현재 NavigationViewController -> TabBarController 이렇게 `Embed` 되어있는데 이부분을 TabBarController -> NavigationController 로 바꿔주는게 나을것 같다.
- TableView reloadData() 메서드 실행시에 tableView가 깜빡거리는 현상이 있습니다. 시간이 부족하여 어떻게 해야 할까 생각만하고 처리하지 못했습니다. 이 부분은 계속 해결을 위해 시도해볼 예정입니다.
    - 알아본 해결방법
        - TableView reloadSection 메서드 활용하기.
        - TableView performBatchUpdates 메서드 활용하기.

- RxSwift, Rxcocoa를 써보고 싶었지만, 아직 공부 단계라 써보질 못했습니다.
- Client ID, ClientSecret 부분을 숨김 처리하려고 했으나 방법이 떠오르지 않아 처리하질 못했다.
    - 검색을 조금 해본 결과 info.plist에 해당 내역들을 추가 한 뒤 
xcconfig에 값을 저장한 뒤 사용 해볼 수 있을 것 같다.
     참고내용 https://medium.com/swift-india/secure-secrets-in-ios-app-9f66085800b4
