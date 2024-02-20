

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
