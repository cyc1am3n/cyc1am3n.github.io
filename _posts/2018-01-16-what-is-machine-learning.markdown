---
layout: post
title:  "[Machine Learning] What is Machine Learning?"
subtitle: "「 Machine Learning 」 lecture summary #1"
date:   2018-01-16 10:19:54 +0900
tags: [machine-learning, coursera]
background: '/img/posts/machine-learning.png'
author: cyc1am3n
comments: true
---
\* 이 포스트는 Coursera에 있는 Andrew Ng 교수님의 강의 [Machine Learning(링크)](https://www.coursera.org/learn/machine-learning)를 바탕으로 작성되었습니다.

## Machine Learning이란 무엇인가?

Machine Learning에는 여러 의미가 있지만 그 중에서도 Arthur Samuel은 "명확한 지시대로 작동하도록 프로그래밍되지 않으면서 컴퓨터에게 학습하는 능력을 주는 연구분야"라고 했다. 이건 informal한 표현이라고 한다.

Tom Mitchell이 말한 좀 더 현대적인 정의는 다음과 같다. "프로그램이 어떤 종류의 작업 T와 성능 측정 P에 관해서, P로부터 측정된 T에서의 성능이 경험 E를 통해 증가한다면 이 프로그램은 경험 E로부터 학습한다고 한다."

체스 프로그램으로 예를 들면, 
E = 많은 체스 경기를 하면서 얻는 경험(데이터)
T = 체스를 하는 작업
P = 경기에서 이 프로그램이 이길 확률
이라고 할 수 있다.

일반적으로 Machine Learning은 `Supervised learning(지도 학습)`, `Unsupervised learning(비지도 학습)`으로 나뉜다.

## Supervised Learning (지도 학습)

지도학습에서는 data set(input)과 이미 그에 대한 정답(output)이 주어진다. input과 output 사이의 관계를 이용한다.

지도학습은 `"회귀(regression)"`와 `"분류(classification)"`로 나뉜다.
회귀는 연속적인 출력값에 대해서 결과를 예측하는데, 이는 입력 변수를 연속적인 함수에 대응시킨다는 의미이다.
분류는 이산적인 출력값에 대해서 결과를 예측하고, 이는 입력 변수를 개별 범주로 대응시킨다는 의미이다.

이 설명으로는 이해가 힘드니 아래의 예시를 참고하자.

예시 1:
부동산에서 집의 크기(평수)에 대한 데이터를 바탕으로 집 값을 예측할 때는 가격이 집의 크기를 입력으로 받는 연속 함수가 되므로 회귀 문제가 된다.

이 문제는 "시세보다 많이 또는 적게 팔느냐"에 대한 결과를 대신 제시하면 분류 문제로 바꿀 수 있다. 여기에서는 가격을 기준으로 주택을 두 개의 개별 범주(시세보다 높음/낮음)로 분류한다.

예시 2:
(a) 회귀 - 사람의 사진이 주어지면 이를 통해 나이를 예측  
(b) 분류 - 종양이 있는 사람의 종양이 악성인지 양성인지를 예측

## Unsupervised Learning(비지도 학습)

비지도학습은 결과가 어떻게 될지 거의 혹은 전혀 모르는 상태에서 문제에 접근 할 수 있게 해준다. 변수가 어떤 영향을 끼치는지 반드시 알 필요가 없는 데이터로부터 구조를 도출 할 수 있다.

데이터의 변수들 사이의 관계를 통해 데이터를 클러스터링(군집분석)함으로써 이 구조를 도출 할 수 있다.

비지도학습에서는 예측 결과에 기반한 피드백이 없다.

예시:
군집분석: 1,000,000 가지의 유전자를 가지고 이들 유전자의 수명, 위치, 역할 등과 같은 다양한 변수에 의해 어떻게 유사하거나 관련이있는 그룹으로 자동 분류하는 방법을 찾는다.

비군집분석: ["Cocktail Party Algorithm(링크)](https://en.wikipedia.org/wiki/Cocktail_party_effect)"은 소란스러운 환경에서 음성 구조를 찾을 수 있게 한다.