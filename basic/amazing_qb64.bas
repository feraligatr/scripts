' ******************************************************************
' *                                                                *
' * AMAZING.BAS rewritten in QB64                                  *
' *   by orochi115 (orochi115@gmail.com)                           *
' *                                                                *
' * Original program from book "Basic Computer Games"              *
' *   http://www.atariarchives.org/basicgames/showpage.php?page=3  *
' *                                                                *
' * You can get a typed copy at:                                   *
' *   http://www.vintage-basic.net/games.html                      *
' *                                                                *
' ******************************************************************

PRINT TAB(28); "AMAZING PROGRAM"
PRINT TAB(15); "CREATIVE COMPUTING  MORRISTOWN, NEW JERSEY"
PRINT
PRINT
PRINT
PRINT

DO
    INPUT "WHAT ARE YOUR WIDTH AND LENGTH"; mazeWidth, mazeHeight
    IF mazeWidth > 1 AND mazeHeight > 1 THEN
        EXIT DO
    END IF
    PRINT "MEANINGLESS DIMENSIONS.  TRY AGAIN."
LOOP

seed = INT(TIMER)
RANDOMIZE seed
' debug message that doesn't exist in original code
PRINT "USING RANDOM SEED: "; seed

' original array W
'   Mark if a grid is visited (>0) or not (=0).
' Value is the step number when each grid gets visited first time, the numbers are not used.
' Since QB64 doesn't have short-circuit logical operators, I prefer enlarging arrays to ugly nested-if's.
DIM visited(mazeWidth + 1, mazeHeight + 1)

' original array V
'   Represents the right and bottom walls of each grid.
' 0 - right close, bottom close
' 1 - right close, bottom open
' 2 - right open, bottom close
' 3 - right open, bottom open
DIM walls(mazeWidth + 1, mazeHeight + 1)

PRINT
PRINT
PRINT
PRINT

' original variable Q
mayExit = 0

' original variable Z
exitFound = 0

' original variable X
entrancePos = INT(RND(1) * mazeWidth + 1)

' Print the first line containing Entrance
FOR I = 1 TO mazeWidth
    IF entrancePos = I THEN
        PRINT ".  ";
    ELSE
        PRINT ".--";
    END IF
NEXT
PRINT "."

' Start traveling from the Entrance (entrancePos, 1)

' original variable C
' Count the amount of visited grids.
stepCount = 1

visited(entrancePos, 1) = stepCount
stepCount = stepCount + 1

' original variable R
curX = entrancePos

' original variable S
curY = 1

GOTO nextStep

findNextTaken:
' original line 210
' Travel from current grid, line by line, stop at the next visited grid.
' In fact it's ok to pick any visited grid. However, keeping a fixed direction is important to avoid infinite loop caused by bad luck, especially when it's almost done.
DO
    IF curX = mazeWidth THEN
        curX = 1
        IF curY = mazeHeight THEN
            curY = 1
        ELSE
            curY = curY + 1
        END IF
    ELSE
        curX = curX + 1
    END IF
    findNextWithoutMoveFirst:
LOOP WHILE visited(curX, curY) = 0

nextStep:
' original line 260

' Now we are standing at (curX, curY). Look at the neighbour grids.
'    .-.
'    |?|
'  .-+-+-.
'  |?|C|?|
'  .-+-+-.
'    |?|
'    .-.
'
' C - current grid (curX, curY), must be visited already.
' O - not visited yet: visited(x,y)=0
' X - out of the board, or already visited: x<=0 OR x>mazeWidth OR y<=0 OR y>mazeHeight OR visited(x,y)<>0
' ? - unknown

