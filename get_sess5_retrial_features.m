%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%% Generates session 5 retrial features%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%this script attempts to infer what the class labels are for session 5
%trials based on the times between feedback events
clear
tic %start timer
dir_info=loadjson('SETTINGS.json'); %get directory information
training=readtable(strcat(dir_info.features, 'training_set_meta_features.csv')); %load in meta data
training_label=training.label;
training=training(:,1:10); %exclude labels
training.sesh5_retrial=zeros(size(training,1),1); %add column for session 5 feature


%for sub=training_set
training_set=[2,6,7,11,12,13,14,16,17,18,20,21,22,23,24,26];
test_set=[1,3,4,5,8,9,10,15,19,25];
disp('Obtaining session 5 features for training set .....')

for sub=training_set

    
    for j=5
        
    
        sesh=j;
        disp(sprintf('Training set subject %d, session %d',sub,sesh))
        
        if sub<10
            data_path=strcat(dir_info.data,sprintf('Data_S0%d_Sess0%d.csv',sub,sesh));
            var_name1=sprintf('S0%d_Sess0%d',sub,sesh);
            
        else
            data_path=strcat(dir_info.data,sprintf('Data_S%d_Sess0%d.csv',sub,sesh));
            var_name1=sprintf('S%d_Sess0%d',sub,sesh);
            
        end
        
        data=readtable(data_path);
        ind_sess5=find(data.FeedBackEvent==1);
        count=0;
        collect1=zeros(1,80);
        collect2=zeros(1,19);
        i_coll1=0;
        i_coll2=0;
        for ii=1:99
            if rem(ii,5)==0
                i_coll2=i_coll2+1;
                collect2(i_coll2)=data.Time(ind_sess5(ii+1))-data.Time(ind_sess5(ii));
            else
                i_coll1=i_coll1+1;
                collect1(i_coll1)=data.Time(ind_sess5(ii+1))-data.Time(ind_sess5(ii));
            end
            max1=max(collect1);
            min1=min(collect1);
            max2=max(collect2);
            min2=min(collect2);
            
        end
        for ii=1:99  
        count=count+1;
            if rem(ii,5)==0                
                if data.Time(ind_sess5(ii+1))-data.Time(ind_sess5(ii))>max2-(max2-min2)/2
                    
                    if ii<10
                    index_name=strcat(var_name1,sprintf('_FB00%s',num2str(ii)));  
                    index=strmatch(index_name,training.IdFeedBack,'exact');
                    training.sesh5_retrial(index)=1;
                    else
                     index_name=strcat(var_name1,sprintf('_FB0%s',num2str(ii)));
                     index=strmatch(index_name,training.IdFeedBack,'exact');
                    training.sesh5_retrial(index)=1;
                    end
                %row indices=1;
                else
                end
            else
                if data.Time(ind_sess5(ii+1))-data.Time(ind_sess5(ii))>max1-(max1-min1)/2
                if ii<10
                    index_name=strcat(var_name1,sprintf('_FB00%s',num2str(ii)));  
                    index=strmatch(index_name,training.IdFeedBack,'exact');
                    training.sesh5_retrial(index)=1;
                    else
                     index_name=strcat(var_name1,sprintf('_FB0%s',num2str(ii)));
                     index=strmatch(index_name,training.IdFeedBack,'exact');
                    training.sesh5_retrial(index)=1;
                    end
                else
                end
            end
        end
    end
end
training.label=training_label; %add label
writetable(training,strcat(dir_info.features,'training_set_meta_features.csv')) %save files
%%
test=readtable(strcat(dir_info.features, 'test_set_meta_features.csv')); %load in meta data
test.sesh5_retrial=zeros(size(test,1),1);
disp('Obtaining session 5 features for test set .....')

for sub=test_set

    
    for j=5
    
        
        sesh=j;
        disp(sprintf('Test set subject %d, session %d',sub,sesh))
        
        if sub<10
            data_path=sprintf('../data/Data_S0%d_Sess0%d.csv',sub,sesh);
            var_name1=sprintf('S0%d_Sess0%d',sub,sesh);
            
        else
            data_path=sprintf('../data/Data_S%d_Sess0%d.csv',sub,sesh);
            var_name1=sprintf('S%d_Sess0%d',sub,sesh);
            
        end
        
        data=readtable(data_path);
        ind_sess5=find(data.FeedBackEvent==1);
        count=0;
        collect1=zeros(1,80);
        collect2=zeros(1,19);
        i_coll1=0;
        i_coll2=0;
        for ii=1:99
            if rem(ii,5)==0
                i_coll2=i_coll2+1;
                collect2(i_coll2)=data.Time(ind_sess5(ii+1))-data.Time(ind_sess5(ii));
            else
                i_coll1=i_coll1+1;
                collect1(i_coll1)=data.Time(ind_sess5(ii+1))-data.Time(ind_sess5(ii));
            end
            max1=max(collect1);
            min1=min(collect1);
            max2=max(collect2);
            min2=min(collect2);
            
        end
        for ii=1:99  
        count=count+1;
            if rem(ii,5)==0                
                if data.Time(ind_sess5(ii+1))-data.Time(ind_sess5(ii))>max2-(max2-min2)/2
                    
                    if ii<10
                    index_name=strcat(var_name1,sprintf('_FB00%s',num2str(ii)));  
                    index=strmatch(index_name,test.IdFeedBack,'exact');
                    test.sesh5_retrial(index)=1;
                    else
                     index_name=strcat(var_name1,sprintf('_FB0%s',num2str(ii)));
                     index=strmatch(index_name,test.IdFeedBack,'exact');
                    test.sesh5_retrial(index)=1;
                    end
                %row indices=1;
                else
                end
            else
                if data.Time(ind_sess5(ii+1))-data.Time(ind_sess5(ii))>max1-(max1-min1)/2
                if ii<10
                    index_name=strcat(var_name1,sprintf('_FB00%s',num2str(ii)));  
                    index=strmatch(index_name,test.IdFeedBack,'exact');
                    test.sesh5_retrial(index)=1;
                    else
                     index_name=strcat(var_name1,sprintf('_FB0%s',num2str(ii)));
                     index=strmatch(index_name,test.IdFeedBack,'exact');
                    test.sesh5_retrial(index)=1;
                    end
                else
                end
            end
        end
    end
end
writetable(test,strcat(dir_info.features,'test_set_meta_features.csv')) %save files