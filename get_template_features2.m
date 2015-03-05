%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%% Generate second set of template features%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%this script uses the training data to form a 'positive feedback' template
%(similarly for the negative feedback) for the ERP signal for each channel.
%Features are obtained by taking the maximum cross-correlations and cross-covariances 
%between the templates and the individual ERP signals. 

clear
tic
clear
dir_info=loadjson('SETTINGS.json'); %get directory information
tic

%set up parameters for Butterworth bandpass filter
lb=1; %set lower frequency bound (Hz)
hb=20; %set higher frequency bound (Hz)
butt_ord=5; %order for the Butterworth filter
Wn = [lb/100, hb/100];  % Normalized cutoff frequency (as data sampled at 200hz)
[b,a]=butter(butt_ord,Wn);

%parameters for the left and right boundries od the ERP template
lb=55;
rb=175;

%parameters for the lag range for the cross-correlation and cross-covariance 
lb_lag=41;
rb_lag=39;

training_set=[2,6,7,11,12,13,14,16,17,18,20,21,22,23,24,26]; %vector of training subject ids
test_set=[1,3,4,5,8,9,10,15,19,25];  %vector of test subject ids

% EEG channels
chan_vec{1}='Time';%;  Timestamp of each sample
chan_vec{2}='Fp1';%: EEG samples recorded from Fp1
chan_vec{3}='Fp2';%: EEG samples recorded from Fp2
chan_vec{4}='AF7';%: EEG samples recorded from AF7
chan_vec{5}='AF3';%: EEG samples recorded from AF3
chan_vec{6}='AF4';%: EEG samples recorded from AF4
chan_vec{7}='AF8';%: EEG samples recorded from AF8
chan_vec{8}='F7';%: EEG samples recorded from F7
chan_vec{9}='F5';%: EEG samples recorded from F5
chan_vec{10}='F3';%: EEG samples recorded from F3
chan_vec{11}='F1';%: EEG samples recorded from F1
chan_vec{12}='Fz';%: EEG samples recorded from Fz
chan_vec{13}='F2';%: EEG samples recorded from F2
chan_vec{14}='F4';%: EEG samples recorded from F4
chan_vec{15}='F6';%: EEG samples recorded from F6
chan_vec{16}='F8';%: EEG samples recorded from F8
chan_vec{17}='FT7';%: EEG samples recorded from FT7
chan_vec{18}='FC5';%: EEG samples recorded from FC5
chan_vec{19}='FC3';%: EEG samples recorded from FC3
chan_vec{20}='FC1';%: EEG samples recorded from FC1
chan_vec{21}='FCz';%: EEG samples recorded from FCz
chan_vec{22}='FC2';%: EEG samples recorded from FC2
chan_vec{23}='FC4';%: EEG samples recorded from FC4
chan_vec{24}='FC6';%: EEG samples recorded from FC6
chan_vec{25}='FT8';%: EEG samples recorded from FT8
chan_vec{26}='T7';%: EEG samples recorded from T7
chan_vec{27}='C5';%: EEG samples recorded from C5
chan_vec{28}='C3';%: EEG samples recorded from C3
chan_vec{29}='C1';%: EEG samples recorded from C1
chan_vec{30}='Cz';%: EEG samples recorded from Cz
chan_vec{31}='C2';% EEG samples recorded from C2
chan_vec{32}='C4';%: EEG samples recorded from C4
chan_vec{33}='C6';%: EEG samples recorded from C6
chan_vec{34}='T8';%: EEG samples recorded from T8
chan_vec{35}='TP7';%: EEG samples recorded from TP7
chan_vec{36}='CP5';%: EEG samples recorded from CP5
chan_vec{37}='CP3';%: EEG samples recorded from CP3
chan_vec{38}='CP1';%: EEG samples recorded from CP1
chan_vec{39}='CPz';%: EEG samples recorded from CPz
chan_vec{40}='CP2';%: EEG samples recorded from CP2
chan_vec{41}='CP4';%: EEG samples recorded from CP4
chan_vec{42}='CP6';%: EEG samples recorded from CP6
chan_vec{43}='TP8';%: EEG samples recorded from TP8
chan_vec{44}='P7';%: EEG samples recorded from P7
chan_vec{45}='P5';%: EEG samples recorded from P5
chan_vec{46}='P3';%: EEG samples recorded from P3
chan_vec{47}='P1';%: EEG samples recorded from P1
chan_vec{48}='Pz';%: EEG samples recorded from Pz
chan_vec{49}='P2';%: EEG samples recorded from P2
chan_vec{50}='P4';%: EEG samples recorded from P4
chan_vec{51}='P6';%: EEG samples recorded from P6
chan_vec{52}='P8';%: EEG samples recorded from P8
chan_vec{53}='PO7';%: EEG samples recorded from PO7
chan_vec{54}='POz';%: EEG samples recorded from POz
chan_vec{55}='P08';%: EEG samples recorded from P08
chan_vec{56}='O1';%: EEG samples recorded from O1
chan_vec{57}='O2';%: EEG samples recorded from O2
chan_vec{58}='EOG';%: samples recorded from EOG derivation
chan_vec{59}='FeedBackEvent';%: a zero vector  except for each occurring feedback timestamp for which value is equal to one

