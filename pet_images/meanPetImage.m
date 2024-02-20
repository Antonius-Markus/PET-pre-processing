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


