#!mainFile "main.opy"

divider(test scripts) # seperate from rest because this scripts sometimes doesnt exist

rule "slowmo":
    @Disabled # enable slowmotion here
    setSlowMotion(100)

rule "go to last cp - cheat":
    @Disabled
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.ULTIMATE)
    wait(0.2, Wait.ABORT_WHEN_FALSE)
    eventPlayer.CheckpointCurrentIdx = len(Checkpoints) - 2
    SetCheckpoints()
    GoToResetPoint()

rule "test huds":
    wait(1)
    # position hud
    hudSubheader(getAllPlayers(), 
        "\n"
        "Position: {}\n"
        "Eye: {}\n"
        "Facing: {}\n"
        "Throthle: {}\n"
        "{}"
        "".format(
            localPlayer.getPosition(),
            localPlayer.getEyePosition(),
            localPlayer.getFacingDirection(),
            localPlayer.getThrottle(),
            LeftAlign100
        ), 
        HudPosition.LEFT, EHudOrder.TEST_POSITION , Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT
    )

    # load hud
    hudSubheader(
        localPlayer,
        "Load: {}\n"
        "Avrg: {} \n"
        "Peak: {}\n"
        "{}"
        "".format(
            getServerLoad(),
            getAverageServerLoad(),
            getPeakServerLoad(),
            LeftAlign100
        ),
        HudPosition.LEFT, EHudOrder.TEST_LOAD,
        Color.RED if getAverageServerLoad() > 220 else
        Color.ORANGE if getAverageServerLoad() > 190 else
        Color.YELLOW if getAverageServerLoad() > 160  else
        Color.BLUE if getAverageServerLoad() > 130 else
        Color.LIME_GREEN,
        HudReeval.VISIBILITY_SORT_ORDER_STRING_AND_COLOR, SpecVisibility.DEFAULT
    )



# turns bots on/off completly
macro bots_on = true

macro testbot_number = 10
macro test_team = Team.2

# test leaderboard (doesnt triger if action is on)
macro leaderboard_test = true
macro leaderboard_delay = 0.5

# test other set actions (doesnt leaderboard if action is on)
macro other_action = false
macro action_delay = 0.4

# This define puts the time between each bots action, perfectly spacing their actions out
# delay_per_bot(0.5) means that first bot will wait 0, second bot will wait 0.5, third bot will wait 1 seconds etc
macro delay_per_bot(x):
    wait(TestBotArray.index(eventPlayer) * x)

rule "bots: create test bots":
    @Condition bots_on
    TestBotArray = []
    while len(TestBotArray) < testbot_number:
        createDummy(Racer.Hero, test_team, -1, null, null)
        TestBotArray.append(getLastCreatedEntity())
        wait(0.1)
        TestBotArray[len(TestBotArray)-1].startForcingName("test bot {0}".format(len(TestBotArray)-1))


rule "bots: leaderboard test routine":
    @Event eachPlayer
    @Condition getTotalTimeElapsed() > 5
    @Condition other_action == false
    @Condition leaderboard_test
    @Condition bots_on
    @Condition eventPlayer in TestBotArray

    # crouch to trigger start timer etc
    eventPlayer.startForcingButton(Button.CROUCH)
    wait(0.1)
    eventPlayer.stopForcingButton(Button.CROUCH)
    wait(10)
    # delay between each bot to variate leaderboard
    delay_per_bot(leaderboard_delay)

    # set bot to last point, teleport them and force em down into it
    eventPlayer.CheckpointCurrentIdx = len(Checkpoints) - 2
    SetCheckpoints()
    eventPlayer.teleport(eventPlayer.CheckpointGoal + Vector.UP  + Vector.UP * RingSize)
    wait(1)
    eventPlayer.startForcingButton(Button.CROUCH)
    waitUntil(not eventPlayer.IsRacing, 5)
    eventPlayer.stopForcingButton(Button.CROUCH)


rule "bots: custom action routine":
    @Event eachPlayer
    @Condition getTotalTimeElapsed() > 7
    @Condition other_action 
    @Condition leaderboard_test == false
    @Condition bots_on
    @Condition eventPlayer in TestBotArray

    delay_per_bot(0.5) # time space between each bot acting, to stagger the actions

    eventPlayer.forceButtonPress(Button.PRIMARY_FIRE)
