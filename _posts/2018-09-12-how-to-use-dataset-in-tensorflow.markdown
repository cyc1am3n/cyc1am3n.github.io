---
layout: post
title:  "TensorFlow에서 Dataset을 사용하는 방법"
subtitle: "The built-in Input Pipeline. Never use ‘feed-dict’ anymore"
date:   2018-09-13 20:15:00 +0900
tags: [machine-learning, tensorflow]
background: '/img/posts/machine-learning.png'
author: cyc1am3n
comments: true
---
이 포스트는 [Francesco Saverio 님의 How to use Dataset in TensorFlow](https://towardsdatascience.com/how-to-use-dataset-in-tensorflow-c758ef9e4428) 를 한글로 번역한 것 입니다.  

## TensorFlow에서 Dataset을 사용하는 방법  

TensorFlow에서 `feed-dict`만을 사용해서 데이터를 처리하는 것은 느리고 별로 권장되지는 않는다. 모델에 데이터를 제대로 공급하려면 입력 파이프라인을 만들어서 GPU로 들어올 데이터를 멈춰있게 하지 않아야 한다.  

다행스럽게도 TensorFlow에서는 `Dataset` 이라는 built-in-API를 제공하고 있어서 위의 작업을 쉽게 처리할 수 있다. 이 포스트에서는 입력 파이프라인을 만들어서 모델에 데이터를 효율적으로 공급하는 방법을 살펴볼 것이다. 또한, 흔하게 볼 수 있는 예시를 다루면서 Dataset의 기본적인 메커니즘을 설명할 것이다.  

* * *

### 개요

Dataset을 사용하려면 세 가지 단계를 거쳐야한다.  
1.	<strong>데이터 불러오기.</strong> 사용하려는 데이터로부터 Dataset 인스턴스를 만든다.  
2.	<strong>Iterator(반복자) 생성하기.</strong> 생성된 데이터를 사용해서 Iterator 인스턴스를 만들어 Dataset을 iterate시킨다.  
3.	<strong>데이터 사용하기.</strong> 생성된 iterator를 사용해서 모델에 공급할 dataset으로부터 요소를 가져올 수 있다.  
  
* * *

### 데이터 불러오기

일단 dataset안에 넣을 데이터가 필요하다.  


#### numpy에서 불러오기  
numpy 배열이 있고 그걸 tensorflow로 넣는 흔한 케이스이다. 

{% highlight python%}
# create a random vector of shape (100,2)
x = np.random.sample((100,2))
# make a dataset from a numpy array
dataset = tf.data.Dataset.from_tensor_slices(x)
{% endhighlight %}

또한 데이터를 특성(feature)과 라벨(label)로 나누어 사용하는 경우처럼, 한 개 이상의 numpy 배열을 넣을 수도 있다.  

{% highlight python%}
features, labels = (np.random.sample((100,2)), np.random.sample((100,1)))
dataset = tf.data.Dataset.from_tensor_slices((features,labels))
{% endhighlight %}


#### tensor에서 불러오기  
tensor를 사용해서 dataset을 초기화 할 수도 있다.  

{% highlight python%}
# using a tensor
dataset = tf.data.Dataset.from_tensor_slices(tf.random_uniform([100, 2]))
{% endhighlight %}


#### Placeholder에서 불러오기  
dataset안의 데이터의 동적 변경을 할 때 유용한 방법인데, 자세한 내용은 아래에서 살펴보겠다.  

{% highlight python%}
x = tf.placeholder(tf.float32, shape=[None,2])
dataset = tf.data.Dataset.from_tensor_slices(x)
{% endhighlight %}


#### generator에서 불러오기  
generator를 사용해서 dataset을 초기화 할 수 있는데, 데이터의 원소들이 다른 크기를 가지고 있을 때 유용하다. 이런 경우에 tensor를 만들 때 사용할 데이터의 type과 shape도 지정해야 한다.  

{% highlight python%}
# from generator
sequence = np.array([[[1]],[[2],[3]],[[3],[4],[5]]])
def generator():
​    for el in sequence:
​        yield el
dataset = tf.data.Dataset().batch(1).from_generator(generator,
​                                           output_types= tf.int64, 
​                                           output_shapes=(tf.TensorShape([None, 1])))
iter = dataset.make_initializable_iterator()
el = iter.get_next()
with tf.Session() as sess:
​    sess.run(iter.initializer)
​    print(sess.run(el))
​    print(sess.run(el))
​    print(sess.run(el))
{% endhighlight %}

출력은 다음과 같다.  

{% highlight python%}
[[1]]
[[2]
 [3]]
[[3]
 [4]
 [5]]
{% endhighlight %}


#### csv파일에서 불러오기  
csv파일에서 dataset으로 직접적으로 읽어올 수도 있다. 다음과 같이 트윗(text)과 좋아요(sentiment)가 들어있는 csv파일이 있다고 해보자.  

{: refdef: style="text-align: center;"}  
![tweets.csv](/img/posts/dataset-in-tensorflow/tweets_csv.png){: width="50%" height="50%"} 
{: refdef}

여기서 `tf.contrib.data.make_csv_dataset`을 사용하면 쉽게 `Dataset`을 만들 수 있다. Iterator는 column의 이름을 key로 하고 row 값을 가진 Tensor를 value로 하는 딕셔너리를 만든다.  

{% highlight python%}
# load a csv
CSV_PATH = './tweets.csv'
dataset = tf.contrib.data.make_csv_dataset(CSV_PATH, batch_size=32)
iter = dataset.make_one_shot_iterator()
next = iter.get_next()
print(next) # next is a dict with key=columns names and value=column data
inputs, labels = next['text'], next['sentiment']
with  tf.Session() as sess:
​    sess.run([inputs, labels])
{% endhighlight %}

next는 다음을 나타낸다.  

{% highlight python%}
{'sentiment': <tf.Tensor 'IteratorGetNext_15:0' shape=(?,) dtype=int32>,
'text': <tf.Tensor 'IteratorGetNext_15:1' shape=(?,) dtype=string>}
{% endhighlight %}

* * *

### Iterator(반복자) 생성하기  
Dataset을 생성하고 나면 어떻게 데이터를 받을 수 있을까? 이 때는 Iterator를 사용해서 dataset을 통해 iterate하고 데이터에서 실제 값을 받아올 수 있다.  
Iterator에는 다음과 같이 네 가지 타입이 존재한다.  
1.	<strong>One shot.</strong> Dataset을 통해 한 번만 iterate할 수 있고, 여기에 추가적으로 어떠한 값도 공급할 수 없다.  
2.	<strong>Initializable.</strong> feed-dict를 통해서 초기화 연산 호출과 새로운 데이터 전달을 동적으로 변경할 수 있다. feed-dict는 데이터를 담을 수 있는 버킷이다.  
3.  <strong>Reinitializable.</strong> 다른 Dataset을 통해서 초기화 될 수 있다. 셔플과 같이 추가적인 변형이 필요한 training dataset과 testing dataset을 가지고 있을 때 효과적으로 쓸 수 있다.  마치 각기 다른 컨테이너를 고르는 타워 크레인같은 역할을 한다.  
4.  <strong>Feedable.</strong> 사용하려는 iterator를 선택하는데 사용할 수 있다. 위의 비유와 연관지으면 타워 크레인을 고르는 타워 크레인이라고 할 수 있겠다. 필자의 의견으로는 쓸모가 없어보인다.    
  

#### One-shot Iterator  
가장 간단한 iterator이다. 처음의 예를 사용하면  

{% highlight python%}
x = np.random.sample((100,2))
# make a dataset from a numpy array
dataset = tf.data.Dataset.from_tensor_slices(x)
# create the iterator
iter = dataset.make_one_shot_iterator()
{% endhighlight %}

그러면 데이터를 포함할 tensor를 얻기 위해서 `get_next()`를 호출해야 한다.  

{% highlight python%}
...
# create the iterator
iter = dataset.make_one_shot_iterator()
el = iter.get_next()
{% endhighlight %}

값을 보려면 `el` 을 실행시키면 된다.  

{% highlight python%}
with tf.Session() as sess:
​    print(sess.run(el)) # output: [ 0.42116176  0.40666069]
{% endhighlight %}

#### Initializable Iterator  
데이터의 런타임을 변경할 수 있는 동적인 dataset을 만들고 싶을 때, placeholder를 사용할 수 있다. 그리고 `feed-dict`를 사용해서 placeholder를 초기화 할 수 있는데, 이게 initializable iterator로 수행되는 것이다. 아까 위에서 했던 예를 사용하면 다음과 같은데,  

{% highlight python%}
# using a placeholder
x = tf.placeholder(tf.float32, shape=[None,2])
dataset = tf.data.Dataset.from_tensor_slices(x)
data = np.random.sample((100,2))
iter = dataset.make_initializable_iterator() # create the iterator
el = iter.get_next()
with tf.Session() as sess:
​    # feed the placeholder with data
​    sess.run(iter.initializer, feed_dict={ x: data }) 
​    print(sess.run(el)) # output [ 0.52374458  0.71968478]
{% endhighlight %}

이때 `make_initializable_iterator`을 호출 한다. 그러면 sess가 있는 with 블록 안에서 데이터를 보내기 위해서 `initializer`명령어를 실행시키는데, 여기에서는 랜덤 numpy 배열이 데이터에 해당한다.  

이제 흔하게 볼 수 있는 train과 test set이 있는 상황을 생각해보자.  

{% highlight python%}
train_data = (np.random.sample((100,2)), np.random.sample((100,1)))
test_data = (np.array([[1,2]]), np.array([[0]]))
{% endhighlight %}

그러면 모델을 학습시킨 후에 test dataset으로 평가해야 할 텐데, iterator를 초기화해서 사용한다.  

{% highlight python%}
# initializable iterator to switch between dataset
EPOCHS = 10
x, y = tf.placeholder(tf.float32, shape=[None,2]), tf.placeholder(tf.float32, shape=[None,1])
dataset = tf.data.Dataset.from_tensor_slices((x, y))
train_data = (np.random.sample((100,2)), np.random.sample((100,1)))
test_data = (np.array([[1,2]]), np.array([[0]]))
iter = dataset.make_initializable_iterator()
features, labels = iter.get_next()
with tf.Session() as sess:
#     initialise iterator with train data
    sess.run(iter.initializer, feed_dict={ x: train_data[0], y: train_data[1]})
    for _ in range(EPOCHS):
        sess.run([features, labels])
#     switch to test data
    sess.run(iter.initializer, feed_dict={ x: test_data[0], y: test_data[1]})
    print(sess.run([features, labels]))
{% endhighlight %}

#### Reinitializable Iterator  
데이터끼리의 동적 변경을 하는 initializable iterator와 컨셉은 비슷한데, 같은 dataset에 새로운 데이터를 넣는 것 대신에 dataset 자체를 바꿀 것이다. 아까처럼 train과 test data가 있다고 해보자.  

{% highlight python%}
# making fake data using numpy
train_data = (np.random.sample((100,2)), np.random.sample((100,1)))
test_data = (np.random.sample((10,2)), np.random.sample((10,1)))
{% endhighlight %}

여기서 두 개의 Dataset을 만들 수 있는데,  

{% highlight python%}
# create two datasets, one for training and one for test
train_dataset = tf.data.Dataset.from_tensor_slices(train_data)
test_dataset = tf.data.Dataset.from_tensor_slices(test_data)
{% endhighlight %}

여기에서 generic Iterator를 만들어보자.  

{% highlight python%}
# create a iterator of the correct shape and type
iter = tf.data.Iterator.from_structure(train_dataset.output_types,
​                                           train_dataset.output_shapes)
{% endhighlight %}

그리고 두 개의 초기화 연산도 만들자.   

{% highlight python%}
# create the initialisation operations
train_init_op = iter.make_initializer(train_dataset)
test_init_op = iter.make_initializer(test_dataset)
{% endhighlight %}

전과 같이 get_next를 통해서 다음 원소를 얻을 수 있다.  

{% highlight python%}
features, labels = iter.get_next()
{% endhighlight %}

이제 session을 사용해서 직접 두 개의 초기화 연산을 실행 시킬 수 있는데, 위에 했던걸 합치면 다음과 같다.  

{% highlight python%}
# Reinitializable iterator to switch between Datasets
EPOCHS = 10
# making fake data using numpy
train_data = (np.random.sample((100,2)), np.random.sample((100,1)))
test_data = (np.random.sample((10,2)), np.random.sample((10,1)))
# create two datasets, one for training and one for test
train_dataset = tf.data.Dataset.from_tensor_slices(train_data)
test_dataset = tf.data.Dataset.from_tensor_slices(test_data)
# create a iterator of the correct shape and type
iter = tf.data.Iterator.from_structure(train_dataset.output_types,
​                                           train_dataset.output_shapes)
features, labels = iter.get_next()
# create the initialisation operations
train_init_op = iter.make_initializer(train_dataset)
test_init_op = iter.make_initializer(test_dataset)
with tf.Session() as sess:
​    sess.run(train_init_op) # switch to train dataset
​    for _ in range(EPOCHS):
​        sess.run([features, labels])
​    sess.run(test_init_op) # switch to val dataset
​    print(sess.run([features, labels]))
{% endhighlight %}

#### Feedable Iterator  
`reinitializable` iterator와 매우 비슷한데, dataset의 전환 대신에 iterator의 전환을 한다. 다음과 같이 두 개의 dataset을 만들고,  

{% highlight python%}
train_dataset = tf.data.Dataset.from_tensor_slices((x,y))
test_dataset = tf.data.Dataset.from_tensor_slices((x,y))
{% endhighlight %}

그 다음에 iterator를 만들 수 있다. 여기에서는 `initializable` iterator를 사용하는데, `one shot` iterator 또한 사용가능하다.  

{% highlight python%}
train_iterator = train_dataset.make_initializable_iterator()
test_iterator = test_dataset.make_initializable_iterator()
{% endhighlight %}

이제 동적으로 변경이 가능한 placeholder인 `handle`을 만든다.  

{% highlight python%}
handle = tf.placeholder(tf.string, shape=[])
{% endhighlight %}

그리고 전과 같이, dataset의 shape를 이용해서 generic iterator를 만든다.  

{% highlight python%}
iter = tf.data.Iterator.from_string_handle(
​    handle, train_dataset.output_types, train_dataset.output_shapes)
{% endhighlight %}

또 get_next로 다음 원소를 받을 수 있고,  

{% highlight python%}
next_elements = iter.get_next()
{% endhighlight %}

iterator의 변경을 위해서 `next_elements`을 실행시켜서 feed_dict에 정확한 `handle`이 들어갈 수 있게 한다. 예를 들어 train set에서 한 개의 원소를 받아오려면 다음과 같이 한다.  

{% highlight python%}
sess.run(next_elements, feed_dict = {handle: train_handle})
{% endhighlight %}

`initializable` iterator를 사용하려면 그냥 시작 전에 초기화 시켜주기만 하면 된다.  

{% highlight python%}
sess.run(train_iterator.initializer, feed_dict={ x: train_data[0], y: train_data[1]})
sess.run(test_iterator.initializer, feed_dict={ x: test_data[0], y: test_data[1]})
{% endhighlight %}

이걸 종합해보면 다음과 같다.  

{% highlight python%}
# feedable iterator to switch between iterators
EPOCHS = 10
# making fake data using numpy
train_data = (np.random.sample((100,2)), np.random.sample((100,1)))
test_data = (np.random.sample((10,2)), np.random.sample((10,1)))
# create placeholder
x, y = tf.placeholder(tf.float32, shape=[None,2]), tf.placeholder(tf.float32, shape=[None,1])
# create two datasets, one for training and one for test
train_dataset = tf.data.Dataset.from_tensor_slices((x,y))
test_dataset = tf.data.Dataset.from_tensor_slices((x,y))
# create the iterators from the dataset
train_iterator = train_dataset.make_initializable_iterator()
test_iterator = test_dataset.make_initializable_iterator()
# same as in the doc https://www.tensorflow.org/programmers_guide/datasets#creating_an_iterator
handle = tf.placeholder(tf.string, shape=[])
iter = tf.data.Iterator.from_string_handle(
​    handle, train_dataset.output_types, train_dataset.output_shapes)
next_elements = iter.get_next()

with tf.Session() as sess:
​    train_handle = sess.run(train_iterator.string_handle())
​    test_handle = sess.run(test_iterator.string_handle())
​    
​    # initialise iterators. 
​    sess.run(train_iterator.initializer, feed_dict={ x: train_data[0], y: train_data[1]})
​    sess.run(test_iterator.initializer, feed_dict={ x: test_data[0], y: test_data[1]})
​    
    for _ in range(EPOCHS):
        x,y = sess.run(next_elements, feed_dict = {handle: train_handle})
        print(x, y)
        
    x,y = sess.run(next_elements, feed_dict = {handle: test_handle})
    print(x,y)
{% endhighlight %}

* * *

### 데이터 사용하기  

위의 예제에서 Dataset에 있는 `next` 원소의 값을 출력하기 위해서 session을 사용했다.  

{% highlight python%}
...
next_el = iter.get_next()
...
print(sess.run(next_el)) # will output the current element
{% endhighlight %}

모델에 데이터를 공급하기 위해서는 `get_next()`로 만들어진 tensor로 공급해야한다.  

다음 부분에서는 이전의 예제에서 사용했던 두 개의 numpy 배열을 가진 Dataset을 사용했다. 데이터를 batch로 처리하는 데 필요한 차원을 추가하려면 다른 numpy 배열에 `.random.sample`을 래핑해야한다.  

{% highlight python%}
# using two numpy arrays
features, labels = (np.array([np.random.sample((100,2))]), 
​                    np.array([np.random.sample((100,1))]))
dataset = tf.data.Dataset.from_tensor_slices((features,labels)).repeat().batch(BATCH_SIZE)
{% endhighlight %}

그리고 언제나 그랬듯이 iterator를 만들어야한다.  

{% highlight python%}
iter = dataset.make_one_shot_iterator()
x, y = iter.get_next()
{% endhighlight %}

간단한 neural network model을 만들어보았다.  

{% highlight python%}
# make a simple model
net = tf.layers.dense(x, 8) # pass the first value from iter.get_next() as input
net = tf.layers.dense(net, 8)
prediction = tf.layers.dense(net, 1)
loss = tf.losses.mean_squared_error(prediction, y) # pass the second value from iter.get_net() as label
train_op = tf.train.AdamOptimizer().minimize(loss)
{% endhighlight %}

첫 번째 레이어의 입력과 loss function의 라벨로 `iter.get_next()`에서 나온 Tensor를 <strong>직접적으로</strong> 사용한다. 이제 종합해보자.  
{% highlight python%}
EPOCHS = 10
BATCH_SIZE = 16
# using two numpy arrays
features, labels = (np.array([np.random.sample((100,2))]), 
​                    np.array([np.random.sample((100,1))]))
dataset = tf.data.Dataset.from_tensor_slices((features,labels)).repeat().batch(BATCH_SIZE)
iter = dataset.make_one_shot_iterator()
x, y = iter.get_next()
# make a simple model
net = tf.layers.dense(x, 8, activation=tf.tanh) # pass the first value from iter.get_next() as input
net = tf.layers.dense(net, 8, activation=tf.tanh)
prediction = tf.layers.dense(net, 1, activation=tf.tanh)
loss = tf.losses.mean_squared_error(prediction, y) # pass the second value from iter.get_net() as label
train_op = tf.train.AdamOptimizer().minimize(loss)

with tf.Session() as sess:
​    sess.run(tf.global_variables_initializer())
​    for i in range(EPOCHS):
​        _, loss_value = sess.run([train_op, loss])
​        print("Iter: {}, Loss: {:.4f}".format(i, loss_value))
{% endhighlight %}

결과는 다음과 같다.  

{% highlight python%}
Iter: 0, Loss: 0.1328 
Iter: 1, Loss: 0.1312 
Iter: 2, Loss: 0.1296 
Iter: 3, Loss: 0.1281 
Iter: 4, Loss: 0.1267 
Iter: 5, Loss: 0.1254 
Iter: 6, Loss: 0.1242 
Iter: 7, Loss: 0.1231 
Iter: 8, Loss: 0.1220 
Iter: 9, Loss: 0.1210
{% endhighlight %}

* * *

### 유용한 것들  
#### Batch  
일반적으로 데이터를 batch 시키는 것에는 문제가 많은데, `Dataset` API를 사용하면 주어진 크기로 데이터 세트를 자동으로 처리하는`batch(BATCH_SIZE)`메서드를 사용할 수 있다. 기본 batch size는 1이고, 다음의 예에서는 4이다.  

{% highlight python%}
# BATCHING
BATCH_SIZE = 4
x = np.random.sample((100,2))
# make a dataset from a numpy array
dataset = tf.data.Dataset.from_tensor_slices(x).batch(BATCH_SIZE)
iter = dataset.make_one_shot_iterator()
el = iter.get_next()
with tf.Session() as sess:
​    print(sess.run(el)) 
{% endhighlight %}

결과는 다음과 같다.  

{% highlight python%}
[[ 0.65686128  0.99373963]
 [ 0.69690451  0.32446826]
 [ 0.57148422  0.68688242]
 [ 0.20335116  0.82473219]]
{% endhighlight %}


#### Repeat  
`.repeat()`를 사용하면 dataset이 몇 번 반복해서 사용될 지 정할 수 있다. 파라미터가 없다면 계속 반복하고 보통 계속 반복시키고 epoch 값을 직접 제어하는 것이 좋다.  

#### Shuffle  
`shuffle()`을 사용하면 설정된 epoch마다 Dataset을 섞을 수 있다.  

Dataset의 shuffle은 <strong>overfitting</strong>을 피할 때 매우 중요하다.  

또한 아래의 예처럼 다음 원소가 일정하게 선택되는 고정된 버퍼의 크기인 `buffer_size` 파라미터를 설정 할 수 있다.  

{% highlight python%}
# BATCHING
BATCH_SIZE = 4
x = np.array([[1],[2],[3],[4]])
# make a dataset from a numpy array
dataset = tf.data.Dataset.from_tensor_slices(x)
dataset = dataset.shuffle(buffer_size=100)
dataset = dataset.batch(BATCH_SIZE)
iter = dataset.make_one_shot_iterator()
el = iter.get_next()
with tf.Session() as sess:
​    print(sess.run(el))
{% endhighlight %}

첫 실행 결과:  

{% highlight python%}
[[4]
 [2]
 [3]
 [1]]
{% endhighlight %}

두 번째 실행 결과:  

{% highlight python%}
[[3]
 [1]
 [2]
 [4]]
{% endhighlight %}

원한다면 shuffle에 `seed` parameter를 설정 할 수도 있다.  

#### Map  
`map` 함수를 이용해서 dataset의 각 멤버에 사용자 지정 함수를 적용할 수 있다. 다음 예제에서는 각 원소에 2를 곱한다.  

{% highlight python%}
# MAP
x = np.array([[1],[2],[3],[4]])
# make a dataset from a numpy array
dataset = tf.data.Dataset.from_tensor_slices(x)
dataset = dataset.map(lambda x: x*2)
iter = dataset.make_one_shot_iterator()
el = iter.get_next()
with tf.Session() as sess:
#     this will run forever
        for _ in range(len(x)):
            print(sess.run(el))
{% endhighlight %}

결과:  

{% highlight python%}
[2]
[4]
[6]
[8]
{% endhighlight %}

* * *

### 전체 예제 
#### Initializable iterator
이 예제에서는 batching을 이용해서 간단한 모델을 학습시키고 <strong>Initializable iterator</strong>를 사용해서 train과 test dataset간에 전환을 할 것이다.  

{% highlight python%}
# Wrapping all together -> Switch between train and test set using Initializable iterator
EPOCHS = 10
# create a placeholder to dynamically switch between batch sizes
batch_size = tf.placeholder(tf.int64)

x, y = tf.placeholder(tf.float32, shape=[None,2]), tf.placeholder(tf.float32, shape=[None,1])
dataset = tf.data.Dataset.from_tensor_slices((x, y)).batch(batch_size).repeat()

# using two numpy arrays
train_data = (np.random.sample((100,2)), np.random.sample((100,1)))
test_data = (np.random.sample((20,2)), np.random.sample((20,1)))

iter = dataset.make_initializable_iterator()
features, labels = iter.get_next()
# make a simple model
net = tf.layers.dense(features, 8, activation=tf.tanh) # pass the first value from iter.get_next() as input
net = tf.layers.dense(net, 8, activation=tf.tanh)
prediction = tf.layers.dense(net, 1, activation=tf.tanh)

loss = tf.losses.mean_squared_error(prediction, labels) # pass the second value from iter.get_net() as label
train_op = tf.train.AdamOptimizer().minimize(loss)

with tf.Session() as sess:
​    sess.run(tf.global_variables_initializer())
​    # initialise iterator with train data
​    sess.run(iter.initializer, feed_dict={ x: train_data[0], y: train_data[1], batch_size: BATCH_SIZE})
​    print('Training...')
​    for i in range(EPOCHS):
​        tot_loss = 0
​        for _ in range(n_batches):
​            _, loss_value = sess.run([train_op, loss])
​            tot_loss += loss_value
​        print("Iter: {}, Loss: {:.4f}".format(i, tot_loss / n_batches))
​    # initialise iterator with test data
​    sess.run(iter.initializer, feed_dict={ x: test_data[0], y: test_data[1], batch_size: test_data[0].shape[0]})
​    print('Test Loss: {:4f}'.format(sess.run(loss)))
{% endhighlight %}

<strong>학습 후 dataset을 동적으로 전환 하려면 batch size에 대해서 placeholder를 사용해야 한다.</strong>  

결과:  

{% highlight python%}
Training...
Iter: 0, Loss: 0.2977
Iter: 1, Loss: 0.2152
Iter: 2, Loss: 0.1787
Iter: 3, Loss: 0.1597
Iter: 4, Loss: 0.1277
Iter: 5, Loss: 0.1334
Iter: 6, Loss: 0.1000
Iter: 7, Loss: 0.1154
Iter: 8, Loss: 0.0989
Iter: 9, Loss: 0.0948
Test Loss: 0.082150
{% endhighlight %}

#### Reinitializable Iterator  
이 예제에서는 batch를 사용해서 간단한 모델을 학습시키고 <strong>Reinitializable Iterator</strong>을 사용해서 train과 test dataset간의 전환을 할 것이다.  

{% highlight python%}
# Wrapping all together -> Switch between train and test set using Reinitializable iterator
EPOCHS = 10
# create a placeholder to dynamically switch between batch sizes
batch_size = tf.placeholder(tf.int64)

x, y = tf.placeholder(tf.float32, shape=[None,2]), tf.placeholder(tf.float32, shape=[None,1])
train_dataset = tf.data.Dataset.from_tensor_slices((x,y)).batch(batch_size).repeat()
test_dataset = tf.data.Dataset.from_tensor_slices((x,y)).batch(batch_size) # always batch even if you want to one shot it
# using two numpy arrays
train_data = (np.random.sample((100,2)), np.random.sample((100,1)))
test_data = (np.random.sample((20,2)), np.random.sample((20,1)))

# create a iterator of the correct shape and type
iter = tf.data.Iterator.from_structure(train_dataset.output_types,
​                                           train_dataset.output_shapes)
​										   features, labels = iter.get_next()
# create the initialisation operations
train_init_op = iter.make_initializer(train_dataset)
test_init_op = iter.make_initializer(test_dataset)

# make a simple model
net = tf.layers.dense(features, 8, activation=tf.tanh) # pass the first value from iter.get_next() as input
net = tf.layers.dense(net, 8, activation=tf.tanh)
prediction = tf.layers.dense(net, 1, activation=tf.tanh)

loss = tf.losses.mean_squared_error(prediction, labels) # pass the second value from iter.get_net() as label
train_op = tf.train.AdamOptimizer().minimize(loss)

with tf.Session() as sess:
​    sess.run(tf.global_variables_initializer())
​    # initialise iterator with train data
​    sess.run(train_init_op, feed_dict = {x : train_data[0], y: train_data[1], batch_size: 16})
​    print('Training...')
​    for i in range(EPOCHS):
​        tot_loss = 0
​        for _ in range(n_batches):
​            _, loss_value = sess.run([train_op, loss])
​            tot_loss += loss_value
​        print("Iter: {}, Loss: {:.4f}".format(i, tot_loss / n_batches))
​    # initialise iterator with test data
​    sess.run(test_init_op, feed_dict = {x : test_data[0], y: test_data[1], batch_size:len(test_data[0])})
​    print('Test Loss: {:4f}'.format(sess.run(loss)))
{% endhighlight %}

* * *

### 마무리 지으면서...  
`Dataset` API를 통해서 최적화된 입력 파이프라인을 만들어 모델을 학습, 평가, 테스트 할 수 있는 빠르고 강력한 방법을 사용할 수 있다. 이 포스트에서는 우리가 흔히 볼 수 있는 일반적인 작업의 대부분을 살펴보았다.  

* * *

### Other resources
TensorFlow dataset tutorial: [https://www.tensorflow.org/programmers_guide/datasets](https://www.tensorflow.org/programmers_guide/datasets)

Dataset docs:

[https://www.tensorflow.org/api_docs/python/tf/data/Dataset](https://www.tensorflow.org/api_docs/python/tf/data/Dataset)

