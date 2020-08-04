%% FILENAME :         Cres_features_compare.m
%
% DESCRIPTION :
%        This script imports *.mat files from the Cresswell data micro CT r
%        adiomics results, lumps the cases and controls, and compares featu
%        res with the previously reported features in the Cresswell Study, 
%        such as volume and bone volume fraction.
%
% NOTES :
%        Import the *.mat radiomics data, import the *.xlsx data from the C
%        resswell data, and compare with a few plots. 
%
% AUTHOR :    Parminder S. Basran       START DATE :    03-Jan-2020
%
% CHANGES :
%
% REF NO  VERSION DATE    WHO     DETAIL
%
%
%% First define editable variables in the study

clearvars;

% Modify as needed
RadiomicsDataPath = '/Users/psb92/Documents/GitHub/EquineRadiomics/Rescale1.00/';
RadiomicsDataFileNm = 'IBSI_CT__62_cases_Isotrop_1mm_1_bins_FBN_Discr___29-Jan-2020_22_03_38.mat'; %Output from radiomics run
CresswellDataFileNm ='/Users/psb92/Documents/GitHub/EquineRadiomics/Cresswell_studykey2.xlsx'; %An excel file with a bunch of pre-formatted data
SigLevel = 0.01;    %P significance level, adjust as desired
Cthres = 0.90;       %r significance level, adjust as desired


% Correction factors to ensure radiomic resolutions are correct (because one needs to scale the voxel dimensions to run the code)
VolCF = 1.2500e-04; % Ran at '0.99836' instead of '0.049918', so vol needs to be scaled by (0.049918)^3 / (0.99836)^3  = 1.2500e-04
AreaCF = 0.0025;    % Ran at '0.99836' instead of '0.049918', so vol needs to be scaled by (0.049918)^2 / (0.99836)^2  = 0.01
DistCF = 0.05;      % Ran at '0.99836' instead of '0.049918', so vol needs to be scaled by 0.049918/0.99836  = 0.1

%% Load the Cresswell dataset

[NUM,TXT]=xlsread(CresswellDataFileNm,'CresswellImageStudyKey'); % This sheet has TV, BVF and identifies case/controls
ImageNames_c = TXT(2:length(TXT),1);

%7th column indentifes the 'study' and 8 the 'controls
study_i = find(NUM(:,7)==1);
cntrl_i = find(NUM(:,8)==1);

%Cresswell volumes and BVFs
VOL_c = NUM(1:length(NUM),10);
BVF_c = NUM(1:length(NUM),11)./VOL_c;

%Load feature names (conveniently defined in the spreadsheet)
[NUM,TXT]=xlsread(CresswellDataFileNm,'RadiomicsLUT'); % This sheet has TV, BVF and identifies case/controls
FeatureNames = TXT(2:length(TXT),4);
%Replace '_' with a space (darn you LaTex!)
for i = 1: length(FeatureNames) 
    FeatureNames(i,:) = strrep(FeatureNames(i,:),'_', ' ');
end

%% Load the micro CT dataset

load([RadiomicsDataPath, RadiomicsDataFileNm]);

%Only 1 ROI analyzed
Features_all = squeeze(features_all);

[NUM,TXT]=xlsread(CresswellDataFileNm,'RadiomicsFileOrder'); 

