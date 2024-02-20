# PET-pre-processing

# Cognitive Neuroscience - V4

Created: February 19, 2024 3:54 PM
Last edited by: Markus Walden

# PET Preprocessing

A PET Image is a set of three dimensional pixel data. The format of the data is called voxel and it is presented inside a NIFTI-file (*.nii). There exists a library in Matlab called SPM containing the support functions for processing the voxel-data. The first block of code is the configuration settings to running majority of the functions presented. It contains input as the subject to study and atlas as the layer to contain the voxels into separate brain regions.

```matlab
% input data
currentDir = pwd;

dataFolder = fullfile(currentDir, '..', '..', '..', '..', 'data', 'health', 'pet', ...
    '1_session_neuroimaging_basics', 'nii_data');

file = 'wsrpet_nrm2018baseline1_bfsrtm_BP.nii';
inputDataPath = fullfile(dataFolder, file);

files = dir(fullfile(dataFolder, '*.nii')); 

pet_file_list = cell(length(files), 1);
for i = 1:length(files)
    pet_file_list{i} = fullfile(dataFolder, files(i).name); 
end

% atlas data
fileAtlas_input = 'aal2_atlas.nii';
fileAtlas_roi = 'aal2_atlas_roi_information.csv';

atlasFolder = fullfile(currentDir, 'data', 'atlasses');

atlasDataPath_input = fullfile(atlasFolder, fileAtlas_input);
atlasDataPath_roi   = fullfile(atlasFolder, fileAtlas_roi);

% mean
file_mean = 'baseline_mean_pet.nii';

% return path
resultsPath = ['/data/results/'];
```

## Utility functions

The utility functions capture the case of processing multiple PET-Images as one sample. This is done by calculating a mean image from a set of images or by calculating the regional mean-binding-potential(s). The first functions produces a kind of composite.

```matlab
function [mean_img, V_pet]  = meanPetImage(pet_image_paths)
    % Compute the mean PET image from a list of PET image paths.
    
    % Inputs:
    %   - pet_image_paths: A cell array containing paths to the PET image files.
    
    % Output:
    %   - mean_img: The mean PET image computed from the input list of images.
    
    % Example:
    %   pet_image_paths = {'path_to_pet_image_1.nii', 'path_to_pet_image_2.nii'};
    %   mean_img = meanPetImage(pet_image_paths);
    
    sum_img = [];
    for I = 1:numel(pet_image_paths)
        V_pet = spm_vol(pet_image_paths{I});
        img_pet = spm_read_vols(V_pet);
        if isempty(sum_img)
            sum_img = img_pet;
        else
            sum_img = sum_img + img_pet;
        end
    end
    mean_img = sum_img / numel(pet_image_paths);
end
```

The second-function utilizes uses the output from the first function and utilizes a brain-map called atlas (map of modules inside the brain). The goal is to show activity by regions of interest (ROI).

```matlab
function roi_bp = RegionalMeanBindingPotential(mean_img, atlas_path, roi_info_path)
    % Function to Extract Regional Mean Binding Potential (BP)
    % roi_bp = RegionalMeanBindingPotential(atlas_path, roi_info_path)
    
    % Input:
    %   - atlas_path: File path to the atlas volume.
    %   - roi_info_path: File path to the table with ROI information.
    
    % Output:
    %   - roi_bp: Table with regional mean binding potentials and ROI names.
    
    % Description:
    %   This function computes regional mean binding potentials from an atlas based on provided ROI information.
    %   It extracts voxel values for each ROI, calculates the mean, and stores results with ROI names.
    
    % Example:
    %   roi_bp = RegionalMeanBindingPotential('atlas.nii', 'roi_info.csv');

    V_atlas = spm_vol(atlas_path);
    atlas = spm_read_vols(V_atlas);

    roi_info = readtable(roi_info_path);
    roi_id = roi_info.roi_id;
    roi_name = roi_info.roi_name;

    roi_bp = zeros(numel(roi_id), 1);
    for I = 1:numel(roi_id)
        id = roi_id(I);
        roi_data = mean_img(atlas == id);
        roi_bp(I) = mean(roi_data);
    end

    roi_bp = array2table(roi_bp);
    roi_bp.name = roi_name;
end
```

## Main Executable

There are multiple ways to toggle the pre-processing of PET-data. The first method is about the use of threshold in order to minimize the impact of weak-values. The idea is that contrast between reaction and non-reaction is more meaningful than the scalar-value of individual voxels (3D Pixels). 

