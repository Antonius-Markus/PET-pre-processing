function roi_bp = RegionalMeanBindingPotential(mean_img, atlas_path, roi_info_path)
    % Function to Extract Regional Mean Binding Potential (BP)
    % roi_bp = RegionalMeanBindingPotential(atlas_path, roi_info_path)
    %
    % Input:
    %   - atlas_path: File path to the atlas volume.
    %   - roi_info_path: File path to the table with ROI information.
    %
    % Output:
    %   - roi_bp: Table with regional mean binding potentials and ROI names.
    %
    % Description:
    %   This function computes regional mean binding potentials from an atlas based on provided ROI information.
    %   It extracts voxel values for each ROI, calculates the mean, and stores results with ROI names.
    %
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

