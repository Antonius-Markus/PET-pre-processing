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

