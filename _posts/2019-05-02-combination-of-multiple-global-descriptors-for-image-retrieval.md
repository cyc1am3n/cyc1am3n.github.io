---
layout: post
title:  "[Paper] Combination of Multiple Global Descriptors for Image Retrieval 리뷰"
subtitle: "CGD for Image Retrieval Review"
post_description: "Clova AI에서 발표한 Combination of Multiple Global Descriptors for Image Retrieval 논문에 대한 리뷰입니다."
date:   2019-05-02 16:40:54 +0900
tags: [paper, machine-learning]
background: '/img/posts/ai-vision/background.jpeg'
author: cyc1am3n
comments: true
---

### 시작하기 앞서

Image Retrieval 이라는 주제는 올해 초 부터 2월 까지 진행되었던 Naver AI Hackathon(AI-Vision)을 통해 알게 되었는데요,

Clova AI 측에서는 대회를 마무리 지으면서 "현재 이 내용에 대한 SOTA 급 성능을 내는 연구를 마쳤고 논문을 작성 중에 있다." 라고 이야기 해주셔서 기대하고 있었는데, 한동안 소식이 없어 기억에서 사라져가는 와중 3월 말에 ["Combination of Multiple Global Descriptors for Image Retrieval"](https://arxiv.org/pdf/1903.10663.pdf) 이라는 이름의 논문이 올라왔습니다.

논문이 나오고 한 달 늦은 일주일 전 이 소식을 듣게 되어서 부랴부랴 논문을 읽어 보고 급하게 작성한 리뷰를 포스팅하게 되었습니다.

아직까지는 작동 원리를 제대로 이해하지 못한 부분도 있어서 저도 이를 바탕으로 부족한 부분을 채워나가야겠다는 생각이 드네요.

그렇기에 잘못 작성한 부분이 있을 수도 있으니 참고 부탁드립니다! (피드백 환영)

<br />

------

### Keyword

CNN, **Image Retrieval**, **Global Descriptor**

<br />

---

### Introduction

- 많은 **Image Retrieval** 연구에서는 Convolution layer들 뒷 단에 FC(Fully connected) layer를 붙여서 이미지의 Dimension을 줄인 **Global Descriptor**로 사용해왔다.  

  

- 이어 다양한 연구들이 진행되고 Global Descriptor에도 여러가지 변형 및 발전이 있어왔다. 

  - **Global pooling method** - Convolution layer의 activation을 활용한 기법

    

    - **SPoC**(Sum Pooling of Convolution)

      

    - **MAC**(Maximum Activation of Convolution)

      

    - **GeM**(Generalized mean Pooling)

      

    - 이런 Global Descriptor는 다른 성질을 가지고 있어서, 데이터셋에 따라서 성능이 변했다.  
      ex) SPoC는 이미지 내에서 큰 부분, MAC은 초점이 잡힌 부분에 활성화가 잘 된다.

      

  - Global Pooling method에 성능을 더 높이기 위해서 변형을 주기도 했다.

    

    - **weighted sum pooling**

      

    - **weighted GeM**

      

    - **R-MAC(regional MAC)**

      

    - etc..

      

- 비교적 최근 연구에서는 이렇게 다양한 global descriptor가 달린 모델을 각각 따로 학습을 시켜서 합치는 기법(**ensemble**)을 사용한다.

  

  - 하지만 이런 기법을 사용하면 모델의 크기가 커지고, 학습하는데에 시간이 오래 걸린다. (즉, **시간과 메모리 소모가 큼**)

    

  - 이런 문제를 해결하기 위해 retrieval 모델을 **end-to-end**로 학습시키는 ensemble 기법도 시도되고 있다.

    

    - 하지만 다양한 데이터셋에 보편적으로 적용할 수 있게 만들기 위해서는 특별한 접근법과 손실 함수가 필요하기에 까다로울 수 있고, 이를 만든다고 해도 학습시키는 과정 자체도 복잡할 것이다.

<br />

