% This code calls radiomics feature calcuations as developed by 
%  Saeed Ashrafinia 
% https://github.com/ashrafinia/SERA/tree/master/Data
% All kudos goes to Saeed!


clearvars;
Rescale = 1; % Rescale =1 no rescaling, 0.05 works out to 0.099/0.05 mm = ~2 mm 
SafePathFln='/Users/psb92/Sync/_current/research/CTEquineRadiomics/ProcessuCTData/CresswellSegmentation/Rescale1.00/isoVoxSize/'; 
DiscType    = 'FBS';        % Discretization type: either 'FBN' (fixed bin numbers) or 'FBS' (fixed bin size or fixed bin width). 
BinSize = 100;               % Number of bins (for FNB) or bin size (the size of each bin for FBS). It can be an array, and the features will be calculated for each NB or BS.
isotVoxSize = 2;            % New isotropic voxel size for resampling in 3D. This will be the new voxel size in X, Y and Z dimension. 
isotVoxSize2D = 2;  
ROIFileName = 'contours';
SERA_Main_uCT_CresswellSegmentations;

clearvars;
Rescale = 1; % Rescale =1 no rescaling, 0.05 works out to 0.099/0.05 mm = ~2 mm 
SafePathFln='/Users/psb92/Sync/_current/research/CTEquineRadiomics/ProcessuCTData/CresswellSegmentation/Rescale1.00/isoVoxSize/'; 
DiscType    = 'FBS';        % Discretization type: either 'FBN' (fixed bin numbers) or 'FBS' (fixed bin size or fixed bin width). 
BinSize = 100;               % Number of bins (for FNB) or bin size (the size of each bin for FBS). It can be an array, and the features will be calculated for each NB or BS.
isotVoxSize = 10;            % New isotropic voxel size for resampling in 3D. This will be the new voxel size in X, Y and Z dimension. 
isotVoxSize2D = 10;  
ROIFileName = 'contours';
SERA_Main_uCT_CresswellSegmentations;

clearvars;
Rescale = 1; % Rescale =1 no rescaling, 0.05 works out to 0.099/0.05 mm = ~2 mm 
SafePathFln='/Users/psb92/Sync/_current/research/CTEquineRadiomics/ProcessuCTData/CresswellSegmentation/Rescale0.05/isoVoxSize/'; 
DiscType    = 'FBS';        % Discretization type: either 'FBN' (fixed bin numbers) or 'FBS' (fixed bin size or fixed bin width). 
BinSize = 100;               % Number of bins (for FNB) or bin size (the size of each bin for FBS). It can be an array, and the features will be calculated for each NB or BS.
isotVoxSize = 1;            % New isotropic voxel size for resampling in 3D. This will be the new voxel size in X, Y and Z dimension. 
isotVoxSize2D = 1;  
ROIFileName = 'contours';
SERA_Main_uCT_CresswellSegmentations;

clearvars;
Rescale = 1; % Rescale =1 no rescaling, 0.05 works out to 0.099/0.05 mm = ~2 mm 
SafePathFln='/Users/psb92/Sync/_current/research/CTEquineRadiomics/ProcessuCTData/CresswellSegmentation/Rescale0.05/isoVoxSize/'; 
DiscType    = 'FBS';        % Discretization type: either 'FBN' (fixed bin numbers) or 'FBS' (fixed bin size or fixed bin width). 
BinSize = 100;               % Number of bins (for FNB) or bin size (the size of each bin for FBS). It can be an array, and the features will be calculated for each NB or BS.
isotVoxSize = 2;            % New isotropic voxel size for resampling in 3D. This will be the new voxel size in X, Y and Z dimension. 
isotVoxSize2D = 2;  
ROIFileName = 'contours';
SERA_Main_uCT_CresswellSegmentations;

clearvars;
Rescale = 1; % Rescale =1 no rescaling, 0.05 works out to 0.099/0.05 mm = ~2 mm 
SafePathFln='/Users/psb92/Sync/_current/research/CTEquineRadiomics/ProcessuCTData/CresswellSegmentation/Rescale0.05/isoVoxSize/'; 
DiscType    = 'FBS';        % Discretization type: either 'FBN' (fixed bin numbers) or 'FBS' (fixed bin size or fixed bin width). 
BinSize = 100;               % Number of bins (for FNB) or bin size (the size of each bin for FBS). It can be an array, and the features will be calculated for each NB or BS.
isotVoxSize = 10;            % New isotropic voxel size for resampling in 3D. This will be the new voxel size in X, Y and Z dimension. 
isotVoxSize2D = 10;  
ROIFileName = 'contours';
SERA_Main_uCT_CresswellSegmentations;
