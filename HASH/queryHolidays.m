function [ress] = queryHolidays( hm, sifts, num, C_255_u, C_255_d, kdtree_u, kdtree_d, hash_funs, n, k, N, subs, min_hashes )

    % prepare sift
    sift = sifts{num};
    sift = double(sift);

    % kdtrees for half sifts for 2 vocabularies of 255 words (less than a second)
    idxs_u = vl_kdtreequery(kdtree_u, C_255_u, sift(1:64,:));
    idxs_d = vl_kdtreequery(kdtree_d, C_255_d, sift(65:128,:));
    idxs = (idxs_u - 1) .* 255 + idxs_d;
    idxs = unique(idxs);

    % get min hashes
    [~, idx] = min(hash_funs(idxs,:));
    min_hash = idxs(idx);

    % get results
    res = [];
%     idx = num2str(min_hash(subs), '%05u');
    idx = min_hash(subs(:,1)) .* min_hash(subs(:,2));

    for j = 1:size(idx,2)
        if hm.isKey(idx(j))
            res = [res hm(idx(j))];
        end
    end

    ress = 0;
    un = unique(res);
    if ~isempty(un)
        ress = zeros(3,numel(un));
        ress(1,:) = un;
        for i = 1:numel(un)
            % sketches
            ress(2,i) = sum(res == un(i));
            
            % min_hashes
            ress(3, i) = sum(sum(min_hash == min_hashes(un(i),:)));
        end
        ress(2,:) = ress(2,:) ./ k;
        ress(3,:) = ress(3,:) ./ N;
        
        [~, ix] = sort(ress(3,:), 2, 'descend');
        ress = ress(:,ix);
    end
    
%     % plot the results
%     s = min([size(ress,2) 4]);
%     Imgs2 = dir('/mnt/Images/Holidays/');
%     Imgs2 = Imgs2(3:end-1);
%     
%     % plot query image
%     subplot(s+1,1,1);
%     img = imread(['/mnt/Images/Holidays/' Imgs2(num).name]);
%     subimage(img);
%     title(Imgs2(num).name);
%     axis off;
%     
%     % plot results
%     for i = 1:s
%         subplot(s+1,1,i+1);
%         img = imread(['/mnt/Images/Holidays/' Imgs2(ress(1,i)).name]);
%         subimage(img);
%         title(Imgs2(ress(1,i)).name);
%         axis off;
%     end

end

