%{

Based on Domino Theory by Margery Albis in Games: World of Puzzles, February 2020.

%}
%{

use the open space outside dom hints for other ui elements, like ng,
starting hints, etc
- add starting difficulty options in the first place
- reset button?

decide on updateNotes()
- possibly trickier with repetitions, but unique() should help
- would it check agains doms? or just side/top/bot hints?

see what elements need scaling code
- dom hint dots definitely do

try to fix the enter tool movement code

'cla' can probably be removed from newGame() as the board never changes
size
- ui creation code will need to be altered though.

break up the grid so it looks more like dominos?
- like the dom hints

use gValues in more places

should entering the number already there clear it?

upside down domino indicator is ugly and hard to read

top/bot hint indicators don't touch and I wish they did.

scroll wheel to change size of enter tool?
%}
function [] = Domino_Theory()
	f = [];
	ax = [];
	numGrid = [];
	
	numPanel = [];
	textGrid = [];
	notesGrid = [];
	userGrid = [];
	finished = [];
	but = [];
	noteMode = [];
	selectorBox = [];
	gValues = [];
	topHints = gobjects(7,4);
	botHints = gobjects(7,4);
	sideHints = gobjects(8,7);
	domHints = gobjects(28,1);
	domHintsP = gobjects(28,1);
	checkmark = [];
	
	debugging = false; 
	
	figureSetup();
	newGame();
	
	% debug function to display solution to help speed up testing
	function [] = cheat()
		fprintf('\nAnswer Key:\n')
		disp(numGrid)
	end
	
	function [] = click(~,~)
