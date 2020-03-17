i% -------------------------------------------------------------------------
% Standardized Environment for Radiomics Analysis (SERA)
% Main code for calculating radiomics features based on protocols by IBSI 
% -------------------------------------------------------------------------
% DESCRIPTION: 
% This program loads an input volume and its associated ROI for 2D and 3D
% radiomics analysis. 
% Four sections found below should be configured to run the code properly:
%     %% Path to dataset and voxel size info:
%     %% Radiomics Framework Settings
%     %% Verifying Image and ROI variable names
%     %% Loading ROIs and Decrypting contours 
% 
% Each case should be located inside a separated directory, and
% two files, whose names are given to ImgFileName and ROIFileName variables
% contain the image volume and its ROI, respectively.
% It performs necessary checks at the beginning to assure the input data is
% valid, then runs the radiomics feature calculation code. The framework
% first performs image pre-processing, and then calculates various
% radiomics features, including: first-order: morphological, statistical,
% histogram, volume histogram; second-order: GLCM  and GLRLM; and higher
% order: GLSZM, GLDZM, NGLDM, NGTDM, as well as moment invarient based on
% guidelines from Image Biomarker Standardization Initiative guideline
% https://arxiv.org/pdf/1612.07003.pdf 
% -------------------------------------------------------------------------
% INPUTS:
% Inputs are located in the first two sections of the code: section 1:
% "Selecting the dataset" and section 2: "Radiomics Framework Settings".
% Make sure to set and check every variable inside these two sections. 
% -------------------------------------------------------------------------
% OUTPUTS: 
% - features_all: A matrix of calculated Radiomic features.
% -------------------------------------------------------------------------
% % AUTHOR(S): 
% - Saeed Ashrafinia
% -------------------------------------------------------------------------
% HISTORY:
% - Creation: May 2016
% - Revision: July 2018
% - 1.3: Fix legendre for AEE calculation 
% -------------------------------------------------------------------------
% STATEMENT:
% This file is part of Standardized Environment for Radiomics Analysis
% (SERA) Package by Saeed Ashrafinia, Rahmimlab.com
% --> Copyright (C) 2013-2018  Saeed Ashrafinia, Johns Hopkins University
%   All rights reserved for Saeed Ashrafinia and Arman Rahmim. 
%    This package is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
%
% -------------------------------------------------------------------------


tic
addpath 'texture_code' % Radiomics features calcualtion codes folders

%% Path to dataset and voxel size info:
% Link to datasets. Each dataset should include folders containing two
% files: one for image and one for RIO. Both of these filenames should be
% identical inside every patient directory. Every patient image and its
% ROIs should be inside a separate directory. 
% Set the path to the parent directory below:

% IBSI Standardization with CT data:
%DataDir = '..\Data\Patients\'; 
%dbsName = 'IBSI_CT'; 

%DataDir = '/Users/psb92/Sync/_current/research/CTEquineRadiomics/JonsData/IMGS/'; 
%SafePathFln='/Users/psb92/Sync/_current/research/CTEquineRadiomics/ProcessuCTData/AutoSegmentation/';

dbsName = 'IBSI_CT'; 

% Loading Excel or CSV sheet containing voxel information for each case. 
% First column has the patient ID, and has to be in the same order as the
% patient folders (alphabetically sorted). Second column contains X (=Y)
% voxel thickness, and the third column contains the  slice thickness (Z). 
% Locate the file here:   
try
    %VoxelSizeInfo = xlsread([DataDir , '..\VoxelSizes\VoxelSizeInfo.xlsx']);
    VoxelSizeInfo = xlsread('/Users/psb92/Sync/_current/research/CTEquineRadiomics/ProcessuCTData/CresswellSegmentation/Rescale0.10/VoxelSizes/VoxelSizeInfoRES.xlsx');
    
catch
    error('Error loading VoxelSizeInfo. Please make sure the Excel file name/path is correct, and you have Excell installed on your system.');
end

disp(['Selecting the ',dbsName,' dataset.']); 

%% Radiomics Framework Settings



%% !!!! Make sure to check the following two sections below: 
%      %% Verifying Image and ROI variable names
%           To specify the image and ROI variable names that which you 
%           saved inside your image and ROI ".mat" files.
% 
%      %% Loading ROIs and Decrypting contours 
%           In case you have saved multiple ROIs in your ROI variable, you
%           have to modify this section accordingly to load all ROIs and
%           append all 3D matrices into a 4D matrix.           




