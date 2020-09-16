function [] = Domino_Theory()
	f = [];
	ax = [];
	numGrid = [];
	blobs = [];
	indGrid = [];
	n = [];
	numPanel = [];
	textGrid = [];
	userGrid = [];
	notesGrid = [];
	blobSize = [];
	gridSize = [];
	finished = [];
	but = [];
	allowedOps = [];
	numPicker = [];
	addCheck = [];
	arrayOptions = [];
	arrayCustom = [];
	theNums = [];
	checkmark = [];
	noteMode = [];
	selectorBox = [];
	numBoxes = [];
	tableSlider = [];
	toolColumnsSlider = [];
	gValues = [];
	
	figureSetup();
	newGame();
	
	function [] = click(~,~)
		if finished
			return
		end
		highlight(false); % unhighlight last box
		m = floor(ax.CurrentPoint([3, 1]));% gives (r,c)
		if any(m<1) || m(1)>8 || m(2)>7
			numPanel.Visible = 'off';
			return
		end
		
		% find x,y location to put the enter tool
		% positioned at the right edge and with the height centered
		x = f.CurrentPoint(1);
		y = f.CurrentPoint(2);
		ax.Units = 'normalized';		
		
		numPanel.Position(1) = x;
		numPanel.Position(2) = max(0, min([y, f.Position(4) - numPanel.Position(4)])); % keeps the tool from displaying off the screen vertically
		
		numPanel.UserData = m;
		if strcmp(f.SelectionType,'alt')
			noteMode = true;
			but(2).Visible = 'on';
		else
			noteMode = false;
			but(2).Visible = 'off';
		end
		highlight(true,m);
		f.UserData = f.SelectionType;
		for i = 3:9
			if notesGrid(m(1),m(2)).String{but(i).UserData.cellRow}(but(i).UserData.strInds(1)) ~=' '
				but(i).BackgroundColor = gValues.noteOnColor; % square color
			else
				but(i).BackgroundColor = gValues.noteOffColor;
			end
		end
		numPanel.Visible = 'on';
	end
	
	function [] = newGame(~,~)
		cla
		
		numPanel.Visible = 'off';
		numPanel.UserData = [1 1];
		
		finished = false;
		noteMode = false;
		
		userGrid = nan(8,7);
		patchGrid();
		numGrid = dominoGen();
		drawnow;
		hintNums();
		drawnow;
		blankNums();
		buildEnterTool();
		checkmark = patch(1.5 + 6*[0 9 37 87 100 42]/100, 1.9 + 6*[72 59 78 3 12 100]/100,[0 1 0],'FaceAlpha',0.5,'EdgeColor','none','Visible','off');
% 		showNums(); % For debugging purposes only
	end
	
	function [] = hintNums()
		% most of the randomization should be turned to sorting
		fs = 0.035;
		topNums = numGrid(1:2:7,:); % each col gives the upper hints, each row gives side hints
		botNums = numGrid(2:2:8,:); % each col gives the lower hints, each row gives side hints
		
		% top and bot hints
		for i = 1:7
			t = sort(topNums(:,i))';
			b = sort(botNums(:,i))';
