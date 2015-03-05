%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%% Generates meta features%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%this script extracts 'meta' features, such as timestamp, whether the trial
%was long or short, session number etc.
clear
tic %start timer
dir_info=loadjson('SETTINGS.json'); %get directory information
training_set=[2,6,7,11,12,13,14,16,17,18,20,21,22,23,24,26]; %vector of training subject ids
test_set=[1,3,4,5,8,9,10,15,19,25]; %vector of test subject ids
chan='Cz'; 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%% Training set%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
training_labels_path=strcat(dir_info.data,'TrainLabels.csv'); %set path
training_labels=readtable(training_labels_path); %load in training data labels
training_data=zeros(5440,11); %initialise table
for i=1:5440
   name_array{i}='placeholder99999'; 
end
var_name_table=cell2table(name_array');
training_data=array2table(training_data);
training_data=[var_name_table, training_data];

%name columns in table
training_data.Properties.VariableNames(1)={'IdFeedBack'}; %ID feedback
training_data.Properties.VariableNames(2)={'long'}; %1 for long trial, 0 for short
training_data.Properties.VariableNames(3)={'short'};  %1 for short trial, 0 for long
training_data.Properties.VariableNames(4)={'trial_no'};
training_data.Properties.VariableNames(5)={'timesptamp'};
training_data.Properties.VariableNames(6)={'session1'}; %1 for session 1, 0 otherwise (similarly for below)
training_data.Properties.VariableNames(7)={'session2'};
training_data.Properties.VariableNames(8)={'session3'};
training_data.Properties.VariableNames(9)={'session4'};
training_data.Properties.VariableNames(10)={'session5'};
training_data.Properties.VariableNames(11)={'sesh5_retrial'};
training_data.Properties.VariableNames(end)={'label'};
training_data.label=table2array(training_labels(:,2)); %load in label data into table

row_count=0;
disp('Obtaining meta features for training set .....')

for sub=training_set
    for j=1:5
        sesh=j; %session number
        disp(sprintf('Training set subject %d, session %d',sub,sesh))
        %get path
        if sub<10
            data_path=strcat(dir_info.data,sprintf('Data_S0%d_Sess0%d.csv',sub,sesh));
            sub_collect_bad=sprintf('S0%d_bad',sub);%0
            eval(strcat(sub_collect_bad,'=zeros(260,1);'))
            sub_collect_good=sprintf('S0%d_good',sub);%1
            eval(strcat(sub_collect_good,'=zeros(260,1);'))
        else
            data_path=strcat(dir_info.data,sprintf('Data_S%d_Sess0%d.csv',sub,sesh));
            sub_collect_bad=sprintf('S%d_bad',sub);%0
            eval(strcat(sub_collect_bad,'=zeros(260,1);'))
            sub_collect_good=sprintf('S%d_good',sub);%1
            eval(strcat(sub_collect_good,'=zeros(260,1);'))
        end
        
        data=readtable(data_path);
        ind=find(data.FeedBackEvent==1); %find indices of vector containing signal which correspond to feedback events
        data_filt=strcat('data.',chan);  %use data for Cz channel
        
        for i=1:length(ind)    
        row_count=row_count+1;  %incriment row count                 
        
                if sub<10
                    var_name1=sprintf('S0%d_Sess0%d',sub,sesh);
                else
                    var_name1=sprintf('S%d_Sess0%d',sub,sesh);
                end
                
                if i<10
                    var_name=strcat(var_name1,sprintf('_FB00%d',i));
                else
                    var_name=strcat(var_name1,sprintf('_FB0%d',i));
                end
             
             training_data.IdFeedBack(row_count)=cellstr(var_name);
             
             %Populate table with features
             training_data.trial_no(row_count)=i; %trial number 
             training_data.timesptamp(row_count)=data.Time(ind(i)); %timestamp 
             if sesh==1
                training_data(row_count,6)=num2cell(1); %Session 1
             elseif sesh==2
                training_data(row_count,7)=num2cell(1); %Session 2
             elseif sesh==3
                training_data(row_count,8)=num2cell(1); %Session 3
             elseif sesh==4
                training_data(row_count,9)=num2cell(1); %Session 4
             elseif sesh==5
                training_data(row_count,10)=num2cell(1); %Session 5
                training_data(row_count,3)=num2cell(1); %All trials for session 5 are short
             else
             end      
                       
             
        end
        
        %find out if short or long trial
        mean_collect=[];
        for i=1:5:length(ind)
            mean_collect=[mean_collect, mean(diff(data.Time(ind(i:i+4))))];
        end   
        trial_group=zeros(1,12);
        for k=1:12
            if mean_collect(k)<mean(mean_collect) && sesh<5
                trial_group(k)=1;
            else
                trial_group(k)=2;
            end    
        end 
        row_count_temp=row_count-59;
        for k=1:12
            if trial_group(k)==1 && sesh<5
                training_data((row_count_temp+5*k-5):(row_count_temp+5*k-1),3)=num2cell(1);
            elseif trial_group(k)==2 && sesh<5
                training_data((row_count_temp+5*k-5):(row_count_temp+5*k-1),2)=num2cell(1);
            elseif sesh==5
                training_data((row_count_temp+5*k-5):(row_count_temp+5*k-1),3)=num2cell(1);
            end
        end    
    end

end
writetable(training_data,strcat(dir_info.features,'training_set_meta_features.csv')) %save files
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%% Test set%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
test_data=zeros(3400,10);
test_data=array2table(test_data);
name_array=[];
for i=1:3400
   name_array{i}='placeholder99999'; 
end    
var_name_table=cell2table(name_array');
test_data=[var_name_table, test_data];
test_data.Properties.VariableNames(1)={'IdFeedBack'};
test_data.Properties.VariableNames(2)={'long'};
test_data.Properties.VariableNames(3)={'short'};
test_data.Properties.VariableNames(4)={'trial_no'};
test_data.Properties.VariableNames(5)={'timesptamp'};
test_data.Properties.VariableNames(6)={'session1'};
test_data.Properties.VariableNames(7)={'session2'};
test_data.Properties.VariableNames(8)={'session3'};
test_data.Properties.VariableNames(9)={'session4'};
test_data.Properties.VariableNames(10)={'session5'};
test_data.Properties.VariableNames(11)={'sesh5_retrial'};
  
disp('Obtaining meta features for test set .....')
row_count=0;
for sub=test_set
    for j=1:5
        disp(sprintf('Test set subject %d, session %d',sub,sesh))
        sesh=j;
        
        if sub<10
            data_path=strcat(dir_info.data,sprintf('Data_S0%d_Sess0%d.csv',sub,sesh));
            sub_collect_bad=sprintf('S0%d_bad',sub);%0
            eval(strcat(sub_collect_bad,'=zeros(260,1);'))
            sub_collect_good=sprintf('S0%d_good',sub);%1
            eval(strcat(sub_collect_good,'=zeros(260,1);'))
        else
            data_path=strcat(dir_info.data,sprintf('Data_S%d_Sess0%d.csv',sub,sesh));
            sub_collect_bad=sprintf('S%d_bad',sub);%0
            eval(strcat(sub_collect_bad,'=zeros(260,1);'))
            sub_collect_good=sprintf('S%d_good',sub);%1
            eval(strcat(sub_collect_good,'=zeros(260,1);'))
        end
        
        data=readtable(data_path);
        ind=find(data.FeedBackEvent==1);
        data_filt=(strcat('data.',chan));  
        
        for i=1:length(ind)    
        row_count=row_count+1;  %incriment row count 
                 
        
                if sub<10
                    var_name1=sprintf('S0%d_Sess0%d',sub,sesh);
                else
                    var_name1=sprintf('S%d_Sess0%d',sub,sesh);
                end
                
                if i<10
                    var_name=strcat(var_name1,sprintf('_FB00%d',i));
                else
                    var_name=strcat(var_name1,sprintf('_FB0%d',i));
                end
             
             test_data.IdFeedBack(row_count)=cellstr(var_name);
             
             %Populate table with features
             test_data.trial_no(row_count)=i; %trial number 
             test_data.timesptamp(row_count)=data.Time(ind(i)); %timestamp 
             if sesh==1
                test_data(row_count,6)=num2cell(1); %Session 1
             elseif sesh==2
                test_data(row_count,7)=num2cell(1); %Session 2
             elseif sesh==3
                test_data(row_count,8)=num2cell(1); %Session 3
             elseif sesh==4
                test_data(row_count,9)=num2cell(1); %Session 4
             elseif sesh==5
                test_data(row_count,10)=num2cell(1); %Session 5
                test_data(row_count,3)=num2cell(1); %All trials for session 5 are short
             else
             end      
              
        end
        
        %find out if short or long trial
        mean_collect=[];
        for i=1:5:length(ind)
            mean_collect=[mean_collect, mean(diff(data.Time(ind(i:i+4))))];
        end   
        trial_group=zeros(1,12);
        for k=1:12
            if mean_collect(k)<mean(mean_collect) && sesh<5
                trial_group(k)=1;
            else
                trial_group(k)=2;
            end    
        end 
        row_count_temp=row_count-59;
        for k=1:12
            if trial_group(k)==1 && sesh<5
                test_data((row_count_temp+5*k-5):(row_count_temp+5*k-1),3)=num2cell(1);
            elseif trial_group(k)==2 && sesh<5
                test_data((row_count_temp+5*k-5):(row_count_temp+5*k-1),2)=num2cell(1);
            elseif sesh==5
                test_data((row_count_temp+5*k-5):(row_count_temp+5*k-1),3)=num2cell(1);
            else    
            end
        end    
    end

end
writetable(test_data,strcat(dir_info.features,'test_set_meta_features.csv')) %save files

toc
