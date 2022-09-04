---
layout: post
title:  "From Information to Divergence"
subtitle: "Self-information, Entropy, Cross Entropy, KL-divergence, F-divergence"
post_description: "Self-information, Entropy, Cross Entropy, KL-divergence, F-divergence"
date:   2020-03-01 22:30:00 +0900
tags: [info]
background: '/img/posts/notebook.jpg'
author: cyc1am3n
comments: true
---

### Self-information(정보량)

- Information theory 에서 information은 특정한 관찰에 의해 얼마만큼의 정보를 획득했는지 수치로 정량화한 값이다.
- 모델 학습에 있어서 얼마나 영향력 있는지, 정보의 파급력 또는 놀람의 정도로 해석할 수 있다.
  - 즉, 큰 정보량은 자주 발생하는 관찰이나 사건에 대해서는 작은 값을 갖고 자주 발생하지 않는 사건에 대해서는 큰 값을 갖는다.
- 정보이론에서는 자주 일어나지 않는 사건의 정보량은 자주 발생하는 사건보다 정보량이 많다고 간주한다.
- 관찰이나 사건 $$A$$의 정보량 $$h(A)$$ 를 다음과 같이 정의한다.

$$
h(A):=-\log P(A)
$$

- 여기에서 $$P(A)$$는 사건 $$A$$의 확률을 의미한다.

<br/>

### Entropy

- Entropy는 확률변수의 평균 정보량, 즉 평균적인 놀람(불확실성)의 정도를 나타낸다.
- 이산확률 변수 $$X$$의 평균 정보량 $$H[X]$$는 다음과 같이 정의한다.

$$
H[X]:=-\sum_{i=1}^N p_i \log p_i
$$

- 연속확률 변수 $$X$$의 평균 정보량 $$H[X]$$는 다음과 같이 정의한다.

$$
H[X]:=-\int p(x)\log (p(x))dx
$$

<br/>

### Cross Entropy

- 두 확률 분포 $$p$$ 와 $$q$$ 에 대해서 분포 $$p$$ 대신에 $$q$$를 사용해 분포 $$p$$를 설명할 때 필요한 정보량을 Cross Entropy라고 한다.
- 주어진 확률변수 $$X$$에 대해서 확률분포 $$p$$를 찾는 문제를 생각해보자.
  - 확률분포 $$p$$의 정확한 형태를 모르기 때문에 $$p$$를 예측한 근사 분포 $$q$$를 이용해야 한다.
- Cross-entropy는 다음과 같다.

$$
\text{Cross-entropy}=-\sum_{i=1}^N p_i \log q_i
$$

- 정보를 나타내는 $$\log$$ 값에 $$p(x)$$ 대신 $$q(x)$$ 를 사용한 것을 볼 수 있다.

<br/>

### Kullback-Leibler divergence(KL-divergence)

- 두 확률분포의 유사한 정도를 계산하는 방법 중의 하나이다.
- KL Divergence의 정의는 다음과 같다.

$$
KL(p|q):=-\sum_{i=1}^N p_i \log q_i - \left( -\sum_{i=1}^N p_i \log p_q \right)=-\sum_{i=1}^N p_i \log \left(q_i \over p_i\right)
$$

- Cross Entropy에 Entropy를 뺀 값이라고 생각하면 된다.
- KL Divergence의 성질은 다음과 같다.
  - $$KL(p\vert q)≠KL(q\vert p) $$ (non-symmetric).
  - $$KL(p\vert q)=0$$ if and only if $$p=q$$.
  - $$KL(p\vert q)≥0$$.
- KL Divergence를 최소화하는 것은 결국 Cross Entropy를 최소화하는 것과 같으므로 CE를 loss로 사용한다.

<br/>

### F-divergence

- 두 확률분포의 유사도를 일반화한 형태의 함수이다.
- 정의는 다음과 같다.

$$
D_f(P||Q)=\int q(x)f\left({p(x) \over q(x)}\right)dx
$$

- 여기에서 $$f$$는 convex  function이며 $$f(1)=0$$ 을 만족해야한다.
- $$f$$ 에 따라서 다양한 divergence를 만들 수 있다.

| Divergence                                        | Corresponding *f(t)*                                         |
| ------------------------------------------------- | ------------------------------------------------------------ |
| KL-divergence                                     | $$t\log t$$                                                  |
| reverse KL-divergence                             | $$-\log t$$                                                  |
| squared Hellinger distance                        | $$({\sqrt {t}}-1)^{2},\,2(1-{\sqrt {t}})$$                   |
| Total variation distance                          | $${\frac {1}{2}}\vert t - 1\vert $$                          |
| Pearson $$\chi ^{2}$$-divergence                  | $$(t-1)^{2},\,t^{2}-1,\,t^{2}-t$$                            |
| Neyman $$\chi ^{2}$$-divergence (reverse Pearson) | $${\frac {1}{t}}-1,\,{\frac {1}{t}}-t$$                      |
| α-divergence                                      | $${\begin{cases}{\frac {4}{1-\alpha ^{2}}}{\big (}1-t^{(1+\alpha )/2}{\big )},&{\text{if}}\ \alpha \neq \pm 1,\\t\ln t,&{\text{if}}\ \alpha =1,\\-\ln t,&{\text{if}}\ \alpha =-1\end{cases}}$$ |
| α-divergence (other designation)                  | $$\begin{cases}{\frac {t^{\alpha }-t}{\alpha (\alpha -1)}},&{\text{if}}\ \alpha \neq 0,\,\alpha \neq 1,\\t\ln t,&{\text{if}}\ \alpha =1,\\-\ln t,&{\text{if}}\ \alpha =0\end{cases}$$ |

---

> **Reference:**
>
> - [알기 쉬운 산업 수학 - Entropy, Cross-entropy, KL Divergence](https://icim.nims.re.kr/post/easyMath/550)
> - [reniew's blog - 정보이론 : 엔트로피, KL-Divergence](https://reniew.github.io/17/)
> - [Wikipedia - f divergence](https://en.wikipedia.org/wiki/F-divergence)

