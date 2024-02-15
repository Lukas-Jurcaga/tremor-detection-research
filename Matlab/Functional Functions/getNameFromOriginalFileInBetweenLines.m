function SelectedName = getNameFromOriginalFileInBetweenLines(FileName_Original,SignToIdentify1,PositionLine1,PositionLine2,SignToIdentify2)
% getNameFromOriginalFileInBetweenLines(FileName,'_',0,1); 
%1st (PositionLine1) = 0: 1st sample from the name; 'last": last position of the sign of interest; = 1/2/5: the 1st, 2nd or 5th sign in the name
%2nd (PositionLine2) = 0: last sample from the name; 'last": last position of the sign of interest; = 1/2/5: the 1st, 2nd or 5th sign in the name
%for PositionLine1 and PositionLine2 any number indicates the position of the sign to determine the name (1/2/5)

LocationSign1 = strfind(FileName_Original,SignToIdentify1);
if PositionLine1 == 0
    Pos1 = 1;
elseif strcmp(PositionLine1,'last')
    Pos1 = LocationSign1(end)+1;
else
    Pos1 = LocationSign1(PositionLine1)+1;
end
if nargin > 4
    LocationSign2 = strfind(FileName_Original,SignToIdentify2);    
    if strcmp(PositionLine2,'last')
        Pos2 = LocationSign2(end)-1;
    else
        Pos2 = LocationSign2(PositionLine2)-1;
    end
else
    if PositionLine2 == 0
        Pos2 = size(FileName_Original,2);
    elseif strcmp(PositionLine2,'last')
        Pos2 = LocationSign1(end)-1;
    else
        Pos2 = LocationSign1(PositionLine2)-1;
    end
end
SelectedName = char(extractBetween(FileName_Original,Pos1,Pos2));