% 			num2str(t(1:2),' %i')
			topHint = text(i + 0.5,0.9375,{num2str(t(1:2),' %i'),num2str(t(3:4),' %i')},'FontUnits','normalized','FontSize',fs,'FontName','fixedwidth','HorizontalAlignment','center','VerticalAlignment','bottom');
			botHint = text(i + 0.5,9.0625,{num2str(b(1:2),' %i'),num2str(b(3:4),' %i')},'FontUnits','normalized','FontSize',fs,'FontName','fixedwidth','HorizontalAlignment','center','VerticalAlignment','top');
		end
		
		%side hints
		for i = 1:4
			t = sort(topNums(i,:));
			text(0.9,2*i-0.5,num2str(t,' %i'),'FontUnits','normalized','FontSize',fs,'FontName','fixedwidth','HorizontalAlignment','right');
			
			b = sort(botNums(i,:));
			sideHint = text(0.9,2*i+0.5,num2str(b,' %i'),'FontUnits','normalized','FontSize',fs,'FontName','fixedwidth','HorizontalAlignment','right');
		end
		ax.XLim = [sideHint.Extent(1)-0.5, 8.025];
		ax.YLim = [topHint.Extent(2) - topHint.Extent(4), botHint.Extent(2)];
	end
	
	function [B] = dominoGen()
		i = randperm(28)';
		dominoes = [00 01 02 03 04 05 06 11 12 13 14 15 16 22 23 24 25 26 33 34 35 36 44 45 46 55 56 66]';

		A = reshape(dominoes(i),[4,7]);
		B = zeros(8,7);
		for j = 1:size(A,1)
			B(2*j-1,:) = floor(A(j,:)/10);
			B(2*j,:) = mod(A(j,:),10);
		end
	end
	
	function [] = blankNums()
		textGrid = gobjects(8,7);%matlab.graphics.primitive.Text.empty;
		notesGrid = gobjects(8,7);%matlab.graphics.primitive.Text.empty;
		
		fs = 1/(5*8);
		temp = text(1, 1, '1','FontName','fixedwidth','FontUnits','normalized','FontSize',fs); % initial test object
		m = 1 - 0.5*temp.Extent(3);
		y = 1;
		noteString = {' 0',' 1 2 3',' 4 5 6'};
		notesGrid(1,1) = text(1+m, 1+y, noteString,'FontName','fixedwidth','FontUnits','normalized','FontSize',fs,'Visible','off','HorizontalAlignment','right','VerticalAlignment','bottom');
		none = regexprep(noteString,'-|\d',' '); % get a blank copy of the string with only spaces
		
		for r = 1:8
			for c = 1:7
				textGrid(r,c) = text(c+0.5,r+0.5,' ','FontUnits','normalized','FontSize',gValues.noteHeight/8,'HorizontalAlignment','center','VerticalAlignment','middle');
				notesGrid(r,c) = text(c+m, r+y, none,'FontName','fixedwidth','FontUnits','normalized','FontSize',fs,'HorizontalAlignment','right','VerticalAlignment','bottom','Color',0.2*[1 1 1]);
			end
		end
		notesGrid(1,1).UserData.all = noteString;
		notesGrid(1,1).UserData.none = none;
		delete(temp);
	end
	
	function [] = patchGrid()
		gridlines = gobjects(9+8,1);
		for i = 1:9
			gridlines(i) = line([1 8], [i i],'Color',0.5*ones(1,3) - 0.5*mod(i,2),'Visible','on','LineWidth',2. + 1.75*mod(i,2));
		end
		for i = 1:8
			gridlines(9 + i) = line([i i], [1 9],'Color',zeros(1,3),'Visible','on','LineWidth',3.75);
		end
			
		selectorBox = patch([0 1 1 0],[0 0 1 1],[1 1 1],'EdgeColor',0.5*ones(1,3),'Visible','off');
		selectorBox.UserData.x = [0 1 1 0];
		selectorBox.UserData.y = [0 0 1 1];
	end
	
	function [] = resize(~,~)
		
	end
	
	function [] = buildEnterTool()
		% get current aspect ratio of numPanel
		% determine how many rows needed (max 3 buts per column) (remember x)
		% change aspect ratio of panel to match
		% position needed buttons
		% hide/show as needed
		
		cols = 3;
		nR = 3;
		numPanel.Position(4) = numPanel.Position(3)/cols*nR;
		bottom = 1-1/nR;
		for i = 0:6
			[indI, indF] = regexp(notesGrid(1,1).UserData.all,[' ' num2str(i)]); % without the space in the expression, it finds the '2' in '-2'
			j = 1;
			while isempty(indI{j}) && j < length(indI) %in theory the j < check is unnecessary
				j = j + 1;
			end
			
			if i > length(but) - 3
				but(i+3) = uicontrol(...
				'Parent',numPanel,...
				'Style','pushbutton',...
				'Units','normalized',...
				'Position',[mod(i-1,cols)/cols 0.5, 1/cols 0.5],...
				'FontSize',15);
			end
			but(i+3).String = num2str(i);
			but(i+3).Callback = {@numFill, num2str(i), i, j, (indI{j}+1):indF{j}};
			but(i+3).UserData.cellRow = j;
			but(i+3).UserData.strInds = (indI{j}+1):indF{j};
			but(i+3).Position(2) = bottom;
			but(i+3).Position(4) = 1/nR;
			if mod(i,cols)==0
				bottom = bottom - 1/nR;
			end
			but(i+3).Visible = 'on';
		end
	end
	
	function [] = numFill(~,~,newNumStr, num, cellRow, strInds)
		r = numPanel.UserData(1); % get grid location from numPanel
		c = numPanel.UserData(2);
		
		% Entering/removing notes
		if noteMode
			userGrid(r,c) = nan; % remove any "big" numbers
			textGrid(r,c).String = '';
			if ~isnan(num)% change a specific number
				if notesGrid(r,c).String{cellRow}(strInds(1)) == ' '
					s = newNumStr;
					but(num + 3).BackgroundColor = gValues.noteOnColor;
				else
					s = ' ';
					but(num + 3).BackgroundColor = gValues.noteOffColor;
				end
				notesGrid(r,c).String{cellRow}(strInds) = s;
			elseif isnan(num) % enter all possible notes (based on latin square)
				notesGrid(r,c).String = notesGrid(1,1).UserData.all;
				updateNotes(0,0,r,c); % remove blocked numbers
				numPanel.Visible = 'off';
				highlight(false);
			else % X button pressed, clear the notes
				notesGrid(r,c).String = notesGrid(1,1).UserData.none;
				numPanel.Visible = 'off';
				highlight(false);
			end
			mistakeChecks(r,c);
		else
			% Enter 'big' number
			textGrid(r,c).FontSize = gValues.noteHeight/8;
			textGrid(r,c).String = newNumStr;
			if textGrid(r,c).Extent(3) > 1 % scale text to fit in the box
				textGrid(r,c).FontSize = textGrid(r,c).FontSize/textGrid(r,c).Extent(3);
			end
			numPanel.Visible = 'off';

			if isempty(num) % X button pressed
				num = nan; % should only check if turning off red text			
			else
				notesGrid(r,c).String = notesGrid(1,1).UserData.none;
			end
			userGrid(r,c) = num;
			mistakeChecks(r,c);

			% display the check mark if the puzzle is completed
			finished = winCheck();
			highlight(false);
		end
		
		% Checks for mistakes
		function [] = mistakeChecks(row,col)
