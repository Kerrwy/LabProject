% function Visualiz(vSurfSub)
function Visualiz(vSurfSub, Location)
% Visualize detected event points, red show.
%
%   Parameters:
%       vSurfON: Denoised and subtraction events surface.
%       vSurfSub: Only denoised events surface.
%       Location: Effective event points coordinate, red labeled when
%       visualizing.
figure(1);
imshow(vSurfSub);
% figure(2);
% imshow(vSurfON);
hold on;
if isempty(Location)
    hold off;
    drawnow;
    return;
end
% scatter(Location(:, 1), Location(:, 2), 300, '.', 'r');
% hold off;
drawnow;
end