- 이 논문에서는 데이터의 다양성을 고려하지 않아도 적용이 가능하며, 여러 global descriptor를 활용해 ensemble 같은 효과를 낼 수 있는 기법에 초점을 맞추었다.

  

- 여기에 사용된 핵심 프레임워크는 **CGD(Combination of multiple Global Descriptors)**이다.

  

  - 이를 사용하면end-to-end로 global descriptor를 결합하게 만들어준다.

    

  - 각각 global descriptor에 맞춰 조작하거나 ensemble 모델을 명시하지 않아도 ensemble 같은 효과를 낼 수 있다.

    

  - 또한 매우 유연하고 global descriptor, CNN backbone, loss, dataset에 따라 확장할 수 있다.

    

- 이 프레임워크를 사용해서 다른 기법들과 큰 차이를 보이며 **SOTA**(state-of-the-art)를 달성했다. (CARS196, CUB200, SOP(Standard Online Products), In-shop(In-shop Clothes))

<br />

---

### Proposed Framework

- CGD 프레임워크를 사용해 여러 개의 global descriptor들을 **concatenate** 시킨 **combine descriptor**를 만들어 학습시킨다.

  

- 이 논문에서 제안한 프레임워크는 **CNN backbone 네트워크와 두 개의 모듈**로 이루어져있다.

  

  - 첫 번째 모듈은 **주 모듈**로, **ranking loss**를 이용해 여러 global descriptor의 결합으로 이루어진 image representation을 학습한다.

    

  - 두 번째는 **보조 모듈**로, **classification loss**를 이용해 CNN을 fine-tune 하도록 돕는다.

    

- 이 프레임워크를 사용해 학습을 시킬 때, 주 모듈에서 나오는 ranking loss와 보조 모듈에서 나오는 classification loss의 **합**인 **final loss**를 사용한다.

  

- 아래 그림과 같은 구조를 가지고 있다.

{% include image.html file="https://user-images.githubusercontent.com/11629647/57060294-e0730d80-6cf3-11e9-8e88-4178f76d9fdf.png" description="The combination of multiple global descriptors (CGD) framework." class="center-95"%}

#### Backbone Network

- 여기에 제안된 프레임워크에는 BN-Inception, ShuffleNet-v2, ResNet 을 비롯한 **어떠한 CNN backbone 네트워크**를 사용할 수 있는데, 위 그림의 프레임워크에서는 ResNet-50을 사용했다.

  

- 마지막 단의 feature map의 정보를 보존하기 위해서 네트워크의 Stage(block)3와 Stage(block)4 사이에 **downsampling 부분을 제거**했다. 그렇게 변형된 Stage4에서는 224x224 크기를 입력으로 받아 14x14 크기의 feature map을 내보낸다.

  

#### Main Module: Multiple Global Descriptors

- 주 모듈은 **여러 branch**를 가지는데, 마지막 convolutional layer에 붙은 global descriptor들로 나타내지는 여러 image representation를 출력으로 한다.

  

- 논문에서는 가장 대표적인 global descriptor인 **SPoC, MAC, GeM** 세 가지를 사용한다.

<br />

- 이미지 $$I$$ 가 주어졌을 때, 마지막 convolutional layer의 출력은 $$C\times H\times W$$ 의 크기를 가진 3D tensor $$\chi$$ 이다. ($$C$$ 는 feature map의 갯수이고 $$H,W$$ 는 각각 convolutional layer의 높이와 너비이다.)

  

- 여기에서 $$\chi_c$$ 를 feature map인 $$c \in \{1...C\}$$ 에 해당하는 $$H\times W$$ 크기의 activation 집합이라고 하자.

  

- Global descriptor는 $$\chi$$ 를 입력으로 받아 pooling process를 거쳐 vector $$f$$ 를 만든다.  
  이런 pooling method는 다음과 같이 일반화가 가능하다.

$$
f=[f_1...f_c...f_C]^\top,\quad f_c=\left({1 \over|\chi_c|}\sum_{x\in \chi_c}x^{p_c}\right)^{1\over p_c}
$$