```matlab
function [V_pet, img_pet_thr] = thresholdBrainImage(inputDirectory, inputFile, threshold, outputDirectory)
    % Perform thresholding on a PET neuroimaging image.
    
    % Thresholding in neuroimaging is a common preprocessing step used to enhance the contrast between regions of interest and background noise in images. 
    % By setting a threshold value, voxels with intensities above or below this threshold can be selectively retained or removed. 
    
    % Inputs:
    %   - inputDirectory: Directory containing the input PET image.
    %   - inputFile: Name of the input PET image file.
    %   - threshold: Threshold value for thresholding the PET image.
    %   - outputDirectory: Directory where the thresholded image will be saved.
    
    % Outputs:
    %   - V_pet: Header information of the input PET image.
    %   - img_pet_thr: Thresholded PET image data.
    
    % Example:
    %   thresholdBrainImage('input_directory', 'input_file.nii', 0.2, 'output_directory')

    inputDataSource = fullfile(inputDirectory, inputFile);

    % Load the header of the PET image using spm_vol function
    V_pet = spm_vol(inputDataSource);
    img_pet = spm_read_vols(V_pet);

    % Threshold the image (assign zero to all voxels where BP<threshold)
    img_pet_thr = img_pet;
    img_pet_thr(img_pet_thr < threshold) = 0;

    % Create the relative path to the output file
    outputFilename = [inputFile(1:end-4), '_thresholded.nii']; % Remove the '.nii' extension
    relativeOutputPath = fullfile(outputDirectory, outputFilename);

    % Create the absolute path to the output file
    absoluteOutputPath = fullfile(pwd, relativeOutputPath);

    % Update the header filename to save the thresholded image separately
    V_pet.fname = absoluteOutputPath;

    % Save the thresholded image using the V_pet header and spm_write_vol function
    spm_write_vol(V_pet, img_pet_thr);

    % Display a message indicating where the thresholded image is saved
    fprintf('Thresholded image saved at: %s\n', absoluteOutputPath);
end
```

The second approach is similar to thresholding. It is to assign a mask containing a map for voxels to be ignored or accepted. The ideal is limiting the discovery to specific cell-type or other type of category that can be assigned for each voxel.

```matlab
function [V_pet, img_pet_masked] =  maskAndPlotPET(inputDir, inputFile, maskFile, outputStore)
    % combine inputfile with path
    inputDataPath = fullfile(inputDir, inputFile);

    % Load the header and image matrix of the PET image
    V_pet = spm_vol(inputDataPath);
    img_pet = spm_read_vols(V_pet);

    % Load the header and image matrix of the gray matter mask
    V_mask = spm_vol(maskFile);
    mask = spm_read_vols(V_mask);

    % Check how many unique values the mask contains
    uniqueValues = unique(mask);

    % Initialize the masked PET image matrix
    img_pet_masked = zeros(size(img_pet));

    % Assign zero to each voxel outside the gray matter mask
    img_pet_masked(logical(mask)) = img_pet(logical(mask));

    % Create the relative path to the output file
    outputFilename = [inputFile(1:end-4), '_masked.nii']; 
    relativeOutputPath = fullfile(pwd, outputStore);

    % Create the absolute path to the output file
    absoluteOutputPath = fullfile(relativeOutputPath, outputFilename);
    
    % store results into a new file
    V_pet.fname = absoluteOutputPath; 
    spm_write_vol(V_pet,img_pet_masked); 
end
```

The third example is case wherein each voxel is contained inside a region. The idea is that brain is a collection of modules responsible of differing functions. Thus, evaluating the voxels in isolation or without this classification is suspect.

```matlab
function [roi_bp, insula_id, insula_data, insula_BP] = RoiDataOnPet(input_file, atlas_input, atlas_roi)

    % Load the header of a PET image using spm_vol function (PATH)
    V_pet = spm_vol(input_file);
    img_pet = spm_read_vols(V_pet);
    
    % Load the header and image matrix of AAL2 atlas using spm_vol and spm_read_vols (PATH)
    V_atlas = spm_vol(atlas_input);
    atlas = spm_read_vols(V_atlas);
    
    % Load the atlas ROI information using readtable (PATH)
    roi_info = readtable(atlas_roi);
    roi_id = roi_info.roi_id; 
    roi_name = roi_info.roi_name;
    
    % Extract the mean BP value for right insula (Insula_R)
    insula_id = roi_id(strcmp(roi_name,'Insula_R')); 
    insula_data = img_pet(atlas == insula_id); 
    insula_BP = mean(insula_data); 

    % Next extract the mean BP value for each AAL2 ROI.
    roi_bp = zeros(size(roi_id,1),1);
    for I = 1:size(roi_id,1) 
        id = roi_id(I); 
        roi_data = img_pet(atlas == id); 
        roi_bp(I) = mean(roi_data); 
    end
    
    % Catenate BP and ROI name columns
    roi_bp = array2table(roi_bp);
    roi_bp.name = roi_name;

end
```

The final code segment contains the processing from the utility-functions sections. The idea is that this is representing a more concrete example putting together the mean-image of multiple samples-figures and the regionalization of independent voxels. 

```matlab
[mean_img, V_pet]  = meanPetImage(pet_file_list);

V_pet.fname = [pwd, resultsPath, file_mean]; 
spm_write_vol(V_pet,mean_img); 

roi_bp = RegionalMeanBindingPotential(mean_img, atlasDataPath_input, atlasDataPath_roi);
```

## Matlab and Python Integration

While using Matlab to process PET images is easy to justify. This is because Matlab is stable and in many cases favored by the non-IT community. But whereas the Matlab is suitable for pre-processing PET-data; there are some capabilities wherein using Python is advantageous; these include tasks for machine learning and neural-network based classification. 

Therefore; looking into interfaces to intergrade python and Matlab together is meaningful. Thus far, the first avenue to focus on is pycortex.  

A separate goal is to find ways to integrating the development environments together. Here, Matlab-jupiter notebook is useful.

[GitHub - mathworks/jupyter-matlab-proxy: MATLAB Integration for Jupyter enables you to run MATLAB code in Jupyter Notebooks and other Jupyter environments. You can also open MATLAB in a browser directly from your Jupyter environment to use more MATLAB features.](https://github.com/mathworks/jupyter-matlab-proxy#matlab-kernel-create-a-jupyter-notebook-using-matlab-kernel-for-jupyter)