' original line 260
IF curX > 1 AND visited(curX - 1, curY) = 0 THEN
    ' original line 270
    '    .-.
    '    |?|
    '  .-+-+-.
    '  |O|C|?|
    '  .-+-+-.
    '    |?|
    '    .-.
    IF curY > 1 AND visited(curX, curY - 1) = 0 THEN
        ' original line 290
        '    .-.
        '    |O|
        '  .-+-+-.
        '  |O|C|?|
        '  .-+-+-.
        '    |?|
        '    .-.
        IF curX < mazeWidth AND visited(curX + 1, curY) = 0 THEN
            ' original line 310
            '    .-.
            '    |O|
            '  .-+-+-.
            '  |O|C|O|
            '  .-+-+-.
            '    |?|
            '    .-.
            ' The bottom grid must be already visited in this case. Or else where did we come from?
            X = INT(RND(1) * 3 + 1)
            ON X GOTO goLeft, goUp, goRight
        ELSE
            ' original line 330
            '    .-.
            '    |O|
            '  .-+-+-.
            '  |O|C|X|
            '  .-+-+-.
            '    |?|
            '    .-.
            IF curY = mazeHeight AND exitFound <> 1 THEN
                ' original line 338
                mayExit = 1
            END IF
            IF (curY = mazeHeight AND exitFound <> 1) OR (curY < mazeHeight AND visited(curX, curY + 1) = 0) THEN
                ' original line 350
                '    .-.            .-.
                '    |O|            |O|
                '  .-+-+-.        .-+-+-.
                '  |O|C|X|   OR   |O|C|X|
                '  .=+=+=.        .-+-+-.
                '                   |O|
                ' exitFound=0       .-.
                X = INT(RND(1) * 3 + 1)
                ON X GOTO goLeft, goUp, goDownOrExit
            ELSE ' (curY = mazeHeight AND exitFound = 1) OR (curY < mazeHeight AND visited(curX, curY + 1) <> 0)
                ' original line 370
                '    .-.            .-.
                '    |O|            |O|
                '  .-+-+-.        .-+-+-.
                '  |O|C|X|   OR   |O|C|X|
                '  .=+=+=.        .-+-+-.
                '                   |X|
                ' exitFound=1       .-.
                X = INT(RND(1) * 2 + 1)
                ON X GOTO goLeft, goUp
            END IF
        END IF
    ELSE
        ' original line 390
        '    .-.
        '    |X|
        '  .-+-+-.
        '  |O|C|?|
        '  .-+-+-.
        '    |?|
        '    .-.
        IF curX < mazeWidth AND visited(curX + 1, curY) = 0 THEN
            ' original line 405
            '    .-.
            '    |X|
            '  .-+-+-.
            '  |O|C|O|
            '  .-+-+-.
            '    |?|
            '    .-.
            IF curY = mazeHeight AND exitFound <> 1 THEN
                ' original line 415
                mayExit = 1
            END IF
            IF (curY = mazeHeight AND exitFound <> 1) OR (curY < mazeHeight AND visited(curX, curY + 1) = 0) THEN
                ' original line 430
                '    .-.            .-.
                '    |X|            |X|
                '  .-+-+-.        .-+-+-.
                '  |O|C|O|   OR   |O|C|O|
                '  .=+=+=.        .-+-+-.
                '                   |O|
                ' exitFound=0       .-.
                X = INT(RND(1) * 3 + 1)
                ON X GOTO goLeft, goRight, goDownOrExit
            ELSE ' (curY = mazeHeight AND exitFound = 1) OR (curY < mazeHeight AND visited(curX, curY + 1) <> 0)
                ' original line 450
                '    .-.            .-.
                '    |X|            |X|
                '  .-+-+-.        .-+-+-.
                '  |O|C|O|   OR   |O|C|O|
                '  .=+=+=.        .-+-+-.
                '                   |X|
                ' exitFound=1       .-.
                X = INT(RND(1) * 2 + 1)
                ON X GOTO goLeft, goRight
            END IF
        ELSE
            ' original line 470
            '    .-.
            '    |X|
            '  .-+-+-.
            '  |O|C|X|
            '  .-+-+-.
            '    |?|
            '    .-.
            IF curY = mazeHeight AND exitFound <> 1 THEN
                ' original line 485
                mayExit = 1
            END IF
            IF (curY = mazeHeight AND exitFound <> 1) OR (curY < mazeHeight AND visited(curX, curY + 1) = 0) THEN
                ' original line 500
                '    .-.            .-.
                '    |X|            |X|
                '  .-+-+-.        .-+-+-.
                '  |O|C|X|   OR   |O|C|X|
                '  .=+=+=.        .-+-+-.
                '                   |O|
                ' exitFound=0       .-.
                X = INT(RND(1) * 2 + 1)
                ON X GOTO goLeft, goDownOrExit
            ELSE ' (curY = mazeHeight AND exitFound = 1) OR (curY < mazeHeight AND visited(curX, curY + 1) <> 0)
                ' original line 520
                '    .-.            .-.
                '    |X|            |X|
                '  .-+-+-.        .-+-+-.
                '  |O|C|X|   OR   |O|C|X|
                '  .=+=+=.        .-+-+-.
                '                   |X|
                ' exitFound=1       .-.
                GOTO goLeft
            END IF
        END IF
    END IF