- 여기에서는 SPoC를 $$p_c=1$$ 일 때의 $$f^{(s)}$$ 라고, MAC를 $$p_c \to \infty$$ 일 때의 $$f^{(m)}$$ 이라고, GeM을 나머지 케이스에서의 $$f^{(g)}$$ 라고 정의하였다.

  

- GeM의 경우에는 $$p_c$$ 를 미분할 수 있어서 학습시키거나 수동으로 정해줄 수 있는데, 일단 여기에서는 $$p_c=3$$ 이라고 고정시켜서 실험을 진행하였다.

<br />

- FC layer와 $$l2$$-nomalization layer를 통해 각각 차원 축소와 정규화를 거쳐 얻어지는 $$i$$ 번째 branch로부터 나오는 feature vector $$\Phi^{(a_i)}$$ 는 다음과 같다.  
  ($$n$$ 을 branch의 갯수라 할 때, $$i$$ 는 $$i \in \{1...n\}$$)

$$
\Phi^{(a_i)} = \frac{W^{(i)}\cdot f^{(a_i)}}{||W^{(i)}\cdot f^{(a_i)}||}_{2} , \quad a_i \in \{s,m,g\}
$$

- 여기서의 $$W^i$$ 는 FC layer의 weight 이다.

<br />

- 이제 마지막 feature vector이자 combined descriptor인 $$\Psi_{CGD}$$ 는 여러 개의 branch를 합쳐주고(여기에서는 3개), 순차적으로 $$l2$$-normalization을 진행한다. 다음과 같이 표현할 수 있다. ($$\oplus$$ 는 concatenation을 뜻함.)

$$
\Psi_{CGD}=\frac{\Phi^{(a_1)}\oplus...\oplus\Phi^{(a_i)}\oplus...\oplus \Phi^{(a_n)}}{||\Phi^{(a_1)}\oplus...\oplus\Phi^{(a_i)}\oplus...\oplus \Phi^{(a_n)}||_2}
$$

- 이렇게 만들어진 combined descriptor는 어떠한 타입의 ranking loss를 사용해도 학습시킬 수 있다. 여기에서는 **batch-hard triplet loss**를 사용하였다.

<br />

- 논문에서 제안된 프레임워크는 여러 개의 global descriptor를 결합함으로써 얻어지는 두 가지 이점이 있다.

  

  1. parameter를 몇 개만 추가하면서도 **ensemble 같은 효과**를 볼 수 있다.

     

     -  ensemble 효과를 얻으면서 end-to-end 로 학습하게 만들기 위해서 단일 CNN backbone 네트워크에서 여러 개의 global descriptor를 추출하고 결합했다.

       

  2. 어떠한 **diversity control 없이** 각각의 branch의 output으로 얻어지는 다양한 성질을 사용할 수 있다.

<br />

#### Auxiliary Module: Classification Loss

- 보조 모듈은 **auxiliary classification loss**를 이용해 주 모듈에서 나오는 첫 번째 global descriptor를 기반으로 CNN backbone을 fine-tune 한다.

  

- 보통 이런 접근법을 사용할 때는 다음 두 가지 과정을 거쳐 진행된다.

  

  1. convolutional filter의 성능을 높이기 위해 classification loss를 통한 CNN backbone을 fine-tune 시키기

     

  2. global descriptor의 성능을 높이기 위해 network를 fine-tune 시키기

     

- 하지만 여기에서는 이 방법을 변형시켜 **end-to-end** 로 가능하게끔 하나의 단계로 합쳤다.

  

-  auxiliary classification loss 로 학습을 시키면 **클래스 간 성질**을 가지는 image represenation을 만들 수 있으며, 네트워크를 더 **빠르게** 학습시킬 수 있고, 주 모듈의 ranking loss로만 학습시키는 것 보다 **안정적**이다.

  

