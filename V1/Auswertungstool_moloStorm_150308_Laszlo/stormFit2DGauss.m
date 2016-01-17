function [myFits,myParams]=stormFit2DGauss(myFrame,myPixels,initX0,initSig,allowSig,rad,tol,allowX,maxIts)
global fFitPropS

showFit=(length(reshape(myPixels,[],1))==3);

myFits = zeros(size(myPixels,1),5);		% [row col fitX fitY lpPx] matrix for each candidate
xx = (-rad:rad)';
yy = (-rad:rad)';
[sY,sX]=meshgrid(-rad:rad,-rad:rad);

%% loop through the maxima
% -------------------------------------------------------------------------
for lpPx = 1:size(myPixels,1);
	pTic=tic;
	myRow = myPixels(lpPx,1);
	myCol = myPixels(lpPx,2);
	myROI = myFrame(myRow-rad:myRow+rad,myCol-rad:myCol+rad);
	flagRowFits = false;
	flagColFits = false;

	yRows = sum(myROI,2);
	yCols = sum(myROI,1)';

	% rows
	% -------------------------------------------
	x0 = initX0;
	sigX = initSig;
	C = min(yRows);
	A = yRows(rad+1)-C;
	fofX = A*exp(-(xx-x0).^2/(2*sigX^2))+C;
	Beta = yRows - fofX;

% 	xFit=(-rad:0.1:rad)';
% 	yFit=A*exp(-(xFit-x0).^2/(2*sigX^2))+C;
% 	figure(); hold on;
% 	plot(xx,yRows,'ob','MarkerSize',5,'MarkerFaceColor','blue');
% 	plot(xFit,yFit,'-g');

	for lpLSF = 1:maxIts
		Aa = [(fofX-C)/A,(fofX-C).*(xx-x0)/sigX^2,(fofX-C).*(xx-x0).^2/sigX^3,ones(2*rad+1,1)];
		b = Aa'*Beta;
		a = Aa'*Aa;
		if (rcond(a) > eps)
			dL= a\b;
			A = A+dL(1);
			x0 = x0 + dL(2);
			sigX = sigX + dL(3);
			C = C + dL(4);
			fofX = A*exp(-(xx-x0).^2/(2*sigX^2))+C;
			Beta = yRows - fofX;
		else
			sigX=0;
		end
		if(abs(x0)>allowX || (sigX < allowSig(1)) || (sigX > allowSig(2)) )
			myFits(lpPx,3)=1;
			break;
		end
	end
	residueRows = sum(Beta.^2)/sum(yRows.^2);
	fitRowPos = double(myRow) + x0;
	if (residueRows < tol && abs(x0)<allowX && sigX>allowSig(1) && sigX<allowSig(2))
		flagRowFits = true;
	elseif (myFits(lpPx,3)~=1)
		myFits(lpPx,3)=2;
	end
	if (showFit)
		xFit=(-rad:0.1:rad)';
		yFit=A*exp(-(xFit-x0).^2/(2*sigX^2))+C;
		axes(fFitPropS(1)); cla;
		plot([-rad rad],C*[1 1],'-g');
		plot([-rad rad],(C+A)*[1 1],'-g');
		plot(xx,yRows,'ob','MarkerSize',5,'MarkerFaceColor','blue');
		plot(xFit,yFit,'-r');
	end

	% columns
	% -------------------------------------------
	y0 = initX0;
	sigY = sigX;
% 	sigY = initSig;
	C = min(yCols);
	A = yCols(rad+1)-C;
	fofX = A*exp(-(yy-y0).^2/(2*sigY^2))+C;
	Beta = yCols - fofX;

