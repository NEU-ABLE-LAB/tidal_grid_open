N = 3;
boxes_rows = dec2bin((1:2^(N^2-1))',N^2)=='1';
boxes_cells = mat2cell(boxes_rows,ones(2^(N^2-1),1),N^2);
boxes_mats = cellfun(@(x)(reshape(x,[N,N])), boxes_cells, ...
    'UniformOutput', false);
areas   = cellfun(@(x)(sum(sum(x  ))), boxes_mats);
widths  = cellfun(@(x)(sum(any(x,1))), boxes_mats);
heights = cellfun(@(x)(sum(any(x,2))), boxes_mats);

area_per_width = mean(areas ./ widths);
area_per_height = mean(areas ./ heights);

mean_area_per_width = mean(area_per_width);
mean_area_per_height = mean(area_per_height);

area_est_width = mean_area_per_width .* widths;
area_est_height = mean_area_per_height .* heights;

subplot(2,2,1);
a_max = max([area_est_width,area_est_height],[],2);
e_max = (a_max - areas);
histogram(e_max);
title('max');

subplot(2,2,2);
a_avg = mean([area_est_width,area_est_height],2);
e_avg = (a_avg - areas);
histogram(e_avg);
title('avg');

subplot(2,2,3);
a_sum = sum([area_est_width,area_est_height],2);
e_sum = (a_sum - areas);
histogram(e_sum);
title('sum');

subplot(2,2,4);
a_product = area_est_width .* area_est_height;
e_product = (a_product - areas);
histogram(e_product);
title('product')


