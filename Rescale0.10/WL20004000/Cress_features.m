
%% Cres_features.m
%
% By: PS Basran     Date: Jan 27, 2020
% 
% Script: View /analyze features
%
% Syntax: 
%
% Inputs: NA; 
%
% Outputs: 
%
% Notes: Requires file 'Patient' to be in current directory.
% 
% Version: 
%

clear all;

%% Load data

% Load feature names... text file
FeatureNames = readtable('/Users/psb92/Sync/_current/research/CTEquineRadiomics/ProcessuCTData/215FeatureNames.csv');
% Load studykey data of CaseNumber, weight, etc
ImageKey = readtable('/Users/psb92/Sync/_current/research/CTEquineRadiomics/ProcessuCTData/Cresswell_studykey.xls','Sheet','CresswellImageStudyKey');
StudyKey = readtable('/Users/psb92/Sync/_current/research/CTEquineRadiomics/ProcessuCTData/Cresswell_studykey.xls','Sheet','Cresswell_studykey');

% paths/filenames for Cresswell Segmentations
CresPath = '/Users/psb92/Sync/_current/research/CTEquineRadiomics/ProcessuCTData/CresswellSegmentation/Rescale0.10/WL20004000/';
FileNameCres_Data_FBN_2 = 'Radiomics_IBSI_CT_04-Feb-2020 165519_62_cases_Isotrop_2mm_1_bins_FBN_Discr_.mat';
FileNameCres_Data_FBN_1 = 'Radiomics_IBSI_CT_04-Feb-2020 160527_62_cases_Isotrop_1mm_1_bins_FBN_Discr_.mat';
FileNameCres_Data_FBS_2 = 'Radiomics_IBSI_CT_04-Feb-2020 172854_62_cases_Isotrop_1mm_1_bins_FBS_Discr_.mat';
FileNameCres_Data_FBS_1 = 'Radiomics_IBSI_CT_04-Feb-2020 172854_62_cases_Isotrop_1mm_1_bins_FBS_Discr_.mat';

% Load Cres segmentation
Cres_FBN_1 = load([CresPath, FileNameCres_Data_FBS_2]);

%% Clean up and organize data for processing

% Clean up some of the table data
FeatureNames = table2array(FeatureNames(:,3));
for i=1:length(FeatureNames)
    FeatureNames(i) = strcat(num2str(i),FeatureNames(i));
end

% Convert weights into numbers
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
Set1 = squeeze ( Cres_FBN_1.features_all (Study_i , 1 , :) ); % Study images
Set2 = squeeze ( Cres_FBN_1.features_all (Cntrl_i , 1 , :) ); % Control images

%Set2, Auto_FBS_1 has a bad dataset in

%Check...figure for imagesc
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
    
% %     %Mutual information
    
end

sigLevel = 0.05;

figure(2);clf
plot(p_t,'LineWidth',1);hold on
plot(h_w,'r','LineWidth',1); axis([0 215 0 1])
plot([0 215], [sigLevel sigLevel]);legend('T-statistic','Wilcoxon');

% xtickangle(45)

p_wi = find(h_w < sigLevel);
p_ti = find(p_t < sigLevel);
%h=breakxaxis([50 150]);
set(gca,'xtick',p_ti,'xticklabel',FeatureNames(p_ti),'FontSize',14);
xtickangle(45);
axis([50 100 0 1]);
xlabel('Radiomic Feature');
ylabel('Significance');


RadLabelSets=['Morphology';'LocalInten'; 'Statistics'; 'IntHistogr';...
    'IntVHstogr'; 'AveCo-ocrm'; 'MerCo-ocrm'; 'AveRunLnMx'; ...
    'MerRunLnMx'; 'SizeZoneMx'; 'DistZoneMx'; 'NeighGrLvl'];
RadLabelPos = [29; 31; 49; 72; 79; 104; 129; 145; 161; 177; 193; 215];
plot([RadLabelPos, RadLabelPos]', [zeros(12,1), ones(12,1)]','k--','LineWidth',1);
for i=1:12
    text(RadLabelPos(i)-3,0.8,RadLabelSets(i,:),'Rotation',90,'FontSize',14);
