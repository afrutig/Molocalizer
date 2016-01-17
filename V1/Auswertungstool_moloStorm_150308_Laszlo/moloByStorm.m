%% Main Program
%% moloByStorm('mologram.tif')
%% ------------------------------------------------------------------------
function moloByStorm(varargin)
clc;
close all;
clearvars -except varargin;
global fFitPropS

%% parameters
% -------------------------------------------------------------------------
enhThreshFact=5; % threshold for image enhancement (factor of mean intensity)
borderPixNo=20; % number of pixels at the border (excluded from loc. maximum search)
fitRad=3; % area for 2D Gaussian fit (-rad:rad)
xGap=40;
yGap=32;
gapTol=0.22;
pixTol=2;

%% initialization
% -------------------------------------------------------------------------
	maxThresh=1.3;
	actMaxNo=1; actFrame=1;
	if (~nargin)
		[FileName,PathName] = uigetfile('*.tif','Select the image');
		imF=strcat(PathName,FileName);
	else
		imF=varargin{1};
	end
	[fileDir,fileN,fileExt]=fileparts(imF);
	if (isempty(fileDir))
		fileDir='.';
	end
	stackNo=length(imfinfo(imF));

	tStart=tic;

%% enhanced image
% -------------------------------------------------------------------------
	fEnh=figure('Name','Enhanced Image','NumberTitle','off');
	hold on; set(gca,'YDir','reverse');
	movegui(fEnh,[20 -30]); fEnh.Position(3)=350;
	fEnh.MenuBar='none'; fEnh.ToolBar='none';
	title(imF,'Interpreter','none');

%% fit properties
% -------------------------------------------------------------------------
	fFitProp=figure('Name','Fit Properties','NumberTitle','off');
	movegui(fFitProp,[400 -30]);
	fFitProp.MenuBar='none'; fFitProp.ToolBar='none';
	fFitPropS(1)=axes('Position',[.13 .58 .33 .34]); hold on; grid on; title('x fit'); xlabel('x [pixels]'); ylabel('projected int.');
	fFitPropS(2)=axes('Position',[.13 .11 .33 .34]); hold on; grid on; title('y fit'); xlabel('y [pixels]'); ylabel('projected int.');
	fFitPropS(3)=axes('Position',[.57 .58 .33 .34]); hold on; grid on; title('2D fit'); xlabel('r [pixels]'); ylabel('intensity');
	fFitPropS(4)=axes('Position',[.57 .11 .33 .34],'Visible','off');

%% GUI control
% -------------------------------------------------------------------------
fGUI=figure('Name','GUI Control','NumberTitle','off');
movegui(fGUI,[1000 -30]); fGUI.Position(3)=200;
fGUI.MenuBar='none'; fGUI.ToolBar='none';

hFrameT = uicontrol('Style','text','String',sprintf('frame # [1-%d]:',stackNo), ...
		'Units','normalized','HorizontalAlignment','left','Position',[0.1,0.9,0.6,0.05]);
hFrame = uicontrol('Style','edit', ...
		'Units','normalized','Position',[0.1,0.85,0.2,0.05], ...
		'Callback',@cFrame);
hPrevF = uicontrol('Style','pushbutton','String','PrevF', ...
		'Units','normalized','Position',[0.1,0.75,0.35,0.05],...
		'Callback',@cPrevF);
hNextF = uicontrol('Style','pushbutton','String','NextF', ...
		'Units','normalized','Position',[0.55,0.75,0.35,0.05],...
		'Callback',@cNextF);

hThreshT = uicontrol('Style','text','String','maxThresh [1-2]:', ...
		'Units','normalized','HorizontalAlignment','left','Position',[0.1,0.65,0.6,0.05]);
hThresh = uicontrol('Style','edit', ...
		'Units','normalized','Position',[0.1,0.6,0.2,0.05], ...
		'Callback',@cThresh);

hMaxNoT = uicontrol('Style','text','String',sprintf('max. # [1-]:'), ...
		'Units','normalized','HorizontalAlignment','left','Position',[0.1,0.5,0.6,0.05]);
