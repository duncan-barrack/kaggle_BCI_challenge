# INRIA BCI Challenge
This repository contains the code I used for the winning solution for the INRIA BCI challenge hosted on Kaggle.

https://www.kaggle.com/c/inria-bci-challenge

# Hardware and OS
* 8 Intel Celeron M processors (1.5GHz), 64 GB RAM, 512 GB SSD 
* Ubuntu 14.04.2

# Software and version numbers
* Python - 2.7.6
  * scikit_learn - 0.14.1
  * numpy - 1.8.2
  * pandas - 0.13.1
* Matlab - R2014b (see www.mathworks.com)
  * JSONlab (this can be downloaded from http://www.mathworks.com/matlabcentral/fileexchange/33381-jsonlab--a-toolbox-to-encode-decode-json-files-in-matlab-octave)

n.b. it may be possible to use Octave (free) instead of Matlab (proprietary) but I haven't tested my code using Octave. 

# Settings.json
# Generating features
There are five Matlab scripts (generate_meta_features.m, get_sess5_retrial_features.m, ...) which will generate the features used in my model. It's important to run generate_meta_features.m before get_sess5_retrial_features.m, as the latter scripts loads the data created by the former. The order in which the other scripts are run does not matter.

To run generate_meta_features.m, simply type in the following in a matlab 

`generate_meta_features`

You will see the following printed to screen

````Obtaining meta features for training set .....
Training set subject 2, session 1
Training set subject 2, session 2````
# Fitting the model
# Predicting using the model
# Description of features
