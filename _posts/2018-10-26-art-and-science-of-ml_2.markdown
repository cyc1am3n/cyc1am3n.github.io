---
layout: post
title:  "[Coursera] Art and Science of Machine Learning (2)"
subtitle: "Machine Learning with TensorFlow on GCP"
post_description: "Coursera 강의 Machine Learning with TensorFlow on Google Cloud Platform 중 다섯 번째 코스인 Art and Science of Machine Learning의 강의노트입니다."
date:   2018-10-26 17:50:54 +0900
tags: [data-science, machine-learning, coursera, tensorflow]
background: '/img/posts/machine-learning.png'
author: cyc1am3n
comments: true
---

Coursera 강의 "Machine Learning with TensorFlow on Google Cloud Platform" 중 다섯 번째 코스인 [Art and Science of Machine Learning](https://www.coursera.org/learn/art-science-ml/home/welcome)의 강의노트입니다.

------

<br />

## Review Embedding

------

- Creating an embedding column from a `feature cross`.
- The weights in the embedding column are `learned from data`.
- The model learns how to embed the feature cross in lower-dimensional space
- Embedding a feature cross in TensorFlow

{% highlight python %} 
import tf.feature_column as fc

day_hr = fc.crossed_column([dayofweek, hourofday], 24*7)

# Transfer Learning of embedding from similar ML models
day_hr_em = fc.embedding_column(day_hr, 2,
​		ckpt_to_load_from='london/*ckpt-1000*',
​		tensor_name_in_ckpt='dayhr_embed',
​		trainable=False
)
{% endhighlight %}

- Transfer Learning of embeddings from similar ML models
  - First layer: the feature cross
  - Second layer: a mystery box labeled latent factor
  - Third layer: the embedding
  - Fourth layer: one side: image of traffic
  - Second side: image of people watching TV

<br />

## Recommendations

------

- Using a `second dimension` gives us more freedom in organizing movies by similarity
- A `d-dimensional` embedding assumes that user interest in movies can be approximated by d aspects (d < N)

{% include image.html file="/img/posts/art-and-science-of-ml/14.png" class="center-75"%}

<br />

## Data-driven Embeddings

------

- We could give the axes names, but it is not essential
- Its' easier to train a model with d inputs than a model with N inputs
- Embeddings can be learned from data

{% include image.html file="/img/posts/art-and-science-of-ml/15.png" class="center-75"%}

<br />

## Sparse Tensors

------

- `Dense` representations are inefficient in space and compute

- So, use a `sparse representation` to hold the example 

  - Build a dictionary mapping each feature to an integer from 0, ... # movies -1
  - Efficiently represent the sparse vector as just the movies the user watched

- Representing feature columns as sparse vectors (These are all different ways to create a categorical column) 

  - If you `know the keys` beforehand:

  {% highlight python %} tf.feature_column.categorical_column_with_vocabulary_list('employeeId',
  ​	vocabulary_list = ['8345', '72345', '87654', '98723', '23451'])
  {% endhighlight %}

  - If your data is `already indexed`: i.e., has integers in[0-N):

  {% highlight python %} tf.feature_column.categorical_column_with_identity('employeeId',
  ​	num_bucket = 5)
  {% endhighlight %}

  - If you don't have a vocabulary of all possible values:

{% highlight python %} 
tf.feature_column.categorical_column_with_hash_bucket('employeeId',
​	hash_bucket_size = 500)
{% endhighlight %}

<br />

## Train an Embedding

------

- Embedding are feature columns that function like layers

{% highlight python %} 
sparse_word = fc.categorical_column_with_vocabulary_list('word',
​	vocabulary_list=englishWords)
embedded_word = fc.embedding_column(sparse_word, 3)
{% endhighlight %}

- The weights in the embedding layer are learned through `backprop` just as with other weights
- Embeddings can be thought of as `latent features`.

{% include image.html file="/img/posts/art-and-science-of-ml/16.png" class="center-75"%}

<br />

## Similarity Property

------

- Embeddings provides `dimensionality reduction`.

{% include image.html file="/img/posts/art-and-science-of-ml/17.png" class="center-75"%}

- You can take advantage of this similarity property of embeddings

- A good starting point for number of embedding dimensions

  - Higher dimensions → `more accuracy`
  - Higher dimensions → `overfitting`, `slow training`
  - Empirical tradeoff

  $$dimensions\approx\sqrt[4]{possible\ values}$$

<br />

## Custom Estimator

------

- Estimator provides a lot of benefits
- Canned Estimators are sometimes insufficient

{% include image.html file="/img/posts/art-and-science-of-ml/18.png" class="center-75"%}

- Suppose that you want to use a model structure from a research paper...

  - Implement the model using low-level TensorFlow ops

  {% highlight python %} def model_from_research_paper(timeseries):
  ​	x = tf.split(timeseries, N_INPUTS, i)
  ​	lstm_cell = rnn.BasicLSTMCell(LSTM_SIZE, forget_bias=1.0)
  ​	outputs, _ = rnn.static_rnn(lstm_cell, x, dtype=tf.float32)
  ​	outputs = output[-1]
  ​	weights = tf.Variable(tf.random_normal([LSTM_SIZE, N_OUTPUTS]))
  ​	bias = tf.Variable(tf.random_normal[N_OUTPUTS]))
  ​	predictions = tf.matmul(outputs, weights) + bias
  ​	return predictions
  {% endhighlight %}

  - How do we wrap this custom model into Estimator framework?