% 	xFit=(-rad:0.1:rad)';
% 	yFit=A*exp(-(xFit-y0).^2/(2*sigY^2))+C;
% 	figure(); hold on;
% 	plot(xx,yCols,'ob','MarkerSize',5,'MarkerFaceColor','blue');
% 	plot(xFit,yFit,'-g');

	for lpLSF = 1:maxIts
		Aa = [(fofX-C)/A,(fofX-C).*(yy-y0)/sigY^2,(fofX-C).*(yy-y0).^2/sigY^3,ones(2*rad+1,1)]; % Jacobian
		b = Aa'*Beta;
		a = (Aa'*Aa);
		if (rcond(a)>eps)
			dL= a\b;
			A = A+dL(1);
			y0 = y0 + dL(2);
			sigY = sigY + dL(3);
			C = C + dL(4);
			fofX = A*exp(-(yy-y0).^2/(2*sigY^2))+C; 
			Beta = yCols - fofX;
		else
			sigY=0;
		end
		if (abs(y0)>allowX || (sigY < allowSig(1)) || (sigY > allowSig(2)))
% 			[abs(y0)>allowX (sigY < allowSig(1)) (sigY > allowSig(2))],
			myFits(lpPx,4)=1;
			break;
		end
	end
	residueCols = sum(Beta.^2)/sum(yCols.^2);
	fitColPos = double(myCol)+y0;
	if (residueCols<tol && abs(y0)<allowX && sigY>allowSig(1) && sigY<allowSig(2))
		flagColFits = true;
	elseif (myFits(lpPx,4)~=1)
		myFits(lpPx,4)=2;
	end
	if (showFit)
		yFit=A*exp(-(xFit-y0).^2/(2*sigY^2))+C;
		axes(fFitPropS(2)); cla;
		plot([-rad rad],C*[1 1],'-g');
		plot([-rad rad],(C+A)*[1 1],'-g');
		plot(yy,yCols,'ob','MarkerSize',5,'MarkerFaceColor','blue');
		plot(xFit,yFit,'-r');
	end

	if(1)
		gauss2D = @(c)sum(sum((c(1)*exp( ...
			-(sigY^2*(sX-x0).^2+sigX^2*(sY-y0).^2)/(2*sigX^2*sigY^2))+c(2)-double(myROI)).^2));
		if (flagRowFits && flagColFits)
			[cFit,fval] = fminsearch(gauss2D,[A C]);
		else
			cFit=[A C];
		end

		if (showFit)
			pixDist=[reshape(sX-x0,1,[]);reshape(sY-y0,1,[])];
			pixDist=sqrt(sum(pixDist.*pixDist));
			pixVal=reshape(double(myROI),1,[]);
			rFit=(0:0.1:max(pixDist))';
			yFit=cFit(1)*exp(-(sigY^2*(rFit/sqrt(2)).^2+sigX^2*(rFit/sqrt(2)).^2)/(2*sigX^2*sigY^2))+cFit(2);

			axes(fFitPropS(3)); cla;
			plot([min(rFit) max(rFit)],cFit(2)*[1 1],'-g');
			plot([min(rFit) max(rFit)],sum(cFit)*[1 1],'-g');
			plot(pixDist,pixVal,'ob','MarkerSize',5,'MarkerFaceColor','blue');
			plot(rFit,yFit,'-r');

			axes(fFitPropS(4)); cla;
			fitText={sprintf('A = %0.0f \t C = %0.0f',cFit);
				'';
				sprintf('x_0 = %0.1f \t y_0 = %0.1f',fitRowPos,fitColPos);
				'';
				sprintf('\\sigma_x = %0.1f \t \\sigma_y = %0.1f',sigX,sigY);};
			if (myFits(lpPx,3)==1)
				fitText(end+1:end+2)={'';'bad x iteration'};
			elseif (myFits(lpPx,3)==2)
				fitText(end+1:end+2)={'';'bad x fit'};
			end
			if (myFits(lpPx,4)==1)
				fitText(end+1:end+2)={'';'bad y iteration'};
			elseif (myFits(lpPx,4)==2)
				fitText(end+1:end+2)={'';'bad y fit'};
			end
			text(0,1,fitText,'VerticalAlignment','top');
		end

		myFits(lpPx,[1 2 5])=[fitRowPos,fitColPos lpPx];
		myParams(lpPx,:)=[cFit sigX sigY];
	end
end

% myParams = myParams(myFits(:,1)~=0,:);
% myFits = myFits(myFits(:,1)~=0,:);

end