% given a set of sorted points (x,y) that define a polygon  
% for each pair of points this function compute the x and y projection 
% of segment between them and the coordinates of the midpoint
%
% INPUT PARAMETERS
% x, y = arrays of x and y coordinates, respectively;
%        NB: these points have to be ordinated along the domain boundary
% label= array of point labels
%
% OUTPUT PARAMETERS
% xM, yM = arrays of x and y coordinates of the midpoints
% nodes = matrix containing the label of the pair of points corresponding 
%         to the computed midpoints
	   % prHor, prVert = projections of segment of which (xM,yM)is the 
%                            midpoint, on x and y direction, respectively

function [xM,yM,nodes,prHor,prVert]=computeMidPoint(x,y,label)

if size(x,1) ~= size(y,1)
    error('x and y must have the same dimensions');
end
if size(label,1) ~= size(y,1)
    error('label must have the same dimensions thayt x and y');
end
if (size(x,2)~=1|size(y,2)~=1|size(label,2)~=1)
    error('x,y and label must be vertical arrays');
end

for i=1:size(x,1)
    nodes(i,1)=label(i); %label of the first point
    if i~=size(x,1)
        xM(i)=(x(i)+x(i+1))/2; %midpoint x coordinate
        yM(i)=(y(i)+y(i+1))/2; %midpoint y coordinate
        nodes(i,2)=label(i+1); %label of the second point

        side= sqrt((x(i)-x(i+1))^2+(y(i)-y(i+1))^2);
        angCoef=(y(i)-y(i+1))/(x(i)-x(i+1));
    else
        xM(i)=(x(i)+x(1))/2;
        yM(i)=(y(i)+y(1))/2;
        nodes(i,2)=label(1);

        side= sqrt((x(i)-x(1))^2+(y(i)-y(1))^2);
        angCoef=(y(i)-y(1))/(x(i)-x(1));
    end
    Dspace=side/1000;
    if (angCoef==0)
        prHor(i)=side;
        prVert(i)=0;
        Xpoint=[xM(i); xM(i)];
        Ypoint=[yM(i)+Dspace; yM(i)-Dspace];
        checkDir=inpolygon(Xpoint,Ypoint,x,y);
        if checkDir(1)==checkDir(2)
            error('error when compute the outgoing direction')
        end
        if checkDir(1)==1
            prHor(i)=-prHor(i);
        end
    elseif (angCoef ==Inf | angCoef==-Inf)
        prHor(i)=0;
        prVert(i)=side;
        Xpoint=[xM(i)+Dspace xM(i)-Dspace];
        Ypoint=[yM(i) yM(i)];
        checkDir=inpolygon(Xpoint,Ypoint,x,y);
        if checkDir(1)==checkDir(2)
            error('error when compute the outgoing direction')
        end
        if checkDir(1)==1
            prVert(i)=-prVert(i);
        end
    elseif (angCoef>0 & angCoef~=inf)
        prHor(i)=abs(side*cos(atan(angCoef)));
        prVert(i)=abs(side*sin(atan(angCoef)));
        Xpoint=[xM(i)+Dspace; xM(i)-Dspace];
        Ypoint=[yM(i)-Dspace/angCoef; yM(i)+Dspace/angCoef];
        checkDir=inpolygon(Xpoint,Ypoint,x,y);
        if checkDir(1)==checkDir(2)
            error('error when compute the outgoing direction')
        end
        if checkDir(1)==1
            prVert(i)=-prVert(i);
        else
            prHor(i)=-prHor(i);
        end
    elseif (angCoef<0 & angCoef~=-inf)
        prHor(i)=abs(side*cos(atan(angCoef)));
        prVert(i)=abs(side*sin(atan(angCoef)));
        Xpoint=[xM(i)+Dspace; xM(i)-Dspace];
        Ypoint=[yM(i)-Dspace/angCoef; yM(i)+Dspace/angCoef];
        checkDir=inpolygon(Xpoint,Ypoint,x,y);
        if checkDir(1)==checkDir(2)
            error('error when compute the outgoing direction')
        end
        if checkDir(1)==1
            prHor(i)=-prHor(i);
            prVert(i)=-prVert(i);
        end
    end
end

