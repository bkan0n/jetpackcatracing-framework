#!mainFile "main.opy"

# Global variables
# Map Data
globalvar Checkpoints 0
globalvar RingSize 10

# Customization
globalvar CreatorName 20
globalvar MapCode 21
globalvar ColorConfig 22
# globalvar GoalText 23

# Workshop Settings
globalvar RestartLobbyTime 50
globalvar ServerTimeElapsed 51
globalvar EditorOn 52

# HUD Related
globalvar LeaderboardText 60 # txt entities
globalvar LeaderboardEntries 61 # # [ [name, time] ]
globalvar LeaderboardRemake 62 # trigger remake leaderboard

# Plugins
globalvar MapVectorArray 127 # Little Destructo | Fence breaker
globalvar TestBotArray 126
#globalvar TagFG 125

# Player variables
playervar EditorExport
playervar EditorCurrentMode
playervar EditingActive
playervar EditCheckpointEffect
playervar EditCheckpointTemp
playervar EditMeleeButtonPressed
playervar EditorIsMovingCheckpoint
playervar EditorShowingExportInstructions

playervar CheckpointCurrentIdx
playervar CheckpointCurrent
playervar CheckpointGoal
playervar CheckpointAfterNext

playervar TimeStart
playervar TimeStop
playervar TimePersonalBest
playervar TimeSplit
playervar TimeSplits
playervar TimeSplitsPB
playervar TimeSplitString
playervar PositionOld
playervar PositionCurrent

playervar IsRacing
playervar Speed

# Subroutines
subroutine FullReset
subroutine GoToResetPoint # teleport back to lastpoint
subroutine StartEditorCamera
subroutine StartEditorCamera2
subroutine StopEditorCamera
subroutine DisableAbilities
subroutine EnableAbilities
subroutine SetCheckpoints

# testscripts disable: ##, enable: #
#!define test_script ##

#!define divider(x) rule "------------------------------------------------------------------------  x ------------------------------------------------------------------------ ":\
    @Delimiter\
    @Disabled

#!define LeftAlign100 "                                                                                                    "

enum ECustomize: # index in the customize array for colors and such
    CREDIT_NAME,
    CREDIT_CODE,
    DSC,
    CONTROL_HUD_1,
    PLAYER_TIME,
    AFTER_NEXT_CP,
    GOAL_CP,
    GOAL_COLOR,
    SPD_COLOR,
    PERSONAL_BEST,

enum ELoadOrder:
    MAP_DATA     = -1,
    CUSTOMIZE   = 0,
    DESTRUCTO   = 0.016 * 2,
    SETUP       = 0.016 * 32,
    PLAYER_INIT = 0.016 * 33
    #ADDON       = 0.016 * 40,
    HUDS_GLOBAL  = 0.016 * 48,
    #HUDS_PLAYER  = 0.016 * 56,
    #HUDS_EDITOR  = 0.016 * 64,
    MISSING_DATA = 3,
    EFFECTS     = 0.016 * 256,

# _END are general purpose last order huds for their side
enum EHudOrder: # hud ordering
    # hud middle ###############
    TIMER,
	EDITOR_MODE_TEXT,
	NEXT_CP_TEXT,
	NEXT_PREV_MODE_TEXT,
	FIRST_CP_TEXT,
	MODE_ACTION_TEXT,
	PREV_CP_TEXT,
	EXPORT_INFO_TEXT,

    MIDLE_END, 
    # hud left ###############
    CREDIT,
    DISC,
    SPD,
    LIVE_SPLIT,
    TEST_POSITION,
    TEST_LOAD,

    LEFT_END,

    # hud right ###############
    CONTROLS,
    TOP,
    TOP1,
    TOP2,
    TOP3,
    TOP4,
    TOP5,

    RIGHT_END,

enum EEditorMode:
    OFF = 0,
    ON = 1,
    MOVE = 2,
    INSERT = 3,
    REMOVE = 4,

macro Float.numberString(precision = 4, truncate = 2):
    # Precision: Min 3 Max 7
    # Truncate: 0=Floor 1=Round 2=Ceil
    "{0}.{1}".format(floor(self),
    (((1 + self - floor(self)) * 10 ** precision) if truncate == 0 else
    round((1 + self - floor(self)) * 10 ** precision) if truncate == 1 else
    ceil((1 + self - floor(self)) * 10 ** precision) if truncate == 2 else [])
    [0].substring(1, precision))

macro BASE_SPEED = 100
macro Player.getSpeedPercent = round(self.Speed)
macro Player.SetSpeed(speed):
    self.Speed = speed
    self.setMoveSpeed(self.Speed)
macro Player.ModifySpeed(modifier):
    self.Speed += modifier
    self.SetSpeed(self.Speed)
macro Player.ResetSpeed():
    eventPlayer.SetSpeed(BASE_SPEED)

macro Player.CurrentTime = self.TimeStop.numberString() if self.TimeStop else ( ServerTimeElapsed - self.TimeStart if self.TimeStart else 0 )
macro LiveSplitMaxLines = 10
macro Player.LiveTime = ServerTimeElapsed - self.TimeStart if self.TimeStart else 0.001
macro Player.LiveDelta = ServerTimeElapsed - self.TimeStart - self.TimeSplitsPB[self.CheckpointCurrentIdx] if self.TimeStart else 0.001

macro Player.getSplit(lastSplit = 0):
    # TODO Not functional
    getTotalTimeElapsed() - lastSplit

macro line_segmentXsphere(v1, v2, c0, r):
    # Line-Segment: vect v1 is outside sphere, vect v2 is inside sphere
    # Sphere: vect c0 is center, num r is radius
    # Intersect_Position = v1 + directionTowards(v1, v2) * \
    [2.0 * dotProduct(vectorTowards(c0, v1), directionTowards(v1, v2))].map(lambda b: -0.5 * (b + sqrt(b * b - 4.0 * (dotProduct(vectorTowards(c0, v1), vectorTowards(c0, v1)) - r * r))))

macro Array.insertAt(index, item):
    self.append(null)
    self = self.map(lambda CAE, CAI: CAE if CAI <= index else self[CAI - 1])
    self[index] = item

macro Player.flyMovementDelta():
    ((0.096 + 0.192 * self.isHoldingButton(Button.PRIMARY_FIRE) - 0.048 * self.isHoldingButton(Button.SECONDARY_FIRE)) *
    (self.getFacingDirection() * self.getThrottle().z * (vect(1, not self.isHoldingButton(Button.ABILITY_1), 1)) +
    worldVector(self.getThrottle() * Vector.LEFT, self, Transform.ROTATION) +
    Vector.UP * (self.isHoldingButton(Button.JUMP) - self.isHoldingButton(Button.CROUCH))))

macro Variable.setupTag():
    self = "​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​"
    self = f"​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​­{self}〼".replace(f"​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​­{self}〼".replace([], []), f"​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​­{self}ࡀ".replace([], []).substring(171, true))