%% Retreiving folders inside the directory
ListDirName = dir(DataDir);
NumCases = size(ListDirName , 1) - 2;                % number of patients in the Directory

% Create a variable containing skipped cases:
% Flags: 1: less than 2 files inside dir, 2:no PETimg, 3:no contours,
% 4:conversion to uint16 error 5:empty ROI, 6:1D ROI, 7:image contains NaNs
% 8:contours.m is Empty 
SkippedCases = [];

% Check the number of files inside each directory
NumOKfolders = 0; 
for casenum = 1:NumCases
    PatDir = dir([DataDir , char(cellstr(ListDirName(casenum + 2).name))]);         % get the info of the patient dir
    if (size(PatDir , 1) - 2) >= 2
        NumOKfolders = NumOKfolders +1;
        PatDirName(NumOKfolders) = cellstr(ListDirName(casenum + 2).name); %#ok<SAGROW> % save the patient directory name
    else
        warning(['"', char(cellstr(ListDirName(casenum + 2).name)) , '" has ',int2str((size(PatDir , 1) - 2)), ' files. Probably missing something.']);
        SkippedCases = cat(1,SkippedCases , { char(cellstr(ListDirName(casenum + 2).name)) , 0 , 1});
    end
end
% disp('*******************');
disp(['Total number of folders with at least 2 files: ',int2str(NumOKfolders), ' out of ',int2str(NumCases)]);
IVHconfig = [IVH_Type, IVH_DiscCont, IVH_binSize ]; 


%% Loop over every patient
for casenum = 1:NumOKfolders
    CurrentCaseName = PatDirName(casenum); %cellstr(ListDirName(casenum + 2).name); % save the patient directory name
    CurrentCaseDir = [DataDir , char(CurrentCaseName) , '/' ];
    
    %% Loading image and contours
    disp(['Loading image and contours for patient "', char(CurrentCaseName) , '", case # ',int2str(casenum),' at ' , num2str(toc,5)]);
    
    % Loading the image
    try
        load([CurrentCaseDir , ImgFileName]);
    catch
        warning([ImgFileName, ' was not found. Skipping case # ',char(CurrentCaseName)]);
        SkippedCases = cat(1,SkippedCases , { char(cellstr(ListDirName(casenum).name)) , 0 , 2});
        continue;
    end
    % Loading the contours
    try
        load([CurrentCaseDir , ROIFileName]);
    catch
        warning([ROIFileName, ' was not found. Skipping case # ',char(CurrentCaseName)]);
        SkippedCases = cat(1,SkippedCases , { char(cellstr(ListDirName(casenum).name)) , 0 , 3});
        continue;
    end
    
    %% Verifying Image and ROI variable names
    % !!!!!!Image and ROI variable names inside ImgFileName and ROIFileName
    % !!!!!!should be specified below in front of "ImgVol" and "ROIvol".
    try
        ImgVol = vol_vals; % Change "vol_vals" to the name of variable containing the 3D matrix of the image
    catch
        error(['Image variable names inside "',ImgFileName,'". is not defined! Please fix it under this section.']);
    end
    
    try
        ROIvol = total; % Change "total" to the name of variable containing the 3D matrix of the ROI
    catch
        error(['ROI variable names inside "',ROIFileName,'". is not defined! Please fix it under this section.']);
    end

    if isempty(total)
        warning([ROIFileName,' is empty. Skipping the case.']);
        SkippedCases = cat(1,SkippedCases , { char(cellstr(ListDirName(casenum).name)) , 0 , 8});
        continue;
    end

    %% Loading ROIs and Decrypting contours 
    % !!!!!!! Currently this code is set for 1 ROI inside ROIvol. Please
    % modify this section accordingly if you have saved multiple ROIs. 
    % ******* Each ROI should be a matrix of 0 and 1. ********* 
    % ALL 3D ROIs SHOULD BE STACKED UP AND SAVED INTO THE 4D MATRIX
    % "ROIsCollection4D" VARIABLE BELOW. Please modify below accordingly.
    
    
    [dxImg, dyImg, dzImg] = size(ImgVol);     
    [dxROI, dyROI, dzROI,ROIsPerImg] = size(ROIvol);     
    
    ROIsCollection4D   = zeros(dxImg,dyImg,dzImg,ROIsPerImg,'uint8');
    try
        ROIsCollection4D(:,:,:,:) = ROIvol;
    catch
        error('Please make sure you have converted multiple ROIs correctly into a 4D matrix');
    end
    
    
     %% Plot the  contours on top of the image (This is here if you want to display images and verify loading the right ROI).
     % Uncomment and run
     
