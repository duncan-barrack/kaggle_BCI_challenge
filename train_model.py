import cPickle
import json
import numpy as np
import pandas as pd
import time
from sklearn.linear_model import LogisticRegression
from sklearn.svm import SVC
from sklearn import preprocessing
t = time.time()
#load paths for feature files
with open('SETTINGS.json') as f:
    settings = json.load(f)
path_features=str(settings['features'])
path_trained_model=str(settings['trained_model'])

#set up models
model_fit1=SVC(probability=True,kernel='linear',C=0.0011253,random_state=1)
model_fit2=SVC(probability=True,kernel='linear',C=0.00069519,random_state=1)

#############################
##########Model 1###########
#############################


#############################
#########load data###########
#############################

#set paths
path1_train=path_features + 'training_set_meta_features.csv'
path2_train=path_features + 'training_set_ave_amp_features.csv'
path1_test=path_features + 'test_set_meta_features.csv'
path2_test=path_features + 'test_set_ave_amp_features.csv'

##load training set data
print "Model 1 (SVM, linear kernel, meta and average amplitude features), loading data ...."
train1_mod1=pd.read_csv(path1_train)
del train1_mod1['label'] #drop label
train2_mod1=pd.read_csv(path2_train)
train_mod1=pd.merge(train1_mod1,train2_mod1,on='IdFeedBack') #merge features

####Apply subset selection########
print "Model 1, applying subset selection ...."
model_fit_sub=LogisticRegression(C=0.00135)
X_scaled = preprocessing.scale(train_mod1.values[:,1:-1].astype(float))
model_fit_sub=model_fit_sub.fit(X_scaled.astype(float), train_mod1.values[:,-1].astype(int)) #fit the model      
coefs=abs(model_fit_sub.coef_)   
ind_sort=np.argsort(coefs)
ind_sort=np.fliplr(ind_sort)
end_ind=round(0.5*train_mod1.shape[1])
end_ind=np.asanyarray(end_ind)
ind_sort=ind_sort+1
ind_sort=np.append(0,ind_sort)
train_mod1=train_mod1.ix[:,np.append((ind_sort[0:end_ind.astype(np.int64)]),-1)]
test_idx=ind_sort[0:end_ind.astype(np.int64)]

print "Model 1, training ...." 
X_scaled = preprocessing.scale(train_mod1.values[:,1:-1].astype(float)) #standardise data
model_fit1=model_fit1.fit(X_scaled, train_mod1.values[:,-1].astype(int))

#save output
# save the classifier
print "Model 1, saving files ...."
model1_save=path_trained_model + 'model1.pkl'
with open(model1_save, 'wb') as fid:
    cPickle.dump(model_fit1, fid)     

# save the index values of the retained features for the test set
test_idx_save=path_trained_model + 'test_idx.csv'
np.savetxt(test_idx_save, test_idx, delimiter=",")

#############################
##########Model 2###########
#############################


#############################
#########load data###########
#############################

#set paths
path3_train=path_features + 'training_set_template_features1.csv'
path4_train=path_features + 'training_set_template_features2.csv'

#load training set data
print "Model 2 (SVM, linear kernel, meta and template features), loading data ...."
train1_mod2=pd.read_csv(path1_train)
del train1_mod2['label'] #drop label
train2_mod2=pd.read_csv(path3_train)
del train2_mod2['label'] #drop label
train3_mod2=pd.read_csv(path4_train)
train_mod2=pd.merge(train1_mod2,pd.merge(train2_mod2,train3_mod2,on='IdFeedBack'),on='IdFeedBack')

print "Model 2, training ...." 
X_scaled = preprocessing.scale(train_mod2.values[:,1:-1].astype(float)) #standardise data
model_fit2=model_fit2.fit(X_scaled, train_mod2.values[:,-1].astype(int))

#save output
# save the classifier
print "Model 2, saving files ...."
model2_save=path_trained_model + 'model2.pkl'
with open(model2_save, 'wb') as fid:
    cPickle.dump(model_fit2, fid)     


elapsed = (time.time() - t)/60
print "Elapsed time = %0.3f minutes" %elapsed