ELSE
    leftIsTaken:
    ' original line 530
    '    .-.
    '    |?|
    '  .-+-+-.
    '  |X|C|?|
    '  .-+-+-.
    '    |?|
    '    .-.
    IF curY > 1 AND visited(curX, curY - 1) = 0 THEN
        ' original line 545
        '    .-.
        '    |O|
        '  .-+-+-.
        '  |X|C|?|
        '  .-+-+-.
        '    |?|
        '    .-.
        IF curX < mazeWidth AND visited(curX + 1, curY) = 0 THEN
            ' original line 550
            '    .-.
            '    |O|
            '  .-+-+-.
            '  |X|C|O|
            '  .-+-+-.
            '    |?|
            '    .-.
            IF curY = mazeHeight AND exitFound <> 1 THEN
                ' original line 554
                mayExit = 1
            END IF
            IF (curY = mazeHeight AND exitFound <> 1) OR (curY < mazeHeight AND visited(curX, curY + 1) = 0) THEN
                ' original line 570
                '    .-.            .-.
                '    |O|            |O|
                '  .-+-+-.        .-+-+-.
                '  |X|C|O|   OR   |X|C|O|
                '  .=+=+=.        .-+-+-.
                '                   |O|
                ' exitFound=0       .-.
                X = INT(RND(1) * 3 + 1)
                ON X GOTO goUp, goRight, goDownOrExit
            ELSE ' (curY = mazeHeight AND exitFound = 1) OR (curY < mazeHeight AND visited(curX, curY + 1) <> 0)
                ' original line 590
                '    .-.            .-.
                '    |O|            |O|
                '  .-+-+-.        .-+-+-.
                '  |X|C|O|   OR   |X|C|O|
                '  .=+=+=.        .-+-+-.
                '                   |X|
                ' exitFound=1       .-.
                X = INT(RND(1) * 2 + 1)
                ON X GOTO goUp, goRight
            END IF
        ELSE
            ' original line 610
            '    .-.
            '    |O|
            '  .-+-+-.
            '  |X|C|X|
            '  .-+-+-.
            '    |?|
            '    .-.
            IF curY = mazeHeight AND exitFound <> 1 THEN
                ' original line 625
                mayExit = 1
            END IF
            IF (curY = mazeHeight AND exitFound <> 1) OR (curY < mazeHeight AND visited(curX, curY + 1) = 0) THEN
                ' original line 640
                '    .-.            .-.
                '    |O|            |O|
                '  .-+-+-.        .-+-+-.
                '  |X|C|X|   OR   |X|C|X|
                '  .=+=+=.        .-+-+-.
                '                   |O|
                ' exitFound=0       .-.
                X = INT(RND(1) * 2 + 1)
                ON X GOTO goUp, goDownOrExit
            ELSE ' (curY = mazeHeight AND exitFound = 1) OR (curY < mazeHeight AND visited(curX, curY + 1) <> 0)
                ' original line 660
                '    .-.            .-.
                '    |O|            |O|
                '  .-+-+-.        .-+-+-.
                '  |X|C|X|   OR   |X|C|X|
                '  .=+=+=.        .-+-+-.
                '                   |X|
                ' exitFound=1       .-.
                GOTO goUp
            END IF
        END IF
    ELSE
        ' original line 670
        '    .-.
        '    |X|
        '  .-+-+-.
        '  |X|C|?|
        '  .-+-+-.
        '    |?|
        '    .-.
        IF curX < mazeWidth AND visited(curX + 1, curY) = 0 THEN
            ' original line 685
            '    .-.
            '    |X|
            '  .-+-+-.
            '  |X|C|O|
            '  .-+-+-.
            '    |?|
            '    .-.
            IF curY = mazeHeight AND exitFound <> 1 THEN
                ' original line 695
                ' The original code has a bug.
                '   695 Q=1:GOTO 830
                ' should be:
                '   695 Q=1:GOTO 710
                mayExit = 1
            END IF
            IF (curY = mazeHeight AND exitFound <> 1) OR (curY < mazeHeight AND visited(curX, curY + 1) = 0) THEN
                ' original line 710
                '    .-.            .-.
                '    |X|            |X|
                '  .-+-+-.        .-+-+-.
                '  |X|C|O|   OR   |X|C|O|
                '  .=+=+=.        .-+-+-.
                '                   |O|
                ' exitFound=0       .-.
                X = INT(RND(1) * 2 + 1)
                ON X GOTO goRight, goDownOrExit
            ELSE ' (curY = mazeHeight AND exitFound = 1) OR (curY < mazeHeight AND visited(curX, curY + 1) <> 0)
                ' original line 730
                '    .-.            .-.
                '    |X|            |X|
                '  .-+-+-.        .-+-+-.
                '  |X|C|O|   OR   |X|C|O|
                '  .=+=+=.        .-+-+-.
                '                   |X|
                ' exitFound=1       .-.
                GOTO goRight
            END IF
        ELSE
            ' original line 740
            '    .-.
            '    |X|
            '  .-+-+-.
            '  |X|C|X|
            '  .-+-+-.
            '    |?|
            '    .-.
            IF curY = mazeHeight AND exitFound <> 1 THEN
                ' original line 755
                mayExit = 1
            END IF
            IF (curY = mazeHeight AND exitFound <> 1) OR (curY < mazeHeight AND visited(curX, curY + 1) = 0) THEN
                ' original line 770
                '    .-.            .-.
                '    |X|            |X|
                '  .-+-+-.        .-+-+-.
                '  |X|C|X|   OR   |X|C|X|
                '  .=+=+=.        .-+-+-.
                '                   |O|
                ' exitFound=0       .-.
                GOTO goDownOrExit
            ELSE ' (curY = mazeHeight AND exitFound = 1) OR (curY < mazeHeight AND visited(curX, curY + 1) <> 0)
                ' original line 780
                '    .-.            .-.
                '    |X|            |X|
                '  .-+-+-.        .-+-+-.
                '  |X|C|X|   OR   |X|C|X|
                '  .=+=+=.        .-+-+-.
                '                   |X|
                ' exitFound=1       .-.
                GOTO findNextTaken
            END IF
        END IF
    END IF
