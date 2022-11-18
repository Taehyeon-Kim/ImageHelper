# 💰Cache

![imageCache_banner](https://user-images.githubusercontent.com/61109660/202178985-8c9c9938-c6fe-4a90-ace3-d6d76dbd4e0e.png)

## 1️⃣ 들어가며

### 여러분은 [Kingfisher](https://github.com/onevcat/Kingfisher)를 왜 사용하시나요?


![스크린샷 2022-11-16 오후 3 09 29](https://user-images.githubusercontent.com/61109660/202737707-57d1ad16-51ec-440d-bb2c-619160a17d44.png)

저는 Kingfisher라는 라이브러리를 쓰면서 다음과 같은 생각을 했습니다.

1. 이미지 다운로드하고 캐싱하는 정도로만 쓰는 것 같은데?
2. 캐싱이 뭐지? 뭐길래 라이브러리에서 지원하고 있는거지?
3. 나는 당장 이미지를 가져오는 기능만 쓰고 있는건데 코드는 뭐가 이렇게 많은거지?

<br />

```swift
imageView.kf.setImage(with: URL(string: imageURL))
```
- 실제로 제가 사용하는 코드의 대부분은 해당 코드였습니다.

<br />

> 캐시가 무엇인지도 모른채 라이브러리를 쓰는 것보다 적어도 이미지 캐시 원리가 무엇인지 이해해보는 시간을 가져보자.

- 다음과 같은 생각에 캐시, 이미지 캐시 동작 원리에 대해서 알아보게 되었습니다.

<br />
<br />

## 2️⃣ 캐시가 무엇인가요?

캐시는 다음과 같이 요약해볼 수 있습니다.
> 데이터나 값을 미리 저장해놓는 **임시저장소**

<br />

### 왜 임시 저장소가 필요할까요?

다음과 같은 상황에 효율적이기 때문입니다.
1. 원본 데이터에 접근하는 시간이 오래 걸리는 경우 (접근 속도⬆️, 접근 시간⬇️)
2. 값을 다시 계산하는 시간을 절약하고 싶은 경우 (높은 비용의 네트워크 호출 ⬇️)

<br />

### 다시 말해서, 캐시의 목적은 효율성에 있습니다.
1. 데이터의 접근을 **빠르게**
2. 원본 데이터에 대한 접근 **비용을 저렴하게**

<br />

### 그럼 다시 돌아와서, Wikipedia의 정의를 살펴볼까요?

- 위에서 언급한 내용을 좀 더 풀어쓴 것 뿐입니다. 이해가 좀 되시나요?

```
캐시(cache, 문화어: 캐쉬, 고속완충기, 고속완충기억기)는 컴퓨터 과학에서 데이터나 값을 미리 복사해 놓는 임시 장소를 가리킨다. 
캐시는 캐시의 접근 시간에 비해 원래 데이터 를 접근하는 시간이 오래 걸리는 경우나 값을 다시 계산하는 시간을 절약하고 싶은 경우에 사용한다. 
캐시에 데이터를 미리 복사해 놓으면 계산이나 접근 시간 없이 더 빠른 속도로 데이터에 접근할 수 있다.

캐시는 시스템의 효율성을 위해 여러 분야에서 두루 쓰이고 있다.
```

<br />

### 캐시의 특징을 보면 안 쓸 이유가 딱히 없어보입니다. 그렇기에 캐시는 시스템의 효율성을 위해 여러 분야에서 두루 쓰이고 있습니다.

> 한 번은 이해하고 넘어갈 필요가 있어보이네요!

- CPU
- 디스크(DRAM, HDD)
- CDN
- 웹 브라우저
- 운영체제
- 데이터베이스
- 파일 시스템
- HTTP
- Proxy
- Application
- ...

<br />
<br />

## 3️⃣ Image Cache 이해하기

<img width="1000" alt="스크린샷 2022-11-19 오전 12 28 05" src="https://user-images.githubusercontent.com/61109660/202740732-e986d10a-6808-4158-9123-2a085b5cbe9c.png">

- 애플리케이션 내에서 이미지를 사용하는 경우가 상당히 많죠.
- 안 쓰이는 곳이 찾기 힘들 정도입니다.
- 이미지를 기기 내에 저장해놓고 쓰기도 하고, 서버에서 받아와 쓰기도 합니다.

<br />

### 카카오톡 프로필 화면을 예로 들어보겠습니다. 만약에 프로필 이미지를 1년동안 바꾸지 않는 상황이라면 어떡할까요?

- 프로필 사진을 짧게는 몇 달, 길게는 몇 년 동안 프로필 사진을 바꾸지 않는 사용자들이 생각보다 많습니다.

<br />

### 그렇다면 앱을 접속할 때마다 서버에서 프로필 이미지를 받아올 필요가 있을까요?

### 변경이 자주 일어나지 않은 데이터에 대해서 서버에 불필요한 요청을 줄일 수는 없을까요?
> 용량이 상대적으로 큰 데이터(예시에서는 이미지 데이터)를 캐시에 저장해놓고 사용하면 이미지를 로드해오는 시간을 줄일 수 있고, 불필요한 네트워크 요청을 줄일 수 있을 것입니다.

<br />

### 위에서 살펴보았던 캐시의 개념을 이미지를 처리하는데에 사용해보자는 것입니다.
- 이를 오픈소스화 해놓은 것이 Kingfisher가 되는 것이죠.

<br />
<br />

## 4️⃣ iOS에서의 캐시
> iOS에서는 크게 2가지 방식을 생각해볼 수 있습니다.  
> 메모리에 캐시를 구성하는 방법이랑 디스크에 캐시를 구성하는 방법으로 나눌 수 있어요.

1. 메모리 캐시 - NSCache(in-memory)
2. 디스크 캐시 - FileManager, UserDefaults, Core Data ...

***자매품) URLCache(in-memory, on-disk)*** - URLCache는 on-disk 방식으로도 캐시를 사용할 수 있습니다.

<br />

### 장단점이 분명하기에 적절히 혼합해서 사용하는 것이 좋습니다.

||메모리|디스크|
|:--|:--|:--|
|접근 속도|빠름|느림|
|데이터|앱 종료 시 데이터 삭제|앱 종료시에도 데이터 유지 가능|
|용량 및 가격|상대적으로 작고 비쌈|상대적으로 크고 쌈|

<br />

### 1. 메모리 캐시(with NSCache)
> 메모리 캐시는 Apple에서 제공하는 내장 클래스인 NSCache를 사용해서 구현할 수 있습니다. 딕셔너리와 비슷한 모습을 띠고 있습니다.

![nscache](https://user-images.githubusercontent.com/61109660/202746128-575f6987-9b01-4882-aa40-1892b75bdd63.png)

> 리소스가 부족할 때 제거될 수 있는 일시적인 키-값 쌍을 임시로 저장하는데 사용하는 변경 가능(Mutable)한 컬렉션

- 시스템 메모리를 너무 많이 사용하지 않도록 Auto-Eviction Policies(자동 제거 정책)을 따릅니다.
- Thread-Safe 합니다. 캐시를 Lock하지 않아도 다른 Thread에서 캐시의 항목을 추가, 제거, 검색할 수 있습니다.
- NSMutableDictionary와 달리 캐시에 넣은 키(Key)를 복사하지 않습니다.
- 탐색과 접근을 O(1)의 시간 복잡도로 할 수 있습니다.

### 자동 제거 정책
![스크린샷 2022-11-16 오후 4 44 58](https://user-images.githubusercontent.com/61109660/202747147-35eaee95-2d36-4adf-b713-419febc9090d.png)

> 기본적으로 구현은 LRU/LFU의 하이브리드 형태로 구현되어있다고 하네요.  
> 옵션을 설정해주면 Cost가 작은 Object부터 삭제하도록 동작합니다.

**countLimit**
- 캐시가 보유하는 최대 Object 수
- 기본값은 0(제한 없음)

**totalCostLimit**
- 캐시가 Object 제거를 시작하기 전에 보유할 수 있는 최대 비용(byte)
- 기본값은 0(제한 없음)

### 사용법

#### GET(접근)
```swift
func object(forKey: KeyType) -> ObjectType?
```

#### SET(저장)
```swift
func setObject(ObjectType, forKey: KeyType)
func setObject(ObjectType, forKey: KeyType, cost: Int)
```

#### REMOVE(제거)
```swift
func removeObject(forKey: KeyType)
func removeAllObjects()
```

#### 캐시 선언
```swift
private let cache = NSCache<NSString, UIImage>()
```

<br />

### 2. 디스크 캐시(with FileManager)
> 메모리 캐시에서 데이터를 조회해보고 없다면 다음으로 디스크 캐시를 확인해보는 과정을 거쳐봅시다.  
> iOS에서는 FileManager를 이용해볼 수 있습니다. Library/Caches Directory를 이용해봅니다.

#### 2-1. Cache의 디렉터리 경로를 가져옵니다.
```swift
guard let path = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first else { return }
```

#### 2-2. Image 파일 경로를 만들어줍니다.
```swift
var filePath = URL(fileURLWithPath: path)
filePath.appendPathComponent("경로")
```

#### 2-3. Disk에 파일이 있는지 확인합니다.
```swift
if fileManager.fileExists(atPath: filePath.path) {
  guard let data = try? Data(contentsOf: filePath) else { return }
  guard let image = UIImage(data: data) else { return }
  completion(image)
  return
} else {
  // No data in disk cache
}
```

![스크린샷 2022-11-19 오전 1 06 49](https://user-images.githubusercontent.com/61109660/202749252-5a82371b-19bf-4ea3-87dd-930e88831a8f.png)
- Kingfisher를 사용하는 프로젝트에 가보면 Cache를 사용하는 것을 확인해볼 수 있습니다.
- Library/Caches 디렉터리를 확인해보세요!

<br />
<br />

## 5️⃣ 이미지 캐시 동작 원리
<img width="450" alt="스크린샷 2022-11-19 오전 1 08 00" src="https://user-images.githubusercontent.com/61109660/202749525-fd521f11-a568-4329-b442-261fb89079c2.png">

```
메모리 캐시 -> 디스크 캐시 -> 서버
```
- 캐시에 데이터가 있으면 바로 가져오고 없으면 서버에 데이터를 요청하고 가져온 뒤 캐시에 저장하는 과정을 거칩니다.

### 상세 과정
1. 메모리 캐시에서 이미지를 검색합니다.
2. 없는 경우에 디스크 캐시에서 이미지를 검색합니다.
3. 없는 경우에 네트워크 통신을 통해 이미지를 가져옵니다.
4. 메모리 캐시와 디스크 캐시에 이미지를 저정합니다.
5. 이후 요청부터는 메모리 캐시에서 이미지를 불러옵니다.
6. 앱을 재시작한 이후의 요청부터는 디스크 캐시에서 이미지를 불러오고 메모리캐시에 이미지를 저정합니다.

<br />
<br />

## 6️⃣ ETag

<img width="1000" alt="스크린샷 2022-11-19 오전 1 12 54" src="https://user-images.githubusercontent.com/61109660/202750527-31594075-e2b0-4514-8fc5-afa0880aa8d5.png">

- 그런데 문득 의문점이 생길 수 있어요.
- 캐시에 이미지를 저장해놓고 사용하고 있는데, 만약에 서버의 원본 데이터에서 변경이 일어나면 어떡하죠?

<br />

이 문제를 ETag라는 것으로 해결해볼 수 있습니다.

<br />

### ETag
> ETag는 리소스에 대한 고유한 해시값입니다.  
> 리소스의 내용이 업데이트 되면 ETag 또한 변경됩니다.

> ETag를 저장해서 가지고 있으면서 서버의 값과 비교해보는 것이죠.  
> 이를 통해서 리소스의 최신화 상태를 체크해볼 수 있습니다.

<br />

### 맥주 API를 이용해서 이미지를 받아오는 상황이라고 가정해봅시다.

> 무작정 캐시에 있는 데이터를 가져다 쓰는 것이 아니라, 쓰기 전에 서버에 내가 쓰려고 하는 리소스가 최신 상태인지 확인하는 과정을 한 번 거치는 것입니다. 그 확인하는 작업을 ETag라는 것으로 해보는 것이죠. 마치 리소스의 신분증이라고 생각해볼 수 있습니다.

![ETag](https://user-images.githubusercontent.com/61109660/202751314-c2ac0761-ade3-41c4-b45f-1933c58a5cbb.png)
![ETag-1](https://user-images.githubusercontent.com/61109660/202751444-1454e086-a2a3-4e7a-97b1-a30212db58d8.png)
![ETag-2](https://user-images.githubusercontent.com/61109660/202751473-aff0d612-ea21-458e-b97a-e09ee09eae85.png)
![ETag-3](https://user-images.githubusercontent.com/61109660/202751509-75e93ef0-f8f2-4246-9ebd-a758e41d1de3.png)
![ETag-5](https://user-images.githubusercontent.com/61109660/202751584-29777051-be14-4b57-8bd5-e370f92acb57.png)
![ETag-6](https://user-images.githubusercontent.com/61109660/202751596-b755acc1-bfa2-4048-99a9-f7d61932100a.png)
![ETag-4](https://user-images.githubusercontent.com/61109660/202751525-a9b9ebe2-b620-47d4-8fb8-cdbe4d8161e5.png)
![iOS에서의 캐시](https://user-images.githubusercontent.com/61109660/202751553-8f6e73d5-6b12-483a-a73c-12226f48a5ae.png)

<br />
<br />

## 7️⃣ 마무리

> Cache-Control이나 Cache-Policy 등 정책적인 부분으로 들어가면 내용도 많고 깊습니다. 지금 당장은 이 정도만 이해해봐도 좋지 않을까 싶은데요. 그동안 무심코 사용하는 라이브러리가 대략적으로 어떤 원리를 가지고 동작하는지 알아볼 수 있어서 좋았던 것 같습니다. 그리고 공부를 하다보니까 캐시라는 개념이 이미지 캐시 말고도 생각보다 많은 곳에 녹아있는 것을 알게되었는데요. 이후에 시간이 있을 때 조금 더 찾아보고 보완해보려고 합니다.

### 🐙 시간이 된다면 간단한 부분에 대해서는 캐시를 직접 구현해보는 것은 어떨까요?
