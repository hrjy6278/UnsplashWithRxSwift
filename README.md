# Unsplash App

## 프로젝트에 대해

야곰 iOS 커리어 스타터를 다니고 수료하면서 까지 RxSwift에 대한 얘기가 캠퍼들 사이에 많이 오갔고, 신입은 안해도 되는 라이브러리이다 라는 말을 많이 들었습니다.

하지만 저는 취업준비를 진행하면서 회사에서 사용하고 있는 라이브러리중 `RxSwift`의 비중이 높단 걸 알게되었습니다.

자연스럽게 `RxSwift에` 대해 호기심이 많아졌고, 이것저것 검색을해보고 공부를 해가면서 프로젝트를 진행을 해보았습니다.

많이 부족한 코드지만 이렇게 프로젝트를 진행해보니 `RxSwift`가 뭔지, 어떻게 로직을 짜야하는지 선언형, 함수형 패러다임을 조금이나마 알 수 있었던 기회였던 것 같습니다.


---
## 기술 스택
### 사용언어 : Swift
### 아키텍처 : MVVM
### 의존성 도구: SPM(Swift Package Manager)
### 라이브러리: Alamofire, Kingfisher, RxSwift, RxCocoa, RxDataSource, RxKeyboard
### 기타 
- RxSwift를 이용한 `ViewModel` 과 `View`의 Binding 구현
- RxDataSource 를 이용한 `TableView` DataSource 구현
- RxKeyboard를 이용하여 keyboard View에 가리는 문제 해결
- OAuth2를 이용한 유저 권한 획득
- OAuth2 유저 토큰 저장시 `KeyChain` 활용
- 유저에게 보여줄 Message를 `UIAlertController` 활용하여 구현
- 유저 프로필 `Edit` 구현
- RESTful `GET`, `POST`, `DELETE`,` PUT` 사용
---
## 동작구현

### 검색

| 사진 검색 | Like | OAth2를 이용한 로그인 |
|:----------------------------------------------------------:|:------------------------------------------------------------:|:----------------------------------------------------------:|
| <img src ="https://imgur.com/DjMyaeW.gif" width = 800> | <img src ="https://imgur.com/CFcScPD.gif" width = 800> | <img src ="https://imgur.com/3GS8eo3.gif" width = 800>|

---

### 프로필

| Profile Login| Profil Edit|
| :-: | :-----------------------------: |
| <img src ="https://imgur.com/8Pd37Pw.gif"> | ![Profile Edit](https://imgur.com/PirHlyu.gif) |

<br>

## 폴더별 간단한 구현 내용
### KeyChain

<details>
<summary>구현내용</summary>

- 키체인을 활용하여 값을 저장하거나, 꺼낼 수 있게 끔 구현하였습니다. 기본 Query는 `KeyChainQueryable` Protocol을 활용하여 의존성 주입을 받도록 구현하였습니다.
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
  clientID 와 Seceret Key는 보안상의 이유로 xcconfig를 따로 만들어 저장하였습니다.
- `UnsplashRouter`는 url들이 모여있는 곳 입니다. baseURL, path, parameter를 나눠 각각의 서버 통신 url을 case에 맞게끔 작성하여 헷갈리지 않도록 하였습니다.
</details>

#### OAuth

<details>
<summary>구현내용</summary>

- `TokenManager`는 OAuth2를 이용해 서버로 부터 토큰을 받았을때 KeyChain에 저장하고 꺼내는 용도로 만들었습니다.(전반적인 CRUD)
키의 저장과 삭제를 `BehaviorSubject` 의 스트림을 구성하여 구독자들에게 알려 줄 수 있도록 하였습니다. 
- `TokenQuery`는 KeyChain에 쓰일 `query`를 구현한 부분입니다. `KeyChainQueryable`를 채택하고 구현하여 기본적인 query를 작성하였습니다.
- `UnsplashAccessToken`은 서버로 부터 Token을 받았을때 Json 형식을 파싱할 타입입니다.
</details>

---

### Model
- Model에 있는 타입들은 각각 unsplash서버로 부터 통신하고 Json으로 받아온 data들을 파싱하는 타입들이 모여있습니다.

---

### Controller
#### UnsplashTabbarController
- 탭바 컨트롤러입니다. 열거형 `TabBarType`을 만들어 탭바의 제목과 이미지를 줄 수 있는 타입을 선언하였습니다.

#### ImageListDataSource
#### Profile
- 탭바의 프로필 영역을 보여주는 View와 Controller가 있습니다. 
- 프로필을 Edit 할 수 있는 ProfileEditViewController가 있습니다.

#### Login
- OAuth2를 이용하여 서버와 통신하는 컨트롤러(Oauth2ViewController)가 있습니다.

#### Search
- 탭바의 검색 영역입니다. `SearchViewController` 에서는 searchBar를 구현하고, 검색 로직을 담고 있습니다.

---