END IF

goLeft:
' original line 790
'    .-.            .-.
'    | ?            | ?
'  .-+?+-.        .-+?+-.
'  |0|C? ?   =>   |2  ? ?
'  .-+?+?.        .-+?+?.
'    | ?            | ?
'    .?.            .?.
visited(curX - 1, curY) = stepCount
stepCount = stepCount + 1
' Break the right wall of the left grid (curX-1,curY).
' walls(curX-1,curY) must be 0 now. Or else (curX-1,curY) should have already been visited from right (curX,curY) or below (curX-1,curY+1), then visited(curX-1,curY) should be >0 before goLeft was called, which is impossible here.
walls(curX - 1, curY) = 2
curX = curX - 1
IF stepCount = mazeWidth * mazeHeight + 1 THEN
    GOTO finishMap
END IF
mayExit = 0
GOTO nextStep

goUp:
' original line 820
'    .-.            .-.
'    |0|            |1|
'  .-+-+-.        .-+ +-.
'  | ?C? ?   =>   | ? ? ?
'  .?+?+?.        .?+?+?.
'    | ?            | ?
'    .?.            .?.
visited(curX, curY - 1) = stepCount
stepCount = stepCount + 1
' Break the bottom wall of the above grid (curX,curY-1).
' walls(curX,curY-1) must be 0 now. Or else (curX,curY-1) should have already been visited from right (curX+1,curY-1) or below (curX,curY), then visited(curX,curY-1) should be >0 before goUp was called, which is impossible here.
walls(curX, curY - 1) = 1
curY = curY - 1
IF stepCount = mazeWidth * mazeHeight + 1 THEN
    GOTO finishMap
END IF
mayExit = 0
GOTO nextStep

goRight:
' original line 860
visited(curX + 1, curY) = stepCount
stepCount = stepCount + 1
' Break the right wall of current grid (curX, curY).
IF walls(curX, curY) = 0 THEN
    '    .-.            .-.
    '    | ?            | ?
    '  .-+?+-.        .-+?+-.
    '  | ?0| ?   =>   | ?2 C?
    '  .?+-+?.        .?+-+?.
    '    | ?            | ?
    '    .?.            .?.
    walls(curX, curY) = 2
