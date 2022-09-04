---
layout: post
title:  "[Coursera] Intro to TensorFlow (1)"
subtitle: "Machine Learning with TensorFlow on GCP"
post_description: "Coursera 강의 Machine Learning with TensorFlow on Google Cloud Platform 중 세 번째 코스인 Intro to TensorFlow의 1주차 강의노트입니다."
date:   2018-10-22 20:00:54 +0900
tags: [data-science, machine-learning, coursera, tensorflow]
background: '/img/posts/machine-learning.png'
author: cyc1am3n
comments: true
---

Coursera 강의 "Machine Learning with TensorFlow on Google Cloud Platform" 중 세 번째 코스인 [Intro to TensorFlow](https://www.coursera.org/learn/intro-tensorflow/home)의 1주차 강의노트입니다.

------

<br />

## What is TensorFlow?

***

- TensorFlow is an open-source high-performance library for `numerical computation` that uses `directed graphs`.
- The `nodes` represent mathematical operations.(ex. add)
- The `edges` represent the input and output of mathematical operations.



<br />

## Benefits  of a Directed Graph

***

- Directed acyclic graph(DAG) is a `language-independent` representation of the code in model.
- This makes graphs `being portable` between different devices.
- TensorFlow can `insert send and receive nodes` to distribute the graph across machines.
- TensorFlow can optimize the graph by `merging successive nodes` where necessary.
- TensorFlow Lite provides on-device inference of ML models on mobile devices and is available for a variety of hardware.
- TensorFlow supports `federated` learning.

<br />

## TensorFlow API Hierarchy

***

{% include image.html file="/img/posts/intro-to-tensorflow/01.png" description="TensorFlow tolkit hierarchy" class="center-75"%}

- The lowest level is a layer that's implemented to target different hardware platforms.
- The next level is a TensorFlow C++ API.
- The core Python API is what contains much of the `numeric processing code`.
- Set of Python modules that have `high level representation` of useful NN components. (good for custom model)
- `Estimator` knows how to training, evaluate, create a check point, save and serve model.

<br />

## Lazy Evaluation

***

- The Python API lets you `build and run` Directed Graphs
- Create the Graph (Build)

{% highlight python %}
...
c = tf.add(a,b)
{% endhighlight %}

- Run the Graph (Run)

{% highlight python %}
session = tf.Session()
numpy_c = session.run(c, feed_dict=...)
{% endhighlight %}

- The graph definition is separate from the training loop because this is a lazy evaluation model. (need to run the graph to get results)
- `tf.eager`, however, allows to execute operations imperatively.

<br />

## Graph and Session

***

- `Graphs` can be processed, compiled, remotely executed, and assigned  to devices.
- The `edges` represent data as `tensor` which are n-dimensional arrays.
- The `nodes` represent TensorFlow `operations` on those tensors.
- `Session` allows  TensorFlow to `cache and distribute` computation.

{% include image.html file="/img/posts/intro-to-tensorflow/02.png" description="Session" class="center-75"%}

- Execute TensorFlow graphs by calling `run()` on a `tf.Session`

<br />

## Evaluating a Tensor

***

- It is possible to `evaluate` a list of tensors.
- TensorFlow in `Eager mode` makes it easier to try out things, but is not recommended for production code.

{% highlight python %}
import tensorflow as tf
from tensorflow.contrib.eager.python import tfe
tfe.enable_eager_execution() # Call exactly once
x = tf.constant([3, 5, 7])
y = tf.constant([1, 2, 3])
print(x-y)

# OUTPUT:
# tf.Tensor([2 3 4], shape=(3,), dtype=int32)
{% endhighlight %}

<br />

## Visualizing a graph

***

- You can write the graph out using `tf.summary.FileWriter`

{% highlight python %}
import tensorflow as tf

x = tf.constant([3, 5, 7], name="x") # Name the tensors and the operations
y = tf.constant([1, 2, 3], name="y")
z1 = tf.add(x, y, name="z1")
z2 = x + y
z3 = z2 - z1

with tf.Session() as sess:
​	# Write the session graph to summary directory
​	with tf.summary.FileWriter('summaries', sess.graph) as writer:
​		a1, a3 = sess.run([z1, z3])
{% endhighlight %}

Then,

{% highlight python %}
!ls summaries
event.out.tfevents.1517032067.e7cbb0325e48
{% endhighlight %}

It's not human-readable.

- The graph can be visualized in `TensorBoard`.

<br />

## Tensors

***

- A tensor is an N-dimensional array of data.

{% include image.html file="/img/posts/intro-to-tensorflow/03.png" description="what is tensor" class="center-75"%}

- Tensors can be `sliced`

{% highlight python %}
import tensorflow as tf
x = tf.constant([3, 5, 7], [4, 6, 8])
y = x[:. 1]
with tf.Session() as sess:
​	print y.eval()

# OUTPUT:
# [5 6]
{% endhighlight %}

- Tensors can be `reshaped`

{% highlight python %}
import tensorflow as tf
x = tf.constant([[3, 5, 7], [4, 6, 8]])
y = tf.reshape(x, [3, 2])
with tf.Session() as sess:
​	print y.eval()

# OUTPUT:
# [[3 5]
#  [7 4]
#  [6 8]
{% endhighlight %}

{% highlight python %}
import tensorflow as tf
x = tf.constant([[3, 5, 7], [4, 6, 8]])
y = tf.reshape(x, [3, 2])[1, :]
with tf.Session() as sess:
​	print y.eval()

# OUTPUT:
# [7 4]
{% endhighlight %}

<br />

## Variables

***

- A variable is a tensor whose value is `initialized` and then typically `changed` as the program runs.

{% highlight python %}
def forward_pass(w, x):
​	return tf.matmul(w, x)

def train_loop(x, niter=5):
​	# Create variable, specifying how to init and whether it can be tuned
​	with tf.variable_scope("model", reuse=tf.AUTO_REUSE):
​		w = tf.get_variable("weights",
​										shape=(1, 2), # 1 x 2 matrix
​										initializer=tf.truncated_normal_initializer(),
​										trainable=True)
​	# "Training loop" of 5 updates to weights
​	preds = []
​	for k in xrange(niter):
​		preds.append(forward_pass(w, x))
​		w = w + 0.1 # "Gradient Update"
​	return preds
{% endhighlight %}

- `tf.get_variable` can be helpful to be able to reuse variables or create them afresh depending on different situations.

{% highlight python %}
with tf.Session() as sess:
​	# Multiplying [1,2] x [2,3] yields a [1,3] matrix
​	preds = train_loop(tf.constant([[3.2, 5.1, 7.2],[4.3, 6.2, 8.3]])) # 2 x 3 matrix
​	# Initialize all variables
​	tf.global_variables_initializer().run()
​	for i in xrange(len(preds)):
​		print "{}:{}".format(i, preds[i].eval())

# OUTPUT:
# 0:[[-0.5322 -1.408 -2.3759]]
# 1:[[0.2177 -0.2780 -0.8259]]
# 2:[[0.9677 0.8519 0.724]]
# 3:[[1.7177 1.9769 2.2747]]
# 4:[[2.4677 3.1155 3.8245]]
{% endhighlight %}

- To summarize, 
  1. create a variable by calling `get_variable`
  2. decide on how to `initialize` a variable
  3. use the `variable` just like any other tensor when building the graph
  4. In session, `initialize` the variable
  5. evaluate any tensor that you want to evaluate
- `Placeholders` allow you to feed in values, such as by reading from a text file

{% highlight python %}
import tensorflow as tf

a = tf.placeholder("float", None)
b = a * 4
print a
with tf.Session() as sess:
​	print(sess.run(b, feed_dict={a: [1,2,3]}))

# OUTPUT:
# Tensor("Placeholder:0", dtype=float32)
# [4 8 12]
{% endhighlight %}

<br />

## Debugging TensorFlow programs

***

- Debugging TensorFlow programs is `similar` to debugging any piece of software 
  1. Read error messages to `understand the problem`
  2. `Isolate` the method with fake data
  3. Send made-up data into the method with fake data
  4. Know how to solve common problems
- The most common problem tends to be `tensor shape`
  - Tensor shape
  - Scalar-vector mismatch
  - Data type mismatch
- Shape problems also happen because of `batch size` or because **you have a scalar when a vector is needed** (or vice versa)
- Shape problems can often be fixed using 
  1. tf.reshape()
  2. tf.expand_dims()
  3. tf.slice()
  4. tf.squeeze()
- `tf.expand_dims` inserts a dimension of 1 into a tensor's shape

{% highlight python %}
x = tf.constant([[3. 2], [4, 5], [6, 7]])
print "x.shape", x.shape
expanded = tf.expand_dims(x, 1)
print("expanded.shape", expanded.shape)

with tf.Session() as sess:
​	print("expanded:\n":, expanded.eval())

# OUTPUT:
# x.shape (3, 2)
# expanded.shape (3, 1, 2)
# expanded:
# [[[3 2]]
#  [[4 5]]
#  [[6 7]]]
{% endhighlight %}

- `tf.slice` extracts a slice from a tensor

{% highlight python %}
x = tf.constant([[3. 2], [4, 5], [6, 7]])
print "x.shape", x.shape
sliced = tf.slice(x, [0, 1], [2, 1])
print("sliced.shape", sliced.shape)

with tf.Session() as sess:
​	print("sliced:\n:", sliced.eval())

# OUTPUT:
# x.shape (3, 2)
# sliced.shape (2, 1)
# sliced:
# [[2]
#  [5]]
{% endhighlight %}

- `tf.squeeze` removes dimensions of size 1 from the shape of a tensor

{% highlight python %}
t = tf.constant([[[1],[2],[3],[4]],[[5],[6],[7],[8]]])
with tf.Session() as sess:
​	print("t")
​	print(sess.run(t))
​	print("t squeezed")
​	print(sess.run(tf.squeeze(t)))

# OUTPUT:
# t
# [[[1]
#   [2]
#   [3]
#   [4]]
#
#  [[5]
#   [6]
#   [7]
#   [8]]]
# t squeezed
# [[1 2 3 4]
#  [5 6 7 8]]
{% endhighlight %}

- Another common problem is `data type`
  - The reason is because we are `mixing types`.(ex. Adding a tensor of floats to a tensor of ints won't work)
  - One solution is to do a cast with `tf.cast()`.

------

- To debug full-blown programs. there are three methods 
  - `tf.Print()`
  - `tfdbg`
  - `TensorBoard`
- Change logging level from `WARN`

{% highlight python %}
tf.logging.set_verbosity(tf.logging.INFO)
{% endhighlight %}

- `tf.Print()` can be used to log specific tensor values

{% highlight python %}
def some_method(a, b):
​	b = tf.cast(b, tf.float32)
​	s = (a / b) # oops! NaN
​	print_ab = tf.Print(s, [a, b])
​	s = tf.where(tf.is_nan(s), tf.transpose(s)))
​	return tf.sqrt(tf.matmul(s, tf.transpose(s)))

with tf.Session() as sess:
​	fake_a = tf.constant([[5.0, 3.0, 7.1], [2.3, 4.1, 4.8]])
​	fake_b = tf.constant([[2, 0, 5], [2, 8, 7]])
​	print(sess.run(some_method(fake_a, fake_b))
{% endhighlight %}

{% highlight python %}
%bash
python xyz.py

Output:
[[ nan     nan][ nan 1.43365264]]
{% endhighlight %}

- TensorFlow has a dynamic, interactive debugger (`tfdbg`)

{% highlight python %}
import tensorflow as tf
from tensorflow.python impoty debug as tf_debug

def some_method(a, b):
​	b = tf.cast(b, tf.float32)
​	s = (a / b) # oops! NaN
​	return tf.sqrt(tf.matmul(s, tf.transpose(s)))

with tf.Session() as sess:
​	fake_a = tf.constant([[5.0, 3.0, 7.1], [2.3, 4.1, 4.8]])
​	fake_b = tf.constant([[2, 0, 5], [2, 8, 7]])

	sess = tf.debug.LocalCLIDegubWrapperSession(sess)
	sess.add_tensor_filter("has_inf_or_nan", tf_debug.has_inf_or_nan)
	print sess.run(some_method(fake_a, fake_b)

# in a Terminal window
# python xyz.py --debug
{% endhighlight %}