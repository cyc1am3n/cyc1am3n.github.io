---
layout: post
title:  "[Reversing] 1장 리버싱 개론"
subtitle: "Reverse Engineering Chapter 1. Introduction to Reversing"
post_description: "리버스 엔지니어링 Chapter 1. 리버싱 개론"
date:   2020-03-01 20:50:00 +0900
tags: [reversing]
background: '/img/posts/notebook.jpg'
author: cyc1am3n
comments: true
---

해당 포스팅은 강병탁 교수님의 수업과 [리버스 엔지니어링 바이블](https://wikibook.co.kr/reverse-engineering-bible/)을 참고해 작성했습니다.

---

### 리버스 엔지니어링

- 소스를 역추적하는 것을 말함.
- 소스코드를 빌드해서 만들어진 exe, dll의 바이너리를 분석해 원래의 소스코드가 어떤 식으로 만들어져 있는지 파악한다.

<br/>

### 리버싱이 쓰이는 분야

#### **좋은 쪽**

- 악성코드 분석
- 모의해킹과 보안검수
  - Black-Box Testing: 아무것도 없는 상황에서 파일만 주고 분석해야 함.
  - Gray-Box Testing: 어느정도 부분적인 정보를 제공해준다. ex) 구조
  - White-Box Testing: 소스코드까지 제공해준다.
- 취약점 발견 및 버그 수정
- 경쟁 제품 분석 ex) Anti-Virus, 키보드 보안 솔루션

#### **나쁜 쪽**

- 보안 솔루션 우회, 악성코드 개발
- 개임 해킹툴 개발
- 인증 우회
- 날짜 제한, 사용기능 제한, 시리얼 키 추출 등의 **크랙**

<br/>

### 크랙

- 프로그램의 제한된 기능을 제거시키는 것.

- 소스코드를 변조시켜서 원래 의도와는 다른 결과를 나타내도록

  - 분기문 바꿔치기

    ```diff
    <원래 코드>
    test al, al
    jz 0x401234
    
    <변조 코드>
    test al, al
    jnz 0x401234
    ```

  - 명령어 삭제

    ```diff
    <원래 코드>
    mov eax, ds[ebx]
    call 0x403635
    
    <변조 코드>
    mov eax, ds[ebx]
    nop
    nop
    nop
    nop
    nop
    ```

- 보통의 프로그램은 Thread를 사용해 반복적으로 파일의 변조를 확인하는데, thread를 공격해서 보안 확인을 못하도록 만든다. (요즘에는 thread의 작동이 멈추면 프로그램도 꺼지도록 만들어지고 있다.)

<br/>

### 어셈블리

- 소프트웨어 체인에서 가장 낮은 레벨
- 리버싱의 언어
- **컴파일과 리버싱의 차이**
  - 컴파일러는 소스코드를 어셈블리어로 바꿔서 프로그램을 만들고
  - 리버싱에서는 프로그램을 어셈블리로 바꿔서 소스코드를 알아낸다

<br/>

### 정적 분석과 동적 분석

- 정적 분석
  - 코드가 **실행되지 않은 상태**에서 보는 작업(감염은 되지 않음)
  - 내가 분석 중인 상황을 해커가 절대 알 수 없음
  - 한계가 있음(시체를 부검하는 느낌)
- 동적 분석
  - 실제로 바이너리를 **실행시켜서** 감염시킨 뒤 상태를 보는 작업
  - 옵져버라고 생각할 수 있음
  - 악성코드의 동작 내역은 다 볼 수 있지만, 시간이 많이 걸리고 번거로움(특정 시간에만 작동하는 코드가 있을수도, 원래대로 복구하는 수고)

<br/>

### 리버싱의 순서

1. **PE Header를 통해 뭘로 언제 코딩한 파일인지 알아내기**
   - 파일 스캐너(ex. PEiD)를 사용하면 PE Header를 볼 수 있음
   - 언제 어떤 컴파일러를 사용했는지, 메모리에 올라가는 Offset 주소가 어디 인지 등
2. **PE, String, Resource로 파일에 어떤 정보가 들어있는지 찾아보기**
   - 친절하게 써놓은 정보가 많아서 String만 분석해도 얻을 수 있는 것이 많다. (String.exe 활용)
     - 개발자가 넣은 에러 메시지, 디버깅용 메시지, API의 이름, 해커의 Email, 해커의 C2 IP 등
   - Resource Hacker를 사용하면 프로그램의 version info를 알 수 있다.
     - Company Name, File Version 등
     - 아이콘과 이미지도 볼 수 있다.
     - 회사 명이 MS인데 바이러스인 경우가 있을 경우 PE Header의 CheckSum이 비어있다.

3. **Packing(코드의 암호화)가 되어 있는지 확인**

   - 패킹이 되어 있으면 정적 분석이 힘들다. (아래 그림에서는 B를 분석해야 함)

   {% include image.html file="https://user-images.githubusercontent.com/11629647/75625440-4b85bd00-5c01-11ea-96ee-f56fab5e976f.png" class="center-95"%} 

