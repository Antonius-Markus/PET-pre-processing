

function [V_pet, img_pet_thr] = thresholdBrainImage(inputDirectory, inputFile, threshold, outputDirectory)
    % Perform thresholding on a PET neuroimaging image.
    %
    % Thresholding in neuroimaging is a common preprocessing step used to enhance the contrast between regions of interest and background noise in images. 
    % By setting a threshold value, voxels with intensities above or below this threshold can be selectively retained or removed. 
    %
    % Inputs:
    %   - inputDirectory: Directory containing the input PET image.
    %   - inputFile: Name of the input PET image file.
    %   - threshold: Threshold value for thresholding the PET image.
    %   - outputDirectory: Directory where the thresholded image will be saved.
    %
    % Outputs:
    %   - V_pet: Header information of the input PET image.
    %   - img_pet_thr: Thresholded PET image data.
    %
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
