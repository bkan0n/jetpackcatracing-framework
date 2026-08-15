#!mainFile "main.opy"



rule "HUD Setup":
    wait(ELoadOrder.HUDS_GLOBAL)
    # Left
    hudText(
        localPlayer, 
        heroIcon(Racer.Hero), 
        f"Made By: {CreatorName}{LeftAlign100}",
        f"Map Code: {MapCode}{LeftAlign100}",
        HudPosition.LEFT, EHudOrder.CREDIT, Color.SKY_BLUE, ColorConfig[ECustomize.CREDIT_NAME], ColorConfig[ECustomize.CREDIT_CODE], 
        HudReeval.VISIBILITY, SpecVisibility.DEFAULT
    )
    hudSubheader(localPlayer,
        f"Discord: {Racer.Discord}{LeftAlign100}",
        HudPosition.LEFT, EHudOrder.DISC, ColorConfig[ECustomize.DSC], HudReeval.VISIBILITY, SpecVisibility.DEFAULT)

    hudSubtext(localPlayer, "\n{0} Speed: {1}\n{2} Multiplier: {3}%{4}".format(abilityIconString(Racer.Hero, Button.SECONDARY_FIRE), localPlayer.getSpeed(), iconString(Icon.BOLT), localPlayer.getSpeedPercent, LeftAlign100), HudPosition.LEFT, EHudOrder.SPD, ColorConfig[ECustomize.SPD_COLOR], HudReeval.VISIBILITY_AND_STRING)
    
    hudSubheader(localPlayer, "\n{0} Personal best: {1}\nLvl      PB       Split\n{2}{3}{4}".format(
        abilityIconString(Racer.Hero, Button.ABILITY_2),
        localPlayer.TimePersonalBest if localPlayer.TimePersonalBest else " —",
        localPlayer.TimeSplitString,
        [] if localPlayer.TimeStop else "{0}:     {1}{2}{3}{1}     {4}".format(
            localPlayer.CheckpointCurrentIdx,
            "", #TagFG,
            #"A0FFA0FF"
            [] if ServerTimeElapsed - localPlayer.TimeStart - localPlayer.TimeSplitsPB[localPlayer.CheckpointCurrentIdx] <= 0 else "+", #"FF0040FF",
            localPlayer.LiveDelta if localPlayer.TimePersonalBest else 0.001,
            localPlayer.LiveTime
        ),
        LeftAlign100
    ), HudPosition.LEFT, sortOrder = EHudOrder.LIVE_SPLIT, reevaluation = HudReeval.VISIBILITY_AND_STRING)

    # Center
    hudText(
        localPlayer if not hostPlayer.EditorShowingExportInstructions else null, 
        iconString(Icon.ARROW_RIGHT) if localPlayer.IsRacing else iconString(Icon.FLAG) if localPlayer.CheckpointCurrentIdx == 0 else  iconString(Icon.CHECKMARK) , 
        "{} / {}".format(localPlayer.CheckpointCurrentIdx, len(Checkpoints)-1), 
        "Time: {}".format(localPlayer.CurrentTime), 
        HudPosition.TOP, 
		EHudOrder.TIMER,
        ColorConfig[ECustomize.PLAYER_TIME], ColorConfig[ECustomize.PLAYER_TIME], ColorConfig[ECustomize.PLAYER_TIME], 
        HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT
    )

    # Right
    hudSubtext(true if localPlayer.EditorCurrentMode == EEditorMode.OFF else null, 
        "Press [{0}]: Quick reset\n"
        "Hold [{0}]: Full restart\n"
        "".format(
            inputBindingString(Button.RELOAD)
        ), 
        HudPosition.RIGHT, EHudOrder.CONTROLS, ColorConfig[ECustomize.CONTROL_HUD_1] , HudReeval.VISIBILITY_AND_STRING
    )