- Create `train_and_evaluate function` with the base-class Estimator

{% highlight python %} 
def train_and_evaluate(output_dir, ...):
​	estimator = tf.estimators.Estimator(model_fn = myfunc,
​		model_dir = output_dir)
​	train_spec = get_train()
​	exporter = ...
​	eval_spec = get_valid()
​	tf.estimator.train_and_evaluate(estimator, train_spec, eval_spec)
{% endhighlight %}

- myfunc (above) is a `EstimatorSpec`.

  - The 6 things in a EstimatorSpec

  1. `Mode` is pass-through
  2. Any tensors you want to return
  3. `Loss` metric
  4. `Training` op
  5. `Eval` ops
  6. Export outputs

  {% highlight python %} def myfunc(features, targets, mode):
  	# Code up the model
  ​	predictions = model_from_research_paper(features[INCOL})

  # Set up loss function, training/eval ops
  ... # (next code)

  # Create export outputs
  export_outputs = {"regression_export_outputs":
  tf.estimator.export.RegressionOutput(value = predictions)}
  # Return EstimatorSpec
  return tf.estimator.EstimatorSpec(
  mode = mode,
  predictions = predictions_dict,
  loss = loss,
  train_op = train_op,
  eval_metric_ops = eval_metric_ops,
  export_outputs = export_outputs)

  {% endhighlight %}

  - The ops are set up in the appropriate mode

{% highlight python %} 
if mode == tf.estimator.ModeKeys.TRAIN or
​	mode == tf.estimator.ModeKeys.EVAL:
​	loss = tf.losses.mean_squared_error(targets, predictions)
​	train_op = tf.contrib.layers.optimize_loss(
​		loss=loss,
​		global_step=tf.contrib.framework.get_global_step(),
​		learning_rate=0.01,
​		optimizer="SGD")
​	eval_metric_ops = {
​		"rmse" : tf.metrics.root_mean_squared_error(targets, predictions)}
else:
​	loss = None
​	train_op = None
​	eval_metric_ops = None
{% endhighlight %}

<br />

## Keras Models

------

- Keras is high-level deep neural networks library that supports multiple backends
- Keras is easy to use for fast prototyping

{% highlight python %} 
model = Sequential()
model.add(Embedding(max_features, output_dim=256))
model.add(LSTM(128))
model.add(Dropout(0.5))
model.add(Dense(1, activation='sigmoid'))

model.compile(loss='binary_crossentropy',
​		optimizer='rmsprop',
​		metrics=['accuracy'])

model.fit(x_train, y_train, batch_size=16, epochs=10)
score = model.evaluate(x_test, y_test, batch_size=16)
{% endhighlight %}

- From a compiled Keras model, you can get an Estimator

{% highlight python %} 
from tensorflow import keras

model = Sequential()
model.add(Embedding(max_features, output_dim=256))
model.add(LSTM(128))
model.add(Dropout(0.5))
model.add(Dense(1, activation='sigmoid'))

model.compile(loss='binary_crossentropy',
​		optimizer='rmsprop',
​		metrics=['accuracy'])

# Get estimator from keras
estimator = keras.estimator.model_to_estimator(keras_model=model)
{% endhighlight %}

- You will use this estimator the way you normally use an estimator

{% highlight python %} 
def train_and_evaluate(output_dir):
​	estimator = make_keras_estimator(output_dir)
​	train_spec = tflestimator.TrainSpec(train_fn, max_steps = 1000)
​	exporter = LatestExporter('exporter', serving_input_fn)
​	eval_spec = tf.estimator.EvalSpec(eval_fn,
​				steps = None,
​				exporters = exporter)
​	tf.estimator.train_and_evaluate(estimator, train_spec, eval_spec)
{% endhighlight %}

- The connection between the input features and Keras is through a naming convention

{% highlight python %} 
model = keras.models.Sequential()
model.add(keras.layers.Dense(..., name'XYZ'))

def train_input_fn():
​	...
​	features = {
​				'XYZ_input': some_tensor,
​			}
​	return features, labels
{% endhighlight %}