---
layout: post
title:  "Compute Distance with Matrix"
subtitle: "cs231n assignment1"
date:   2018-07-06 15:50:54 +0900
tags: [machine-learning, cs231n]
background: '/assets/img/posts/machine-learning.png'
author: cyc1am3n
comments: true
---
이 포스트는 knn (k-nearest neighbors) 구현에 필요한 test point와 training point의 L2 distance matrix를 python을 통해 구하는 방법을 다룰 것이다.  

## What is L2 Distance?
L2 distance(Euclidean distance)는 유클리드 좌표계에서 두 점 사이의 직선 거리를 의미한다. 유클리드 공간에서 두 점 p = (p<sub>1</sub>, p<sub>2</sub>, ..., p<sub>n</sub>)와 q = (q<sub>1</sub>, q<sub>2</sub>, ..., q<sub>n</sub>)의 L2 distance는 다음과 같다.  

{: refdef: style="text-align: center;"}  
![그림1](/assets/img/posts/compute_distance/l2distance.svg){: width="80%" height="80%"} 
{: refdef}

## With Two loops  
제일 간단한 방법으로, 모든 test data와 training data를 하나하나 비교하는 방법이라 vectorization 을 사용하지 않으며 시간이 오래 걸린다.  

{% highlight python%}
def compute_distances_two_loops(self, X):
​    num_test = X.shape[0]
​    num_train = self.X_train.shape[0]
​    dists = np.zeros((num_test, num_train))
​    for i in range(num_test):
​         for j in range(num_train):
​            sub = np.subtract(X[i], self.X_train[j])
​            square = np.square(sub)
​            dists[i, j] = np.sqrt(np.sum(square))
​    return dists
{% endhighlight %}


## With One Loop  
numpy.sum 함수를 이용해 vectorization을 했다.  sum 함수에서 axis=1 일 때는 column을 합치게 된다.  

{% highlight python%}
def compute_distances_one_loop(self, X):
​    num_test = X.shape[0]
​    num_train = self.X_train.shape[0]
​    dists = np.zeros((num_test, num_train))
​    for i in range(num_test):
​         dists[i, :] = np.sqrt(np.sum(np.square(self.X_train - X[i, :]), axis=1))
​    return dists
{% endhighlight %}


## Without loop  
loop 없이 L2 distance를 구할 때 약간의 트릭이 필요한데, 

{: refdef: style="text-align: center;"}  
(x - y)<sup>2</sup> = x<sup>2</sup> + y<sup>2</sup> - 2xy
{: refdef}  

를 이용하는 것이다.  

여기에서는 numpy.tile 함수를 사용했는데, 이는 square 후에 column으로 합친 행렬을 num_test 또는 num_train만큼 복사하는 함수이다.  

tile을 통해 X<sup>2</sup>와 Y<sup>2</sup>을 더하고 X * Y를 X와 Y(train)을 transposing 한 Y.T를 dot product한 값을 더하면 L2 distance가 만들어진다.   

실행 시간을 서로 비교해보면, 역시 loop가 줄어들수록 빨리 실행되는 것을 볼 수 있다.   
{% highlight python%}
def compute_distances_no_loops(self, X):
​    num_test = X.shape[0]
​    num_train = self.X_train.shape[0]
​    dists = np.zeros((num_test, num_train))
​    dists = np.sqrt(np.tile(np.sum(np.square(self.X_train), axis=1), (num_test, 1)) + np.tile(np.sum(np.square(X), axis=1), (num_train, 1)).T - 2 * np.dot(X, self.X_train.T))
​    return dists
{% endhighlight %}