hMaxNo = uicontrol('Style','edit', ...
		'Units','normalized','Position',[0.1,0.45,0.2,0.05], ...
		'Callback',@cMaxNo);
hGetMax = uicontrol('Style','pushbutton','String','GetMax', ...
		'Units','normalized','Position',[0.55,0.45,0.35,0.05],...
		'Callback',@cGetMax);
hPrevM = uicontrol('Style','pushbutton','String','PrevM', ...
		'Units','normalized','Position',[0.1,0.35,0.35,0.05],...
		'Callback',@cPrevM);
hNextM = uicontrol('Style','pushbutton','String','NextM', ...
		'Units','normalized','Position',[0.55,0.35,0.35,0.05],...
		'Callback',@cNextM);

hSetPos = uicontrol('Style','pushbutton','String','SetPos', ...
		'Units','normalized','Position',[0.1,0.25,0.35,0.05],...
		'Callback',@cSetPos);
hRunExp = uicontrol('Style','pushbutton','String','RunExp', ...
		'Units','normalized','Position',[0.55,0.25,0.35,0.05],...
		'Callback',@cRunExp);

%% frames
% -------------------------------------------------------------------------
function loadFrame()
	global dRaw dMaxDataRaw imRGB
	hFrame.String=actFrame;

	% load image
	% -------------------------------------------
	dRaw=imread(imF,actFrame);
	imSize=size(dRaw);
	dRaw=double(dRaw);

	% image enhancement
	% -------------------------------------------
	dEnh=int16(dRaw);
	if (mean(mean(dEnh))<5000)
		enhThresh=mean(mean(dEnh))*enhThreshFact;
		dEnh=dEnh-enhThresh; dEnh=(dEnh-sign(dEnh).*dEnh)/2;
		dEnh=dEnh+enhThresh;
	end
	% make it an RGB image
	dNorm=cast(dEnh,'double');
	dNorm=dNorm/max(max(dNorm));
	imRGB=reshape(repmat(dNorm,[1,3]),imSize(1),imSize(2),3);

	% find local maxima
	% -------------------------------------------
	dMaxDataRaw = stormFindMax(dRaw,borderPixNo);
	dMaxDataRaw = sortrows(dMaxDataRaw,3); % sort by increasing intensity
	locMaxNo=length(dMaxDataRaw(:,1)),

	threshAndFit();
end
function cFrame(source,eventdata)
	actFrame=str2num(source.String);
	if (isempty(actFrame) || actFrame<=0 || stackNo<actFrame)
		actFrame=1;
	end
	loadFrame();
end
function cPrevF(source,eventdata)
	if (1<actFrame)
		actFrame=actFrame-1;
		loadFrame();
	end
end
function cNextF(source,eventdata)
	if (actFrame<stackNo)
		actFrame=actFrame+1;
		loadFrame();
	end
end

%% maxThresh
% -------------------------------------------------------------------------
function cThresh(source,eventdata)
	maxThresh=str2num(source.String);
	if (isempty(maxThresh) || maxThresh<=1 || 2<maxThresh)
		maxThresh=1.4;
	end
	threshAndFit();
end

%% maxima
% -------------------------------------------------------------------------
function cMaxNo(source,eventdata)
	global locMaxNoAftThresh
	actMaxNo=str2num(source.String);
	if (isempty(actMaxNo) || actMaxNo<=0 || locMaxNoAftThresh<actMaxNo)
		actMaxNo=1;
	end
	fitRefresh();
end
function cGetMax(source,eventdata)
	global dMaxData locMaxNoAftThresh

	figure(fEnh);
	maxPos=ginput(1),
	diffAbs=dMaxData(:,1:2)-repmat(maxPos([2 1]),locMaxNoAftThresh,1);
	[minVal,actMaxNo]=min(sum(diffAbs'.*diffAbs')),
	fitRefresh();
