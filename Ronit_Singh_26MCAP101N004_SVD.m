%% Image Compression Using SVD
clc; clear; close all;

%% 1. Load image and convert to grayscale
img = imread('peppers.png');      % built-in MATLAB image; replace with your own file
if size(img,3) == 3
    img = rgb2gray(img);
end

%% 2. Represent image as a matrix
A = double(img);
[m, n] = size(A);
fprintf('Image size: %d x %d\n', m, n);
fprintf('Rank of image matrix: %d\n', rank(A));

%% 3. Apply SVD
[U, S, V] = svd(A);
sv = diag(S);                     % singular values

%% 4. Reconstruct using different numbers of singular values
k_values = [5 20 50 100];
recon = cell(1, length(k_values));
for i = 1:length(k_values)
    k = k_values(i);
    recon{i} = U(:,1:k) * S(1:k,1:k) * V(:,1:k)';
end

%% 5. Error analysis and storage comparison
max_k = min(m, n);
k_range = 1:5:max_k;
errors = zeros(size(k_range));
for i = 1:length(k_range)
    k = k_range(i);
    Ak = U(:,1:k) * S(1:k,1:k) * V(:,1:k)';
    errors(i) = norm(A - Ak, 'fro') / norm(A, 'fro');   % relative error
end

fprintf('\n k    Rel.Error   PSNR(dB)   Storage(values)   Compression Ratio\n');
for i = 1:length(k_values)
    k = k_values(i);
    err = norm(A - recon{i}, 'fro') / norm(A, 'fro');
    mse = mean((A(:) - recon{i}(:)).^2);
    psnr_val = 10 * log10(255^2 / mse);
    storage = k * (m + n + 1);
    ratio = (m * n) / storage;
    fprintf('%3d   %8.4f   %8.2f   %10d        %6.2f : 1\n', ...
        k, err, psnr_val, storage, ratio);
end
fprintf('Original storage: %d values\n', m*n);

%% 6. Display images
figure('Name', 'Image Compression using SVD', 'Position', [100 100 1000 600]);
subplot(2,3,1); imshow(uint8(A)); title('Original');
for i = 1:length(k_values)
    subplot(2,3,i+1);
    imshow(uint8(recon{i}));
    title(sprintf('k = %d', k_values(i)));
end

% Singular value decay and error graphs
figure('Name', 'Analysis', 'Position', [150 150 1000 400]);
subplot(1,2,1);
semilogy(sv, 'b', 'LineWidth', 1.5);
xlabel('Index'); ylabel('Singular value (log scale)');
title('Singular Value Decay'); grid on;

subplot(1,2,2);
plot(k_range, errors, 'r', 'LineWidth', 1.5);
xlabel('Number of singular values (k)'); ylabel('Relative error');
title('Reconstruction Error vs k'); grid on;