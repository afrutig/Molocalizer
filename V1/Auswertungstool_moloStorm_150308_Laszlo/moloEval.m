%% Main Program
%% moloEval('mologram.mat')
%% ------------------------------------------------------------------------
function moloEval(varargin)
clc;
close all;
clearvars -except varargin;

%% parameters
% -------------------------------------------------------------------------
enhThreshFact=5; % threshold for image enhancement (factor of mean intensity)

%% initialization
% -------------------------------------------------------------------------
	actMaxInd=1;
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
	load(strcat(fileDir,'/',fileN));
	load(strcat(fileDir,'/',fileN,'.pos'),'-mat','gridPos');
% 	gridPos,

	tStart=tic;

%% enhanced image
% -------------------------------------------------------------------------
	fEnh=figure('Name','Enhanced Image','NumberTitle','off');
	hold on; set(gca,'YDir','reverse');
	movegui(fEnh,[20 -30]); fEnh.Position(3)=350;
	fEnh.MenuBar='none'; fEnh.ToolBar='none';
	title(imF,'Interpreter','none');

%% time dependence
% -------------------------------------------------------------------------
	fTimeDep=figure('Name','Time Dependence','NumberTitle','off');
	movegui(fTimeDep,[400 -30]);
	fTimeDep.MenuBar='none'; fTimeDep.ToolBar='none';

%% GUI control
% -------------------------------------------------------------------------
fGUI=figure('Name','GUI Control','NumberTitle','off');
movegui(fGUI,[1000 -30]); fGUI.Position(3)=200;
fGUI.MenuBar='none'; fGUI.ToolBar='none';

hHold = uicontrol('Style','pushbutton','String','Hold', ...
		'Units','normalized','Position',[0.1,0.85,0.35,0.05],...
		'Callback',@cHold);
hClear = uicontrol('Style','pushbutton','String','Clear', ...
		'Units','normalized','Position',[0.55,0.85,0.35,0.05],...
		'Callback',@cClear);

hRowT = uicontrol('Style','text','String','Row:', ...
		'Units','normalized','HorizontalAlignment','left','Position',[0.1,0.75,0.6,0.05]);
hColumnT = uicontrol('Style','text','String','Column:', ...
		'Units','normalized','HorizontalAlignment','left','Position',[0.55,0.75,0.6,0.05]);
hRow = uicontrol('Style','edit', ...
		'Units','normalized','Position',[0.1,0.7,0.2,0.05], ...
		'Callback',@cRow);
hColumn = uicontrol('Style','edit', ...
		'Units','normalized','Position',[0.55,0.7,0.2,0.05], ...
		'Callback',@cColumn);

hPrevM = uicontrol('Style','pushbutton','String','PrevM', ...
		'Units','normalized','Position',[0.1,0.6,0.35,0.05],...
		'Callback',@cPrevM);
hNextM = uicontrol('Style','pushbutton','String','NextM', ...
		'Units','normalized','Position',[0.55,0.6,0.35,0.05],...
		'Callback',@cNextM);

%% plot
% -------------------------------------------------------------------------
function cHold(source,eventdata)
	global actMaxIndPrev

	figure(fTimeDep);
	cla;
	actMaxIndPrev=0;
	if (isequal(hHold.BackgroundColor,[0 1 0]))
		hold off;
		hHold.BackgroundColor=[.94 .94 .94];
	else
		hold on;
		hHold.BackgroundColor='g';
	end
	plotTimeDep();
end
function cClear(source,eventdata)
	global actMaxIndPrev

	figure(fTimeDep);
	cla;
	actMaxIndPrev=0;
	plotTimeDep();
end

%% choose maximum
% -------------------------------------------------------------------------
function cRow(source,eventdata)
	global actMaxPos actMaxIndPrev

	newPos=str2num(source.String);
	if (isempty(newPos) || newPos<=0 || 4<newPos)
		actMaxPos(1)=1;
	else
		actMaxPos(1)=newPos;
	end
	actMaxIndPrev=actMaxInd;
	actMaxInd=pos2ind(actMaxPos);
	maxRefresh();
end
function cColumn(source,eventdata)
	global actMaxPos actMaxIndPrev

	newPos=str2num(source.String);
	if (isempty(newPos) || newPos<=0 || 10<newPos)
		actMaxPos(2)=1;
	else
		actMaxPos(2)=newPos;
	end
	actMaxIndPrev=actMaxInd;
	actMaxInd=pos2ind(actMaxPos);
	maxRefresh();