end
function cPrevM(source,eventdata)
	if (1<actMaxNo)
		actMaxNo=actMaxNo-1;
		fitRefresh();
	end
end
function cNextM(source,eventdata)
	global locMaxNoAftThresh
	if (actMaxNo<locMaxNoAftThresh)
		actMaxNo=actMaxNo+1;
		fitRefresh();
	end
end

%% SetPos
% -------------------------------------------------------------------------
function cSetPos(source,eventdata)
	global origPos

	if (strcmp(hSetPos.String,'SetPos'))
		hSetPos.String='DelPos';
		hSetPos.BackgroundColor='g';
	else
		hSetPos.String='SetPos';
		hSetPos.BackgroundColor=[.94 .94 .94];
	end
	findGrid();
	[gridPos(:,:,2),gridPos(:,:,1)]=meshgrid(0:9,0:3);
	gridPos(:,:,1)=origPos(1)+gridPos(:,:,1)*xGap;
	gridPos(:,:,2)=origPos(2)+gridPos(:,:,2)*yGap;
	save(strcat(fileDir,'/',fileN,'.pos'),'gridPos');
end

%% RunExp
% -------------------------------------------------------------------------
function cRunExp(source,eventdata)
	global gridValFrame

	clc;
	hRunExp.BackgroundColor='r';
	gridVal=-ones(4,10,2,stackNo);
	for frameNo=1:stackNo
		actFrame=frameNo;
		loadFrame();
		drawnow;
		gridVal(:,:,:,frameNo)=gridValFrame;
	end
	save(strcat(fileDir,'/',fileN),'gridVal');
	hRunExp.BackgroundColor=[.94 .94 .94];

end