% %%%%%This section of code only necessary if you are not sure your radiomics
% %file order matches the original file order... this is not the case for
% %this dataset
% 
% % The radiomics data was processed starting with file names according to
% % those listed in the sheet 'RadiomicsFileOrder', which also lists the
% % pixel size and slice thickness
% count = 1;
% for i = 1:length(TXT);
%     tmp = cell2mat(TXT(i));
%     tmp2 = findstr('''',tmp);
%     ImageNames_r{count,:}=tmp(1,tmp2(1)+1:tmp2(2)-1);
% end
% %%%%% Now check your ImageNames_r = ImageNames_c as below..end of this section

% All voxel sizes are same, so pull out first one
VoxelSize = NUM(1,1);

 
%% Analyze Volumes with radiomic features
StudyVols_c = VOL_c(study_i,:);
StudyVols_r = Features_all(study_i,1) * VolCF; % First feature = voxel count volume

ControlVols_c = VOL_c(cntrl_i,:);
ControlVols_r = Features_all(cntrl_i,1) * VolCF; % First feature = voxel count volume

%Lets plot it
figure(1);clf
plot(StudyVols_c, StudyVols_r,'bo');
hold on;
plot(ControlVols_c,ControlVols_r,'ro');
axis([9.5 16 9.5, 16]);
pause(0.5);

% Done this bit

%% Analyze relationship of BVF with radiomic features
% We are going to look for features that, irrespective of whether they are
% case or controls, correlate with BVF.

% Loop through all feature sets and compute the correlation coefficient..
% use Spearman as we don't know if variables are linear (BVF isn't)

for i = 1: length(Features_all)
    CCoef(i) = corr(BVF_c, Features_all(:,i),'type','Spearman');
end

%Lets find features which have r > thresh and plot them for fun
r_thresh_i = find(abs(CCoef) >Cthres);

% Now lets see how cases and controls statistically differ for those
% features compared with BVF
BVF_z=zscore(BVF_c);
Study_BVF = BVF_c(study_i);
Control_BVF = BVF_c(cntrl_i);
[p_ref,t_ref]=ttest2(Study_BVF,Control_BVF);

% Set up data for boxplots
nS=length(Study_BVF);
nC=length(Control_BVF);
boxdata_c=[Control_BVF;Study_BVF];

for i=1:nC
    boxdatalabels_c(i,:)='Control_BVF';
    boxdatalabels_r(i,:)='Control_r  ';
end
for i=nC+1:nC+nS
    boxdatalabels_c(i,:)='Study_BVF  ';
    boxdatalabels_r(i,:)='Study_r .  ';
end


figure(1);
for i = 1:length(r_thresh_i)
    zF=Features_all(:,r_thresh_i(i));
    Study_r =  zF(study_i);
    Control_r = zF(cntrl_i);
    
    %T-test and P value for the ith feature
    [t_val(i),p_val(i)] = ttest2(Study_r,Control_r);
    
    %plot out some data
    figure(1);clf;
    plot(BVF_c(study_i),Features_all((study_i),r_thresh_i(i)),'+');
    %axis([-3 3 -3 3]); 
    grid;xlabel('BVF');ylabel(FeatureNames(r_thresh_i(i)));
    hold on;
    plot(BVF_c(cntrl_i),Features_all((cntrl_i),r_thresh_i(i)),'o');
    txt = ['z-scores of features '; FeatureNames(r_thresh_i(i)); 'r = ' num2str(CCoef(r_thresh_i(i))); ' Feature Numb: ' num2str(r_thresh_i(i))];
    title(txt);
    
    figure(2);clf
    subplot(1,2,1);
    boxplot(boxdata_c,boxdatalabels_c);
    txt = ['Boxplots ', 'BVF', 'P = ' num2str(t_ref)];
    title(txt);
    subplot(1,2,2);
    
    boxdata_r=[ Control_r;Study_r];    
    boxplot(boxdata_r,boxdatalabels_r);
    txt = [FeatureNames(r_thresh_i(i)); 'P = ' num2str(p_val(i)); ' Feature Numb: ' num2str(r_thresh_i(i))];
    title(txt);
    pause(0.5);
end

% Done this bit

%% Analyze  case and control radiomic features
% Lets see how many case/control feature differences there are

for i = 1 : length(Features_all)
    [t_val(i),p_val(i)] = ttest2(Features_all(study_i,i),Features_all(cntrl_i,i));
end

feats_siglevel = find(p_val < SigLevel);
for i = 1:length(feats_siglevel)
    Study_feat = Features_all(study_i,feats_siglevel(i));
    Control_feat = Features_all(cntrl_i,feats_siglevel(i));
    
    figure(3);clf;
    boxdata_r = [Control_feat; Study_feat];

    boxplot(boxdata_r,boxdatalabels_r);
    pvalue = p_val(feats_siglevel(i));
    txt = [FeatureNames(feats_siglevel(i)); 'P = ' num2str(pvalue); ' Feature Numb: ' num2str(feats_siglevel(i))];
    title(txt);
    pause(0.5);
end