% 		[f.CurrentPoint]
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
		
		drawBackground();
		
		numGrid = dominoGen();
		hintNums();
		blankNums();
		buildEnterTool();
		
		if debugging
			cheat();
		end
	end
	
	function [] = hintNums()
		if f.Position(3) / f.Position(4) > gValues.baseFigDim(1) / gValues.baseFigDim(2) % limited by height of figure
			scale = f.Position(4)/gValues.baseFigDim(2);
		else
			scale = f.Position(3)/gValues.baseFigDim(1); % limited by width of figure
		end
		fs = 0.035;
		topNums = numGrid(1:2:7,:); % each col gives the upper hints, each row gives side hints
		botNums = numGrid(2:2:8,:); % each col gives the lower hints, each row gives side hints
		
		
		% top and bot hints
		for i = 1:7
			t = sort(topNums(:,i))';
			b = sort(botNums(:,i))';
			for j = 1:4
				topHints(i,j) = text(i - 0.33*(mod(j,2) - 2), 0.4 + 0.5*floor((j-1)/2),num2str(t(j)),'FontUnits','normalized','FontSize',fs,'FontName','fixedwidth','HorizontalAlignment','center','VerticalAlignment','bottom');
				topHints(i,j).UserData.num = t(j);
				botHints(i,j) = text(i - 0.33*(mod(j,2) - 2), 9.4 + 0.5*floor((j-1)/2),num2str(b(j)),'FontUnits','normalized','FontSize',fs,'FontName','fixedwidth','HorizontalAlignment','center','VerticalAlignment','bottom');
				botHints(i,j).UserData.num = b(j);
			end
		end
		
		%side hints
		for i = 1:4
			t = sort(topNums(i,:));
			b = sort(botNums(i,:));
			for j = 1:7
				sideHints(2*i-1,j) = text(j*2/7 - 9/7, 2*i - 0.40, num2str(t(j)),'FontUnits','normalized','FontSize',fs,'FontName','fixedwidth','HorizontalAlignment','center','VerticalAlignment','middle');
				sideHints(2*i-1,j).UserData.num = t(j);
				sideHints(2*i,j) = text(j*2/7 - 9/7, 2*i + 0.40, num2str(b(j)),'FontUnits','normalized','FontSize',fs,'FontName','fixedwidth','HorizontalAlignment','center','VerticalAlignment','middle');
				sideHints(2*i,j).UserData.num = b(j);
			end
		end
		
		% domino hints		
		ind = 1;
		s = 16/9; % scaling factor
		v = 0.9/s*([1 1; 2 1; 2 2; 1 2; 1 3; 2 3] - [1.5 3.5]); % vertices to draw the domino tiles
		for i = 0:6 % top num of domino
			[xi, yi] = dotCoords(i);
			for j = i:6 % bot num
				[xj, yj] = dotCoords(j); % ax.XLim is used here, but it would be better if ax.XLim was set based on these, not the other way around
				domHintsP(ind) = patch('Faces',[1 2 3 4; 3 4 5 6],'Vertices',v + [ax.XLim(1) + (j + 0.5)/s, 9 + (0.4 - 2*i)/s],'FaceColor',[1 1 1],'LineJoin','round');
				domHints(ind) = line(ax.XLim(1) + (j + 0.5 + [xi, xj])/s, 9 - (0.5 + 2*i + [0.9+yi, yj])/s,'MarkerSize',2*scale,'LineStyle','none','Marker','o','MarkerFaceColor',[0 0 0],'MarkerEdgeColor',[0 0 0]);
				ind = ind + 1;
			end
		end
		
		
		% gives coordinates to draw domino dots
		function [x, y] = dotCoords(n)
			switch n
				case 0
					x = nan; % prevents it from creating an "empty" line object that can't be saved in an array
					y = nan;
				case 1
					x = 2;
					y = 2;
				case 2
					x = [1 3];
					y = [3 1];
				case 3
					x = [1 2 3];
					y = [3 2 1];
				case 4
					x = [1 1 3 3];
					y = [1 3 1 3];
				case 5
					x = [1 1 2 3 3];
					y = [1 3 2 1 3];
				case 6
					x = [1 1 1 3 3 3];
					y = [1 2 3 1 2 3];
			end
			x = (x-2)/4; % center around (0,0)
			y = (y-2)/4;
		end
	end
	
	
	% generates the matrix representing the shuffled dominos
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
				textGrid(r,c) = text(c+0.5,r+0.5,' ','FontUnits','normalized','FontSize',gValues.noteHeight,'HorizontalAlignment','center','VerticalAlignment','middle');
				notesGrid(r,c) = text(c+m, r+y, none,'FontName','fixedwidth','FontUnits','normalized','FontSize',fs,'HorizontalAlignment','right','VerticalAlignment','bottom','Color',0.2*[1 1 1]);
			end
		end
		notesGrid(1,1).UserData.all = noteString;
		notesGrid(1,1).UserData.none = none;
		delete(temp);
	end
	
	function [] = drawBackground()
		patch([1 1 8 8],[1 9 9 1],[1 1 1],'EdgeAlpha',0);
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
		
		checkmark = patch(1.5 + 6*[0 9 37 87 100 42]/100, 1.9 + 6*[72 59 78 3 12 100]/100,[0 1 0],'FaceAlpha',0.5,'EdgeColor','none','Visible','off'); % displays when you win
	end
	
	% handles ui resizing when the figure is resized
	function [] = resize(~,~)
		if f.Position(3) / f.Position(4) > gValues.baseFigDim(1) / gValues.baseFigDim(2) % limited by height of figure
			scale = f.Position(4)/gValues.baseFigDim(2);
		else
			scale = f.Position(3)/gValues.baseFigDim(1); % limited by width of figure
		end
		for i = 1:length(domHints)
			domHints(i).MarkerSize = 2*scale;
		end