%     figure; 
%     colormap('Jet');
%     MINC = min(ImgVol(:));
%     MAXC = max(ImgVol(:));
%     
%     seg2start = 1;  % which ROI you want to start to display
%     Subsets=[2 2];  % specify the number of rows and columns of subsets if you have multiple ROIs.
% 
%     for k=1:dzROI
%         TXT = ['Slice # ',int2str(k),', ROI # '];
%         for r = seg2start:size(ROIsCollection4D,4)     
%             %subplot(Subsets(1),Subsets(2),r+1-seg2start)
%             imagesc(double(ImgVol(:,:,k))); hold on;
%             contour(double(ROIsCollection4D(:,:,k,r))*MAXC ); hold off;
%             axis image
%             title([TXT,int2str(r-1)]);
%             caxis([MINC MAXC]);
%         end
%         pause(0.05);
%     end


    
    %% Start processing
    % Data types can be changed to single below to save memory.
    % (for texture calculation code which requires singles or doubles)
    
    for roi = 1:ROIsPerImg
        %% Prepare image and ROI
         ImgVol=single(ImgVol); % Uncomment if your matrices are big!!
         ImgVol=ImgVol;
        
        % Check if ROI is not empty
        try
            ROIbox = computeBoundingBox(ROIsCollection4D(:,:,:,roi));
        catch
            if isempty(find(ROIsCollection4D(:,:,:,roi)~=0)) %#ok<*EFIND>
                warning('ROI has no voxels, Skipping this ROI');
                SkippedCases = cat(1,SkippedCases , { char(cellstr(ListDirName(casenum).name)) , roi , 5});
                continue
            end
        end
        
        
        % Check image for NaNs
        if (isnan(sum(ImgVol(:))))
            warning(['Vol image has NaNs. Skipping case # ',int2str(casenum),', ROI # ',int2str(roi)]);
            SkippedCases = cat(1,SkippedCases , { char(cellstr(ListDirName(casenum).name)) , roi , 7});
            continue
        end
        loadedROI = single(squeeze(ROIsCollection4D(:,:,:,roi))) ;
        
       
        %% Calculating features
        disp(['Calculating features for ROI # ',int2str(roi)]);
        F_all = Calc_All_Features(ImgVol,loadedROI , VoxelSizeInfo(casenum ,1) , VoxelSizeInfo(casenum ,2), isotVoxSize , isotVoxSize2D , qntz, BinSize, DiscType, DataType, VoxInterp, ROIInterp, ROI_PV, isIsot2D, isScale, isGLround, isReSegRng, ReSegIntrvl,isQuntzStat,IVHconfig,isOutliers,Feats2out); 
        features_all(casenum,roi,:,:)=F_all; %#ok<SAGROW>
        
    end
end

disp(['Features were calculated for ',int2str(size(features_all,1)),' case(s), up to ',int2str(size(features_all,2)),' ROI(s), ',...
    int2str(size(features_all,3)),' features and ',int2str(size(features_all,4)),' GLs.']); 

%% Saving the results
time    = now; 
dt = datetime; dt = strrep(datestr(dt),'/','');dt = strrep(datestr(dt),':','');

save([SafePathFln,'Radiomics_',dbsName,'_',dt,'_',int2str(NumOKfolders),'_cases_Isotrop_',num2str(isotVoxSize),'mm_',int2str(numel(BinSize)),'_bins_',DiscType,'_Discr_','.mat'] ,...
        'features_all', 'PatDirName', 'SkippedCases','isotVoxSize', 'isotVoxSize2D', 'qntz', 'BinSize', 'DiscType', 'DataType', 'VoxInterp', 'ROIInterp', 'isScale', 'isGLround', 'isReSegRng', 'ReSegIntrvl'); %#ok<UNRCH>

toc

FullFeatures = squeeze(features_all);