ELSE
    '    .-.            .-.
    '    | ?            | ?
    '  .-+?+-.        .-+?+-.
    '  | ?1| ?   =>   | ?3 C?
    '  .?+ +?.        .?+ +?.
    '    | ?            | ?
    '    .?.            .?.
    ' walls(curX,curY) must be 1 now. Or else (curX,curY) should have already been visited from right (curX+1,curY), or to right previously before goRight was called this time, which is impossible here.
    walls(curX, curY) = 3
END IF
curX = curX + 1
IF stepCount = mazeWidth * mazeHeight + 1 THEN
    GOTO finishMap
END IF
mayExit = 0
' Since we have just moved from left, there's no need to check if left is taken.
GOTO leftIsTaken

goDownOrExit:
' original line 910
IF mayExit <> 1 THEN
    ' original line 920
    visited(curX, curY + 1) = stepCount
    stepCount = stepCount + 1
    ' Break the bottom wall of current grid (curX, curY).
    IF walls(curX, curY) = 0 THEN
        '    .-.            .-.
        '    | ?            | ?
        '  .-+?+-.        .-+?+-.
        '  | ?0| ?   =>   | ?1| ?
        '  .?+-+?.        .?+ +?.
        '    | ?            |C?
        '    .?.            .?.
        walls(curX, curY) = 1
    ELSE
        '    .-.            .-.
        '    | ?            | ?
        '  .-+?+-.        .-+?+-.
        '  | ?2  ?   =>   | ?3  ?
        '  .?+-+?.        .?+ +?.
        '    | ?            |C?
        '    .?.            .?.
        ' walls(curX,curY) must be 2 now. Or else (curX,curY) should have already been visited from below (curX,curY+1), or to below previously before goDownOrExit was called this time, which is impossible here.
        walls(curX, curY) = 3
    END IF
    curY = curY + 1
    IF stepCount = mazeWidth * mazeHeight + 1 THEN
        GOTO finishMap
    END IF
ELSE
    ' original line 960
    exitFound = 1
    mayExit = 0
    IF walls(curX, curY) = 0 THEN
        '    .-.            .-.
        '    | ?            | ?
        '  .-+?+-.        .-+?+-.
        '  | ?0| ?   =>   | ?1| ?
        '  .=+=.=.        .=+ +=.
        walls(curX, curY) = 1
        curX = 1
        curY = 1
        GOTO findNextWithoutMoveFirst
    ELSE
        '    .-.            .-.
        '    | ?            | ?
        '  .-+?+-.        .-+?+-.
        '  | ?2  ?   =>   | ?3  ?
        '  .=+=.=.        .=+ +=.
        walls(curX, curY) = 3
    END IF
END IF
GOTO nextStep

finishMap:

' Original program has a bug, may cause no exit.
' To fix it, first rename all lines after (including) 1010, from 10XX to 11XX. Then add these:
'   1010 IF Z=1 THEN 1110
'   1015 IF S=V THEN 1025
'   1020 X=INT(RND(1)*H+1):GOTO 1030
'   1025 X=R
'   1030 IF V(X,H)=0 THEN 1050
'   1040 V(X,H)=3:GOTO 1110
'   1050 V(X,H)=1
IF exitFound <> 1 THEN
    IF curY = mazeHeight THEN
        exitPos = curX
    ELSE
        exitPos = INT(RND(1) * mazeWidth + 1)
    END IF
    IF walls(exitPos, mazeHeight) = 0 THEN
        walls(exitPos, mazeHeight) = 1
    ELSE
        walls(exitPos, mazeHeight) = 3
    END IF
END IF

' Print final results
' original line 1010 (1110 after renaming)
FOR J = 1 TO mazeHeight
    PRINT "I";
    FOR I = 1 TO mazeWidth
        IF walls(I, J) < 2 THEN
            PRINT "  I";
        ELSE
            PRINT "   ";
        END IF
    NEXT I
    PRINT
    FOR I = 1 TO mazeWidth
        IF walls(I, J) = 0 OR walls(I, J) = 2 THEN
            PRINT ":--";
        ELSE
            PRINT ":  ";
        END IF
    NEXT I
    PRINT "."
NEXT J
