function p3 = new_p3(tile)

   %For magfactor, use a multiple of 3 to avoid the rounding error
   %when stacking two_tirds, one_third tiles together
   
   magfactor = 9;
   
   tile1 = imresize(tile, magfactor, 'bicubic');   
   height = size(tile1, 1);
   
   %% fundamental region is equlateral rhombus with side length = s
   
   s1 = round(height/3); 
   s = 2*s1;
   
   %NOTE on 'ugly' way of calculating the width
   %after magnification width(tile1) > tan(pi/6)*height(tile1) (should be equal)
   %and after 240 deg rotation width(tile240) < 2*width(tile1) (should be
   %bigger or equal, because we cat them together).
   %subtract one, to avoid screwing by imrotate(240)
   
   width = round(height/sqrt(3)) - 1;
   %width = min(round(height/sqrt(3)), size(tile1, 2)) - 1;
   
   %define rhombus-shaped mask
   
   x = [0 width width 0 0];
   y = [0 s1 height 2*s1 0];
   mask = poly2mask(x, y, height, width);
   tile0 = mask.*tile1(:, 1:width);
    
   %rotate rectangle by 120, 240 degs
   
   %note on 120deg rotation: 120 deg rotation of rhombus-shaped 
   %texture preserves the size, so 'crop' option can be used to 
   %tile size.
   
   tile120 = imrotate(tile0, 120, 'bilinear', 'crop');
   tile240 = imrotate(tile0, 240, 'bilinear');
   
   %%manually trim the tiles:
   
   %tile120 should have the same size as rectangle: [heigh x width]
   %tile120 = tile120(1:height, (floor(0.5*width) + 1):(floor(0.5*width) + width));
   
   %tile240 should have the size [s x 2*width]
   %find how much we need to cut from both sides
   diff = round(0.5*(size(tile240, 2) - 2*width));
   tile240 = tile240((round(0.25*s) + 1):(round(0.25*s) + s), (diff + 1):(2*width + diff));
   
   %%Start to pad tiles and glue them together
   %Resulting tile will have the size [3*height x 2* width]
   
   two_thirds1 = [tile0 tile120];
   two_thirds2 = [tile120 tile0];
   
   two_thirds = [two_thirds1; two_thirds2];
 
   %lower half of tile240 on the top, zero-padded to [height x 2 width]
   one_third11 = [tile240(0.5*s + 1:end, :); zeros(s, 2*width)];
   
   %upper half of tile240 on the bottom, zero-padded to [height x 2 width]
   one_third12 = [zeros(s, 2*width); tile240(1:0.5*s, :)];
    
   %right half of tile240 in the middle, zero-padded to [height x 2 width]
   one_third21 = [zeros(s, width); tile240(:, width + 1:end); zeros(s, width)];
   
   %left half of tile240in the middle, zero-padded to [height x 2 width]
   one_third22 =  [zeros(s, width); tile240(:, 1:width); zeros(s, width)];
   
   %cat them together
   one_third1 = [one_third11; one_third12];
   one_third2 = [one_third21 one_third22];

   %%glue everything together, shrink and replicate 
   one_third = max(one_third1, one_third2);
   
   %size(whole) = [3xheight 2xwidth]
   whole = max(two_thirds, one_third);
   p3 = imresize(whole, 1/magfactor, 'bicubic');
end