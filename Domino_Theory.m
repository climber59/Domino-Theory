%{


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
	mistakes = zeros(8,7);
	
	blobs = [];
	checkmark = [];
	
	figureSetup();
	newGame();
	
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
		mistakes = zeros(8,7);
		userGrid = nan(8,7);
		patchGrid();
		numGrid = dominoGen();
		drawnow;
		hintNums();
		drawnow;
		blankNums();
		buildEnterTool();
		checkmark = patch(1.5 + 6*[0 9 37 87 100 42]/100, 1.9 + 6*[72 59 78 3 12 100]/100,[0 1 0],'FaceAlpha',0.5,'EdgeColor','none','Visible','off');
	end
	
	function [] = hintNums()
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
				domHints(ind) = line(ax.XLim(1) + (j + 0.5 + [xi, xj])/s, 9 - (0.5 + 2*i + [0.9+yi, yj])/s,'MarkerSize',2,'LineStyle','none','Marker','o','MarkerFaceColor',[0 0 0],'MarkerEdgeColor',[0 0 0]);
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
				textGrid(r,c) = text(c+0.5,r+0.5,' ','FontUnits','normalized','FontSize',gValues.noteHeight/8,'HorizontalAlignment','center','VerticalAlignment','middle');
				notesGrid(r,c) = text(c+m, r+y, none,'FontName','fixedwidth','FontUnits','normalized','FontSize',fs,'HorizontalAlignment','right','VerticalAlignment','bottom','Color',0.2*[1 1 1]);
			end
		end
		notesGrid(1,1).UserData.all = noteString;
		notesGrid(1,1).UserData.none = none;
		delete(temp);
	end
	
	function [] = patchGrid()
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
	end
	
	function [] = resize(~,~)
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
		oldnum = userGrid(r,c); % needed for domino hints
		if noteMode
			userGrid(r,c) = nan; % remove any "big" numbers
			if ~isnan(oldnum) % update hints if replacing a big num with notes
				hintUpdate(r, c, oldnum);
				errorCheck(r,c, oldnum);
			end
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
			hintUpdate(r,c, oldnum);
			errorCheck(r,c, oldnum);

			% display the check mark if the puzzle is completed
			finished = winCheck();
			highlight(false);
		end
		
		% updates all the hints after entering a number
		function [] = hintUpdate(r,c, oldnum)
			if mod(r,2) % top hints
				userNums = userGrid(1:2:7,c);
				hints = zeros(1,4);
				for i = 1:4
					hints(i) = topHints(c,i).UserData.num;
				end
				for i = 1:4
					if ~isnan(userNums(i))
						hints(find(userNums(i)==hints,1)) = -1;
					end
				end
				for i = 1:4
					topHints(c,i).Color = [1 1 1]*0.675*(hints(i) < 0);
				end
			else % bot hints
				userNums = userGrid(2:2:8,c);
				hints = zeros(1,4);
				for i = 1:4
					hints(i) = botHints(c,i).UserData.num;
				end
				for i = 1:4
					if ~isnan(userNums(i))
						hints(find(userNums(i)==hints,1)) = -1;
					end
				end
				for i = 1:4
					botHints(c,i).Color = [1 1 1]*0.675*(hints(i) < 0);
				end
			end
			
			% side hints
			userNums = userGrid(r,:);
			hints = zeros(1,7);
			for i = 1:7
				hints(i) = sideHints(r,i).UserData.num;
			end
			for i = 1:7
				if ~isnan(userNums(i))
					hints(find(userNums(i)==hints,1)) = -1;
				end
			end
			for i = 1:7
				sideHints(r,i).Color = [1 1 1]*0.675*(hints(i) < 0);
			end
			
			
			
			% domino hints
			%{
			if new num completes a domino, grey out the dom.
			if old num was also a domino, turn on the old dom.
			if removing a num from a completed domino, turn on the old dom
			%}
			inds = sort(sub2ind(size(userGrid),[r r+(mod(r,2)*2-1)],[c c]));
			if all(~isnan(userGrid(inds)))
				ind = patchInd(userGrid(inds)); % grey out new domino
				domHintsP(ind).FaceColor = [1 1 1]*0.5;
			end
			if all(~isnan([oldnum, userGrid(r+(mod(r,2)*2-1), c)])) || isnan(userGrid(r,c)) % oldnum was a domino, got replaced or removed
				ind = patchInd(oldnum, userGrid(r+(mod(r,2)*2-1),c)); % turn on old domino
				domHintsP(ind).FaceColor = [1 1 1];
				% if a domino appears twice (user error), this will turn on
				% the domino when it's removed even though it should be
				% greyed out because of a different user domino. This might
				% need to turn into checking the whole board to prevent
				% this glitch
			end
			

			
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
	
	function [] = errorCheck()%r, c, oldnum)
		for r = 1:8
			
		end
		for c = 1:7
			
		end
		% top mistakes
		if mod(r,2)
			userNums = userGrid(1:2:7,c)';
			hints = zeros(1,4);
			for i = 1:4
				hints(i) = topHints(c,i).UserData.num;
			end
			hintsO = hints;
			for i = 1:4
				if ~isnan(userNums(i))
					hints(find(userNums(i)==hints,1)) = -1;
				end
			end				
			if sum(hints<0) ~= sum(~isnan(userNums)) % entered nums don't match hints
				for i = unique(userNums(~isnan(userNums))) % check through each entered number
					if sum(userNums==i) > sum(hintsO==i) % a number appears too many times (including when it's not supposed to appear)
						mistakes(2*find(userNums==i)-1,c) = true;
						if any(hintsO==i) % prevents trying to turn '5' red when there aren't any 5s in the row
							topHints(c,hintsO==i).Color = [1 0 0]; % turn side hints red
						else
							% do something else to indicate why this is an
							% error. this text is just to make a warning
							'top error'
						end
					end
				end
			end

		else % bot mistakes
			userNums = userGrid(2:2:8,c)';
			hints = zeros(1,4);
			for i = 1:4
				hints(i) = botHints(c,i).UserData.num;
			end
			hintsO = hints;
			for i = 1:4
				if ~isnan(userNums(i))
					hints(find(userNums(i)==hints,1)) = -1;
				end
			end
			if sum(hints<0) ~= sum(~isnan(userNums)) % entered nums don't match hints
				for i = unique(userNums(~isnan(userNums))) % check through each entered number
					if sum(userNums==i) > sum(hintsO==i) % a number appears too many times (including when it's not supposed to appear)
						mistakes(2*find(userNums==i)-1,c) = true;
						if any(hintsO==i) % prevents trying to turn '5' red when there aren't any 5s in the row
							botHints(c,hintsO==i).Color = [1 0 0]; % turn side hints red
						else
							% do something else to indicate why this is an
							% error. this text is just to make a warning
							'bot error'
						end
					end
				end
			end
		end

		% side mistakes
		userNums = userGrid(r,:);
		hints = zeros(1,7);
		for i = 1:7
			hints(i) = sideHints(r,i).UserData.num;
		end
		hintsO = hints;
		for i = 1:7
			if ~isnan(userNums(i))
				hints(find(userNums(i)==hints,1)) = -1;
			end
		end
% 			userNums
% 			hints
% 			hintsO
		if sum(hints<0) ~= sum(~isnan(userNums)) % entered nums don't match hints
			for i = unique(userNums(~isnan(userNums))) % check through each entered number
				if sum(userNums==i) > sum(hintsO==i) % a number appears too many times (including when it's not supposed to appear)
					mistakes(r,userNums==i) = true;
% 						userNum
					if any(hintsO==i) % prevents trying to turn '5' red when there aren't any 5s in the row
						sideHints(r,hintsO==i).Color = [1 0 0]; % turn side hints red
					else
						% do something else to indicate why this is an
						% error. this text is just to make a warning
						'side error'
					end
				end
			end
		end

		% domino mistakes



		mistakes
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





		% side hint checking
		%{
		sum(hints<0) ~= sum(isnan(userNums)) will tell you if there is
		a mistake.

		red the entire row?
		-easy

		red the numbers in question?
		- easy for a number that shouldn't appear
		- trickier for too many of a number sum(hintsO == x) ==	sum(userNums == x)
		%}
		userNums = userGrid(r,:);
		hints = zeros(1,7);
		for i = 1:7
			hints(i) = sideHints(r,i).UserData.num;
		end
		hintsO = hints;
		for i = 1:7
			if ~isnan(userNums(i))
				hints(find(userNums(i)==hints,1)) = -1;
			end
		end
		for i = 1:7
			sideHints(r,i).Color = [1 1 1]*0.675*(hints(i) < 0);
		end
		if sum(hints<0) ~= sum(~isnan(userNums)) % entered nums don't match hints
			mistake = true;
			userNums
			hints
			hintsO

			for i = unique(userNums(~isnan(userNums))) % check through each entered number
				[i sum(userNums==i)	sum(hintsO==i)]
				if sum(userNums==i) > sum(hintsO==i) % a number appears too many times (including when it's not supposed to appear)
					% turn side hints red
					if ~isempty(hintsO==i)
						sideHints(r,hintsO==i).Color(1) = 1;
					end
					% turn big number red
					for j = 1:7
						if userNums(j) == i
							textGrid(r,j).Color(1) = 1;
							fprintf('\n%d %d turned red by side',r,j);
						end
					end
				end
			end
		end


% 			doms
		inds = sort(sub2ind(size(userGrid),[r r+(mod(r,2)*2-1)],[c c]));
		if diff(userGrid(inds)) < 0 % top > bottom on the domino, mistake
			mistake = true;
			textGrid(inds(1)).Color(1) = 1; % should also mark the domino in some way
			textGrid(inds(2)).Color(1) = 1;
			fprintf('\n%d %d turned red by dom',r,j);



		%}
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
		clf('reset')
		f.MenuBar = 'none';
		f.Name = 'Domino Theory';
		f.NumberTitle = 'off';
		f.WindowButtonDownFcn = @click;
% 		f.Position(3) = 1.5*f.Position(4);
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
			'Position',[0.05 0 0.1 0.1],...
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