rule "Remake Leaderboard HUD":
    @Condition LeaderboardRemake
    LeaderboardRemake = null
    LeaderboardEntries = sorted(LeaderboardEntries, lambda i: i[1])

    while len(LeaderboardText) > 0: # delete previous board (because re-val is off)
        destroyHudText(LeaderboardText[0])
        del LeaderboardText[0]

    /* #$$ For future use - Generates a single string leaderboard
    LeaderBoardRemake = []
    LeaderboardText = LeaderboardEntries.map(tuple: "　 {}:　{} - {}".format(CAI + 1, CAE[0], CAE.last()))
    while len(LeaderboardText):
        LeaderBoardRemake = "{}\n{}".format(LeaderBoardRemake, LeaderboardText[0])
        del LeaderboardText[0]
    LeaderBoardRemake = "{}\n".format(LeaderBoardRemake)
    */
    if LeaderboardEntries[0]:
        hudSubtext(getAllPlayers(), "{0} Top 5 {0}".format(abilityIconString(Racer.Hero, Button.SECONDARY_FIRE))
            , HudPosition.RIGHT, EHudOrder.TOP, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
        LeaderboardText.append(getLastCreatedText())
        hudText(getAllPlayers(), heroIcon(Racer.Hero), LeaderboardEntries[0][0], LeaderboardEntries[0][1].numberString(), HudPosition.RIGHT, EHudOrder.TOP1, Color.RED, Color.RED, Color.RED, HudReeval.VISIBILITY, SpecVisibility.DEFAULT)
        LeaderboardText.append(getLastCreatedText())
        if LeaderboardEntries[1]:
            hudText(getAllPlayers(), heroIcon(Racer.Hero), LeaderboardEntries[1][0], LeaderboardEntries[1][1].numberString(), HudPosition.RIGHT, EHudOrder.TOP2, Color.ORANGE, Color.ORANGE, Color.ORANGE, HudReeval.VISIBILITY, SpecVisibility.DEFAULT)
            LeaderboardText.append(getLastCreatedText())
            if LeaderboardEntries[2]:
                hudText(getAllPlayers(), heroIcon(Racer.Hero), LeaderboardEntries[2][0], LeaderboardEntries[2][1].numberString(), HudPosition.RIGHT, EHudOrder.TOP3, Color.YELLOW, Color.YELLOW, Color.YELLOW, HudReeval.VISIBILITY, SpecVisibility.DEFAULT)
                LeaderboardText.append(getLastCreatedText())
                if LeaderboardEntries[3]:
                    hudText(getAllPlayers(), heroIcon(Racer.Hero), LeaderboardEntries[3][0], LeaderboardEntries[3][1].numberString(), HudPosition.RIGHT, EHudOrder.TOP4, Color.LIME_GREEN, Color.LIME_GREEN,Color.LIME_GREEN, HudReeval.VISIBILITY, SpecVisibility.DEFAULT)
                    LeaderboardText.append(getLastCreatedText())
                    if LeaderboardEntries[4]:
                        hudText(getAllPlayers(), heroIcon(Racer.Hero), LeaderboardEntries[4][0], LeaderboardEntries[4][1].numberString(), HudPosition.RIGHT, EHudOrder.TOP5, Color.GREEN, Color.GREEN, Color.GREEN,HudReeval.VISIBILITY, SpecVisibility.DEFAULT)
                        LeaderboardText.append(getLastCreatedText())



rule "Effects Setup":
    wait(ELoadOrder.EFFECTS)
    createEffect(localPlayer.filter(lambda _: localPlayer.CheckpointGoal != 0), Effect.GOOD_AURA, ColorConfig[ECustomize.GOAL_CP], localPlayer.CheckpointGoal, RingSize-0.15, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createEffect(localPlayer.filter(lambda _: localPlayer.CheckpointAfterNext != 0), Effect.GOOD_AURA, ColorConfig[ECustomize.AFTER_NEXT_CP], localPlayer.CheckpointAfterNext, RingSize-0.15, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createEffect(localPlayer.filter(lambda _: Checkpoints[localPlayer.CheckpointCurrentIdx] != 0 and localPlayer.EditorCurrentMode > EEditorMode.OFF), Effect.GOOD_AURA, Color.RED, Checkpoints[localPlayer.CheckpointCurrentIdx], RingSize-0.15, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)

    # checkpoint icon
    createIcon( 
        localPlayer.filter(lambda _: localPlayer.EditorCurrentMode == EEditorMode.OFF and localPlayer.CheckpointGoal != 0 and not localPlayer.isInViewAngle(localPlayer.CheckpointGoal, 4) ), 
        localPlayer.CheckpointGoal + vect(0,1,0), 
        Icon.ARROW_DOWN, 
        IconReeval.VISIBILITY_AND_POSITION, ColorConfig[ECustomize.GOAL_COLOR], true
    )



rule "Editor HUD":
    @Condition EditorOn
    
	# Current mode Top HUD
    hudHeader(
        hostPlayer if hostPlayer.EditorCurrentMode > EEditorMode.OFF and not hostPlayer.EditorShowingExportInstructions else null,
		" {0} Move Mode ".format(abilityIconString(Hero.SYMMETRA, Button.ABILITY_2)) if localPlayer.EditorCurrentMode == EEditorMode.MOVE else " {0} Insert Mode ".format(iconString(Icon.HALO)) if localPlayer.EditorCurrentMode == EEditorMode.INSERT else " {0} Remove Mode ".format(iconString(Icon.TRASHCAN)),
        HudPosition.TOP, 
        EHudOrder.EDITOR_MODE_TEXT, 
		Color.BLUE if localPlayer.EditorCurrentMode == EEditorMode.MOVE else Color.GREEN if localPlayer.EditorCurrentMode == EEditorMode.INSERT else Color.RED,
        HudReeval.VISIBILITY_STRING_AND_COLOR, 
        SpecVisibility.NEVER
    )

	# Next checkpoint HUD
    hudSubtext(
        hostPlayer if hostPlayer.EditorCurrentMode > EEditorMode.OFF and not hostPlayer.EditorShowingExportInstructions else null,
        f"\n\n\n\n\n{iconString(Icon.ARROW_UP)} NEXT CHECKPOINT",
        HudPosition.TOP, 
        EHudOrder.NEXT_CP_TEXT, 
        Color.WHITE, 
        HudReeval.VISIBILITY_STRING_AND_COLOR, 
        SpecVisibility.NEVER
    )

	# Previous/Next mode button
    hudSubtext(
        hostPlayer if hostPlayer.EditorCurrentMode > EEditorMode.OFF and not hostPlayer.EditorShowingExportInstructions else null,
        f"\n\n\n\n\n\n\n\n{iconString(Icon.ARROW_LEFT)} {'Move Mode' if (localPlayer.EditorCurrentMode + 1 if localPlayer.EditorCurrentMode < len(EEditorMode) - 1 else 2) == EEditorMode.MOVE else 'Insert Mode' if (localPlayer.EditorCurrentMode + 1 if localPlayer.EditorCurrentMode < len(EEditorMode) - 1 else 2) == EEditorMode.INSERT else 'Remove Mode'}                                                                             {'Move Mode' if (localPlayer.EditorCurrentMode - 1 if localPlayer.EditorCurrentMode > 2 else len(EEditorMode) - 1) == EEditorMode.MOVE else 'Insert Mode' if (localPlayer.EditorCurrentMode - 1 if localPlayer.EditorCurrentMode > 2 else len(EEditorMode) - 1) == EEditorMode.INSERT else 'Remove Mode'} {iconString(Icon.ARROW_RIGHT)}",
        HudPosition.TOP, 
        EHudOrder.NEXT_PREV_MODE_TEXT, 
        Color.WHITE, 
        HudReeval.VISIBILITY_STRING_AND_COLOR, 
        SpecVisibility.NEVER
    )

	# Press interact to open editor for if there's no checkpoints
	hudSubtext(
        hostPlayer if len(Checkpoints) == 0 and not hostPlayer.EditorShowingExportInstructions else null,
        "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\nHold [{0}] to set the first checkpoint and open the editor".format(inputBindingString(Button.INTERACT)), 
		HudPosition.TOP,
        EHudOrder.FIRST_CP_TEXT,
        Color.YELLOW, 
        HudReeval.VISIBILITY_STRING_AND_COLOR,
        SpecVisibility.NEVER
    )

	# Press interact to open editor
    # hudSubtext(
    #     hostPlayer if len(Checkpoints) > 0 and not hostPlayer.ShouldShowExportInstructions else null,
    #     "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\nEnable Editor: Hold [{0}]".format(inputBindingString(Button.INTERACT)) if localPlayer.EditorCurrentMode <= EEditorMode.OFF else (f"Disable Editor: Hold [{inputBindingString(Button.INTERACT)}]" if not localPlayer.IsMovingCheckpoint else f"Cancel Move: Press [{inputBindingString(Button.INTERACT)}]" ),        HudPosition.TOP,
    #     103,
    #     Color.WHITE, 
    #     HudReeval.VISIBILITY_STRING_AND_COLOR,
    #     SpecVisibility.NEVER
    # )

	# Save buttons (Melee)
    hudSubtext(
        hostPlayer if hostPlayer.EditorCurrentMode > EEditorMode.OFF and not hostPlayer.EditorShowingExportInstructions else null,
		f"\n\n\n\nSave: [{inputBindingString(Button.MELEE)}]                                                                    Cancel Move: [{inputBindingString(Button.INTERACT)}]" if localPlayer.EditorCurrentMode == EEditorMode.MOVE and localPlayer.EditingActive else f"\n\n\n\n                                                                              Move: [{inputBindingString(Button.MELEE)}]" if localPlayer.EditorCurrentMode == EEditorMode.MOVE else f"\n\n\n\n                                                                              Insert: [{inputBindingString(Button.MELEE)}]" if localPlayer.EditorCurrentMode == EEditorMode.INSERT else f"\n\n\n\n                                                                              Remove: Hold [{inputBindingString(Button.MELEE)}]",
		HudPosition.TOP,
        EHudOrder.MODE_ACTION_TEXT,
		Color.SKY_BLUE if localPlayer.EditorCurrentMode == EEditorMode.MOVE else Color.LIME_GREEN if localPlayer.EditorCurrentMode == EEditorMode.INSERT else Color.ROSE,
        HudReeval.VISIBILITY_STRING_AND_COLOR,
        SpecVisibility.NEVER
    )

	# Previous checkpoint 
    hudSubtext(
        hostPlayer if hostPlayer.EditorCurrentMode > EEditorMode.OFF and not hostPlayer.EditorShowingExportInstructions else null,
        f"\n\n{iconString(Icon.ARROW_DOWN)} PREVIOUS CHECKPOINT",
        HudPosition.TOP, 
        EHudOrder.PREV_CP_TEXT, 
        Color.WHITE, 
        HudReeval.VISIBILITY_STRING_AND_COLOR, 
        SpecVisibility.NEVER
    )

	# Editor mode and export buttons
    hudSubtext(
        hostPlayer if EditorOn else null, 
        f"Hold [{inputBindingString(Button.INTERACT)}]: To toggle Editor\nHold [{inputBindingString(Button.INTERACT)} + {inputBindingString(Button.ULTIMATE)}]: To Export Data\n",
        HudPosition.RIGHT, EHudOrder.CONTROLS + 10, ColorConfig[ECustomize.CONTROL_HUD_1] , HudReeval.VISIBILITY_AND_STRING
    )

	# move fast/slow in move mode
    hudSubtext(
        hostPlayer if EditorOn and hostPlayer.EditorCurrentMode == EEditorMode.MOVE and hostPlayer.EditingActive else null, 
        f"Hold [{inputBindingString(Button.PRIMARY_FIRE)}]: Move fast\nHold [{inputBindingString(Button.SECONDARY_FIRE)}]: Move slow",
        HudPosition.RIGHT, EHudOrder.CONTROLS + 10, ColorConfig[ECustomize.CONTROL_HUD_1] , HudReeval.VISIBILITY_AND_STRING
    )


    # Export instruction
	hudText(hostPlayer if hostPlayer.EditorShowingExportInstructions else null, 
		
		" 0. Clear Extra Data:\n"
        "   Already Done Upon Opening This Window\n\n"

        " 1. Copy Data:\n"
        "   Open Workshop Inspector\n"
        "   Click The [(X)] button\n\n"

        " 2. Insert Data:\n"
        "   Paste The Data Into Rule Named 'Map # Data <--- Insert Map Data Here' \n" 
		"   in the workshop editor\n\n"

        " 3. Workshop Settings:\n"
        "   Esc -> Show Lobby -> Settings -> Workshop Settings ->\n"
        "   Toggle 'Editor Mode Enabled' to 'Off'\n\n"

        " 4. Create Initial Sharecode:\n"
        "   Esc -> Show Lobby -> Settings -> Share Code ->\n"
        "   Create New Code -> Copy Code\n\n"

        " 5. Add Credits:\n"
        "   Enter Your Name & Map Code In The 'Customize Credits and\n"
		"   Colors Here' Rule in the workshop editor\n\n"

        " 6. Update For Credits:\n"
        "   Esc -> Show Lobby -> Settings -> Share Code ->\n"
        "   Upload To Existing Code -> Paste The Code You Created In Step 4 \n\n" 

		" Press [{0}] to hide this text".format(buttonString(Button.MELEE)), 
		null,
		null, 
		HudPosition.TOP, 
		EHudOrder.EXPORT_INFO_TEXT, 
		Color.YELLOW, 
		Color.WHITE, 
		Color.LIME_GREEN, 
		HudReeval.VISIBILITY_AND_STRING, 
		SpecVisibility.NEVER)