%% threshAndFit
% -------------------------------------------------------------------------
function threshAndFit()
	global dRaw dMaxDataRaw dMaxData locMaxNoAftThresh dPartPos dPartFit
	global dMaxPos dMaxNo

	hThresh.String=maxThresh;
	dMaxBgd=dMaxDataRaw; dMaxData=dMaxDataRaw;
	dMaxBgd((dMaxBgd(:,3))>=maxThresh,:)=[];
	dMaxData((dMaxData(:,3))<maxThresh,:)=[];
	locMaxNoAftThresh=length(dMaxData(:,1)),
	hMaxNoT.String=sprintf('max. # [1-%d]:',locMaxNoAftThresh);

	% 3D Gaussian fit
	% -------------------------------------------
	dMaxData = flipud(dMaxData); % decreasing intensity
	% stormFit2DGauss(myFrame,myPixels,initX0,initSig,allowSig,rad,tol,allowX,maxIts)
	[dPartPos,dPartFit]=stormFit2DGauss(dRaw,dMaxData,0,0.5,[0.1 (fitRad+1)],fitRad,0.2,2,6);

	dMaxPos=[dMaxData(:,1:2) (1:length(dMaxData(:,1)))'];
	dMaxPos(sum(dPartPos(:,3:4),2)~=0,:)=[];
	dMaxNo=length(dMaxPos(:,1));

% 	%	check gaps
% 	dMaxPos=dMaxPos(randperm(dMaxNo),:);
% 	xDiff=mod(round(10*diff(dMaxPos(:,1))/xGap),10);
% 	yDiff=mod(round(10*diff(dMaxPos(:,2))/yGap),10);
% 	figure();
% 	hist(xDiff,0:9);
% 	figure();
% 	hist(yDiff,0:9);

	findGrid();
end

%% findGrid
% -------------------------------------------------------------------------
function findGrid()
	global dMaxPos dMaxNo origPos
	global dPartPos dPartFit
	global gridValFrame

	if (strcmp(hSetPos.String,'SetPos'))
		gridPoints=zeros(dMaxNo,1);
		for i=1:dMaxNo
			diffAbs=dMaxPos(:,1:2)-repmat(dMaxPos(i,1:2),dMaxNo,1);
			diffSteps=diffAbs./repmat([xGap yGap],dMaxNo,1);
			diffSteps=max(abs(diffSteps-round(diffSteps)),[],2);
			gridPoints(i)=sum((diffAbs(:,1)>-1*pixTol).*(diffAbs(:,2)>-1*pixTol).*(diffSteps<gapTol));
		end
		[maxVal,gridZ]=max(gridPoints);
		origPos=dMaxPos(gridZ,1:2);a
	end

	diffAbs=dMaxPos(:,1:2)-repmat(origPos,dMaxNo,1);
	diffSteps=diffAbs./repmat([xGap yGap],dMaxNo,1);
	diffStepsMod=max(abs(diffSteps-round(diffSteps)),[],2);
	diffSteps=round(diffSteps);
	onGrid=cast((diffStepsMod<gapTol).*(0<=diffSteps(:,1)).*(diffSteps(:,1)<4).*(0<=diffSteps(:,2)).*(diffSteps(:,2)<10),'logical');
	onOrigin=cast((diffStepsMod<gapTol).*(diffSteps(:,1)==0).*(diffSteps(:,2)==0),'logical');
	gridIDs=dMaxPos(onGrid,3);
	originIDs=dMaxPos(onOrigin,3);
	dPartPos(:,6)=-ones(length(dPartPos(:,1)),1);
	succFitIDs=find(sum(dPartPos(:,3:4),2)==0);
	succFitNo=length(succFitIDs),
	onGridNo=length(gridIDs),
	dPartPos(succFitIDs,6)=zeros(succFitNo,1);
	dPartPos(gridIDs,6)=ones(onGridNo,1);
	dPartPos(originIDs,6)=9*ones(length(originIDs),1);

	gridValFrame=-ones(4,10,2);
	for i=1:onGridNo
		gridInd=diffSteps(dMaxPos(:,3)==gridIDs(i),:)+[1 1];
		gridValFrame(gridInd(1),gridInd(2),:)=dPartFit(gridIDs(i),1:2);
	end
	
	fitRefresh();
end

%% fitRefresh
% -------------------------------------------------------------------------
function fitRefresh()
	global dRaw imRGB dMaxData dPartPos

	hMaxNo.String=actMaxNo;

	stormFit2DGauss(dRaw,dMaxData(actMaxNo,:),0,0.5,[0.1 (fitRad+1)],fitRad,0.2,2,6);
	figure(fEnh);
	colormap('gray'); imagesc(imRGB); colorbar(); axis image;
	for i=find(dPartPos(:,6)==-1)'
		if (i~=actMaxNo)
			plot(dMaxData(i,2),dMaxData(i,1),'or','MarkerSize',12);
		end
	end
	for i=find(dPartPos(:,6)==0)'
		if (i~=actMaxNo)
			plot(dMaxData(i,2),dMaxData(i,1),'ob','MarkerSize',12);
		end
	end
	for i=find(dPartPos(:,6)==1)'
		if (i~=actMaxNo)
			plot(dMaxData(i,2),dMaxData(i,1),'og','MarkerSize',12);
		end
	end
	if (dPartPos(actMaxNo,6)==9)
		plot(dMaxData(actMaxNo,2),dMaxData(actMaxNo,1),'sy','MarkerSize',15);
	else
		plot(dMaxData((dPartPos(:,6)==9),2),dMaxData((dPartPos(:,6)==9),1),'oy','MarkerSize',12);
		if (dPartPos(actMaxNo,6)==-1)
			plot(dMaxData(actMaxNo,2),dMaxData(actMaxNo,1),'sr','MarkerSize',15);
		elseif (dPartPos(actMaxNo,6)==0)
			plot(dMaxData(actMaxNo,2),dMaxData(actMaxNo,1),'sb','MarkerSize',15);
		elseif (dPartPos(actMaxNo,6)==1)
			plot(dMaxData(actMaxNo,2),dMaxData(actMaxNo,1),'sg','MarkerSize',15);
		end
	end
		
end

% =========================================================================
% main program
% =========================================================================
	loadFrame();

toc(tStart);
end