end

axis([50 150 0 1]);


%Print out stuff to screen
for i=1:length(FeatureNames)    
    txt=strcat(FeatureNames(i),', P = ',num2str(p_t(i)));
    txt=cell2mat(txt);
    fprintf('\n%s',txt);
end
fprintf('\n');


% % classes of radiomic features
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

%% Try z-norm
% 
% % z-score norm 
% % you must pool datasets!
% Set12=[Set1; Set2];
% zSet12=[];
% figure(1);clf
% for i = 1 : 215
%     feature_i = Set12(:,i);
%     zSet12(:,i) = zscore(feature_i,1);
% end
% 
% 
% Study = Set1(:,p_wi);
% Control = Set2(:, p_wi);
% 
% 
% for i =1 : 215,
%     FeatureNumb = i;
%     %CF = 0.0001;    % Volume correction factor
%     %CF = 0.1;       % Distance correction factor
%     %CF = 0.001;     % Area correction factor
%     CF = 1;
%     
%     StudyFeature    = Set1(:,FeatureNumb)*CF;
%     ControlFeature  = Set2(:,FeatureNumb)*CF;
%     
%     %T-test
%     [h_t(i),p_t(i)]=ttest2(StudyFeature,ControlFeature);
%     %Wilcoxon
%     [h_w(i),p_w(i)] = ranksum(StudyFeature,ControlFeature);
%     
% end
% 
% sigLevel = 0.05;
% 
% p_wi = find(h_w < sigLevel);
% p_ti = find(p_t < sigLevel);
% 
% figure(3);clf
% plot(p_t);hold on
% plot(h_w,'r'); axis([0 215 0 1])
% plot([0 215], [sigLevel sigLevel]);legend('T-statistic','Wilcoxon');

%% Comparison to original published data
%Features are statistically different?
%Check Length/Width/Height
%Check 'Bone volume fraction'

