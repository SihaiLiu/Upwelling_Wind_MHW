function [flag] = judgeLeapYear(year)
    % Input the year to be determined
    % Call format: judgeLeapYear(year)
    % If it is a leap year, it returns 1
    % Otherwise, it returns 0
    if ( (mod(year, 4) == 0 & mod(year, 100) ~= 0) | mod(year, 400) == 0)
        flag = 1;
    else
        flag = 0;
    end
end