%train data
data=readtable(strcat(dir_info.features, 'training_set_meta_features.csv'));
train=data(:,1);
get_label=data.label;

%test data
data=readtable(strcat(dir_info.features, 'test_set_meta_features.csv'));
test=data(:,1);

        
        
       
        for l=2:58
            chan=chan_vec{l};
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%% Generate templates%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %get postive feedback and negative feedback templates
            row_count=0;
            count_pf=0;
            count_nf=0;
            pf_sig=zeros(rb-lb+1,1);
            nf_sig=zeros(rb-lb+1,1);
            for sub=training_set
                for j=1:5
                    sesh=j;
                    disp(sprintf('training data, chan=%s, subject=%d, session=%d', chan,sub,j))
                    
                    if sub<10
                        data_path=strcat(dir_info.data,sprintf('Data_S0%d_Sess0%d.csv',sub,sesh)); 
                    else
                        data_path=strcat(dir_info.data,sprintf('Data_S%d_Sess0%d.csv',sub,sesh)); 
                    end
                    
                    data=readtable(data_path);
                    ind=find(data.FeedBackEvent==1);
                    data_filt=filter(b,a,eval(strcat('data.',chan)));  %filter data
                    for i=1:length(ind)
                        row_count=row_count+1;
                        current_label=get_label(row_count);
                        
                        if current_label==1
                            pf_sig=pf_sig+data_filt(ind(i)+lb:ind(i)+rb);
                            count_pf=count_pf+1;
                        else
                            nf_sig=nf_sig+data_filt(ind(i)+lb:ind(i)+rb);
                            count_nf=count_nf+1;
                        end
                        
                    end
                end
            end
            pf_sig=pf_sig/count_pf;
            nf_sig=nf_sig/count_nf;
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%% Training set%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            %get max cross-correlations and cross-covariances with postive feedback and negative feedback templates
            row_count=0;
            pf_cor_collect=zeros(4080,1);
            nf_cor_collect=zeros(4080,1);
            pf_cov_collect=zeros(4080,1);
            nf_cov_collect=zeros(4080,1);
           
            for sub=training_set
                for j=1:5
                    sesh=j;
                    
                    if sub<10
                        data_path=strcat(dir_info.data,sprintf('Data_S0%d_Sess0%d.csv',sub,sesh)); 
                    else
                        data_path=strcat(dir_info.data,sprintf('Data_S%d_Sess0%d.csv',sub,sesh)); 
                    end
                    
                    data=readtable(data_path);
                    ind=find(data.FeedBackEvent==1);
                    data_filt=filter(b,a,eval(strcat('data.',chan)));  %filter data
                    for i=1:length(ind)
                        row_count=row_count+1;
                        pf_cor=xcorr(data_filt(ind(i)+lb:ind(i)+rb),pf_sig,'coeff');
                        pf_cor=max(pf_cor(length(pf_sig)-lb_lag:length(pf_sig)+rb_lag)); %max lag of 200ms
                        pf_cor_collect(row_count)=pf_cor;
                        nf_cor=xcorr(data_filt(ind(i)+lb:ind(i)+rb),nf_sig,'coeff');
                        nf_cor=max(nf_cor(length(nf_sig)-lb_lag:length(nf_sig)+rb_lag)); %max lag of 200ms
                        nf_cor_collect(row_count)=nf_cor;
                        pf_cov=xcov(data_filt(ind(i)+lb:ind(i)+rb),pf_sig);
                        pf_cov=max(pf_cov(length(pf_sig)-lb_lag:length(pf_sig)+rb_lag)); %max lag of 200ms
                        pf_cov_collect(row_count)=pf_cov;
                        nf_cov=xcov(data_filt(ind(i)+lb:ind(i)+rb),nf_sig);
                        nf_cov=max(nf_cov(length(pf_sig)-lb_lag:length(pf_sig)+rb_lag)); %max lag of 200ms
                        nf_cov_collect(row_count)=nf_cov;
                        
                        
                    end
                end
            end
            
            eval(sprintf('train.%s_pf_xcor=pf_cor_collect;',chan))
            eval(sprintf('train.%s_nf_xcor=nf_cor_collect;',chan))
            eval(sprintf('train.%s_xcor_diff=pf_cor_collect-nf_cor_collect;',chan))
            eval(sprintf('train.%s_pf_xcov=pf_cov_collect;',chan))
            eval(sprintf('train.%s_nf_xcov=nf_cov_collect;',chan))
            eval(sprintf('train.%s_xcov_ratio=pf_cov_collect./nf_cov_collect;',chan))

            row_count=0;
            pf_cor_collect=zeros(1360,1);
            nf_cor_collect=zeros(1360,1);
            pf_cov_collect=zeros(1360,1);
            nf_cov_collect=zeros(1360,1);
            pf_l2_collect=zeros(1360,1);
            nf_l2_collect=zeros(1360,1);
            
               

             
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%% Test set%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            for sub=test_set
                for j=1:5
                    sesh=j;
                    disp(sprintf('test data, chan=%s, subject=%d, session=%d', chan,sub,j))
                    
                    if sub<10
                        data_path=strcat(dir_info.data,sprintf('Data_S0%d_Sess0%d.csv',sub,sesh)); 
                    else
                        data_path=strcat(dir_info.data,sprintf('Data_S%d_Sess0%d.csv',sub,sesh)); 
                    end
                    
                    data=readtable(data_path);
                    ind=find(data.FeedBackEvent==1);
                    data_filt=filter(b,a,eval(strcat('data.',chan)));  %filter data
                    for i=1:length(ind)
                        row_count=row_count+1;
                         pf_cor=xcorr(data_filt(ind(i)+lb:ind(i)+rb),pf_sig,'coeff');
                        pf_cor=max(pf_cor(length(pf_sig)-lb_lag:length(pf_sig)+rb_lag)); %max lag of 200ms
                        pf_cor_collect(row_count)=pf_cor;
                        nf_cor=xcorr(data_filt(ind(i)+lb:ind(i)+rb),nf_sig,'coeff');
                        nf_cor=max(nf_cor(length(nf_sig)-lb_lag:length(nf_sig)+rb_lag)); %max lag of 200ms
                        nf_cor_collect(row_count)=nf_cor;
                        pf_cov=xcov(data_filt(ind(i)+lb:ind(i)+rb),pf_sig);
                        pf_cov=max(pf_cov(length(pf_sig)-lb_lag:length(pf_sig)+rb_lag)); %max lag of 200ms
                        pf_cov_collect(row_count)=pf_cov;
                        nf_cov=xcov(data_filt(ind(i)+lb:ind(i)+rb),nf_sig);
                        nf_cov=max(nf_cov(length(pf_sig)-lb_lag:length(pf_sig)+rb_lag)); %max lag of 200ms
                        nf_cov_collect(row_count)=nf_cov;
    
                    end
                end
            end
            
            eval(sprintf('test.%s_pf_xcor=pf_cor_collect;',chan))
            eval(sprintf('test.%s_nf_xcor=nf_cor_collect;',chan))
            eval(sprintf('test.%s_xcor_diff=pf_cor_collect-nf_cor_collect;',chan))
            eval(sprintf('test.%s_pf_xcov=pf_cov_collect;',chan))
            eval(sprintf('test.%s_nf_xcov=nf_cov_collect;',chan))
            eval(sprintf('test.%s_xcov_ratio=pf_cov_collect./nf_cov_collect;',chan))

            
        end
        %add labels
        train.label=get_label;
        
        %save files and clear from memory
        writetable(train,strcat(dir_info.features,'training_set_template_features2.csv')) %save files
        writetable(test,strcat(dir_info.features,'test_set_template_features2.csv')) %save files
        
 
toc
