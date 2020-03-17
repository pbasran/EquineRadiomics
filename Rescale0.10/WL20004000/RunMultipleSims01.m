
clear all;

SafePathFln='/Users/psb92/Sync/_current/research/CTEquineRadiomics/ProcessuCTData/CresswellSegmentation/Rescale0.10/WL20004000/';
DataDir = '/Users/psb92/Sync/_current/research/CTEquineRadiomics/ProcessuCTData/CresswellSegmentation/Rescale0.10/IMGS/';

%%
DiscType    = 'FBN';        % Discretization type: either 'FBN' (fixed bin numbers) or 'FBS' (fixed bin size or fixed bin width). 
BinSize = 1000;             % Number of bins (for FNB) or bin size (the size of each bin for FBS). It can be an array, and the features will be calculated for each NB or BS. 
isotVoxSize = 2;            % New isotropic voxel size for resampling in 3D. This will be the new voxel size in X, Y and Z dimension. 
isotVoxSize2D = 2;          % New voxel size for resampling slices in 2D. This maintains the Z dimension, and rescales both X and Y to this number.

DataType    = 'CT';         % Type of the dataset. Choose from 'PET', 'CT' or 'MRscan'
VoxInterp   = 'linear';     % Image resampling interpolation type  ('nearest', 'linear', or 'cubic'). Note: 'cubic' yeilds inconsistensies with IBSI results. 
ROIInterp   = 'linear';     % ROI resampling interpolation type  ('nearest', 'linear', or 'cubic'), default: 'linear'

isScale     = 1;            % whether to do scaling. Has to be 1 to perform any resampling. If 0, always uses the original voxel dimension. 
isGLround   = 1;            % whether to round voxel intensities to the nearest integer (usually =1 for CT images, =0 for PET and SPECT)
isReSegRng  = 0;            % whether to perform range re-segmentation. The range is defined below in ReSegIntrvl. NOTE: Re-segmentation generally cannot be provided for arbitrary-unit modalities (MRI, SPECT)
isOutliers  = 1;            % whether to perform intensity outlier filtering re-segmentaion: remove outlier intensities from the intensity mask. If selected, voxels outside the range of +/- 3 standard deviation will be removed. 
isQuntzStat = 1;            % (default 1) whether to use quantized image to calculate first order statistical features. If 0, no image resample/interp for calculating statistical features. (0 is preferrable for PET images)
isIsot2D    = 0;            % (default 0) whether to resample image to isotropic 2D voxels (=1, i.e.keep the original slice thickness) or resample to isotropic 3D voxels (=0). (This is for 1st order features. Higher order 2D features are always calculated with original slice thickness). 

ReSegIntrvl = [2000 4000];     % Range resegmentation interval. Intensity values outside this interval would be replaced by NaN. 
ROI_PV      = 0.5;          % (default 0.5) ROI partial volume threshold. Used to threshold ROI after resampling: i.e. ROI(ROI<ROI_PV) = 0, ROI(ROI>ROI_PV) = 1.

IVH_Type    = 0;            % Setting for Intensity Volume Histogram (IVH) Unit type={0: Definite(PET,CT), 1:Arbitrary(MRI,SPECT. This is FNB), 2: use 1000 bins, 3: use same discritization as histogram (for CT)} 
IVH_DiscCont= 1;            % Disc/Cont = {0:Discrete(for CT), 1:Continuous(for CT,PET. This is FBS)}, 
IVH_binSize = 2.5;          % Bin size for Intensity Volumen Histogram in case choosing setting 1 for FNB, or setting 0 and either IVH_DiscCont options.
ROIsPerImg  = 1;            % "Maximum" number of ROIs per image. When having multiple patients, enter the largest number of ROIs across all patients. 
isROIsCombined = 0;         % Whether to combine ROIs for multiple tumors to one. 

Feats2out   = 2;            % Select carefully! (default 2) which set of features to return: 1: all IBSI features, 2: 1st-order+all 3D features, 3: 1st-order+only 2D features, 4: 1st-order + selected 2D + all 3D features, 5: all features + moment invarient, 6: Custom set of feature classes should be defined in "ReturnFeatures.m"

ImgFileName = 'imgs';     % The filename that includes the image variable. It should be identical for all cases. Each case can be in a separate folder. 
ROIFileName = 'contours';   % The filename that includes the ROI variable. It should be identical for all cases. Each case can be in a separate folder. 
                            % !!!!!! Currently, the name of variables inside ImgFileName and ROIFileName are set as "vol_vals" and "total", respectively. 
                            % !!!!!! Make sure to set them under section "%% Verifying Image and ROI variable names"
                            
ifSave      = 1;            % whether to save the results. Specify the target folder at SafePathFln                           
qntz        = 'Uniform';    % An extra option for FBN Discretization Type: Either 'Uniform' quantization or 'Lloyd' for Max-Lloyd quantization. (defualt: Uniform)


%%
fprintf('\n ----- n');

Rescale = 0.1;
%DiscType    = 'FBN';        % Discretization type: either 'FBN' (fixed bin numbers) or 'FBS' (fixed bin size or fixed bin width).
%BinSize = 1000;             % [32]<=Default Number of bins (for FNB) or bin size (the size of each bin for FBS). It can be an array, and the features will be calculated for each NB or BS.
%isotVoxSize = 1;            % New isotropic voxel size for resampling in 3D. This will be the new voxel size in X, Y and Z dimension.
%isotVoxSize2D = 1;          % New voxel size for resampling slices in 2D. This maintains the Z dimension, and rescales both X and Y to this number.
%SERA_Main_uCT;

DiscType    = 'FBN';        % Discretization type: either 'FBN' (fixed bin numbers) or 'FBS' (fixed bin size or fixed bin width).
BinSize = 1000;             % [32]<=Default Number of bins (for FNB) or bin size (the size of each bin for FBS). It can be an array, and the features will be calculated for each NB or BS.
isotVoxSize = 2;            % New isotropic voxel size for resampling in 3D. This will be the new voxel size in X, Y and Z dimension.
isotVoxSize2D = 2;          % New voxel size for resampling slices in 2D. This maintains the Z dimension, and rescales both X and Y to this number.
SERA_Main_uCT;

DiscType    = 'FBS';        % Discretization type: either 'FBN' (fixed bin numbers) or 'FBS' (fixed bin size or fixed bin width).
BinSize = 100;             % [32]<=Default Number of bins (for FNB) or bin size (the size of each bin for FBS). It can be an array, and the features will be calculated for each NB or BS.
isotVoxSize = 1;            % New isotropic voxel size for resampling in 3D. This will be the new voxel size in X, Y and Z dimension.
isotVoxSize2D = 1;          % New voxel size for resampling slices in 2D. This maintains the Z dimension, and rescales both X and Y to this number.
SERA_Main_uCT;

DiscType    = 'FBS';        % Discretization type: either 'FBN' (fixed bin numbers) or 'FBS' (fixed bin size or fixed bin width).
BinSize = 100;             % [32]<=Default Number of bins (for FNB) or bin size (the size of each bin for FBS). It can be an array, and the features will be calculated for each NB or BS.
isotVoxSize = 2;            % New isotropic voxel size for resampling in 3D. This will be the new voxel size in X, Y and Z dimension.
isotVoxSize2D = 2;          % New voxel size for resampling slices in 2D. This maintains the Z dimension, and rescales both X and Y to this number.
SERA_Main_uCT;



