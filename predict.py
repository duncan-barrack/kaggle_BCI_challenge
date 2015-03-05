import cPickle
import json
import numpy as np
import pandas as pd
import time
import csv
from sklearn import preprocessing
t = time.time()

#load paths for feature files
with open('SETTINGS.json') as f:
    settings = json.load(f)
path_data=str(settings['data'])    
path_features=str(settings['features'])
path_trained_model=str(settings['trained_model'])
path_submissions=str(settings['submission'])

#set paths
path1_train=path_features + 'training_set_meta_features.csv'
path2_train=path_features + 'training_set_ave_amp_features.csv'
path1_test=path_features + 'test_set_meta_features.csv'
path2_test=path_features + 'test_set_ave_amp_features.csv'

#define weighted arithemtic mean function
def arth_mean(inputs,weights):
    out=((weights[0]*inputs[0])+(weights[1]*inputs[1]))/(weights[0]+weights[1])
    return out
 

#############################
##########Model 1###########
#############################


##load training set data
print "Model 1, loading data ...."
train1_mod1=pd.read_csv(path1_train)
del train1_mod1['label'] #drop label
train2_mod1=pd.read_csv(path2_train)
train_mod1=pd.merge(train1_mod1,train2_mod1,on='IdFeedBack') #merge features

test1_mod1=pd.read_csv(path1_test)
test2_mod1=pd.read_csv(path2_test)
test_mod1=pd.merge(test1_mod1,test2_mod1,on='IdFeedBack') #merge features


#load in model 1
model1_save=path_trained_model + 'model1.pkl'
with open(model1_save, 'rb') as fid:
    model_fit1 = cPickle.load(fid)

#load indices
test_idx_save=path_trained_model + 'test_idx.csv'
test_idx=np.genfromtxt(test_idx_save, delimiter=',')
test_idx=test_idx.astype(int)

#make predictions
print "Model 1, making predictions...."
train_mod1=train_mod1.ix[:,np.append(test_idx,-1)]
X_scaled = preprocessing.scale(train_mod1.values[:,1:-1].astype(float)) #standardise data
test_mod1=test_mod1.ix[:,test_idx]
scaler = preprocessing.StandardScaler().fit(train_mod1.values[:,1:-1].astype(float))
predicts1=model_fit1.predict_proba(scaler.transform(test_mod1.values[:,1:].astype(float)))
  
#############################
##########Model 2###########
#############################
#set paths
path3_train=path_features + 'training_set_template_features1.csv'
path4_train=path_features + 'training_set_template_features2.csv'

path3_test=path_features + 'test_set_template_features1.csv'
path4_test=path_features + 'test_set_template_features2.csv'
   
  
##load training set data
print "Model 2, loading data ...."
train1_mod2=pd.read_csv(path1_train)
del train1_mod2['label'] #drop label
train2_mod2=pd.read_csv(path3_train)
del train2_mod2['label'] #drop label
train3_mod2=pd.read_csv(path4_train)
train_mod2=pd.merge(train1_mod2,pd.merge(train2_mod2,train3_mod2,on='IdFeedBack'),on='IdFeedBack')

test1_mod2=pd.read_csv(path1_test)
test2_mod2=pd.read_csv(path3_test)
test3_mod2=pd.read_csv(path4_test)
test_mod2=pd.merge(test1_mod2,pd.merge(test2_mod2,test3_mod2,on='IdFeedBack'),on='IdFeedBack')

#load in model 2
model2_save=path_trained_model + 'model2.pkl'
with open(model2_save, 'rb') as fid:
    model_fit2 = cPickle.load(fid)

#make predictions
print "Model 2, making predictions...."
X_scaled = preprocessing.scale(train_mod2.values[:,1:-1].astype(float)) #standardise data
scaler = preprocessing.StandardScaler().fit(train_mod2.values[:,1:-1].astype(float))
predicts2=model_fit2.predict_proba(scaler.transform(test_mod2.values[:,1:].astype(float)))

#############################
####Average model output#####
#############################  
print "Averaging models...."
output_prob_arth=np.zeros([3400,1])
for k in range (0,3400):
    output_prob_arth[k,0]=arth_mean([predicts1[k,1], predicts2[k,1]],[0.43, 0.57])
path_samp_sub=path_data + 'SampleSubmission.csv'

reader=csv.reader(open(path_samp_sub,"rb"),delimiter=',')
output=list(reader)#load in sample submission
for i in range(0, len(output_prob_arth)): #replace sample probs with predictions
    output[i+1][1]=output_prob_arth[i,0]

path_out=path_submissions + 'Submission.csv'
csv_out = open(path_out, 'wb')
mywriter = csv.writer(csv_out)

for row in output:
    mywriter.writerow(row)

csv_out.close()  

elapsed = (time.time() - t)/60
print "Elapsed time = %0.3f minutes" %elapsed