end
function cPrevM(source,eventdata)
	global actMaxIndPrev

	if (1<actMaxInd)
		actMaxIndPrev=actMaxInd;
		actMaxInd=actMaxInd-1;
		maxRefresh();
	end
end
function cNextM(source,eventdata)
	global actMaxIndPrev

	if (actMaxInd<4*10)
		actMaxIndPrev=actMaxInd;
		actMaxInd=actMaxInd+1;
		maxRefresh();
	end
end

%% loadFrame
% -------------------------------------------------------------------------
function loadFrame()
% 	global dRaw dMaxDataRaw imRGB
	global imRGB

	% load image
	% -------------------------------------------
	dRaw=imread(imF,stackNo);
	imSize=size(dRaw);
	dRaw=double(dRaw);

	% image enhancement
	% -------------------------------------------
	dEnh=int16(dRaw);
% 	if (enhThreshFact)
	if (mean(mean(dEnh))<5000)
		enhThresh=mean(mean(dEnh))*enhThreshFact;
		dEnh=dEnh-enhThresh; dEnh=(dEnh-sign(dEnh).*dEnh)/2;
		dEnh=dEnh+enhThresh;
	end
	% make it an RGB image
	dNorm=cast(dEnh,'double');
	dNorm=dNorm/max(max(dNorm));
	imRGB=reshape(repmat(dNorm,[1,3]),imSize(1),imSize(2),3);

	maxRefresh();
end

%% maxRefresh
% -------------------------------------------------------------------------
function maxRefresh()
	global imRGB actMaxPos

	actMaxPos=ind2pos(actMaxInd);
	hRow.String=actMaxPos(1); hColumn.String=actMaxPos(2);
	figure(fEnh);
	colormap('gray'); imagesc(imRGB); colorbar(); axis image;
	for i=1:4
		for j=1:10
			if (isequal(actMaxPos,[i j]))
				plot(gridPos(i,j,2),gridPos(i,j,1),'sr','MarkerSize',15);
			else
				plot(gridPos(i,j,2),gridPos(i,j,1),'og','MarkerSize',12);
			end
		end
	end

	plotTimeDep();
end

%% plotTimeDep
% -------------------------------------------------------------------------
function plotTimeDep()
	global actMaxIndPrev actMaxPos

	figure(fTimeDep);
	if (actMaxIndPrev)
		actMaxPosPrev=ind2pos(actMaxIndPrev);
		plot(actFrames,squeeze(gridVal(actMaxPosPrev(1),actMaxPosPrev(2),1,:)),'.-b');
	end
	plot(actFrames,squeeze(gridVal(actMaxPos(1),actMaxPos(2),1,:)),'.-r');
	grid on; xlabel('frame #'); ylabel('intensity');
end

%% indexes
% -------------------------------------------------------------------------
function aPos=ind2pos(aInd)
	aPos(1)=floor((aInd-1)/10)+1;
	aPos(2)=mod(aInd-1,10)+1;
end
function aInd=pos2ind(aPos)
	aInd=10*(aPos(1)-1)+aPos(2);
end

% =========================================================================
% main program
% =========================================================================
	actFrames=1:length(gridVal(1,1,1,:));
	% delete empty frames
	% -------------------------------------------
% 	emptyFrames=(squeeze(sum(sum(gridVal(:,:,1,:))))==-4*10);
% 	gridVal(:,:,:,emptyFrames)=[];
% 	actFrames(emptyFrames)=[];

	% normalization
	% -------------------------------------------
% 	gridVal(:,:,1,:)=squeeze(gridVal(:,:,1,:))./repmat(max(squeeze(gridVal(:,:,1,:)),[],3),1,1,length(actFrames));

	loadFrame();

% 	for iX=1:4
% 		for iY=1:10
% 			plot(actFrames,squeeze(gridVal(iX,iY,1,:)),'.-r');
% 		end
% 	end

toc(tStart);
end

%% myFmin
function f = myFmin(x,myCurveX,myCurveY,limMin,limMax)
	if (x<limMin || x>limMax)
		f=1e3;
	else
		f=interp1(myCurveX,myCurveY,x,'spline');
	end
end
