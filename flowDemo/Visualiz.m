% function Visualiz(vSurfSub)
function Location = Visualiz(vSurfON, Location, vSurfT, WindowNumber, Lwc, Lhc, Lw, Lh)
% Visualize detected event points, red show.
%
%   Parameters:
%       vSurfON: Denoised and subtraction events surface.
%       vSurfSub: Only denoised events surface.
%       Location: Effective event points coordinate, red labeled when
%       visualizing.

% if isempty(Location)
%     for k = 1:WindowNumber
%         for kk = 1:WindowNumber
%             xi = Lwc(k);
%             yi = Lhc(kk);
%             EffectiveEventsNum = 35;
%             [location, ~ ,~] = EventClusterAlgorithm(yi, xi, Lw, Lh, vSurfON, vSurfT, EffectiveEventsNum);
%             if isempty(location)
%                 continue;
%             end
%             Location = cat(1, Location, location);
%         end
%     end
% end
figure(1);
imshow(vSurfON);
hold on;
if isempty(Location)
    return;
end
scatter(Location(:, 1), Location(:, 2), 300, '.', 'r');
hold off;
drawnow;
end