%Features which are p<0.05 from radiomics analysis (using a very broad
%threshold but using the cresswell segmentation
%     {'4Surface to volume ratio'                  }
%     {'5Compactness 1'                            }
%     {'6Compactness 2'                            }
%     {'7Spherical disproportion'                  }
%     {'8Sphericity'                               }
%     {'9Asphericity'                              }
%     {'22Area density (AEE)'                      }
%     {'24Area density (MVEE)'                     }
%     {'26Area density (convex hull)'              }
%     {'183Small distance high grey level emphasis'}
%     {'188Zone distance non-uniformity'           }

%Published data included Width, Tissue volume, and bone volume fraction
%(density)

CVol=(1/0.998^3)/10000;
CF = CVol;

%Volume is the 1st feature, check that
figure(3);clf;
featureNumb=2;
cf = CVol;
bxdata=[Set1(:,featureNumb)*cf ; Set2(:,featureNumb)*cf];
g=[repmat({'Study'},30,1); repmat({'Control'},19,1)]; 
boxplot(bxdata,g,'symbol','o');
[h,p]=ttest2(Set1(:,featureNumb), Set2(:,featureNumb));
txt = [FeatureNames(featureNumb),' P = ',num2str(p)];
title(txt);ylabel('Volume / cm^3 ');
set(gca,'FontSize',14);

%Not very close, and not statistically different like paper suggests (P
%0.0009 vs P~0.85)


%Width 
% 4 surface2volume ratio is just that
% Compactness1/2 is a measure of how spherical the shape is.   
% Cresswell also found 'isotropy' which is
%DA: Degree of anisotropy (1 - long axis eigenvalue / short axis eigenvalue ). 
%0 = isotropic, 1 = anisotropic.
% this is a morphologic feature... closest feature in ISBI is elongation
% (ratio of long/short axis eigenvalue, feature 15 (see below for figure)

figure(4);clf;
featureNumb=8;
cf = 1;
bxdata=[Set1(:,featureNumb)*cf ; Set2(:,featureNumb)*cf];
g=[repmat({'Study'},30,1); repmat({'Control'},19,1)]; 
boxplot(bxdata,g,'symbol','o');
[h,p]=ttest2(Set1(:,featureNumb), Set2(:,featureNumb));
txt = [FeatureNames(featureNumb),' P = ',num2str(p)];
title(txt);
set(gca,'FontSize',14);

% Bone volume fraction?
%22 Area density - 
% Caculate surface area of ROI, compared with surface area of the bounding
% box for the ROI
% Volume density - same but calculate the Volume of the ROI... kind of is a
% measure of how tight the ROI is a bounding box
%     {'24Area density (MVEE)'                     }
%     {'26Area density (convex hull)'              }
%     {'183Small distance high grey level emphasis'}
%     {'188Zone distance non-uniformity'           }
%17/19 is Volume density, 18
% many of these features are different, near statistically differe
% What is not related is integrated intensity, the value is
% astronimically large
% Volume fractions not significant? This radiomics analysis uses a very
% large window for the analysis
% 
% Grey level distance zone features
% The GLDZM thus captures the relation between location and grey level.
% 183 = small connections to high density voxels is HIGH
% 188 = whether the distance to neighboring pixels is uniform for different
% CT intensities.

figure(4);clf;
featureNumb=25;
cf = 1/(0.998^3);
bxdata=[Set1(:,featureNumb)*cf ; Set2(:,featureNumb)*cf];
g=[repmat({'Study'},30,1); repmat({'Control'},19,1)]; 
boxplot(bxdata,g,'symbol','o');
[h,p]=ttest2(Set1(:,featureNumb), Set2(:,featureNumb));
txt = [FeatureNames(featureNumb),' P = ',num2str(p)];
title(txt);
set(gca,'FontSize',14);


%DA: Degree of anisotropy (1 - long axis eigenvalue / short axis eigenvalue ). 
%0 = isotropic, 1 = anisotropic.... cresswell find fracture group have more
%isotropic morphology than nonfracture group...
% this is a morphologic feature... closest feature in ISBI is elongation
% (ratio of long/short axis eigenvalue, feature 15 (see below for figure)
% but this is the square root of the ratio of long/short axis... best is
% the spherical disproportion ... spherical disproportion is higher in
% study group than control (i.e, 
figure(4);clf;
featureNumb=67;
cf = 1;
bxdata=[Set1(:,featureNumb)*cf ; Set2(:,featureNumb)*cf];
g=[repmat({'Study'},30,1); repmat({'Control'},19,1)]; 
boxplot(bxdata,g,'symbol','o');
[h,p]=ttest2(Set1(:,featureNumb), Set2(:,featureNumb));
txt = [FeatureNames(featureNumb),' P = ',num2str(p)];
title(txt);
set(gca,'FontSize',14);


figure(5);clf;
featureNumb=193;
cf = 1;
bxdata=[Set1(:,featureNumb)*cf ; Set2(:,featureNumb)*cf];
g=[repmat({'Study'},30,1); repmat({'Control'},19,1)]; 
boxplot(bxdata,g,'symbol','o');
[h,p]=ttest2(Set1(:,featureNumb), Set2(:,featureNumb));
txt = [FeatureNames(featureNumb),' P = ',num2str(p)];
title(txt);
set(gca,'FontSize',14);



%% Extra scripts

figure(1);clf;
bxdata=[Volume_R1_Set1; Volume_R1_Set2];
g=[repmat({'Study'},length(StudyFeature),1); repmat({'Control'},length(ControlFeature),1)];
boxplot(bxdata,g);
txt = [FeatureNames{FeatureNumb},' ', 'TestName: ',testname, ' Score= ',num2str(p)];







Classes = [zeros(size(Control)); ones(size(Study))];
AllData = [Control; Study];



figure(1);clf;
bxdata=[Volume_R1_Set1; Volume_R1_Set2];
g=[repmat({'Study'},length(StudyFeature),1); repmat({'Control'},length(ControlFeature),1)];
boxplot(bxdata,g);
txt = [FeatureNames{FeatureNumb},' ', 'TestName: ',testname, ' Score= ',num2str(p)];

title(txt);
imgfilename = [txt '_FBN_2_auto_100.jpg'];
imagewd = getframe(gcf);
imwrite(imagewd.cdata, imgfilename);


figure(1);clf;
bxdata=[Volume_R1_Set1; Volume_R1_Set2];
g=[repmat({'Study'},length(Volume_R1_Set1),1); repmat({'Control'},length(Volume_R1_Set2),1)]; 
boxplot(bxdata,g);
[h,p]=ttest2(Volume_R1_Set1,Volume_R1_Set2);
txt = ['Volume cm^3 , P = ',num2str(p)];
title(txt);


%[Volume_R1_Set2; Volume_R1_Set1],'Notch','on','Labels',{'Fracture','Control'},'Whisker',1)
lines = findobj(gcf, 'type', 'line', 'Tag', 'Median');
set(lines, 'Color', 'g');


% % Change the boxplot color from blue to green
% a = get(get(gca,'children'),'children');   % Get the handles of all the objects
% %t = get(a,'tag');   % List the names of all the objects 
% %box1 = a(7);   % The 7th object is the first box
% set(a, 'Color', 'r');   % Set the color of the first box to green
% hold on
% x=ones(length(MPG)).*(1+(rand(length(MPG))-0.5)/5);
% x1=ones(length(MPG)).*(1+(rand(length(MPG))-0.5)/10);
% x2=ones(length(MPG)).*(1+(rand(length(MPG))-0.5)/15);
% f1=scatter(x(:,1),MPG(:,1),'k','filled');f1.MarkerFaceAlpha = 0.4;hold on 
% f2=scatter(x1(:,2).*2,MPG(:,2),'k','filled');f2.MarkerFaceAlpha = f1.MarkerFaceAlpha;hold on
% f3=scatter(x2(:,3).*3,MPG(:,3),'k','filled');f3.MarkerFaceAlpha = f1.MarkerFaceAlpha;hold on
%Check Length/Width/Height

%Check 'Bone volume fraction'


%%
% This is for cluster analysis
% Group data to see if there are some natural clustering


% 
% 
% subplot(2,2,1);
% for i=1:61,
%     plot(meas(i,:));hold on
% end
% %set(gca,'xtick',[1:215],'xticklabel',FeatureNames);
% %xtickangle(45)
% 
% meas=meas'
% 
% % K-Means Clustering...
% subplot(2,2,2);
% NumbClusters=2;
% [cidx2,cmeans2] = kmeans(meas,NumbClusters,'dist','sqeuclidean');
% [silh2,h] = silhouette(meas,cidx2,'sqeuclidean');
% eucD = pdist(meas,'euclidean');
% grid;
% 
% clustTreeEuc = linkage(eucD,'average');
% cophenet(clustTreeEuc,eucD)
% 
% subplot(2,1,2);
% Levels = 215;
% labels = [FeatureNames];
% [h,nodes] = dendrogram(clustTreeEuc,Levels,'Labels',labels);
% xtickangle(45)
% 
% % classes of radiomic features
% %C1_29    = Morphology (1)
% %C30_31   = Local Intensity (2)
% %C32_49   = Statistics (3)
% %C50_72   = Intensity Histogram (4)
% %C73_79   = Intensity Volume Histogram (5)
% %C80_104  = Co-occurence matrix (averaged) (6)
% %C105_129 = Co-occurence matrix (merged) (7)
% %C130_145 = Run length matrix (averaged) (8)
% %C146_161 = Run length matrix (merged) (9)
% %C162_177 = Size zone matrix (10)
% %C178_193 = Distance zone matrix (11)
% %C194_215 = Neighboring grey level dependence (12)
% 
% 
% 
% 
% 
% 
% 
