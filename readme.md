% Radiomics feature calculations for Equine Study
%
% By Parminder S. Basran... just a scientist who codes badly.
% March 17,2020


% Code was adopted from Saeed Ashrafinia code
% https://github.com/ashrafinia/SERA/tree/master/Datae/master/Data
% also available via Dr Arman Rahim's lab
% https://rahimlab.com/software/sera/

% Here are the basic steps 
% 1. We use the radiomics platform described above
% 2. The radiomics platform blows up for very small image resolutions. So,
% we simply trick it into thinking voxels sizes are bigger (i used 0.9ish mm for the simulations)
% mm, and be careful about converting units and dimensions. 
% 3. For resampled data, we average over superimposed voxels of the CT data
% and the ROI
% 4. The ROI and CT image files are stored in a dataformat as required in
% SERA
% 5. We used an image-growing algorithm to generate the ROIs, created by
% Daniel (2020). Region Growing (2D/3D grayscale) 
% https://www.mathworks.com/matlabcentral/fileexchange/32532-region-growing-2d-3d-grayscale)
% MATLAB Central File Exchange
% 
% ROIs were generated AFTER CT data was resampled.
% 
% If you run this code, please edit your paths and create your voxel.xlsx file.
% 



% Code used
% RunMultipleSims.m <= Does what you think. Set parameters so that features
% can be calculated for different radiomic settings
%
% SERA_Main_uCT_CresswellSegmentations.m <=Is a severely edited version of
% the SERA_Main.m code devised by Saeed (apologies!)

% Datasets
% IMG.zip contains all the image and ROI data separated into formats that
% the SERA code requires. This was done by Jon 

% If you have questions, please contact me via github
