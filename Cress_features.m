%% Cres_features.m
%
% By: PS Basran     Date: Jan 27, 2020
% 
% Script: View /analyze features
%
% Notes: Requires file 'Patient' to be in current directory. Navigate / fix
% paths and your output file names

clearvars;

%% Load data

% Load feature names... text file
FeatureNames = readtable('../215FeatureNames.csv');
% Load studykey data of CaseNumber, weight, etc
ImageKey = readtable('../Cresswell_studykey.xls','Sheet','CresswellImageStudyKey');
StudyKey = readtable('../Cresswell_studykey.xls','Sheet','Cresswell_studykey');

% paths/filenames for Segmentations
CresPath = '../Rescale1.00/';
FileNameCres_Data = 'IBSI_CT__62_cases_Isotrop_1mm_1_bins_FBN_Discr___29-Jan-2020_22_03_38.mat';
 
% Load Cres segmentation
Cres_F = load([CresPath, FileNameCres_Data]);

%% Clean up and organize data for processing

% Clean up some of the table data
FeatureNames = table2array(FeatureNames(:,3));
for i=1:length(FeatureNames)
    FeatureNames(i) = strcat(num2str(i),FeatureNames(i));
end

% Convert weights into numbers... didn't explore this 
Weights = StudyKey{:,8};
Weights = strrep(Weights,'kg','');
Weights = strrep(Weights,' ','');
Weights = str2num(cell2mat(Weights));

%Obtain other data
StudyImgs = ImageKey{:,8};
CntrlImgs = ImageKey{:,9};

%Generate the indicies for radiomic profiles that were study, control, intact and not intact
Study_i = find(StudyImgs == 1);  % Study fetlocks
Cntrl_i = find(CntrlImgs == 1);  % Control fetlocks


%% Identify datasets for study (control vs study)

%Edit for each set to examine;


% Results from Cres_FBS_1 done, FBN1, FBN2
Set1 = squeeze ( Cres_F.features_all (Study_i , 1 , :) ); % Study images
Set2 = squeeze ( Cres_F.features_all (Cntrl_i , 1 , :) ); % Control images

%Check...figure w/ imagesc
figure(1);clf;
imagesc(log(abs([Set1; Set2])));
hold on; line([0 215], [19 19],'color','k','linewidth',5);
xlabel('Radiomic feature');ylabel('Log [Abs [ Study ]]')
text (1,0,'STUDY');text(1,50,'CONTROL')


%% Look for significance

for i =1 : length(FeatureNames)
    FeatureNumb = i;
    CF=1;
    
    StudyFeature    = Set1(:,FeatureNumb)*CF;
    ControlFeature  = Set2(:,FeatureNumb)*CF;
    
    %T-test
    [h_t(i),p_t(i)]=ttest2(StudyFeature,ControlFeature);
    %Wilcoxon
    [h_w(i),p_w(i)] = ranksum(StudyFeature,ControlFeature);
        
end

sigLevel = 0.001; %Adjust as desired

%Plot signifance
figure(2);clf
plot(p_t,'LineWidth',1);hold on
plot(h_w,'r','LineWidth',1); axis([0 215 0 1])
plot([0 215], [sigLevel sigLevel]);legend('T-statistic','Wilcoxon');

% xtickangle(45)

% find feature names of those that are significantly different
p_wi = find(h_w < sigLevel);
p_ti = find(p_t < sigLevel);
%h=breakxaxis([50 150]);
set(gca,'xtick',p_ti,'xticklabel',FeatureNames(p_ti),'FontSize',14);
xtickangle(45);
xlabel('Radiomic Feature');
ylabel('Significance');


%Another figure that shows the feature families% 
% %C1_29    = Morphology    Morphology (1)
% %C30_31   = LocalInten    Local Intensity (2)
% %C32_49   = Statistics    Statistics (3)
% %C50_72   = IntHistogr    Intensity Histogram (4)
% %C73_79   = IntVHstogr    Intensity Volume Histogram (5)
% %C80_104  = AveCo-ocrm    Co-occurence matrix (averaged) (6)
% %C105_129 = MerCo-ocrm    Co-occurence matrix (merged) (7)
% %C130_145 = AveRunLnMx    Run length matrix (averaged) (8)
% %C146_161 = MerRunLnMx    Run length matrix (merged) (9)
% %C162_177 = SizeZoneMx    Size zone matrix (10)
% %C178_193 = DistZoneMx    Distance zone matrix (11)
% %C194_215 = NeighGrLvl    Neighboring grey level dependence (12)
figure(1);
hold on;
RadLabelSets=['Morphology';'LocalInten'; 'Statistics'; 'IntHistogr';...
    'IntVHstogr'; 'AveCo-ocrm'; 'MerCo-ocrm'; 'AveRunLnMx'; ...
    'MerRunLnMx'; 'SizeZoneMx'; 'DistZoneMx'; 'NeighGrLvl'];
RadLabelPos = [29; 31; 49; 72; 79; 104; 129; 145; 161; 177; 193; 215];
plot([RadLabelPos, RadLabelPos]', [zeros(12,1), ones(12,1)]','k--','LineWidth',1);
for i=1:12
    text(RadLabelPos(i)-3,0.8,RadLabelSets(i,:),'Rotation',90,'FontSize',14);
end

axis([1 215 0 1 ]);

%Print out stuff to screen
for i=1:length(FeatureNames)    
    txt=strcat(FeatureNames(i),', P = ',num2str(p_t(i)));
    txt=cell2mat(txt);
    fprintf('\n%s',txt);
end
fprintf('\n');


