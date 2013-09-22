% Pauline Kwok and Jonathan Mak
% PLEASE REMEMBER TO INSTALL FONTS
% Jan. 21th, 2010
% Gem Match Final Summative

import GUI
var winID : int := Window.Open ("position:center;center, graphics:900;700, title: Gem Match, xor")

% declares the record to keep track of every players top 10 games
type scores :
    record
	name : string
	games : int
	score : array 1 .. 100 of int
	level : array 1 .. 100 of int
    end record
% declares the record to keep track of top 10 games of all time
type topScores :
    record
	place : int
	name : string
	score : int
	level : int
    end record

% 70*70 boardpieces
% 55*55 pieces
% gameboard 8*8
% 50,50,610,610

% array used when comparing to place order of the top 10 scores of all players
var TopList : array 1 .. 10 of int := init (0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
var TopListLv : array 1 .. 10 of int := init (0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
% array used to keep track of the names of the top 10 players
var TopListName : array 1 .. 10 of string := init ("", "", "", "", "", "", "", "", "", "")
var scoreList : array 1 .. 1000 of scores          % scoreList records keeps tracks up to 1000 players of the game
var r : int := 0    % number of players who has played the game
var dir, dir2 : int % dir to open two text files
var font5, font6 : int
font5 := Font.New ("Gorilla Milkshake:35")
font6 := Font.New ("Kristen ITC:12")
var font3 : int := Font.New ("Arnprior:30")             % font for level up
var picID3 : int
picID3 := Pic.FileNew ("background1.jpg")
% reads the Scores.txt document and retrieves the information to use for comparing
proc readFile
    open : dir, "Scores.txt", get
    % reads score info from file
    loop
	exit when eof (dir)
	r := r + 1      % r keeps tracks of how many people have played to game
	% vv gets name, how many times player have played, and the scores they have gotten below
	get : dir, scoreList (r).name, scoreList (r).games, skip
	for i : 1 .. scoreList (r).games
	    get : dir, scoreList (r).level (i), scoreList (r).score (i), skip
	end for
    end loop
    close : dir      % closes the file
end readFile

var putScore : boolean := false
var temp, temp3 : int
var temp2 : string

% Retrieves players name
var name : string
var score : int := 0
var gamesPlayed : int := 0
var findPlayer : int := 0
var points : int := 0   % points%users name
var outputName : string
var finalScore, finalLevel : string
var lv : int

% vv field and procedure to get user's name
var fromNameField : int
procedure nameField (text : string)
    GUI.SetSelection (fromNameField, 0, 0)
    GUI.SetActive (fromNameField)
end nameField
% procedure to get name and the score
var donebutton : int

proc GetNS
    gamesPlayed += 1
    donebutton := GUI.CreateButton (450, 280, 100, "DONE", GUI.Quit)
    GUI.SetBackgroundColour (95)
    Font.Draw ("Enter username: ", 160, 450, font5, 36)
    GUI.SetDefault (donebutton, true)       % sets enter as the done button
    GUI.SetColor (donebutton, brightgreen)     % Makes the above button green
    % creates text field, and calls procedure to activate it
    fromNameField := GUI.CreateTextFieldFull (100, 350, 350, "", nameField, GUI.INDENT, font3, 0)
    % exits when the done button is depressed
    loop
	exit when GUI.ProcessEvent
    end loop
    name := Str.Trim (Str.Upper (GUI.GetText (fromNameField)))
    % checks if the player has a previous record already
    for findName : 1 .. r
	if name = scoreList (findName).name then
	    findPlayer := findName
	end if
	exit when findPlayer not= 0
    end for
    score := points
    if findPlayer not= 0 then
	scoreList (findPlayer).games += 1
	scoreList (findPlayer).score (scoreList (findPlayer).games) := score
	scoreList (findPlayer).level (scoreList (findPlayer).games) := lv
    else
	r := r + 1
	scoreList (r).name := name
	scoreList (r).games := 1
	scoreList (r).score (1) := score
	scoreList (r).level (1) := lv
	% inits findPlayer for next search
    end if
    GUI.Dispose (donebutton)
    GUI.Disable (fromNameField)
    GUI.ResetQuit
    findPlayer := 0
    outputName := "Player: " + name
    finalLevel := "Level: " + intstr (lv)
    finalScore := "Score: " + intstr (points)
    %outputs the game info
    GUI.Refresh
    cls
    Pic.Draw (picID3, 0, 0, picCopy)
    donebutton := GUI.CreateButton (450, 280, 100, "DONE", GUI.Quit)
    GUI.SetColor (donebutton, brightgreen)     % Makes the above button green
    Font.Draw (outputName, 150, 500, font3, 36)
    Font.Draw (finalLevel, 150, 400, font3, 48)
    Font.Draw (finalScore, 150, 300, font3, 36)
    loop
	exit when GUI.ProcessEvent
    end loop
    cls
    GUI.ResetQuit
    GUI.Dispose (donebutton)
    GUI.Dispose (fromNameField)
end GetNS

% bubble sort to sort all the players scores in order
proc bubble
    % loops for value of the number of players
    for allPlayers : 1 .. r
	for decreasing first : scoreList (allPlayers).games .. 1
	    for i : 1 .. first - 1
		% switches the scores around if one is one is greater than the other
		% also switches the levels that goes with the score
		if scoreList (allPlayers).score (i) > scoreList (allPlayers).score (i + 1) then
		    const temp := scoreList (allPlayers).score (i)
		    const temp3 := scoreList (allPlayers).level (i)
		    scoreList (allPlayers).level (i) := scoreList (allPlayers).level (i + 1)
		    scoreList (allPlayers).level (i + 1) := temp3
		    scoreList (allPlayers).score (i) := scoreList (allPlayers).score (i + 1)
		    scoreList (allPlayers).score (i + 1) := temp
		end if
	    end for
	end for
    end for
end bubble

% COMPARE WITH ABOVE ARRAY .. all the rest of the scores
% and sorts them into the top 10 scores, along with the name of the users
% sorts the topscores
proc insertion
    % sorts EVERY single player's scores in ascending order
    for allPlayer : 1 .. r
	% sorts all the games of the player
	for playersScores : 1 .. scoreList (allPlayer).games
	    % inits putScore back to false
	    putScore := false
	    % checks all the values of the current top score list to see if any should be replaced
	    for check : 1 .. 10
		% if current score is greater than the current top score then
		if scoreList (allPlayer).score (playersScores) > TopList (check) or scoreList (allPlayer).score (playersScores) = TopList (check) then
		    putScore := true            % tells them the current players score have been added to the array
		    % sets player's info of current top score as temp
		    temp := TopList (check)
		    temp2 := TopListName (check)
		    temp3 := TopListLv (check)
		    % switches the current player score with current top score
		    TopList (check) := scoreList (allPlayer).score (playersScores)
		    TopListName (check) := scoreList (allPlayer).name
		    TopListLv (check) := scoreList (allPlayer).level (playersScores)
		    % if the replaced value is not the last digit then
		    if check < 10 then
			% everything from the 9th value to the replaced value
			for decreasing check2 : 9 .. check
			    % when check2 is at the replaced value array position then
			    if check2 = check then
				% the replaced value's information is all moved to the next position in the array
				TopList (check + 1) := temp
				TopListName (check + 1) := temp2
				TopListLv (check + 1) := temp3
				% all the other digits in the arrays are moved forward one digit
			    else
				TopList (check2 + 1) := TopList (check2)
				TopListName (check2 + 1) := TopListName (check2)
				TopListLv (check2 + 1) := TopListLv (check2)
			    end if
			end for
		    end if
		end if
		% exits when value is inserted into array
		exit when putScore
	    end for
	end for
    end for
end insertion

% insertion2 is used every time user finshes a game
proc insertion2
    % checks all ten of the highscores to see if any is less or equal to current score
    for check : 1 .. 10
	putScore := false
	% if the score from current game is equal or more than the highscore(check) then
	if points > TopList (check) or points = TopList (check) then
	    % putScore is true, finished sorting and will exit for loop after the switching this
	    putScore := true
	    % the score to be replaced has all its information assigned a temp value
	    temp := TopList (check)
	    temp2 := TopListName (check)
	    temp3 := TopListLv (check)
	    % the score is replaced with new score
	    TopList (check) := points
	    TopListName (check) := name
	    TopListLv (check) := lv
	    % if the replaced value is not the last digit then
	    if check < 10 then
		% everything from the 9th value to the replaced value
		for decreasing check2 : 9 .. check
		    % when check2 is at the replaced value array position then
		    if check2 = check then
			% the replaced value's information is all moved to the next position in the array
			TopList (check + 1) := temp
			TopListName (check + 1) := temp2
			TopListLv (check + 1) := temp3
			% all the other digits in the arrays are moved forward one digit
		    else
			TopList (check2 + 1) := TopList (check2)
			TopListName (check2 + 1) := TopListName (check2)
			TopListLv (check2 + 1) := TopListLv (check2)
		    end if
		end for
	    end if
	end if
	% exits when value is inserted into array
	exit when putScore
    end for
    % if score is equal to TopList's last place than the name and level is automatically replaed
    if score = TopList (10) then
	TopListName (10) := name
	TopListLv (10) := lv
    end if
end insertion2

proc overWrite
    % opens the file
    open : dir, "Scores.txt", put
    % loops for the number of players that has played the game
    for info : 1 .. r
	% outputs game info
	put : dir, scoreList (info).name, "  ", scoreList (info).games, "  " ..
	% outputs game scores
	for games : 1 .. scoreList (info).games
	    if games = scoreList (info).games then
		put : dir, scoreList (info).level (games), " ", scoreList (info).score (games)
	    else
		put : dir, scoreList (info).level (games), " ", scoreList (info).score (games), "  " ..
	    end if
	end for
    end for
    % closes the file
    close : dir
end overWrite

% writes the top 10 scores of all time
proc overWrite2
    % opens the file
    open : dir2, "TopScores.txt", put
    for info : 1 .. 10
	% outputs place, name, and score
	put : dir2, info, "  ", TopList (info), "  ", TopListLv (info), "  ", TopListName (info)
    end for
    close : dir2
end overWrite2

% each Players Highest scores
var highscores : array 1 .. 1000 of int
var names : array 1 .. 1000 of string
var highlv : array 1 .. 1000 of int

% gets the highest score of each player (the last digit in their score array)
proc AllHighs
    for putScores : 1 .. r
	highscores (putScores) := scoreList (putScores).score (scoreList (putScores).games)
	highlv (putScores) := scoreList (putScores).level (scoreList (putScores).games)
	names (putScores) := scoreList (putScores).name
    end for
end AllHighs

% used when finding highscores
var found : boolean % sees if the user is found
var tempPlayer : int
var font7 : int := Font.New ("ligurino:20")   % font for scores
% finds the name entered by user and finds where in the list they are
var enterLabel : int
proc findRank1
    found := false
    findPlayer := 0
    % checks if the player has a previous record already
    for findName : 1 .. r
	if name = scoreList (findName).name then
	    findPlayer := findName
	end if
	exit when findPlayer not= 0
    end for
    if findPlayer not= 0 then
	found := true
	tempPlayer := highscores (findPlayer)
    end if
end findRank1

% finds the ranks of the player, through bubble sort, and then a loop
% sorts highscoes in a list first
proc sortHighs
    var sorted : boolean := true
    for decreasing first : r .. 1
	for i : 1 .. first - 1
	    % if the first high score is less than the next one then it switches with it
	    % names of that person, and the level of the highscores are also switched
	    if highscores (i) < highscores (i + 1) then
		sorted := false
		const temp2 := highscores (i)
		highscores (i) := highscores (i + 1)
		highscores (i + 1) := temp2
		const temp := names (i)
		names (i) := names (i + 1)
		names (i + 1) := temp
		const temp3 := highlv (i)
		highlv (i) := highlv (i + 1)
		highlv (i + 1) := temp3
	    end if
	end for
	exit when sorted
    end for
end sortHighs

% finds ranks of the people by searching through the highscore list
function findRank2 : int
    for findRanks : 1 .. r
	if tempPlayer = highscores (findRanks) then
	    result findRanks
	end if
	% sets back findplayer to 0 for next time
	findPlayer := 0
    end for
end findRank2

% procedure that runs when user exits the game, gamesover, or wins the entire game
% gets user name, sorts the scores, overwrites the two txt files
proc together
    GetNS
    bubble
    insertion2
    overWrite
    overWrite2
end together

% process to find that rank of the person when the name of the person is entered
% uses two procedures and a function which outputs the users rank
proc findRank
    AllHighs
    findRank1
    sortHighs
    put "User's rank is: ", findRank2
end findRank

var txtbox : int
% outputs ALL the players Highest scores, and rank by that highest score earnt
proc AllPlayerHighs
    GUI.AddLine (txtbox, "")
    for output : 1 .. r
	GUI.AddText (txtbox, intstr (output))
	GUI.AddText (txtbox, repeat ("  ", 8 - length (intstr (output))))
	GUI.AddText (txtbox, intstr (highlv (output)))
	GUI.AddText (txtbox, repeat (" ", 15 - length (intstr (output))))
	GUI.AddText (txtbox, intstr (highscores (output)))
	GUI.AddText (txtbox, repeat (" ", 30 - (length (intstr (highscores (output))) * 2)))
	GUI.AddText (txtbox, names (output))
	GUI.AddLine (txtbox, "")
    end for
end AllPlayerHighs


% menu screen and choices on the screen

var picID1 : array 1 .. 20 of int
picID1 (1) := Pic.FileNew ("classic.bmp")
picID1 (2) := Pic.FileNew ("scores.bmp")
picID1 (3) := Pic.FileNew ("options.bmp")
picID1 (4) := Pic.FileNew ("howToPlay1.1.jpg")
picID1 (5) := Pic.FileNew ("howToPlay2.1.jpg")
picID1 (7) := Pic.FileNew ("help.jpg")
picID1 (6) := Pic.FileNew ("background.bmp")
picID1 (8) := Pic.FileNew ("back3.bmp")
picID1 (9) := Pic.FileNew ("back2.jpg")
picID1 (10) := Pic.FileNew ("resume.jpg")
picID1 (11) := Pic.FileNew ("yorN.jpg")
picID1 (12) := Pic.FileNew ("settings.jpg")
picID1 (13) := Pic.FileNew ("music.jpg")
picID1 (14) := Pic.FileNew ("exitgame.jpg")
picID1 (15) := Pic.FileNew ("AT10.jpg")
picID1 (16) := Pic.FileNew ("my10.jpg")
picID1 (17) := Pic.FileNew ("allranks.jpg")
picID1 (18) := Pic.FileNew ("myrank.jpg")

var x, y, btnNum, btnUpDown : int             % needed for mousebutton
var x1, y1, x2, y2 : int                      % the x and y values of the two selected gems
% menuPress is used throughout the program, to indicate whether a particular loop or procedure should end or not
var menuPress, leavePress : boolean := false
% scores menu with multiple options which calls on different procedures each time
var t : int                                   % the offset for the scores
var font8 : int := Font.New ("Mufferaw:50")   % font for score labels
% can also return to main menu
proc scoresMenu
    % sets background colour
    cls
    GUI.SetBackgroundColour (black)
    % vv loads the game choices on the screen
    Pic.Draw (picID1 (15), 260, 550, picCopy)
    Pic.Draw (picID1 (16), 260, 430, picCopy)
    Pic.Draw (picID1 (17), 260, 310, picCopy)
    Pic.Draw (picID1 (18), 260, 190, picCopy)
    Pic.Draw (picID1 (8), 370, 75, picMerge)
    loop
	t := 0
	% vv brings back on screen input and output words for some options below
	View.Set ("graphics:900;700")
	setscreen ("echo")
	setscreen ("nooffscreenonly")
	% for the loop inside (reinits to false each time)
	leavePress := false
	% for the loop inside (reinits to 0 each time)
	findPlayer := 0
	if Mouse.ButtonMoved ("down") then
	    Mouse.ButtonWait ("down", x, y, btnNum, btnUpDown)
	    % vv % output top 10 all time
	    if x > 264 and x < 630 and y > 550 and y < 659 then
		cls
		GUI.SetBackgroundColour (red)
		Pic.Draw (picID1 (8), 370, 15, picMerge)
		Font.Draw ("Top Ten of ALL TIME", 150, 600, font8, 76) % labels
		Font.Draw ("Rank", 250, 550, font7, 91)
		Font.Draw ("Level", 340, 550, font7, 91)
		Font.Draw ("Points", 435, 550, font7, 91)
		Font.Draw ("Player", 540, 550, font7, 91)
		for tp10 : 1 .. 10
		    % outputs place, name, and score
		    Font.Draw (intstr (tp10), 255, 520 - t, font7, white)
		    Font.Draw (intstr (TopListLv (tp10)), 350, 520 - t, font7, white) % for the level
		    Font.Draw (intstr (TopList (tp10)), 505 - ((length (intstr (TopList (tp10)))) * 15), 520 - t, font7, white)
		    Font.Draw (TopListName (tp10), 540, 520 - t, font7, white)
		    t += 35
		end for
		loop
		    if Mouse.ButtonMoved ("down") then
			Mouse.ButtonWait ("down", x, y, btnNum, btnUpDown)
			if x > 370 and x < 509 and y > 15 and y < 62 then
			    leavePress := true
			    % sets background colour
			    GUI.SetBackgroundColour (black)
			    % vv loads the game choices on the screen
			    Pic.Draw (picID1 (15), 260, 550, picCopy)
			    Pic.Draw (picID1 (16), 260, 430, picCopy)
			    Pic.Draw (picID1 (17), 260, 310, picCopy)
			    Pic.Draw (picID1 (18), 260, 190, picCopy)
			    Pic.Draw (picID1 (8), 370, 75, picMerge)
			end if
		    end if
		    exit when leavePress
		end loop
		% vv  output top 10 of user, after asking for their name ^^ask name code in GetNS... if you want box...rest of it is
	    elsif x > 264 and x < 630 and y > 430 and y < 540 then
		cls
		GUI.SetBackgroundColour (red)
		Pic.Draw (picID1 (8), 370, 15, picMerge)    % back button
		fromNameField := GUI.CreateTextFieldFull (150, 450, 200, "", nameField, GUI.INDENT, font7, GUI.ANY)
		enterLabel := GUI.CreateLabelFull (100, 550, "Enter name to find top 10 scores: ", 20, 20, GUI.LEFT, font7)
		donebutton := GUI.CreateButton (370, 450, 50, "Search!", GUI.Quit)
		GUI.SetDefault (donebutton, true)
		loop
		    loop
			t := 0  % offset is 0
			% when "search" is pressed
			if GUI.ProcessEvent then
			    name := Str.Trim (Str.Upper (GUI.GetText (fromNameField)))
			    % checks if the player has a previous record already
			    found := false
			    findPlayer := 0
			    for findName : 1 .. r
				if name = scoreList (findName).name then
				    findPlayer := findName
				end if
				exit when findPlayer not= 0
			    end for
			    if findPlayer not= 0 then   % if the player is found
				Draw.FillBox (500, 100, 900, 700, red) % cover previous outputs
				Font.Draw ("Level       Scores", 600, 550, font7, 91)
				var tentimes : int := 0
				for decreasing output10 : scoreList (findPlayer).games .. 1
				    tentimes += 1
				    if tentimes < 11 then   % makes sure it only outputs the top TEN games
					Font.Draw (intstr (scoreList (findPlayer).level (output10)), 600, 500 - t, font7, white)
					Font.Draw (intstr (scoreList (findPlayer).score (output10)), 700, 500 - t, font7, white)
					t += 35
				    else                    % if there are over ten gams to be outputted
					exit
				    end if
				end for
			    else    % if the player is not found
				Draw.FillBox (500, 100, 900, 700, red) % cover previous outputs
				Draw.FillBox (100, 390, 450, 420, red) % replace previous output
				Font.Draw ("Player not found.", 100, 400, font7, white)
			    end if
			    GUI.ResetQuit
			end if
			% back to score menu when back is pressed
			if Mouse.ButtonMoved ("down") then
			    Mouse.ButtonWait ("down", x, y, btnNum, btnUpDown)
			    if x > 370 and x < 509 and y > 15 and y < 62 then
				leavePress := true
				GUI.ResetQuit
				GUI.Dispose (fromNameField)         % disables/disposes the widgets so they can be renewed
				GUI.Dispose (enterLabel)
				GUI.Dispose (donebutton)
				% sets background colour
				GUI.SetBackgroundColour (black)
				% vv loads the game choices on the screen
				Pic.Draw (picID1 (15), 260, 550, picCopy)
				Pic.Draw (picID1 (16), 260, 430, picCopy)
				Pic.Draw (picID1 (17), 260, 310, picCopy)
				Pic.Draw (picID1 (18), 260, 190, picCopy)
				Pic.Draw (picID1 (8), 370, 75, picMerge)
			    end if
			end if
			exit when GUI.ProcessEvent
			exit when leavePress
		    end loop
		    exit when leavePress
		end loop

		% vv calls on 3 procedure to output all ranks of players, names and scores
	    elsif x > 264 and x < 630 and y > 310 and y < 420 then
		cls
		View.Set ("graphics:900;700")
		GUI.SetBackgroundColour (red)
		txtbox := GUI.CreateTextBox (100, 200, 700, 400)
		Font.Draw ("Rank is calculated by the HIGHEST score each player has earned.", 100, 650, font7, white)
		GUI.AddText (txtbox, "Rank      Level      High Score           Player")         % adds this to the textbox
		Pic.Draw (picID1 (8), 370, 15, picMerge)
		AllHighs
		sortHighs
		AllPlayerHighs
		% back to score menu when back is pressed
		loop         % until the user clicks back
		    if Mouse.ButtonMoved ("down") then         % if th user clicks back
			Mouse.ButtonWait ("down", x, y, btnNum, btnUpDown)
			if x > 370 and x < 509 and y > 15 and y < 62 then
			    leavePress := true          % yes they watn to leave
			    GUI.Dispose (txtbox)         % take out the textbox
			    % sets background colour
			    GUI.SetBackgroundColour (black)
			    % vv reloads menu
			    Pic.Draw (picID1 (15), 260, 550, picCopy)
			    Pic.Draw (picID1 (16), 260, 430, picCopy)
			    Pic.Draw (picID1 (17), 260, 310, picCopy)
			    Pic.Draw (picID1 (18), 260, 190, picCopy)
			    Pic.Draw (picID1 (8), 370, 75, picMerge)
			end if
		    end if
		    exit when leavePress
		    exit when GUI.ProcessEvent         % needed to make the txtbox scrollable
		end loop
		% vv asks for user name then outputs users rank
	    elsif x > 264 and x < 630 and y > 190 and y < 300 then
		GUI.SetBackgroundColour (red)
		Pic.Draw (picID1 (8), 370, 15, picMerge)
		fromNameField := GUI.CreateTextFieldFull (230, 450, 200, "", nameField, GUI.INDENT, font7, GUI.ANY)
		enterLabel := GUI.CreateLabelFull (100, 450, "Enter name: ", 20, 20, GUI.LEFT, font7)
		donebutton := GUI.CreateButton (450, 450, 50, "Search!", GUI.Quit)
		Font.Draw ("Rank is calculated by the HIGHEST score each player has earned", 100, 550, font7, white)
		GUI.SetDefault (donebutton, true)
		loop
		    loop
			% when "search" is pressed
			if GUI.ProcessEvent then
			    name := Str.Trim (Str.Upper (GUI.GetText (fromNameField)))
			    AllHighs
			    findRank1         % searches for the name
			    if found then     % if the name is found then
				sortHighs
				Draw.FillBox (100, 390, 450, 420, red)         % replace previous output
				Font.Draw ("Player's rank is: ", 100, 400, font7, white)         % outputs rank
				Font.Draw (intstr (findRank2), 300 - (length (intstr (findRank2)) * 15), 400, font7, white)
			    else            % if the search query was not found
				Draw.FillBox (100, 390, 450, 420, red)     % replace previous output
				Font.Draw ("Player not found.", 100, 400, font7, white)
			    end if
			    GUI.ResetQuit
			end if
			% back to score menu when back is pressed
			if Mouse.ButtonMoved ("down") then
			    Mouse.ButtonWait ("down", x, y, btnNum, btnUpDown)
			    if x > 370 and x < 509 and y > 15 and y < 62 then
				leavePress := true
				GUI.ResetQuit
				GUI.Dispose (fromNameField)         % disables/disposes the widgets so they can be renewed
				GUI.Dispose (enterLabel)
				GUI.Dispose (donebutton)
				% sets background colour
				GUI.SetBackgroundColour (black)
				% vv loads the game choices on the screen
				Pic.Draw (picID1 (15), 260, 550, picCopy)
				Pic.Draw (picID1 (16), 260, 430, picCopy)
				Pic.Draw (picID1 (17), 260, 310, picCopy)
				Pic.Draw (picID1 (18), 260, 190, picCopy)
				Pic.Draw (picID1 (8), 370, 75, picMerge)
			    end if
			end if
			exit when leavePress         % if back is pressed
			exit when GUI.ProcessEvent
		    end loop
		    exit when leavePress         % if back is pressed
		end loop
		% exits score menu and goes back to main menu when back is pressed
	    elsif x > 370 and x < 509 and y > 75 and y < 122 then
		menuPress := true
	    end if
	end if
	exit when menuPress
    end loop
    % clears screen before going to main menu
    cls
end scoresMenu

% number of clicks tells if the music should be played or stopped
var click : int := 0

% settings procedure allows user to toggle the background game music
proc settings
    cls             % clears the screen
    GUI.SetBackgroundColour (black)             % background
    Pic.Draw (picID1 (13), 290, 280, picCopy)             % options picture
    loop
	% keeps looping until any mouse button is depressed
	if Mouse.ButtonMoved ("down") then
	    Mouse.ButtonWait ("down", x, y, btnNum, btnUpDown)
	    % vv checks the x and y values from the mouseclick to see if it is inside
	    % any of the options ('yes' 'no' 'back' buttons)
	    if x > 310 and x < 423 and y > 304 and y < 355 then
		click += 1
		% any even number clicks means the music should be turned on
		if click rem 2 = 0 then
		    Music.PlayFileLoop ("O Fortuna.mp3")
		    menuPress := true
		    cls
		    % else odd number clicks means music is turned off
		else
		    Music.PlayFileStop
		    menuPress := true
		    cls
		end if
		% exits the settings and goes back to previous screen (menu or game)
	    elsif x > 445 and x < 550 and y > 305 and y < 355 then
		menuPress := true
		cls
	    end if
	end if
	% exits loop when any button on the screen is pressed
	exit when menuPress
    end loop
end settings

% instructions/help menu
proc help
    cls
    GUI.SetBackgroundColour (black)
    % keeps showing the two instruction pictures until the button to go back to menu/game is depressed
    loop
	% vv pics below fades in for 500 milliseconds and then stays on screen for 2 seconds
	Pic.Draw (picID1 (4), 280, 100, picCopy)
	delay (2000)
	Pic.DrawSpecial (picID1 (5), 280, 100, picCopy, picFadeIn, 500)
	View.Update
	delay (2000)
	if Mouse.ButtonMoved ("down") then
	    Mouse.ButtonWait ("down", x, y, btnNum, btnUpDown)
	    if x > 306 and x < 570 and y > 132 and y < 182 then
		cls
		menuPress := true
	    end if
	end if
	% exits loop when the button is pressed
	exit when menuPress
    end loop
end help

% options Menu with 3 buttons that calls on 3 procedures
proc optionsMenu
    cls
    GUI.SetBackgroundColour (black)
    Pic.Draw (picID1 (12), 290, 250, picCopy)
    menuPress := false
    % loops until back button is pressed
    loop
	% checks if the mouse button has been depressed
	if Mouse.ButtonMoved ("down") then
	    Mouse.ButtonWait ("down", x, y, btnNum, btnUpDown)
	    % checks x and y perimeters for the buttons , matching it with
	    % the values of the clicked position
	    if x > 310 and x < 565 and y > 448 and y < 515 then
		settings
	    elsif x > 310 and x < 565 and y > 367 and y < 433 then
		help
	    elsif x > 310 and x < 565 and y > 286 and y < 353 then
		cls
		menuPress := true
	    end if
	end if
	exit when menuPress
    end loop
end optionsMenu

% the IDs of the gems
var pic : array 1 .. 7 of int
pic (1) := Pic.FileNew ("white.bmp")
pic (2) := Pic.FileNew ("blue.bmp")
pic (3) := Pic.FileNew ("purple.bmp")
pic (4) := Pic.FileNew ("red.jpg")
pic (5) := Pic.FileNew ("orange.bmp")
pic (6) := Pic.FileNew ("green.bmp")
pic (7) := Pic.FileNew ("yellow.bmp")

% select sprite and pic id
var selectp : int := Pic.FileNew ("select.bmp") % ID of the select picture
var select := Sprite.New (selectp)              % ID of the select sprite
var select2 := Sprite.New (selectp)             % ID of the 2nd select sprite

% hint sprite and pic id
var hintp : int := Pic.FileNew ("hint.bmp")         % ID of the hint picture
var hint := Sprite.New (hintp)                      % ID of the hint sprite

var occupied : array 1 .. 8, 1 .. 8 of int          % array that identifies the corresponding sprite's picture number
var sprite : array 1 .. 8, 1 .. 8 of int            % array of sprites on the board
var n : int             % pic number
var numMatch : int      % number of gem in the match
var kind : string       % what kind of match(hor or ver)
var q, w : int          % the x,y coordinates for the flash and pushdown procs
var match : boolean     % is there a match on the board?

% this procedure pushes everything above the matched pieces down
proc pushDown (x, y, numMatch : int, kind : string)             % needs the current (x,y) values of matched gems and
    % gets the number of gems in a row that got matched and gets the kind of match
    if kind = "hor" then                           % if it's a horizontal match
	for decreasing o : x .. x - (numMatch - 1) % for all of the gems in the match
	    for k : y .. 7                         % for all the rows except for the top row
		Sprite.ChangePic (sprite (o, k), pic (occupied (o, k + 1)))             % changes the current sprite into the picture above it
		occupied (o, k) := occupied (o, k + 1)          % sets the occupied value into the new value
		Sprite.Show (sprite (o, k))                     % shows the new sprite
	    end for
	    randint (n, 1, 7)                                   % generates a random gem for the top row
	    Sprite.ChangePic (sprite (o, 8), pic (n))           % changes the top row into the random gem
	    occupied (o, 8) := n                                % changes the occupied value to the new value
	end for
    elsif kind = "ver" then             % if it's a vertical match
	for k : y - (numMatch - 1) .. 8          % starting from the bottom point of the match to the top of the grid
	    if k + numMatch < 9 then             % replace them with the gems on top of them
		Sprite.ChangePic (sprite (x, k), pic (occupied (x, k + numMatch)))
		occupied (x, k) := occupied (x, k + numMatch)
		Sprite.Show (sprite (x, k))
	    else                        % replace them with random gems if there are no more on top
		randint (n, 1, 7)
		Sprite.ChangePic (sprite (x, k), pic (n))
		occupied (x, k) := n
	    end if
	end for
    end if
end pushDown

% flashes the matched gems
proc flashMatch (i, j, numMatch : int, kind : string)             % gets the current i,j(x,y) values of the matched gems,
    % gets the number of gems in a row that got matched and gets the kind of match
    if numMatch not= 0 then             % this is needed when a match is made at the end of a level
	Music.PlayFileReturn ("3Match.wav")
    end if
    for a : 1 .. 3
	for b : 0 .. numMatch - 1            % for all of the matched gems
	    if kind = "hor" then             % if it's a horizontal match
		Sprite.Hide (sprite (i - b, j))
	    elsif kind = "ver" then          % if it's a vertical match
		Sprite.Hide (sprite (i, j - b))
	    end if
	end for
	delay (100)
	for b : 0 .. numMatch - 1
	    if kind = "hor" then
		Sprite.Show (sprite (i - b, j))
	    elsif kind = "ver" then
		Sprite.Show (sprite (i, j - b))
	    end if
	end for
	delay (100)
    end for
    delay (100)
end flashMatch

% this procedure checKs if there are any horizontal or vertical matches, then flashes and eliminates them if they do
proc checkMatch
    match := false
    q := 0
    w := 0
    % checks if there are horizontal matches
    for decreasing i : 8 .. 3         % checks the 6x8 grid of gems on the right
	for decreasing j : 8 .. 1
	    if i = 3 then             % if the x value is 6 then just check if there is 3 in a row
		if occupied (i, j) = occupied (i - 1, j) and occupied (i, j) = occupied (i - 2, j) then % checks if there are three in a row horizontal
		    q := i
		    w := j
		    numMatch := 3
		    kind := "hor"
		    match := true
		end if
	    elsif i = 4 then          % if the x value is 5 then check if there is 3 or 4 in a row
		% vv checks if there are four in a row horizontal vv
		if occupied (i, j) = occupied (i - 1, j) and occupied (i, j) = occupied (i - 2, j) and occupied (i, j) = occupied (i - 3, j) then
		    q := i
		    w := j
		    numMatch := 4
		    kind := "hor"
		    match := true
		    % vv checks if there are three in a row horizontal vv
		elsif occupied (i, j) = occupied (i - 1, j) and occupied (i, j) = occupied (i - 2, j) then % checks if there are three in a row horizontal
		    q := i
		    w := j
		    numMatch := 3
		    kind := "hor"
		    match := true
		end if
	    else             % if the x value is else then check if there is 3,4, or 5 in a row
		% vv checks if there are five in a row horizontal vv
		if occupied (i, j) = occupied (i - 1, j) and occupied (i, j) = occupied (i - 2, j) and occupied (i, j) = occupied (i - 3, j) and occupied (i, j) = occupied (i - 4, j) then
		    q := i
		    w := j
		    numMatch := 5
		    kind := "hor"
		    match := true
		    % vv checks if there are four in a row horizontal vv
		elsif occupied (i, j) = occupied (i - 1, j) and occupied (i, j) = occupied (i - 2, j) and occupied (i, j) = occupied (i - 3, j) then
		    q := i
		    w := j
		    numMatch := 4
		    kind := "hor"
		    match := true
		    % vv checks if there are three in a row horizontal vv
		elsif occupied (i, j) = occupied (i - 1, j) and occupied (i, j) = occupied (i - 2, j) then % checks if there are three in a row horizontal
		    q := i
		    w := j
		    numMatch := 3
		    kind := "hor"
		    match := true
		end if
	    end if
	    exit when match
	end for
	exit when match
    end for
    % checks if there are vertical matches
    for decreasing i : 8 .. 1         % checks the 8x6 grid of gems on the top
	for decreasing j : 8 .. 3
	    if j = 3 then             % if the y value is 6 then check if there is 3 in a row
		% vv checks if there are three in a row vertical vv
		if occupied (i, j) = occupied (i, j - 1) and occupied (i, j) = occupied (i, j - 2) then
		    q := i
		    w := j
		    numMatch := 3
		    kind := "ver"
		    match := true
		end if
	    elsif j = 4 then          % if the y value is 5 then check if there is 3 or 4 in a row
		% vv checks if there are four in a row vertical vv
		if occupied (i, j) = occupied (i, j - 1) and occupied (i, j) = occupied (i, j - 2) and occupied (i, j) = occupied (i, j - 3) then
		    q := i
		    w := j
		    numMatch := 4
		    kind := "ver"
		    match := true
		    % vv checks if there are three in a row vertical vv
		elsif occupied (i, j) = occupied (i, j - 1) and occupied (i, j) = occupied (i, j - 2) then
		    q := i
		    w := j
		    numMatch := 3
		    kind := "ver"
		    match := true
		end if
	    else                      % if the y value is else then check if there is 3, 4 or 5 in a row
		% vv checks if there are five in a row vertical vv
		if occupied (i, j) = occupied (i, j - 1) and occupied (i, j) = occupied (i, j - 2) and occupied (i, j) = occupied (i, j - 3) and occupied (i, j) = occupied (i, j - 4) then
		    q := i
		    w := j
		    numMatch := 5
		    kind := "ver"
		    match := true
		    % vv checks if there are four in a row vertical vv
		elsif occupied (i, j) = occupied (i, j - 1) and occupied (i, j) = occupied (i, j - 2) and occupied (i, j) = occupied (i, j - 3) then
		    q := i
		    w := j
		    numMatch := 4
		    kind := "ver"
		    match := true
		    % vv checks if there are three in a row vertical vv
		elsif occupied (i, j) = occupied (i, j - 1) and occupied (i, j) = occupied (i, j - 2) then
		    q := i
		    w := j
		    numMatch := 3
		    kind := "ver"
		    match := true
		end if
	    end if
	    exit when match
	end for
	exit when match
    end for
end checkMatch



% switches the two selected gems
proc switch (x1, y1, x2, y2 : int)
    var temp : int := occupied (x1, y1)             % saves the first clicked gem into temp
    Sprite.ChangePic (sprite (x1, y1), pic (occupied (x2, y2))) % changes first gem to second
    occupied (x1, y1) := occupied (x2, y2)
    Sprite.Show (sprite (x1, y1))
    Sprite.ChangePic (sprite (x2, y2), pic (temp))              % changes second gem to second
    occupied (x2, y2) := temp
    Sprite.Show (sprite (x2, y2))
end switch

var c : int                    % how many clicks the user clicked
var hintx, hinty : int
var gameOver : boolean
proc checkSolution
    var temp : int             % temporary variable
    for i : 1 .. 7             % switches gems horizontally
	for j : 1 .. 8
	    temp := occupied (i, j)             % switches two gems beside each other
	    occupied (i, j) := occupied (i + 1, j)
	    occupied (i + 1, j) := temp
	    match := false
	    checkMatch             % checks if the switched gems would make a match
	    occupied (i + 1, j) := occupied (i, j) % switches two gems back
	    occupied (i, j) := temp
	    if match then          % if a match was found after switching then
		hintx := i         % assign the hints
		hinty := j
		gameOver := false  % it is not game over
		exit
	    else
		gameOver := true   % if there are no matches then it's gameover
	    end if
	end for
	exit when gameOver = false
    end for
    for i : 1 .. 8                 % switches gems vertically
	exit when gameOver = false
	for j : 1 .. 7
	    temp := occupied (i, j)
	    occupied (i, j) := occupied (i, j + 1)
	    occupied (i, j + 1) := temp
	    match := false
	    checkMatch
	    occupied (i, j + 1) := occupied (i, j)
	    occupied (i, j) := temp
	    if match then
		hintx := i
		hinty := j
		gameOver := false
		exit
	    else
		gameOver := true
	    end if
	end for
    end for
end checkSolution

var font : int := Font.New ("Adobe Fangsong Std R:25")  % font for the points
var font2 : int := Font.New ("Adobe Fangsong Std R:12") % font for the level
var remain : int := 0             % needed to calculate the points receive for the current level
var levelpts : int := 0           % the points of all of the previous levels combined

% this procedure outputs the points on the screen
proc outpoints
    var offset : int := (length (intstr (points)))           % offset depending on digits in the points
    var offsetlv : int := (length (intstr (lv)))             % offset depending on digits in the level
    Pic.ScreenLoad ("gamescreen.jpg", 625, 50, picMerge)     % the picture on the right (points bar and buttons)
    % points not too much
    if points > 0 then            % if points is over zero
	if remain = ((lv * 450) + (100 * lv)) or remain > ((lv * 450) + (100 * lv)) then % if the points is over the level limit
	    if lv < 100 then      % if the level is less than 100
		Draw.FillBox (50, 10, ((560 / ((lv * 450) + (100 * lv)) * 100) div 1) * ((lv * 450) + (100 * lv)) div 100 + 50, 45, yellow)
		% ^box for level progression bar % fill the whole bar ^
		Music.PlayFileReturn ("LevelUp.wav")
		% sets new gems
		for i : 1 .. 8             % the x values
		    for j : 1 .. 8         % the y values
			randint (n, 1, 7)  % randomly pics a gem
			Sprite.Free (sprite (i, j))  % frees the previous gems
			sprite (i, j) := Sprite.New (pic (n))  %assigns a sprite to a gem
			Sprite.SetPosition (sprite (i, j), 58 + ((i - 1) * 70), 58 + ((j - 1) * 70), false) % sets the sprite on the board
			Sprite.Show (sprite (i, j))
			occupied (i, j) := n         % sets the occupied value as the picture number
		    end for
		end for
		loop                       % needed to set the new game board so that there arent any matches
		    checkMatch
		    if match then
			pushDown (q, w, numMatch, kind)
		    else
			exit
		    end if
		end loop
		for i : 1 .. 8             % hide all gems
		    for j : 1 .. 8
			Sprite.Hide (sprite (i, j))
		    end for
		end for
		Pic.ScreenLoad ("gamescreen.jpg", 625, 50, picMerge) % loads the screen on the right
		Font.Draw (intstr (points), 820 - ((offset - 1) * 20), 545, font, white) % outputs the points
		Font.Draw (intstr (lv), 755 - ((offsetlv - 1) * 5), 510, font2, white)   % outputs the level
		for i : 0 .. 80            % animate "level up"
		    Pic.ScreenLoad ("gameboard.jpg", 50, 50, picMerge)
		    Font.Draw ("Level Complete!", 160, 150 + (i * 2), font3, 43)
		    delay (1)
		end for
		numMatch := 0              % so that the gems will not flash after
		kind := "hello"            % so that the gmes will not push down after
		levelpts += ((lv * 450) + (100 * lv)) % adds the points needed to pass level to this variable
		lv += 1                    % adds one level
		% if the points received went over the limit
		remain := points - levelpts % finds how much over the limit it was and adds it to the next level
		Pic.ScreenLoad ("gameboard.jpg", 50, 50, picMerge) % the game board
		Draw.FillBox (50, 10, 610, 45, 54)                 % covers up the previous progress bar
		Draw.FillBox (50, 10, ((560 / ((lv * 450) + (100 * lv)) * 100) div 1) * ((lv * 450) + (100 * lv)) div 100 + 50, 45, red)             % box for level progression bar
		Draw.FillBox (50, 10, ((560 / ((lv * 450) + (100 * lv)) * 100) div 1) * (remain div 100) + 50, 45, yellow) % level progress
		% ((560(length of the bar) / (points needed to pass level)*100 div 1(in order to incorporate the decimals)*(remain div 100)+50(offset))
		for i : 1 .. 8             % shows the gems
		    for j : 1 .. 8
			Sprite.Show (sprite (i, j))
		    end for
		end for
	    else              % if the level is not lower thanm 100 then
		lv += 1       % adds one level
	    end if
	end if
	Draw.FillBox (50, 10, ((560 / ((lv * 450) + (100 * lv)) * 100) div 1) * (remain div 100) + 50, 45, yellow) % level progress
	% ((560(length of the bar) / (points needed to pass level)*100 div 1(in order to incorporate the decimals)*(remain div 100)+50(offset))
    end if
    Pic.ScreenLoad ("gamescreen.jpg", 625, 50, picMerge)                      % loads the screen on the right
    Font.Draw (intstr (points), 820 - ((offset - 1) * 20), 545, font, white)  % outputs the points
    Font.Draw (intstr (lv), 755 - ((offsetlv - 1) * 5), 510, font2, white)    % outputs the level
    %delay (100)
end outpoints

% to know when to exit the game
var exitgame : boolean := false

% what's onscreen when menu is pressed on the game screen
proc optionsMenuGame
    exitgame := false
    cls
    GUI.SetBackgroundColour (black)
    % options menu picture
    Pic.Draw (picID1 (10), 310, 230, picCopy)
    % two inits to false weather to continue game, or exit
    menuPress := false
    var endGamePress : boolean := false
    % loops until one of the proper/specified buttons is clicked
    loop
	if Mouse.ButtonMoved ("down") then
	    Mouse.ButtonWait ("down", x, y, btnNum, btnUpDown)
	    % returns to/resumes the game
	    if x > 328 and x < 537 and y > 455 and y < 509 then
		cls
		menuPress := true
		% calles on the proc settings to turn music on or off
	    elsif x > 328 and x < 537 and y > 390 and y < 440 then
		cls
		settings
		% brings in the help screen procedure, press resume to exit
	    elsif x > 328 and x < 537 and y > 324 and y < 374 then
		cls
		help
		% option to go back to main menu
	    elsif x > 328 and x < 537 and y > 257 and y < 307 then
		cls
		GUI.SetBackgroundColour (black)
		% asks if player really wants to exit the game
		Pic.Draw (picID1 (11), 290, 280, picCopy)
		loop
		    if Mouse.ButtonMoved ("down") then
			Mouse.ButtonWait ("down", x, y, btnNum, btnUpDown)
			% if person clicks yes than endGamePress become true
			if x > 310 and x < 423 and y > 304 and y < 355 then
			    endGamePress := true
			    cls
			    % person presses no, then runs the optionsMenuGame proc again...
			    % press resume game is only way to continue the current game
			elsif x > 445 and x < 550 and y > 305 and y < 355 then
			    optionsMenuGame
			end if
		    end if
		    % exits the loop when a button that makes menuPress or endGamePress true is pressed
		    exit when menuPress or endGamePress
		end loop
	    end if
	end if
	% exits the loop when a button that makes menuPress or endGamePress true is pressed
	exit when menuPress or endGamePress
    end loop
    GUI.Refresh
    % if menuPress is true then continue the current game
    if menuPress then
	GUI.SetBackgroundColour (54)
	Pic.ScreenLoad ("gameboard.jpg", 50, 50, picMerge)
	Pic.ScreenLoad ("gamescreen.jpg", 625, 50, picMerge)
	Draw.FillBox (50, 10, ((560 / ((lv * 450) + (100 * lv)) * 100) div 1) * ((lv * 450) + (100 * lv)) div 100 + 50, 45, red)             % box for level progression bar
	Draw.FillBox (50, 10, ((560 / ((lv * 450) + (100 * lv)) * 100) div 1) * (remain div 100) + 50, 45, yellow)             % level progress
	outpoints
	% else exits game, asks for player info, and outputs the score
	% buttons to see different ranks, and scores sorting info
    else
	cls
	exitgame := true
	cls
    end if
end optionsMenuGame

% this procedure finds the x and y values of the gems that are being clicked
proc findMouse
    c := 1
    loop
	exit when exitgame
	exit when c > 2                    % exit after two clicks
	if Mouse.ButtonMoved ("down") then
	    Mouse.ButtonWait ("down", x, y, btnNum, btnUpDown)
	    Sprite.Hide (hint)
	    % if the click is on the game board
	    if x < 611 and x > 49 and y < 611 and y > 49 then
		x := x - 50                % sets the origin to the bottom left corner of the game board
		y := y - 50
		for i : 1 .. 8             % finds the x co-ordinate value of the gem on the game board
		    if x < 70 * i then
			x := i
			exit
		    end if
		end for
		for i : 1 .. 8
		    if y < 70 * i then
			y := i             % finds the y co-ordinate value of the gem on the game board
			exit
		    end if
		end for
		if c = 2 then              % if this is the 2nd gem selection
		    % if 2nd gem is adjacent to the first gem then
		    if (x = x1 and (y - 1 = y1 or y + 1 = y1)) or (y = y1 and (x - 1 = x1 or x + 1 = x1)) then
			x2 := x
			y2 := y
			c += 1             % the user selected +1 gems
			Sprite.SetPosition (select2, 50 + (70 * (x - 1)), 50 + (70 * (y - 1)), false)
			Sprite.Show (select2)
		    elsif x1 = x and y1 = y then             % if the gem was clicked again
			Sprite.Hide (select)
			c := 1             % resets click counter
		    else                   % if the 2nd gem is not adjacent to the first gem
			x1 := x            % this is now the first gem
			y1 := y            % x1 and y1 values are changed
			Sprite.SetPosition (select, 50 + (70 * (x - 1)), 50 + (70 * (y - 1)), false)
			Sprite.Show (select)
			c := 2             % cancel them both out
		    end if
		elsif c = 1 then           % assign the x,y values if its the first click
		    x1 := x
		    y1 := y
		    c += 1
		    Sprite.SetPosition (select, 50 + (70 * (x - 1)), 50 + (70 * (y - 1)), false)
		    Sprite.Show (select)
		end if
		% elsif the mouse is on "menu"
	    elsif x > 711 and y > 239 and x < 806 and y < 311 then
		for i : 1 .. 8             % hides all sprites
		    for j : 1 .. 8
			Sprite.Hide (sprite (i, j))
		    end for
		end for
		Sprite.Hide (select)
		Sprite.Hide (select2)
		optionsMenuGame
		for i : 1 .. 8             % show all sprites
		    for j : 1 .. 8
			Sprite.Show (sprite (i, j))
		    end for
		end for
	    elsif x > 679 and y > 109 and x < 841 and y < 221 then % if the mouse is on the hint button
		if remain > 0 then   % if the player achieve more than 0 points this level
		    remain -= 100    % subtract 100 points for each hint pressed
		    points -= 100
		end if
		% vv updates the progress bar and pointsvv
		Draw.FillBox (50, 10, ((560 / ((lv * 450) + (100 * lv)) * 100) div 1) * ((lv * 450) + (100 * lv)) div 100 + 50, 45, red)
		Draw.FillBox (50, 10, ((560 / ((lv * 450) + (100 * lv)) * 100) div 1) * (remain div 100) + 50, 45, yellow)
		Pic.ScreenLoad ("gamescreen.jpg", 625, 50, picMerge)
		Font.Draw (intstr (lv), 755 - (((length (intstr (lv))) - 1) * 5), 510, font2, white)                 % outputs the level
		Font.Draw (intstr (points), 820 - (((length (intstr (points))) - 1) * 20), 545, font, white)                 % outputs the points
		Sprite.SetPosition (hint, 40 + (70 * (hintx - 1)), 40 + (70 * (hinty - 1)), false)
		Sprite.Show (hint)
		delay (100)
		Sprite.Hide (hint)
		delay (100)
		Sprite.Show (hint)
	    end if
	end if
    end loop
end findMouse


var font1 : int := Font.New ("Augie:70") % font used for "game over"
% this procedure is the main game
proc game
    loop                % loops entire program
	points := 0     % sets points to zero
	lv := 1         % sets level to one
	remain := 0     % so far in the level there has been 0 points
	levelpts := 0   % all of the points of the previous levels is zero
	x1 := 1         % sets the x and y 1,2 variables
	y1 := 1
	x2 := 1
	y2 := 1
	GUI.SetBackgroundColour (54) %loads background
	Pic.ScreenLoad ("gameboard.jpg", 50, 50, picMerge)
	Draw.FillBox (50, 10, ((560 / ((lv * 450) + (100 * lv)) * 100) div 1) * ((lv * 450) + (100 * lv)) div 100 + 50, 45, red)             % progress bar
	% sets the gems on the grid
	for i : 1 .. 8             % the x values
	    for j : 1 .. 8         % the y values
		randint (n, 1, 7)  % randomly pics a gem
		sprite (i, j) := Sprite.New (pic (n))  %assigns a sprite to a gem
		Sprite.SetPosition (sprite (i, j), 58 + ((i - 1) * 70), 58 + ((j - 1) * 70), false) % sets the sprite on the board
		Sprite.Show (sprite (i, j))
		occupied (i, j) := n % sets the occupied value as the picture number
	    end for
	end for
	outpoints
	loop                       % needed to set the initial game board
	    checkMatch
	    if match then
		pushDown (q, w, numMatch, kind)
	    else
		exit
	    end if
	end loop
	checkSolution              % checks a solution for hint
	loop                       % loops playing the game
	    findMouse              % finds mouse's location
	    exit when exitgame
	    switch (x1, y1, x2, y2) % switched the two selected gems
	    checkMatch             % checks if there is a match
	    if match then          % if theres a match then
		delay (50)
		Sprite.Hide (select)
		Sprite.Hide (select2)
		flashMatch (q, w, numMatch, kind) % flash the match
		pushDown (q, w, numMatch, kind)  % push down
		if numMatch = 3 then             % adds points according to number of gems in match
		    points += 100
		    remain += 100
		elsif numMatch = 4 then
		    points += 300
		    remain += 300
		elsif numMatch = 5 then
		    points += 1000
		    remain += 1000
		end if
		outpoints          % outputs the points
		exit when lv > 100 % if the level is over 100 then exit game
	    else                   % if there isnt a match
		for i : 1 .. 3     % flash the unmatched
		    Sprite.Hide (sprite (x1, y1))
		    Sprite.Hide (sprite (x2, y2))
		    delay (100)
		    Sprite.Show (sprite (x1, y1))
		    Sprite.Show (sprite (x2, y2))
		    delay (100)
		end for
		switch (x1, y1, x2, y2) % switches them back
		Sprite.Hide (select)
		Sprite.Hide (select2)
	    end if
	    loop                   % finds anymore matches
		exit when lv > 100
		checkMatch
		exit when match = false
		if numMatch = 3 then    % adds points according to number of gems in match
		    points += 100
		    remain += 100
		elsif numMatch = 4 then
		    points += 300
		    remain += 300
		elsif numMatch = 5 then
		    points += 1000
		    remain += 1000
		end if
		outpoints               % outputs the points
		flashMatch (q, w, numMatch, kind)
		pushDown (q, w, numMatch, kind)
	    end loop
	    exit when lv > 100
	    checkSolution               % finds the next hint
	    if gameOver then            % if there is no hint and it's game over then
		for k : 1 .. 5          % flash all gems
		    for i : 1 .. 8
			for j : 1 .. 8
			    Sprite.Hide (sprite (i, j)) % hide all sprites
			end for
		    end for
		    delay (100)
		    for i : 1 .. 8
			for j : 1 .. 8
			    Sprite.Show (sprite (i, j)) % hide all sprites
			end for
		    end for
		end for
		Music.PlayFileReturn ("GameOver.wav")
		Font.Draw ("Game Over!", 125, 300, font1, white) % output game over
		delay (2000)
		cls
		exit
	    end if
	end loop
	exit when exitgame
	exit when gameOver
	exit when lv > 100
    end loop
    for i : 1 .. 8
	for j : 1 .. 8
	    Sprite.Hide (sprite (i, j)) % hide all sprite
	end for
    end for
end game


% menu
proc menu
    var gamePress, optionsPress, scorePress, endProg : boolean := false
    % Draw.FillBox(290 ,430, 608, 543 , red)
    loop
	cls
	GUI.SetBackgroundColour (cyan)
	% brings in background picture
	Pic.Draw (picID1 (6), 50, 20, picCopy)
	loop
	    % redeclares follwing booleans as false for future use of the var
	    endProg := false
	    menuPress := false
	    exitgame := false
	    % outputs the title
	    Font.Draw ("Gem Match 2010", 290, 645, font5, purple)
	    Font.Draw ("MENU", 410, 645, font6, brightred)
	    % puts the option buttons on the screen
	    Pic.Draw (picID1 (1), 290, 430, picMerge)
	    Pic.Draw (picID1 (2), 140, 200, picMerge)
	    Pic.Draw (picID1 (3), 610, 200, picMerge)
	    Pic.Draw (picID1 (14), 315, 110, picMerge)
	    % if any mouse button is clicked then
	    if Mouse.ButtonMoved ("down") then
		Mouse.ButtonWait ("down", x, y, btnNum, btnUpDown)
		% checks for the x and y values at the clicked position to see if it is inside any of the buttons
		% if its inside the following perimeters than proc scoresMenu runs
		if x > 139 and x < 306 and y > 199 and y < 281 then
		    scoresMenu
		    % after above proc runs than reput the background and the background picture
		    GUI.SetBackgroundColour (cyan)
		    Pic.Draw (picID1 (6), 50, 20, picCopy)
		    % if game button is pressed then
		elsif x > 289 and x < 611 and y > 429 and y < 544 then
		    View.Set ("offscreenonly")
		    cls
		    % runs the game which runs until gameover, or player returns to menu/gives up
		    game
		    % if the player has beat the entire game (100 levels) then hide the gameboard and pieces
		    if lv > 100 then
			for i : 1 .. 8
			    for j : 1 .. 8
				Sprite.Hide (sprite (i, j))
			    end for
			end for
			% and output the following
			Font.Draw ("Congratulations! You have NO life!", 15, 400, font3, white)
			Font.Draw ("LOL. xD.", 15, 350, font3, white)
			Font.Draw ("Thanks for playing", 15, 300, font3, brightred)
			% stays for a few seconds
			delay (5000)
		    end if
		    % asks player info, sorts various aspects of the scores/ranks and rewrites all the txt files,
		    together
		    % turns off screen mode 'offscreenonly'
		    View.Set ("graphics:900;700")
		    % after above proc runs than reput the background and the background picture
		    GUI.SetBackgroundColour (cyan)
		    Pic.Draw (picID1 (6), 50, 20, picCopy)
		    % when optiosMenu button is pressed then run that proc
		elsif x > 610 and x < 778 and y > 200 and y < 272 then
		    optionsMenu
		    % after above proc runs than reput the background and the background picture
		    GUI.SetBackgroundColour (cyan)
		    Pic.Draw (picID1 (6), 50, 20, picCopy)
		    % when exit game is pressed than endProg is true
		elsif x > 317 and x < 580 and y > 114 and y < 174 then
		    endProg := true
		end if
	    end if
	    % exits the loop when exit game is pressed
	    exit when endProg
	end loop
	% exits the loop when exit game is pressed
	exit when endProg
    end loop
end menu



Music.PlayFileLoop ("O Fortuna.mp3")             % at the start of the program, music begins playing
readFile                % reads the text file information to look through all previous games and information and store them in arrays
insertion               % assigns the top 10 into an array
menu                    % runs the menu which in turn runs the whole program (games, options, etc...)
Window.Close (winID)    % when proc menu is finished executing (when exit game is pressed) then close the main window
Music.PlayFileStop      % stops playing the song

