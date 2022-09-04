---
layout: post
title:  "[Reversing] 2장 디버깅 기본"
subtitle: "Reverse Engineering Chapter 2. Basis of Debugging"
post_description: "리버스 엔지니어링 Chapter 2. 디버깅 기본"
date:   2020-03-01 21:20:00 +0900
tags: [reversing]
background: '/img/posts/notebook.jpg'
author: cyc1am3n
comments: true
---

해당 포스팅은 강병탁 교수님의 수업과 [리버스 엔지니어링 바이블](https://wikibook.co.kr/reverse-engineering-bible/)을 참고해 작성했습니다.

---

### 디버깅을 할 때 사용하는 것

- 중단점(Break Point) 설정
- Step Over: 다음 라인으로 이동한다. 메서드가 있어도 그냥 무시하고 다음 라인으로 이동한다.
- Step Into: 메서드가 존재할 경우 그 안으로 들어가 메서드 진행 상황을 볼 수 있도록 한다.
- Retn까지 실행: 현 메서드에서 바로 리턴한다.

<br/>

### 리버싱에 영향을 주는 옵션

1. **맵 파일 생성** ("**예**"를 사용)
   - 메모리에 올라가는 주소를 텍스트로 저장해준다.
2. **임의 기준 주소** ("**아니오**"를 사용)
   - 임의 기준 주소를 사용하면 메모리에 올릴 주소를 랜덤으로 해서 올리게 된다.
   - 아니오로 하면 대부분 400000 쪽으로 배정 됨
   - 공부할 때 말고 실제로는 "예"를 사용한다.
3. **최적화** ("**사용 안 함**"으로 설정)
   - "사용"으로 설정하면 개발자가 짠 코드를 컴파일러가 바꿔서 빌드한다. (리버싱 할 때 헷갈림)
4. **런타임 라이브러리** ("**MD**"로 설정)
   - MT(**M**ulti **T**hreaded): exe안에서 다 해결
     - 리버싱 방지를 위해서는 이 옵션을 사용한다.
   - MD(**M**ulti Thread **D**LL): 외부의 dll을 사용해 빌드, 해당 dll이 없으면 에러남
     - **DLL이란 동적 연결 라이브러리로 특정 함수를 담고 있는 파일이다.(자주 사용하는 함수가 담겨있다.)**
       - dll을 가져다 쓰면 프로그램의 용량을 줄일 수 있다.
     - ex) strcmp, strcpy는 ucrt~~.dll에 존재한다.

<br/>

### PE Format

- 우리가 만든 이 파일이 실행할 수 있는, 이식 가능한 다른 곳에 옮겨도(**P**ortable) 실행이 가능하도록(**E**xecutable) 만들어놓은 포맷

<br/>

### 빌드 과정

{% include image.html file="https://user-images.githubusercontent.com/11629647/75625613-2bef9400-5c03-11ea-99a2-539a47943f6a.png" class="center-95"%} 

- 소스코드를 작성하고 컴파일 하면 소스와 관계된 모든 헤더 파일과 합쳐서 하나의 기계어 코드가 생긴다. (obj 파일이 만들어짐)
- 운영체제에서 프로그램을 실행하기 위해서는 링커가 동적 라이브러리, 리소스 데이터 등을 처리할 수 있는 정보를 어딘가에 작성한다. (링크 과정)
- 여기서 윈도우는 약속된 규약에 맞춰 정보를 입력하며, exe 파일을 만들 때 헤더에 그 정보를 기입한다.
- 바로 그게 PE Format으로 생성되는 exe 파일이다.
- **컴파일**은 **소스코드 → 바이너리**(obj 파일)의 과정이고, **빌드**는 실행 가능한 **exe까지 만드는** 전체 과정이다.

<br/>

### PE Header

- PE 헤더의 처음에는 시그니쳐가 있는데 MS-DOS의 헤더는 MZ로 시작한다.
- PE Viewer 같은 프로그램으로 PE 헤더를 볼 수 있다.
- 한편 Process Explorer 같은 프로그램으로 해당 프로그램이 실행되고 있는 메모리 주소를 알 수 있는데,
- PE Header의 Optional Header 부분의 ImageBase와 같다.
- Optional Header에서 중요한 부분
  - ImageBase: PE 파일이 실제 메모리 번지에 매핑되는 번지
  - AddressOfEntryPoint: 실제 파일이 메모리에서 실행되는 시작 지점을 말한다.
  - 올리디버거 등을 통해 파일을 실행 시켰을 때 첫 실행 지점을 ImageBase와 AddressOfEntryPoint를 더한 위치에 지정해서 멈춰준다.

{% include image.html file="https://user-images.githubusercontent.com/11629647/75625688-e41d3c80-5c03-11ea-9b2f-685f15cd1f8a.png" class="center-50"%} 

### 올리디버거에서 디버깅 하는 방법

- Attach: 이미 실행되어 있는 프로세스를 OllyDBG에 붙힌다.
- Run via Olly: OllyDBG를 통하여 새 프로세스를 실행한다.(=드래그)
- Attach를 사용하면 프로그램의 초기 단계는 분석할 수 없지만 Run via Olly를 사용하면 분석 할 수 있다.