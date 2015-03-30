function R = AxisRotation(axis, angle)
    if axis == 'x'
        R = [1, 0, 0;
             0, cos(angle), -sin(angle);
             0, sin(angle), cos(angle)];
    elseif axis == 'y'
        R = [cos(angle), 0, sin(angle);
             0, 1, 0;
             -sin(angle), 0, cos(angle)];
    elseif axis == 'z'
        R = [cos(angle), -sin(angle), 0;
             sin(angle), cos(angle), 0;
             0, 0, 1];
    end
end