% 			for i = 1:n %latin square mistakes
% 				blackNum(row,i);
% 				blackNum(i,col);
% 			end
% 			mathCheck(row,col); % check for math mistake
		end
	end
	
	function [won] = winCheck()
		won = false; % none of the code below is adapted yet, so it will just give a win and annoy me in testing
		return
		
		won = sum(sum(~isnan(userGrid)))==56; %everything filled in
		if ~won
			return
		end
		
		for i = 1:56 % could probably be shortened by something like textGrid(:).Color(1), but probably not because matlab doesn't seem to like my dot indexing styles
			won = (textGrid(i).Color(1)==0); % no red numbers
			if ~won
				return
			end
		end
		
		for i = 1:length(blobs)
			won = (blobs(i).UserData.opT.Color(1)==0); % no red operations
			if ~won
				return
			end
		end
		
		won = true; % no mistakes, display check mark, and return true
		checkmark.Visible = 'on';
	end
	
	function [] = updateNotes(~,~,ra,ca)
		numPanel.Visible = 'off';
		if nargin < 4 %if no specified ra/rc, check all notes in all squares
			ra = 1:8;
			ca = 1:7;
		end
% 		for i = ra
% 			r = unique(userGrid(i,:)); % nums in row
% 			r(isnan(r)) = [];
% 			for j = ca
% 				if isnan(userGrid(i,j)) % only update squares not filled in
% 					k = unique([r, userGrid(:,j)']); % all nums in row and column
% 					k(isnan(k)) = [];
% 					for k = k
% 						butInd = 2 + find(theNums == k,1);
% 						notesGrid(i,j).String{but(butInd).UserData.cellRow}(but(butInd).UserData.strInds) = ' ';
% 					end
% 				end
% 			end
% 		end
	end
	
	function [] = highlight(on,rc)
		if on
			selectorBox.XData = rc(2) + selectorBox.UserData.x;
			selectorBox.YData = rc(1) + selectorBox.UserData.y;
			selectorBox.FaceColor = [0.9 0.9 0.9] + [0 0.1*~noteMode 0.1*noteMode];
			selectorBox.Visible = 'on';
		else
			selectorBox.Visible = 'off';
		end
	end
	
	function [] = figureSetup()
		f = figure(1);
		clf
		f.MenuBar = 'none';
		f.Name = 'Domino Theory';
		f.NumberTitle = 'off';
		f.WindowButtonDownFcn = @click;
		f.SizeChangedFcn = @resize;
		f.UserData = 'normal';
		f.Resize = 'on';
		f.Units = 'pixels';
		
		
		
		ax = axes('Parent',f);
		ax.Position = [0.25 0 0.75 1];
		ax.YDir = 'reverse';
		ax.YTick = [];
		ax.XTick = [];
		ax.XColor = f.Color;
		ax.YColor = f.Color;
% 		ax.Color = f.Color;
		ax.XLim = [1 8];
		ax.YLim = [0.5 9.5];
		axis equal
		
		gValues.noteHeight = 0.7;
		gValues.noteOnColor = [0.94 0.94 1];
		gValues.noteOffColor = [0.94 0.94 0.94];
% 		gValues.opHeight = 0.15;
% 		gValues.startN = 5;
		
		
		ng = uicontrol(...
			'Parent',f,...
			'Units','normalized',...
			'Style','pushbutton',...
			'String','New',...
			'Callback',@newGame,...
			'Position',[0.05 0.25 0.1 0.1],...
			'TooltipString','New Puzzle',...
			'FontUnits','normalized',...
			'FontSize',0.25);
		
% 		clearer = uicontrol(...
% 			'Parent',f,...
% 			'Units','normalized',...
% 			'Style','pushbutton',...
% 			'String','Restart',...
% 			'Callback',@restart,...
% 			'Position',[0.05 0.05 0.1 0.1],...
% 			'TooltipString','Restart Puzzle',...
% 			'FontUnits','normalized',...
% 			'FontSize',0.25);


		% ========== Enter Tool ======
		h = 0.175;
		numPanel = uipanel(... % will need special resizing code
			'Parent',f,...
			'Units','normalized',...
			'Position',[0.1 0.1, h*1.5*f.Position(4)/f.Position(3) h],...
			'Units','pixels'); % if pixels is removed, need to alter code for where numpanel moves to when clicking
		
		but = uicontrol(...
			'Parent',numPanel,...
			'Style','pushbutton',...
			'Units','normalized',...
			'Position',[0 2/3, 1/3 1/3],...
			'String','X',...
			'FontSize',15,...
			'Callback',{@numFill, ' ', []});	
		but(2) = uicontrol(...
			'Parent',numPanel,...
			'Style','pushbutton',...
			'Units','normalized',...
			'Position',[1/3 2/3, 1/3 1/3],...
			'String','all',...
			'FontSize',15,...
			'Callback',{@numFill, 'NaN', nan},...
			'Visible','off');	
	end
	
end






		% The code in KenKen worked because the axis object was square, it
		% becomes surprisingly complicated with the rectangualr axis that
		% also has text above and to the side of the "board." Using the
		% point clicked in the figure (f.CurrentPoint) is good enough for
		% now.
% 		ax.Units = 'pixels';
% 		'==============================================================='
% 		ax.CurrentPoint([3, 1])
% 		ax.Position
% 		ax.XLim
% 		ax.YLim
% 		diff(ax.XLim)
% 		(diff(ax.XLim)-7)/diff(ax.XLim)
% 		z = (7)/diff(ax.XLim)
% 		z*ax.Position(3)
% 		'======================'
% 		diff(ax.YLim)
% 		(diff(ax.YLim)-8)/diff(ax.YLim)
% 		z2 = (8)/diff(ax.YLim)
% 		z2*ax.Position(4)
% 		
% 		
% 		if ax.Position(4) > z*ax.Position(3) % axes limited by width
% 			x = (m(2)-1)/7*z*ax.Position(3) + ax.Position(1) + (1-z)*ax.Position(3) - numPanel.Position(3)
% 			y = (7-m(1)+0.5)*z*ax.Position(3)/7 + numPanel.Position(4)/3
% 		else % axes limited by height
% 			x = m(2)/8*z2*ax.Position(4) + ax.Position(1) + (1-z)*ax.Position(3)
% 			y = (8-m(1)+0.5)*(z2*ax.Position(4)-ax.Position(2))/7 %+ ax.Position(2) - numPanel.Position(4)/2;
% 		end





