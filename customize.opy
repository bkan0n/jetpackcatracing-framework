#!mainFile "main.opy"

rule "Customize Credits and Colors Here":
    wait(ELoadOrder.CUSTOMIZE)

    # credits
	CreatorName = "creator name here"
	MapCode = "map code here"

    # ring size
    RingSize = 2.5

    #credit hud name   -   作者HUD
    ColorConfig[ECustomize.CREDIT_NAME] = Color.VIOLET

    #credit hud code   -   代码HUD
    ColorConfig[ECustomize.CREDIT_CODE] = Color.SKY_BLUE

    #discord link
    ColorConfig[ECustomize.DSC] = Color.AQUA

    #control scheme
    ColorConfig[ECustomize.CONTROL_HUD_1] = Color.WHITE

    #player timer
    ColorConfig[ECustomize.PLAYER_TIME] = Color.WHITE

    #personal best time
    ColorConfig[ECustomize.PERSONAL_BEST] = Color.WHITE

    #next cp
    ColorConfig[ECustomize.GOAL_CP] = Color.GREEN

    #after next cp
    ColorConfig[ECustomize.AFTER_NEXT_CP] = Color.WHITE

    #goal icon color
    ColorConfig[ECustomize.GOAL_COLOR] = Color.ROSE

    #speed meter color
    ColorConfig[ECustomize.SPD_COLOR] = Color.WHITE
    