% 		ax.Units = 'pixels';
% 		disp(ax.TightInset) %[0 0 0]
% 		disp(ax.PlotBoxAspectRatio) %[3.5 4 1]
% 		disp(ax.Position) % [0.2986    0.0995    0.6968    0.7958] when normalized
% 		ax.Units = 'normalized';
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
			if ~isnan(userGrid(r,c)) % update hints and errors if replacing a big num with notes
				userGrid(r,c) = nan; % remove any "big" numbers
				textGrid(r,c).String = '';
				errorCheck(r,c);
			end
			
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
		else
			% Enter 'big' number
			textGrid(r,c).FontSize = gValues.noteHeight;
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
			errorCheck(r,c);

			% display the check mark if the puzzle is completed
			finished = winCheck();
			highlight(false);
		end
		
	end
	
	% returns the domHints index of domino (n1,n2) 
	function [index] = patchInd(n1,n2)
		if nargin < 2 % n1 is an array of the two
			t = min(n1);
			b = max(n1);
		else
			t = min([n1,n2]);
			b = max([n1,n2]);
		end
		p = [1 1+cumsum(7:-1:2)];
		index = p(t+1) + b - t;
	end
	
	% Checks for errors and hint completion. Errors will turn the relevant
	% hint and number red. Completed hints will turn grey.
	% r0, c0 is the row/col of that last place with a changed big number
	function [] = errorCheck(r0, c0)
		mistakes = zeros(8,7);
		for r = 1:8
			% side mistakes
			userNums = userGrid(r,:);
			hints = zeros(1,7);
			for i = 1:7
				hints(i) = sideHints(r,i).UserData.num;
				sideHints(r,i).BackgroundColor = 'none'; % remove red background from side hints, will get readded later if needed
			end
			hintsO = hints;
			for i = 1:7
				if ~isnan(userNums(i))
					hints(find(userNums(i)==hints,1)) = -1;
				end
			end
			if r == r0 % grey out only in the current row
				for i = 1:7
					sideHints(r0,i).Color = [1 1 1]*0.675*(hints(i) < 0); % grey out fulfilled side hints. also turns unfulfilled hints black
				end
			end
			if sum(hints<0) ~= sum(~isnan(userNums)) % entered nums don't match hints
				for i = unique(userNums(~isnan(userNums))) % check through each entered number
					if sum(userNums==i) > sum(hintsO==i) % a number appears too many times (including when it's not supposed to appear)
						mistakes(r,userNums==i) = true;
						if any(hintsO==i) % prevents trying to turn '5' red when there aren't any 5s in the row, ie hintsO==i is all 0s
							for j = 1:7
								if hintsO(j)==i
									sideHints(r,j).Color = [1 0 0]; % turn side hints red
								end
							end
						else
							for j = 1:7
								sideHints(r,j).BackgroundColor = gValues.hintBgColor; % turn side hint's background red to show a number shouldn't be there
							end
						end
					end
				end
			end
		end
		for c = 1:7
			% top mistakes
			userNums = userGrid(1:2:7,c)';
			hints = zeros(1,4);
			for i = 1:4
				hints(i) = topHints(c,i).UserData.num;
				topHints(c,i).BackgroundColor = 'none'; % remove red background from top hints, will get readded later if needed
			end
			hintsO = hints;
			for i = 1:4
				if ~isnan(userNums(i))
					hints(find(userNums(i)==hints,1)) = -1;
				end
			end
			if c == c0
				for i = 1:4
					topHints(c,i).Color = [1 1 1]*0.675*(hints(i) < 0);
				end
			end
			if sum(hints<0) ~= sum(~isnan(userNums)) % entered nums don't match hints
				for i = unique(userNums(~isnan(userNums))) % check through each entered number
					if sum(userNums==i) > sum(hintsO==i) % a number appears too many times (including when it's not supposed to appear)
						mistakes(2*find(userNums==i)-1,c) = true;
						if any(hintsO==i) % prevents trying to turn '5' red when there aren't any 5s in the col
							for j = 1:4
								if hintsO(j)==i
									topHints(c,j).Color = [1 0 0]; % turn top hints red
								end
							end
						else
							for j = 1:4
								topHints(c,j).BackgroundColor = gValues.hintBgColor; % turn top hint's background red to show a number shouldn't be there
							end
						end
					end
				end
			end

			% bot mistakes
			userNums = userGrid(2:2:8,c)';
			hints = zeros(1,4);
			for i = 1:4
				hints(i) = botHints(c,i).UserData.num;
				botHints(c,i).BackgroundColor = 'none'; % remove red background from bot hints, will get readded later if needed
			end
			hintsO = hints;
			for i = 1:4
				if ~isnan(userNums(i))
					hints(find(userNums(i)==hints,1)) = -1;
				end
			end
			if c == c0
				for i = 1:4
					botHints(c,i).Color = [1 1 1]*0.675*(hints(i) < 0); % grey out bot hints in current column
				end
			end
			if sum(hints<0) ~= sum(~isnan(userNums)) % entered nums don't match hints
				for i = unique(userNums(~isnan(userNums))) % check through each entered number
					if sum(userNums==i) > sum(hintsO==i) % a number appears too many times (including when it's not supposed to appear)
						mistakes(2*find(userNums==i),c) = true;
						if any(hintsO==i) % prevents trying to turn '5' red when there aren't any 5s in the col
							for j = 1:4
								if hintsO(j)==i
									botHints(c,j).Color = [1 0 0]; % turn bot hints red
								end
							end
						else
							for j = 1:4
								botHints(c,j).BackgroundColor = gValues.hintBgColor; % turn bot hint's background red to show a number shouldn't be there
							end
						end
					end
				end
			end
		end

		% domino mistakes
		% check for upside down dominos
		% check for repeated dominos
		doms = zeros(28,1);
		domsLocs = cell(28,1);
		for r = 1:2:7
			for c = 1:7
				textGrid(r,c).BackgroundColor = 'none';
				textGrid(r+1,c).BackgroundColor = 'none';
				if userGrid(r+1,c) < userGrid(r,c) % upside down domino
					mistakes(r,c) = true;
					mistakes(r+1,c) = true;
					textGrid(r,c).BackgroundColor = gValues.hintBgColor;
					textGrid(r+1,c).BackgroundColor = gValues.hintBgColor;
				elseif ~any(isnan([userGrid(r,c) userGrid(r+1,c)])) % completed domino
					ind = patchInd(userGrid(r,c),userGrid(r+1,c));
					doms(ind) = 1 + doms(ind); % count how many times it appears
					domsLocs{ind} = [domsLocs{ind}; r c; r+1 c]; % store r,c of every domino
				end
			end
		end
		for i = 1:length(doms)
			if doms(i) > 1 % any domino that appears more than once
				for j = 1:size(domsLocs{i},1)
					mistakes(domsLocs{i}(j,1),domsLocs{i}(j,2)) = true; % mark all of them as mistakes
				end
				domHintsP(i).FaceColor = [1 0 0]; % error, mark dom hint red
			elseif doms(i) == 1
				domHintsP(i).FaceColor = [1 1 1]*0.5; % fulfilled exactly once, mark grey
			else
				domHintsP(i).FaceColor = [1 1 1]; % unfulfilled, mark white
			end
		end



% 		mistakes
		for i = 1:8
			for j = 1:7
				textGrid(i,j).Color(1) = mistakes(i,j);
			end
		end
		%{
		side hints should play out very similarly to top/bot hints,
		just transposed

		i could simplify my life by only turning the hints red, not the
		big numbers. this way, none of them interfere with each other.

		if i want to change the color of the big numbers, i think i'm
		going to end up with an 8x7 array keeping track of which spaces
		have an error and then do all color changes at the end.
		- tried the big array to keep track, but i think there's just
		so many ways for errors to occur. to know when to remove an
		error warning, i'll need to check every row and column every
		time a big number changes. I can't safely check just the
		current r,c

		im also running into the issue that I think the domino hints
		may be too linked between error checking and hint updating to
		be done separately. frankly most of them are linked and there's
		more repeated code than i'd prefer
		-- there's so much repeated code that my next plan is to combine
		hintUpdate() and errorCheck() if possible. at least the dom part





		%}
	end
	
	function [won] = winCheck()		
		won = sum(sum(~isnan(userGrid))) == 56; %everything filled in
		if ~won
			return
		end
		
		for i = 1:56
			won = (textGrid(i).Color(1)==0); % no red numbers
			if ~won
				return
			end
		end
		
		% no red hints - top/bot/side or dom
		
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
		clf('reset')
		f.MenuBar = 'none';
		f.Name = 'Domino Theory';
		f.NumberTitle = 'off';
		f.WindowButtonDownFcn = @click;
		f.SizeChangedFcn = @resize;
		f.UserData = 'normal';
		f.Resize = 'on';
		f.Units = 'pixels';
		
		
		
		ax = axes('Parent',f);
% 		ax.Position = [0.3 0 0.7 1];
		ax.Position = [0 0 1 1];
		ax.YDir = 'reverse';
		ax.YTick = [];
		ax.XTick = [];
		ax.XColor = f.Color;
		ax.YColor = f.Color;
		ax.Color = f.Color;
		axis equal
		ax.XLim = [-37/7 8];
		ax.YLim = [0 10];
		
		
		gValues.noteHeight = 0.7/8;
		gValues.noteOnColor = [0.94 0.94 1];
		gValues.noteOffColor = [0.94 0.94 0.94];
		gValues.hintBgColor = [1 .25 .25];
		gValues.baseFigDim = [560 420]; % base [width,height] of a new figure, used for resizing
% 		gValues.opHeight = 0.15;
% 		gValues.startN = 5;
		
		
		ng = uicontrol(...
			'Parent',f,...
			'Units','normalized',...
			'Style','pushbutton',...
			'String','New',...
			'Callback',@newGame,...
			'Position',[0.05 0.8 0.1 0.1],...
			'TooltipString','New Puzzle',...
			'FontUnits','normalized',...
			'FontSize',0.25); %#ok<NASGU>
		
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
		
% 		% enter tool placement code for when it appears
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