4. **Disassembling을 통해 어떤 코드가 들어있는지 확인**

<br/>

### CheckSum, CRC, Hash

- 파일의 손상/변조를 확인할 때 파일의 바이너리 값을 확인 하는데..

- CheckSum: 파일의 값을 다 더해라. (정말 간단한 체크, 취약)

- CRC(Cyclic Redundancy Checking): 나눌 때 뺄셈 대신 XOR을 사용해서 나온 최종 나머지

  - 빠른 무결성 체크, 네트워크에서 주로 사용

  {% include image.html file="https://user-images.githubusercontent.com/11629647/75625163-d0230c00-5bfe-11ea-9583-3c4adcad4012.png" class="center-95"%} 

- Hash: 충돌을 최소화 한 유일한 값. ex) SHA256

  - 민감한 데이터(비밀번호, 전자 서명) 등의 무결성을 검증할 때 사용

<br/>

### Disassembler, Debugger, Decompiler

- Disassembler: 기계어를 어셈블리 언어로 변환
- Debugger: 대상 프로그램을 테스트하고 디버그함
- Decompiler: exe파일을 원본 소스코드로 변환

<br/>

### 어셈블리의 기본 구조

- 명령어(opcode) + 인자(operand)

  ```diff
  push 337 (1개의 operand)
  mov eax, 1 (2개의 operand)
  ```

- operand는 보통 1~2개 사이이며 3개 이상인 경우는 나올 때마다 찾아보기

  ```diff
  push 337 -> 68 37 07 00 00
  
  mov eax, 1 -> B8 01 00 00 00
  
  mov ebx, 1 -> BB 01 00 00 00
  ```

<br/>

### 어셈블리 표기법

- `0x12345678` 을 어떻게?
  - 12 34 56 78 ← Big Endian
  - 78 67 34 12 ← Little Endian (주로 이걸 사용)

{% include image.html file="https://user-images.githubusercontent.com/11629647/75625166-d4e7c000-5bfe-11ea-9592-5d262a4b9382.png" class="center-95"%} 

### 레지스터

- CPU 가 사용하는 변수이다.
- 메모리를 사용하지 않기 때문에 속도가 빠르다.
- 레지스터가 모자라면 stack을 사용한다.
- EAX → EDX → ECX → EBX 순으로 자주 사용한다.

1. **EAX**
   - **산술 계산**을 하며, 리턴값을 전달한다.
   - 더하기, 빼기, 곱셈, 나눗셈 등에 EAX가 자주 등장한다.
   - **함수의 리턴값**이나 return 100, return False 등에 사용된다.
2. **EDX**
   - EAX와 역할은 같되, 리턴값의 용도로 사용되지는 않는다.
   - 각종 연산에 사용하며, 복잡한 연산이 필요할 때 덤으로 쓰이기도 한다.
   - EDX에서 D는 DATA의 약자이다.
3. **ECX**
   - C 는 count의 약자이며, **루프문**을 수행할 때 **카운팅**하는 역할을 한다.
   - ECX에 양수값을 넣고, 감소시키며 카운터가 0이 될 때까지 루프를 돈다.
   - 카운팅 할 필요가 없을 때는 변수로 사용한다.
4. **EBX**
   - 어떤 목적을 가지고 만들어진 레지스터가 아니다.
   - 하나쯤 더 필요하거나 공간이 필요할 때 프로그래머나 컴파일러가 알아서 만들어 쓴다.
5. ESI, EDI
   - EAX ~ EDX는 주로 연산에 사용되지만 ESI는 문자열이나 각종 반복 데이터를 처리 또는 메모리를 옮기는 데 사용된다.
   - ESI는 시작지 인덱스, EDI는 목적지 인덱스로 사용된다.

<br/>

### 어셈블리 명령어들

1. PUSH, POP

   - 스택에 값을 넣는 것을 PUSH, 스택에 있는 값을 가져오는 것이 POP이다.
   - 하나의 오퍼랜드를 사용한다.
   - 함수의 파라미터로 사용한다.

2. MOV

   - 단지 **값을 넣는 역할**을 한다.
   - `MOV eax, 1` - eax에 1을 넣는다.
   - 가장 많이 사용된다.

3. LEA

   - 주소를 넣는 역할을 한다. (MOV는 값을 넣음)

   > (가정) 레지스터와 메모리에 다음과 같은 값이 들어있다.
   >
   > esi:      0x401000 | *esi:         5640EC83
   >
   > → esi에는 0x401000이라는 값이, esi가 가리키는 번지에 5640EC83이란 값이 들어있다.
   >
   > `lea eax, dword ptr ds:[esi]` : esi가 0x401000이므로 eax는 0x401000이 들어온다.
   >
   >  `mov eax, dword ptr ds:[esi]` : eax에는 0x401000번지가 가리키는 5640EC83이 들어온다.

4. ADD

   - `ADD src, dest`
   - src에서 dest의 값 만큼 더하는 명령어이다.

5. SUB

   - `SUB src, dest`
   - add와 반대되는 뺄셈 명령어로, add와 쌍으로 생각하자.