- 한편, softmax cross-entropy loss(이하 softmax loss)에서의 **temperature scaling**과 **label smoothing**이 classification loss를 학습시키는데 도움을 준다 라는 것이 밝혀졌는데, 이를 활용한 softmax loss는 다음과 같이 표현할 수 있다.

$$
L_{softmax}=-\frac{1}{N}\sum_{i=1}^{N}\log\frac{\exp((W_{y_i}^{T}f_i+b_{y_i})/\tau)}{\sum_{j=1}^T\exp((W_{y_i}^{T}f_i+b_{y_i})/\tau)}
$$

* 여기에서 $$N$$ 은 batch size,  
  $$M$$ 은 # of classes ,  
  $$y_i$$ 는 $$i$$ 번째 입력에 대응하는 identify label,  
  $$W$$ 는 trainable weight,  
  $$b$$ 는 bias,  
  $$\tau$$ 는 temperature parameter (기본 값은 1),  
  $$f$$ 는 첫 번째 branch를 통해 얻어지는 global descriptor이다.

  

- 위의 식에서도 표현된 low-temperature parameter인 $$\tau$$ 를 통한 temperature scaling은 판단하기 어려운 입력에 대해 큰 그래디언트 값을 할당하고, 클래스 간 촘촘하거나, 넓게 퍼진 embedding에 대응하는데도 도움이 된다.

  

- 그렇기에 **over-fitting을 방지**하고 **embedding을 잘 학습**시키기 위해서 auxiliary classification loss에 label smoothing과 temperature scaling을 추가했다.

<br />

---

### Experiments

- 논문에서 진행한 실험에서는 CUB200-2011, CARS196, Standard Online Products, In-shop Clothes 데이터셋을 사용하였다.

- 간략하게 요약하자면 다음과 같은데, 자세한 실험 환경과 진행 방식을 비롯한 내용은 논문에 잘 나와있다.

  1. Ranking Loss만 사용한 것과 Classification Loss를 같이 사용한 것을 비교했을 때는 같이 사용한 것의 성능이 좋았다.

     

  2. Trick(Label smoothing, Temperature scaling)을 사용하지 않은 것과 하나씩 사용한 것, 둘 다 사용한 것을 비교했을 때는,
     "둘 다 사용 > Temperature scaling 만 < Label smoothing 만 < 둘 다 사용 안함" 순으로 높은 성능을 보여줬다.

     

  3. 아래 그림과 같이 Descriptor 뒷 단에 combine없이 FC->$$l2$$ norm->ranking loss 여러 개를 사용한 아키텍쳐 A와,
     Descriptor 뒷 단에 제안된 프레임워크처럼 FC와 $$l2$$ norm을 거치지 않고 바로 concate 시킨 아키텍쳐 B와,
     논문에서 제안한 아키텍쳐(CGD)를 비교했을 때는,
     "CGD > B > A" 순으로 높은 성능을 보여줬다.

  {% include image.html file="https://user-images.githubusercontent.com/11629647/57060340-0ac4cb00-6cf4-11e9-8805-63641efd6204.png" description="Different architecture types for training multiple global descriptors." class="center-50"%}

  4. Descriptor를 combine 할 때, sum과 concate를 각각 사용해서 비교했을 때는 concate의 성능이 더 좋았다.

     

  5. 데이터셋에 따라서 어떤 descriptor를 사용하느냐와 classification loss를 어떤 descriptor에서 얻느냐에 따라 차이가 있었다.

  <br />

  ---

### Conclusion

- 이 논문에서는 image retrieval에 사용되는 CGD 라는 작지만 강력한 프레임워크를 소개했다.

  

- CGD는 여러 개의 global descriptor를 사용해 end-to-end로 학습시키면서 ensemble과 비슷한 성능을 보여준다.

  

- 이 프레임워크는 유연하며, 다양한 global descriptor, CNN backbone, loss, dataset에 대해 확장시킬 수 있다.

  

- 이를 사용해 현재 주요 image retrieval benchmark로 실험해본 결과 최고의 성능을 보여줬다.