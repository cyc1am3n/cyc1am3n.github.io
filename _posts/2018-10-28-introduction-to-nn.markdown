---
layout: post
title:  "[CS231n] Introduction to Neural Networks"
subtitle: "Lecture 4 Note"
post_description: "Stanford University cs231n의 4번째 강의인 Introduction to Neural Networks의 강의노트입니다."
date:   2018-10-28 00:50:54 +0900
tags: [data-science, machine-learning, cs231n]
background: '/img/posts/cs231n/background.jpeg'
author: cyc1am3n
comments: true
---

*이 포스트는 Stanford University [cs231n](http://cs231n.stanford.edu/2017/)의 4번째 강의인 Introduction to Neural Networks의 강의노트입니다.*

<br />

## Back Propagation

------

시작에 앞서 computational graph를 활용한 아주 간단한 예제를 살펴보자.

$$ f(x,y,z)=(x+y)z $$

{% include image.html file="/assets/img/posts/cs231n/lec04-01.png" class="center-75"%}

우리가 구하고 싶은 것은 각 input에 대한 f의 gradient이다.(경사 하강법을 적용해야하기 때문에) 이는 최종 출력 노드에서 얻을 수 있는 gradient로 부터 하나씩 거꾸로 거슬러 올라가면서 얻을 수 있을 것이다.

일단 $$q$$를 $$x + y$$ 라고 정의를 하면, $$x$$ 와 $$y$$ 에 대한 $$q$$ 의 gradient는 다음과 같다.  

$$ q=x+y\qquad{\partial q \over \partial x} = 1,\ {\partial q \over \partial y} = 1 $$

이제 $$f$$ 를 $$qz$$ 라고 놓으면, $$q$$ 와 $$z$$ 에 대한 $$f$$ 의 gradient도 구할 수 있다.

$$ f=qz\qquad{\partial f \over \partial q} = z,\ {\partial f \over \partial z} = q $$

곱셈에 대한 미분은 곱셈규칙에 의해서 서로 곱한 값이 미분값이 되기 때문이다.

그리고 이제 우리가 구해야 하는 것은

$$ {\partial f \over \partial x},\ {\partial f \over \partial y},\ {\partial f \over \partial z} $$

이고, 위에서 얻은 값을 **Chain Rule**을 통해서 구하면 된다.

위의 그림과 같이, $$ x=-2,\ y=5,\ z=-4 $$ 라고 놓고 계산을 해보자.

먼저, $$ {\partial f \over\partial f} $$ 는 당연하게 1이다.

이제 뒤로 이동해서 $$ {\partial f \over \partial q},\ {\partial f \over \partial z} $$ 를 구하면 그 값은 $$ z $$ 와 $$ q $$ 이므로

$$ {\partial f \over \partial q} = z=-4,\ {\partial f \over \partial z} = q=x+y=3 $$


이 될 것이다.

그리고 한 번 더 뒤로 이동을 하면 우리가 구하려고 했던 $$ {\partial f \over \partial x},\ {\partial f \over \partial y},\ {\partial f \over \partial z} $$ 또한 구할 수 있다.

**Chain Rule** 에 의해서,

$$
\begin{matrix}
{\partial f \over \partial x}= {\partial f \over \partial q}\cdot {\partial q \over \partial x}=(-4)\cdot1=-4,\\
{\partial f \over \partial y}={\partial f \over \partial q}\cdot {\partial q \over \partial y}=(-4)\cdot1=-4,
\\ {\partial f \over \partial z}=3
\end{matrix}
$$

이 될 것이다.

이것은 $$ x $$ 와 $$ y $$ 를 조금 바꿨을 때 그것이 최종 출력 값인 $$f$$ 에 대해 -4 만큼의 영향력을 가지고, $$z$$ 는 3만큼의 영향력을 미치는 것을 의미한다.

위와 같이 입력 값이 출력 값에 미치는 영향을 얻기 위해 각 노드에서 가질 수 있는 **local gradient** 값과 최종 출력 값에서 부터 나오는 **gradient** 를 곱하는 과정을 뒤에서부터 반복하고, 이를 **Back Propagation** 이라고 한다.

이 과정은 뒤에서 공부할 **neural network** 에서 중요하게 쓰이는데, 복잡한 layer들이 여러 겹 이어져서 하나의 모델을 이룬다고 하면 각 input과 그 가중치에 대한 gradient를 위와 같은 과정을 통해 쉽게(?) 구할 수 있게 되어 이를 통해 효율적인 학습을 할 수 있게 된다.

한편 back propagation에서 더 알아야 할  몇 가지의 내용이 있다.

먼저 여러 연산 게이트에 대한 backward flow 패턴인데, 간략히 설명하자면

- **add** gate는 뒤에서부터 오는 gradient 를 똑같이 나눠주고(gradient distributor),

- **max** gate는 입력 값이 더 큰 값에만 gradient를 나눠주고 그렇지 않는 값에는 0을 주는 라우터의 역할을 하며(gradient router),

- **mul** gate는 각 입력 값의 gradient를 교환해준다(gradient switcher 혹은 scaler).

또한 아래와 같이 하나의 노드가 2개 이상의 branch를 가질 때는 각 branch에서 얻어지는 gradient를 더해야 한다.

{% include image.html file="/assets/img/posts/cs231n/lec04-02.png" class="center-95"%}



마지막으로 스칼라가 아닌 벡터를 입력으로 가지는 연산의 gradient를 생각해보자.

모든 흐름은 정확하게 같은데, 차이점이라고 한다면 gradient는 다변수 벡터 함수의 도함수행렬인 [Jacobian 행렬 (링크)](https://ko.wikipedia.org/wiki/%EC%95%BC%EC%BD%94%EB%B9%84_%ED%96%89%EB%A0%AC)이 될 것이다.

아래 예제를 통해서 생각해보자.

{% include image.html file="/assets/img/posts/cs231n/lec04-03.png" class="center-95"%}

여기서의 입력은 4096 차원의 벡터이고, 이는 CNN에서 흔하게 볼 수 있는 입력 사이즈이다.

또한 이 노드는 요소별로 최대값을 취하며 $$(f(x)=max(0,x))$$, 출력 또한 4096 차원의 벡터이다.

여기서 gradient인 Jacobian 행렬의 사이즈는 4096 * 4096 이고, 여기에서 100개를 동시에 입력으로 받는 미니 배치를 사용하면 Jacobian은 409600*409600까지 커질 수가 있다.

이는 너무 커서 실용적이지는 못하고, 사실 이 전체 Jacobian을 구할 필요는 없다.

실제로 벡터의 각 요소가 출력 값에 미치는 영향을 얻어야 하기 때문에 Jacobian의 **대각행렬**만 알면 된다.

그리고 이 gradient는 항상 변수와 같은 모양(shape)을 가지고 있어 계산을 한 후에 변수의 모양과 같은지 확인하는 식으로 제대로 gradient를 구했는 지를 검사할 수 있다.

지금까지 각 노드를 local하게 보았고, upstream gradient와 같이 local gradient를 계산을 해봤는데, 이것을 forward, backward pass의 API로 생각할 수 있다.

```python
class ComputationalGraph(object):
	#...
	def forward(inputs):
		# 1. [pass inputs to input gates...]
		# 2. forward the computational graph:
		for gate in self.graph.nodes_topologically_sorted():
			gate.forward()
		return loss # the final gate in the graph outputs the loss
	def backward():
		for gate in reversed(self.graph_nodes_topologically_sorted()):
			gate.backward() # little piece of backprop (chain rule applied)
		return inputs_gradients
```

한편 foward pass에서 중요한 부분은 여기서 계산한 값들을 저장해야 한다는 것이다. 이 값들은 backward pass에서 사용되기 때문이다.

지금까지 했던 내용을 요약하자면...

- nueral nets은 매우 크기가 크다: 모든 매개변수에 대해 gradient를 일일히 계산하는 것은 실용적이지 못하다.
- **backpropagation** = 모든 입력 / 매개변수 / 계산에 필요한 중간 변수 의 gradient를 계산하기 위해 computational graph를 따라서 chain rule을 이용해 재귀적으로 적용함
- 실제 구현은 **forward** / **backward** API를 구현하는 그래프 구조를 통해 이루어진다.
- **forward**: 연산의 결과를 계산하고 메모리에 gradient 계산에 필요한 중간 변수들을 저장한다.
- **backward**: chain rule을 적용해서 입력에 대한 loss function의 gradient를 계산한다.

<br />

## Neural Network

------

사람들은 신경망(Neural Network)과 뇌 사이에서 많은 유추와 여러 가지의 생물학적인 영감을 이끌어낸다.

일단은 그것에 대해 이야기 하는 것은 뒤로 미루고, 식으로 표현된 신경망에 대해 이야기를 해보자.

다음과 같은 아주 간단한 형태의 2겹의 레이어를 가진 신경망을 한 번 살펴보자.


$$ f=W_2max(0,W_1x) $$

{% include image.html file="/assets/img/posts/cs231n/lec04-04.png" class="center-95"%}

위 신경망은 첫 번째로 $$W_1$$과 $$x$$의 행렬 곱을 중간 변수로 가지고 $$max(0, W)$$ 라는 **비선형 함수**를 이용해서 선형 값을 얻는다.

선형 레이어들만 계속 쌓는다면 결국 하나의 선형 함수로 표현이 가능하기 때문에 여기서 비선형 함수가 중요한 역할을 한다. (꼭 $$max(0,W)$$일 필요는 없고, 추후에 배울 여러 비선형 함수 또한 사용 가능하다.)

또한 신경망을 폭 넓게 표현하자면 함수들의 집합(class)이라고 할 수 있다.

이는 신경망이 비선형의 복잡한 함수를 만들기 위해서 간단한 함수들을 계층적으로 여러 겹 쌓아 올린 것이기 때문이다.

<br />

한편, 아까 잠깐 언급했던 신경망과 생물학적인 연결을 다시 이어보자.

사실 이 관계는 매우 loose한데, 이러한 연결과 영감이 어디에서 왔는지를 이해할 필요는 있다.

생물학적인 관점에서 많은 뉴런들이 수상돌기에 이어져 서로 연결되어 존재하고, 그 사이에서 각 뉴런을 따라 전달되는 신호가 있다는 것을 알 수 있다.

또한 여러 수상돌기를 통해서 얻어진 신호를 세포체(Cell body)에서 종합하고, 이를 하류 뉴런과 연결된 다른 세포체로 전달을 한다.

지금까지 해왔던 것을 살펴본다면, 각 computational node와 뉴런의 동작이 다음과 같이 비슷한 방식으로 이루어 진다는 것을 알 수 있다.

{% include image.html file="/assets/img/posts/cs231n/lec04-05.png" class="center-95"%}

또한 왼쪽 하단과 같이 활성 함수(activation function)을 볼 수 있는데, 이것은 입력을 받아 나중에 출력이 될 하나의 숫자를 보여주는 것이다.

사실 실제 생물학적 뉴런은 이것보다 훨씬 복잡한데, 위와 같은 loose한 연결을 할 때는 조심할 필요가 있다.

마지막으로 신경망의 feed-forward 계산의 예를 살펴보고 마무리를 하면 될 것 같다.

{% include image.html file="/assets/img/posts/cs231n/lec04-06.png" class="center-95"%}

여기서 가지고 있는 벡터 행렬의 출력은 비선형성을 가진다.

여기서 사용한 활성 함수 $$f$$ 는 sigmoid이고, 입력으로 $$x$$ 벡터를 받아 $$W_1$$과 곱해서($$h_1$$) 비선형성을 적용한 다음 두 번째 히든 레이어인 $$h_2$$를 얻기 위해서 $$W_2$$와 행렬곱을 적용하고 한 번 더 비선형성을 적용한 후에 최종 출력을 얻어낸다.

그리고 앞에서 보았던 backward pass는 신경망을 학습시키기 위해서 필요한데, 그냥 backpropagation을 적용하기만 하면 된다.

<br />

지금까지 했던 부분을 요약하자면,

- 뉴런을 선형 레이어와 fully-connected로 재배열했고,
- 레이어의 추상화는 모든 것을 계산하는데 매우 효율적인 벡터화된 코드를 사용할 수 있게 하는 좋은 속성을 가지고 있으며,
- 신경망이 생물학적 비유와 loose한 영감을 가지고 있지만, 실제로는 뉴런과는 많이 다르다는 것을 간과하면 안된다.

라는 것이다.

다음 시간에는 **Convolutional Neural Networks**를 알아볼 것이다.