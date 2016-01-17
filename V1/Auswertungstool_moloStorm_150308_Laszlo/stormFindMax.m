function [myPixels]=stormFindMax(myFrame,rad)

persistent avNMSim myRR myRC Gtr mask;
avNMSim = (myFrame);

%% find local maxima
% -------------------------------------------------------------------------
myRR = rad+1:size(myFrame,1)-rad;
myRC = rad+1:size(myFrame,2)-rad;
Gtr = false([size(avNMSim),8] );
Gtr(myRR,myRC,1) = avNMSim(myRR,myRC) >  avNMSim(myRR,myRC+1);
Gtr(myRR,myRC,2) = avNMSim(myRR,myRC) >= avNMSim(myRR,myRC-1);
Gtr(myRR,myRC,3) = avNMSim(myRR,myRC) >  avNMSim(myRR+1,myRC);
Gtr(myRR,myRC,4) = avNMSim(myRR,myRC) >= avNMSim(myRR-1,myRC);
Gtr(myRR,myRC,5) = avNMSim(myRR,myRC) >= avNMSim(myRR-1,myRC-1);
Gtr(myRR,myRC,6) = avNMSim(myRR,myRC) >= avNMSim(myRR-1,myRC+1);
Gtr(myRR,myRC,7) = avNMSim(myRR,myRC) >  avNMSim(myRR+1,myRC-1);
Gtr(myRR,myRC,8) = avNMSim(myRR,myRC) >  avNMSim(myRR+1,myRC+1);

mask = Gtr(:,:,1)&Gtr(:,:,2)&Gtr(:,:,3)&Gtr(:,:,4)&...
       Gtr(:,:,5)&Gtr(:,:,6)&Gtr(:,:,7)&Gtr(:,:,8);

[myRows,myCols] = find(mask);
idx = sub2ind(size(mask),myRows,myCols);

%% calculate intensities
% -------------------------------------------------------------------------
avB=10; avS=1;
for i=1:length(idx)
	actR=myRows(i); actC=myCols(i);
	iMax=sum(sum(myFrame(actR-avS:actR+avS,actC-avS:actC+avS)));
	iBgd=sum(sum(myFrame(actR-avB:actR+avB,actC-avB:actC+avB)))-iMax;
	iMax=iMax/((2*avS+1)^2);
	iBgd=iBgd/((2*avB+1)^2-(2*avS+1)^2);
	myIntens(i)=iMax/iBgd;
end

myPixels = [myRows,myCols,myIntens'];
end