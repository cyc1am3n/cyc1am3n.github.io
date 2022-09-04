---
layout: post
title:  "[Reversing] 4장 C 코드 리버싱 방법"
subtitle: "Reverse Engineering Chapter 4. C Code Reversing"
post_description: "리버스 엔지니어링 Chapter 4. C Code Reversing"
date:   2020-03-01 21:52:00 +0900
tags: [reversing]
background: '/img/posts/notebook.jpg'
author: cyc1am3n
comments: true
---

해당 포스팅은 강병탁 교수님의 수업과 [리버스 엔지니어링 바이블](https://wikibook.co.kr/reverse-engineering-bible/)을 참고해 작성했습니다.

---

### if 문

```
int Temp(int a) {
	int b = 1;
	if (a == 1) {
		a++;
	} else {
		b++;
	}
	return b;
}

int main(int argc, char* argv[]) {
	Temp(1);
}
```

- 위의 코드를 디스어셈블링하면 다음과 같다.

  ```diff
  .text:00401000 push ebp
  .text:00401001 mov ebp, esp
  .text:00401003 push ecx
  .text:00401004 mov dword ptr [ebp-4],1
  .text:0040100B cmp dword ptr [ebp+8],1
  .text:0040100F jnz short loc_40101C
  .text:00401011 mov eax, [ebp+8]
  .text:00401014 add eax,1
  .text:00401017 mov [ebp+8], eax
  .text:0040101A jmp short loc_401025
  .text:0040101C mov ecx, [ebp-4]
  .text:0040101F add ecx,1
  .text:00401022 mov [ebp-4], ecx
  .text:00401025 mov eax, [ebp-4]
  .text:00401028 mov esp, ebp
  .text:0040102A pop ebp
  .text:0040102B retn
  ```

- 함수의 골격은 다음과 같다.

  ```diff
  .text:00401000 push ebp
  .text:00401001 mov ebp, esp
  ...
  .text:00401028 mov esp, ebp
  .text:0040102A pop ebp
  .text:0040102B retn
  ```

- `push ecx` : ecx를 스택에 보관한다. 현재 지역 변수는 b 하나밖에 없어서 굳이 스택을 확보하지 않았다.

- `mov dword ptr [ebp-4]` : 스택에 값을 직접 넣는다. [ebp-4]는 b 변수에 해당하는 값이다. (int b=1)

  ```diff
  cmp dword ptr [ebp+8], 1
  jnz short loc_40101C
  mov eax, [ebp+8]
  add eax, 1
  mov [ebp+8], eax
  ```

- 이 부분은 `if(a==1)` 에 해당한다.

- [ebp+8]은 첫 번째 파라미터(a)를 가리킨다.

- `cmp dword ptr [ebp+8], 1` : 첫 번째 파라미터가 1인지 비교한다. 결과가 0이면(if(a==1)) jnz를 통과한다.

- 마지막 세 줄은 [ebp+8], 즉 a에 1을 더하는 부분인데, 스택 메모리에서는 연산을 할 수 없기 때문에 `add [ebp+8], 1` 의 사용은 불가능하다.

- jnz에 걸렸을 경우도 현재 코드와 비슷하니 생략하겠다.

  ```diff
  mov eax, [ebp-4]
  mov esp, ebp
  pop ebp
  retn
  ```

- `mov eax, [ebp-4]` : eax에 b([ebp-4]) 변수의 값을 넣어주고 리턴한다. (리턴값은 eax이다.)

<br/>

### 반복문

- 루프문은 for나 while, goto 등이 있지만 컴퓨터가 보기에는 결국 카운터 레지스터를 이용한 반복행위일 뿐이다.

  ```c
  int loop(int c) {
    int d;
    for (int i=0;i<=0x100;i++) {
      c--;
      d++;
    }
    return c+d;
  }
  ```

- 위의 코드를 디스어셈블링하면 다음과 같다.

  ```diff
  .text:00401000 push ebp
  .text:00401001 mov ebp, esp
  .text:00401003 sub esp,8
  .text:00401006 mov dword ptr [ebp-8],0
  .text:0040100D jmp short loc_401018
  .text:0040100F mov eax, [ebp-8]
  .text:00401012 add eax,1
  .text:00401015 mov [ebp-8], eax
  .text:00401018 cmp dword ptr [ebp-8], 100h
  .text:0040101F jg short loc_401035
  .text:00401021 mov ecx, [ebp+8]
  .text:00401024 sub ecx,1
  .text:00401027 mov [ebp+8], ecx
  .text:0040102A mov edx, [ebp-4]
  .text:0040102D add edx,1
  .text:00401030 mov [ebp-4], edx
  .text:00401033 jmp short loc_40100F
  .text:00401035 mov eax, [ebp+8]
  .text:00401038 add eax, [ebp-4]
  .text:0040103B mov esp, ebp
  .text:0040103D pop ebp
  .text:0040103E retn
  ```

- 함수의 앞뒤 모습은 다음과 같다.

  ```diff
  .text:00401000 push ebp
  .text:00401001 mov ebp, esp
  .text:00401003 sub esp,8 ⭐️
  ...
  .text:0040103B mov esp, ebp
  .text:0040103D pop ebp
  .text:0040103E retn
  ```

- ⭐️ 부분은 함수 내에서 지역변수로 8바이트 사용하겠다는 의미이다.

  ```diff
  .text:0040100F mov eax, [ebp-8]
  .text:00401012 add eax,1
  .text:00401015 mov [ebp-8], eax
  ```

- 위 부분은 for문에서 i++에 해당한다.

  ```diff
  .text:00401018 cmp dword ptr [ebp-8], 100h
  .text:0040101F jg short loc_401035
  ```

- `cmp dword ptr [ebp-8], 100h` : [ebp-8](i)와 0x100과 비교한다.

- `jg short loc_401035` : [ebp-8]이 0x100과 비교해 크면 0x401035번지로 점프한다. (`jg` 는 jump greater를 의미)

  ```diff
  .text:00401035 mov eax, [ebp+8]
  .text:00401038 add eax, [ebp-4]
  .text:0040103B mov esp, ebp
  .text:0040103D pop ebp
  .text:0040103E retn
  ```

- i가 0x100보다 클 때 점프해서 도착한 부분이다.

- `mov eax, [ebp+8]` / `add eax, [ebp-4]` : return c + d에 해당하는 부분이다.

  ```diff
  .text:00401021 mov ecx, [ebp+8]
  .text:00401024 sub ecx,1
  .text:00401027 mov [ebp+8], ecx
  .text:0040102A mov edx, [ebp-4]
  .text:0040102D add edx,1
  .text:00401030 mov [ebp-4], edx
  .text:00401033 jmp short loc_40100F
  ```

- jg를 통과해 for 문 안의 코드를 수행하는 부분이다.

- ecx를 활용해 [ebp+8](d)에 1을 더하고, edx를 활용해 [ebp-4](c)에 1을 더한다.

- 그리고 다시 jg 부분으로 돌아가 대소비교를 진행한다.

<br/>

### 구조체와 API Call

- 구조체의 각 멤버 변수가 어떤 식으로 사용되는지 살펴볼 필요가 있다.

- 또한 인자가 들어가는 상황에서는 디스어셈블된 코드가 어떻게 변경되는지 알아야 한다.

- `STARTUPINFO` 와 `PROCESS_INFORMATION` 구조체를 이용해 `CreateProcess()` 로 새 프로세스를 생성하는 코드를 살펴보자.

  ```c
  void RunProcess() {
    STARTUPINFO si;
    PROCESS_INFORMATION pi;
    ZeroMemory( &si, sizeof(si) );
    si.cb = sizeof(si);
    ZeroMemory( &pi, sizeof(pi) );
    // Start the child process.
    if(!CreateProcess(NULL, “MyChildProcess", NULL, NULL, FALSE, 0, NULL, NULL, &si, &pi )) {
      printf( "CreateProcess failed.\n" );
      return;
    }
    // Wait until child process exits.
    WaitForSingleObject( pi.hProcess, INFINITE );
    // Close process and thread handles.
    CloseHandle( pi.hProcess );
    CloseHandle( pi.hThread );
  }
  ```

- `STARTUPINFO` 와 `PROCESS_INFORMATION` 구조체를 선언하고 `CreateProcess()` 를 호출한다.

- 그러면 두 구조체에는 생성된 새 프로세스와 관련된 값이 들어오며, 해당 구조체의 멤버 변수인 프로세스 핸들을 이용해 프로세스가 종료될 때 까지 `WaitForSingleObject()` 로 대기한다.

- 프로세스가 종료되면 관련 핸들을 닫는다.

- 위 코드를 디스어셈블하면 다음과 같다.

  ```diff
  0x401000 PUSH EBP
  0x401001 MOV EBP,ESP
  0x401003 SUB ESP,54
  0x401006 PUSH 44
  0x401008 PUSH 0
  0x40100A LEA EAX,DWORD PTR SS:[EBP-54]
  0x40100D PUSH EAX
  0x40100E CALL calling.004011A0
  0x401013 ADD ESP,0C
  0x401016 MOV DWORD PTR SS:[EBP-54],44
  0x40101D PUSH 10
  0x40101F PUSH 0
  0x401021 LEA ECX,DWORD PTR SS:[EBP-10]
  0x401024 PUSH ECX
  0x401025 CALL calling.004011A0
  0x40102A ADD ESP,0C
  0x40102D LEA EDX,DWORD PTR SS:[EBP-10]
  0x401030 PUSH EDX
  0x401031 LEA EAX,DWORD PTR SS:[EBP-54]
  0x401034 PUSH EAX
  0x401035 PUSH 0
  0x401037 PUSH 0
  0x401039 PUSH 0
  0x40103B PUSH 0
  0x40103D PUSH 0
  0x40103F PUSH 0
  0x401041 PUSH calling.00407030
  0x401046 PUSH 0
  0x401048 CALL DWORD PTR DS:CreateProcessA
  0x40104E TEST EAX,EAX
  0x401050 JNZ SHORT calling.00401061
  0x401052 PUSH calling.00407040
  0x401057 CALL calling.0040116F
  0x40105C ADD ESP,4
  0x40105F JMP SHORT calling.00401081
  0x401061 PUSH -1
  0x401063 MOV ECX,DWORD PTR SS:[EBP-10]
  0x401066 PUSH ECX
  0x401067 CALL DWORD PTR DS:WaitForSingleObject
  0x40106D MOV EDX,DWORD PTR SS:[EBP-10]
  0x401070 PUSH EDX
  0x401071 CALL DWORD PTR DS:CloseHandle
  0x401077 MOV EAX,DWORD PTR SS:[EBP-C]
  0x40107A PUSH EAX
  0x40107B CALL DWORD PTR DS:CloseHandle
  0x401081 MOV ESP,EBP
  0x401083 POP EBP
  0x401084 RETN
  ```

- 코드가 길지만 처음부터 천천히 살펴보자.

  ```diff
  <함수의 시작>
  0x401000 PUSH EBP
  0x401001 MOV EBP,ESP
  <스택 확보>
  0x401003 SUB ESP,54
  ```

- 레지스터만으로는 메모리를 감당할 수 없을 때 스택을 늘려서 공간을 확보하는데, 이 경우 0x54 바이트만큼 스택을 늘렸다.

- 한편, 우리가 사용한 두 구조체는 다음과 같다.

  ```c
  typedef struct _STARTUPINFO {
    DWORD cb;            // [EBP-54]
    LPTSTR lpReserved;   // [EBP-50]
    LPTSTR lpDesktop;    // [EBP-4C]
    LPTSTR lpTitle;      // ...
    DWORD dwX;
    DWORD dwY;
    DWORD dwXSize;
    DWORD dwYSize;
    DWORD dwXCountChars;
    DWORD dwYCountChars;
    DWORD dwFillAttribute;
    DWORD dwFlags;
    WORD wShowWindow;
    WORD cbReserved2;
    LPBYTE lpReserved2;
    HANDLE hStdInput;
    HANDLE hStdOutput;
    HANDLE hStdError;
  } STARTUPINFO, *LPSTARTUPINFO;
  
  typedef struct _PROCESS_INFORMATION {
    HANDLE hProcess;     // [EBP-10]
    HANDLE hThread;      // [EBP-C]
    DWORD dwProcessId;   // [EBP-8] 
    DWORD dwThreadId;    // [EBP-4]
  } PROCESS_INFORMATION;
  ```

- 멤버 변수의 데이터 타입 크기를 다 계산해보면 `PROCESS_INFORMATION` 은 0x10 바이트이고, `STARTUPINFO` 는 0x44 바이트이다.

  - 즉 함수에 매개변수로 넘겨준 구조체의 데이터 사이즈(0x54)만큼 스택을 확보한 것이다.

  ```diff
  <ZeroMemory(&si, sizeof(si))>
  0x401006 PUSH 44
  0x401008 PUSH 0
  0x40100A LEA EAX,DWORD PTR SS:[EBP-54]
  0x40100D PUSH EAX
  0x40100E CALL calling.004011A0
  0x401013 ADD ESP,0C
  ```

- `STARTUPINFO` 의 크기는 0x44 였고 0x40100A 에서는 그 구조체 [EBP-54]의 포인터를 eax에 넣고 `ZeroMemory()`에 전달한다. (CALL 부분)

- 근데 CALL 윗 부분에서 PUSH로 전달한 변수는 총 3개인데, 원본 코드에서는 2개만 전달한다.

  - 이는 `ZeroMemory()` 가 실제로는 `memset()` 으로 전처리된 구문이고, 바이너리로 `memset()` 인자 개수대로 변환되었던 것이다.

    ```c
    // ZeroMemory 전처리문
    #define RtlZeroMemory(Destination,Length) memset((Destination),0,(Length))
    #define ZeroMemory RtlZeroMemory
    ```

- 그 다음에는 `ADD ESP,0C` 로 PUSH 했던 스택을 원래대로 보정하는데, 함수를 호출한 후 보정하는 것으로 보아 `cdecl` 규약의 함수라는 것을 알 수 있다. (4바이트 3개를 사용했으므로 0x0C 만큼)

  ```diff
  <구조체의 첫 번째 멤버 변수 처리>
  0x401016 MOV DWORD PTR SS:[EBP-54],44
  ```

- 구조체의 첫 번째 멤버 변수에 0x44를 넣으라는 의미이다. (`si.cb=sizeof(si)`)

  ```diff
  <PROCESS_INFORMATION 초기화>
  0x40101D PUSH 10
  0x40101F PUSH 0
  0x401021 LEA ECX,DWORD PTR SS:[EBP-10]
  0x401024 PUSH ECX
  0x401025 CALL calling.004011A0
  0x40102A ADD ESP,0C
  ```

- 첫 번째 구조체를 초기화 했던 방식과 동일하다. `PROCESS_INFORMATION` 구조체는 0x10 바이트이다.

  ```diff
  <CreateProcess>
  0x40102D LEA EDX,DWORD PTR SS:[EBP-10]
  0x401030 PUSH EDX
  0x401031 LEA EAX,DWORD PTR SS:[EBP-54]
  0x401034 PUSH EAX
  0x401035 PUSH 0
  0x401037 PUSH 0
  0x401039 PUSH 0
  0x40103B PUSH 0
  0x40103D PUSH 0
  0x40103F PUSH 0
  0x401041 PUSH calling.00407030
  0x401046 PUSH 0
  0x401048 CALL DWORD PTR DS:CreateProcessA
  ```

- `CreateProcess()` 를 호출하는 코드이다.

- CALL 문 이전에 호출되는 PUSH는 함수의 인자인데, 이는 원래 순서와 반대로 들어간다.

  - 스택은 LIFO의 특성을 가지고 있기 때문이다.

- 0x40102D의 [EBP-10]은 `PROCESS_INFORMATION`의 주소(&pi)이고,

- 0x40102D의 [EBP-54]은 `STARTUPINFO` 의 주소(&si)이다.

- 또한 원본 코드에서 NULL, FALSE, 0 의 구분이 있었지만, 여기에서는 모두 0으로 적용된다.

  ```diff
  <NULL 리턴 시 에러 처리>
  0x40104E TEST EAX,EAX
  0x401050 JNZ SHORT calling.00401061
  0x401052 PUSH calling.00407040
  0x401057 CALL calling.0040116F
  0x40105C ADD ESP,4
  0x40105F JMP SHORT calling.00401081
  ```

- 함수의 리턴값은 EAX에 들어오므로 `CreateProcess()` 가 NULL을 리턴했을 때에는 Zero flag가 1이 되어 점프문을 지나쳐 "CreateProcess failed.\n" 을 출력하는 코드이다.

- 0x0040116F는 `printf()` 가 된다.

  ```diff
  <대기 후 클로즈 루틴>
  0x401061 PUSH -1
  0x401063 MOV ECX,DWORD PTR SS:[EBP-10]
  0x401066 PUSH ECX
  0x401067 CALL DWORD PTR DS:WaitForSingleObject
  0x40106D MOV EDX,DWORD PTR SS:[EBP-10]
  0x401070 PUSH EDX
  0x401071 CALL DWORD PTR DS:CloseHandle
  0x401077 MOV EAX,DWORD PTR SS:[EBP-C]
  0x40107A PUSH EAX
  0x40107B CALL DWORD PTR DS:CloseHandle
  ```

- `WaitForSingleObject()` 에 두 개의 인자를 넣고 대기하는 코드이다.

- 첫 번째 인자에는 핸들이 들어가야 하는데, [EBP-10] 은 `PROCESS_INFORMATION` 구조체이고,

  - `DWORD PTR SS:` 로 4바이트를 넣으니 (DWORD는 4바이트를 의미) 첫 번째 인자인 `HANDLE hProcess`가 된다.

- 두 번째 인자로는 -1을 전달하는데 이는 `INFINITE` 로 선언된 값이다.(WinBase.h 에서)

- `WaitForSingleObject()` 가 리턴된 이후 각각의 인자로 `CloseHandle()` 을 실행하는데,

  - [EBP-10] 은 방금 확인한 프로세스의 핸들이고,
  - [EBP-C] 는 거기에서 4바이트 뒤인 `HANDLE hThread` 이다.

  ```diff
  <함수 종료>
  0x401081 MOV ESP,EBP
  0x401083 POP EBP
  0x401084 RETN
  ```

- 마지막으로 스택을 원래대로 복구해놓고 함수를 종료한다.