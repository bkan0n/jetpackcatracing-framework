#!mainFile "main.opy"

rule "Editor | Enable Checkpoint Selection":
    @Event eachPlayer
    @Condition EditorOn
    @Condition eventPlayer == hostPlayer
	@Condition not hostPlayer.EditorShowingExportInstructions
    @Condition hostPlayer.isHoldingButton(Button.INTERACT)
	@Condition not hostPlayer.isHoldingButton(Button.ULTIMATE)

	
	if hostPlayer.EditorIsMovingCheckpoint:
		smallMessage(hostPlayer, "   {0} Checkpoint Movement Cancelled".format(abilityIconString(Hero.SYMMETRA, Button.ABILITY_2)))
		playEffect(hostPlayer, DynamicEffect.RING_EXPLOSION_SOUND, Color.WHITE, Checkpoints[hostPlayer.CheckpointCurrentIdx], 100)

		StartEditorCamera()
		hostPlayer.EditCheckpointTemp = null
		destroyEffect(hostPlayer.EditCheckpointEffect)
		hostPlayer.EditorIsMovingCheckpoint = false
		hostPlayer.EditingActive = false
		return

	wait(0.5, Wait.ABORT_WHEN_FALSE)
    hostPlayer.TimeStop = 0
	# If there's no checkpoints, create 1 at the player's position
    if len(Checkpoints) == 0:
        Checkpoints[0] = hostPlayer.getPosition()
        hostPlayer.CheckpointCurrentIdx = 0
        SetCheckpoints()

	hostPlayer.EditorCurrentMode = EEditorMode.MOVE if hostPlayer.EditorCurrentMode == EEditorMode.OFF else EEditorMode.OFF

    if hostPlayer.EditorCurrentMode > EEditorMode.OFF: # Entering edit mode: Start the camera and stop the timer
        hostPlayer.TimeStart = 0
        StartEditorCamera()
        wait(0.1)
		playEffect(hostPlayer, DynamicEffect.BUFF_EXPLOSION_SOUND, Color.WHITE, Checkpoints[hostPlayer.CheckpointCurrentIdx], 100)
    else: # Exiting edit mode: Stop the camera and continue the timer
        hostPlayer.TimeStart = getTotalTimeElapsed()
		hostPlayer.EditingActive = false
		destroyEffect(hostPlayer.EditCheckpointEffect)
        StopEditorCamera()
		hostPlayer.EditorIsMovingCheckpoint = false
        #if hostPlayer.CurrentCheckpointIdx < len(Checkpoints) - 1:
        #    hostPlayer.IsRacing = true
		hostPlayer.teleport(Checkpoints[hostPlayer.CheckpointCurrentIdx])
		wait(0.1)
		playEffect(hostPlayer, DynamicEffect.RING_EXPLOSION_SOUND, Color.WHITE, hostPlayer.getPosition(), 100)


rule "Editor | Export Data":
    @Event global # Forces 'Variable Target' to be Global
    @Condition EditorOn
	# @Condition hostPlayer.CurrentEditorMode == EEditorMode.OFF 
    @Condition hostPlayer.isHoldingButton(Button.INTERACT)
	@Condition hostPlayer.isHoldingButton(Button.ULTIMATE)
	@Condition not hostPlayer.EditorShowingExportInstructions
	
    wait(0.5, Wait.ABORT_WHEN_FALSE)
    hostPlayer.EditorShowingExportInstructions = true
    hostPlayer.EditorExport = [ColorConfig, CreatorName, MapCode]
    EditorOn = null
    ColorConfig = null
	CreatorName = null
	MapCode = null
	RestartLobbyTime = null
    ServerTimeElapsed = null
    enableInspector()
    disableInspector()
    EditorOn = true
    ColorConfig = hostPlayer.EditorExport[0]
    CreatorName = hostPlayer.EditorExport[1]
	MapCode = hostPlayer.EditorExport.last()
    smallMessage(hostPlayer, "   Map Data Exported - Open Inspector")
	playEffect(hostPlayer, DynamicEffect.BUFF_IMPACT_SOUND, Color.WHITE, hostPlayer.getPosition() if hostPlayer.EditorCurrentMode == EEditorMode.OFF else Checkpoints[hostPlayer.CheckpointCurrentIdx], 100)


rule "Editor | Hide Export instruction":
    @Condition EditorOn
    @Condition hostPlayer.isHoldingButton(Button.MELEE)
	@Condition hostPlayer.EditorShowingExportInstructions
	@Condition not hostPlayer.EditMeleeButtonPressed

	hostPlayer.EditMeleeButtonPressed = true
	hostPlayer.EditorShowingExportInstructions = false
	playEffect(hostPlayer, DynamicEffect.RING_EXPLOSION_SOUND, Color.WHITE, hostPlayer.getPosition() if hostPlayer.EditorCurrentMode == EEditorMode.OFF else Checkpoints[hostPlayer.CheckpointCurrentIdx], 100)



rule "Editor | Select Checkpoint & Mode":
    @Event eachPlayer
    @Condition EditorOn
    @Condition eventPlayer == hostPlayer
	@Condition hostPlayer.EditorCurrentMode > EEditorMode.OFF
	@Condition not hostPlayer.EditingActive
    @Condition (hostPlayer.getThrottle().z > 0.5 or hostPlayer.getThrottle().z < -0.5 or 
            	hostPlayer.getThrottle().x > 0.5 or hostPlayer.getThrottle().x < -0.5)
	
	if hostPlayer.EditMeleeButtonPressed:
		return

    if hostPlayer.getThrottle().z > 0.5:
        hostPlayer.CheckpointCurrentIdx += 1
        if hostPlayer.CheckpointCurrentIdx >= len(Checkpoints):
            hostPlayer.CheckpointCurrentIdx = 0

    elif hostPlayer.getThrottle().z < -0.5:
        hostPlayer.CheckpointCurrentIdx -= 1
        if hostPlayer.CheckpointCurrentIdx < 0:
            hostPlayer.CheckpointCurrentIdx = len(Checkpoints) - 1
    
    elif hostPlayer.getThrottle().x > 0.5:
        hostPlayer.EditorCurrentMode += 1
        if hostPlayer.EditorCurrentMode >= len(EEditorMode):
            hostPlayer.EditorCurrentMode = EEditorMode.MOVE

    elif hostPlayer.getThrottle().x < -0.5:
        hostPlayer.EditorCurrentMode -= 1
        if hostPlayer.EditorCurrentMode < EEditorMode.MOVE:
            hostPlayer.EditorCurrentMode = len(EEditorMode) - 1
    
    SetCheckpoints()

	wait(0.1)
	playEffect(hostPlayer, DynamicEffect.BUFF_EXPLOSION_SOUND, Color.WHITE, Checkpoints[hostPlayer.CheckpointCurrentIdx], 100)



rule "Editor | Enable Checkpoint Edit":
    @Event eachPlayer
    @Condition EditorOn
    @Condition eventPlayer == hostPlayer
    @Condition hostPlayer.EditorCurrentMode == EEditorMode.MOVE
	@Condition hostPlayer.isHoldingButton(Button.MELEE)
	@Condition not hostPlayer.EditMeleeButtonPressed

	hostPlayer.EditMeleeButtonPressed = true
    hostPlayer.EditingActive = not hostPlayer.EditingActive
    
	if hostPlayer.EditingActive:
        smallMessage(hostPlayer, "   {0} Checkpoint Moving Enabled".format(abilityIconString(Hero.SYMMETRA, Button.ABILITY_2)))
		playEffect(hostPlayer, DynamicEffect.BUFF_IMPACT_SOUND, Color.WHITE, Checkpoints[hostPlayer.CheckpointCurrentIdx], 100)
        StartEditorCamera2()
        hostPlayer.EditCheckpointTemp = Checkpoints[hostPlayer.CheckpointCurrentIdx]
        createEffect(hostPlayer, Effect.GOOD_AURA, Color.ROSE, hostPlayer.EditCheckpointTemp, RingSize-0.15, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
        hostPlayer.EditCheckpointEffect = getLastCreatedEntity()
		hostPlayer.EditorIsMovingCheckpoint = true
    else:
        smallMessage(hostPlayer, "   {0} Checkpoint Placed".format(abilityIconString(Hero.SYMMETRA, Button.ABILITY_2)))
		playEffect(hostPlayer, DynamicEffect.BUFF_IMPACT_SOUND, Color.WHITE, hostPlayer.EditCheckpointTemp, 100)
        StartEditorCamera()
        Checkpoints[hostPlayer.CheckpointCurrentIdx] = hostPlayer.EditCheckpointTemp
        SetCheckpoints()
        hostPlayer.EditCheckpointTemp = null
        destroyEffect(hostPlayer.EditCheckpointEffect)
		hostPlayer.EditorIsMovingCheckpoint = false



rule "Editor | Start Editing Position":
    @Condition EditorOn
    @Condition hostPlayer.EditorCurrentMode == EEditorMode.MOVE
	@Condition hostPlayer.EditingActive
	@Condition not hostPlayer.EditMeleeButtonPressed

    while not hostPlayer.isHoldingButton(Button.MELEE) and hostPlayer.EditingActive:
        hostPlayer.EditCheckpointTemp += hostPlayer.flyMovementDelta()
        wait(0)


rule "Editor | Remove Checkpoint":
    @Event eachPlayer
    @Condition EditorOn
    @Condition eventPlayer == hostPlayer
    @Condition hostPlayer.EditorCurrentMode == EEditorMode.REMOVE
	@Condition hostPlayer.isHoldingButton(Button.MELEE)
	@Condition not hostPlayer.EditMeleeButtonPressed

	wait(0.5, Wait.ABORT_WHEN_FALSE)
    
	hostPlayer.EditMeleeButtonPressed = true
    del Checkpoints[hostPlayer.CheckpointCurrentIdx]
    
	# If deleted the last checkpoint, reset the first checkpoint to be the player's current position
	if len(Checkpoints) == 0:
		hostPlayer.EditorCurrentMode = EEditorMode.OFF
		hostPlayer.EditingActive = false
        StopEditorCamera()
		hostPlayer.CheckpointCurrentIdx = 0
		smallMessage(hostPlayer, "   {0} No Checkpoints left to remove".format(iconString(Icon.TRASHCAN)))
		playEffect(hostPlayer, DynamicEffect.DEBUFF_IMPACT_SOUND, Color.WHITE, hostPlayer.getPosition(), 100)
		return

	if hostPlayer.CheckpointCurrentIdx >= len(Checkpoints):
		hostPlayer.CheckpointCurrentIdx = len(Checkpoints) - 1

	SetCheckpoints()

	wait(0.1)
	smallMessage(hostPlayer, "   {0} Checkpoint Removed".format(iconString(Icon.TRASHCAN)))
	playEffect(hostPlayer, DynamicEffect.RING_EXPLOSION_SOUND, Color.WHITE, Checkpoints[hostPlayer.CheckpointCurrentIdx], 100)



rule "Editor | Insert Checkpoint (After Current Checkpoint)":
    @Event eachPlayer
    @Condition EditorOn
    @Condition eventPlayer == hostPlayer
    @Condition hostPlayer.EditorCurrentMode == EEditorMode.INSERT
	@Condition hostPlayer.isHoldingButton(Button.MELEE)
    @Condition not hostPlayer.EditMeleeButtonPressed

	smallMessage(hostPlayer, "   {0} Checkpoint Inserted".format(iconString(Icon.HALO)))
	playEffect(hostPlayer, DynamicEffect.BUFF_IMPACT_SOUND, Color.WHITE, Checkpoints[hostPlayer.CheckpointCurrentIdx], 100)

	hostPlayer.EditMeleeButtonPressed = true
    Checkpoints.insertAt(hostPlayer.CheckpointCurrentIdx, Checkpoints[hostPlayer.CheckpointCurrentIdx])
    hostPlayer.CheckpointCurrentIdx += 1
    SetCheckpoints()
    hostPlayer.EditorCurrentMode = EEditorMode.MOVE
    hostPlayer.EditingActive = true
    StartEditorCamera2()
    hostPlayer.EditCheckpointTemp = Checkpoints[hostPlayer.CheckpointCurrentIdx]
    createEffect(hostPlayer, Effect.GOOD_AURA, Color.ROSE, hostPlayer.EditCheckpointTemp, RingSize-0.15, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    hostPlayer.EditCheckpointEffect = getLastCreatedEntity()
	hostPlayer.EditorIsMovingCheckpoint = true


rule "Editor | When stopped pressing melee, set EditMeleeButtonPressed back to true so next melee button can be presssed":
    @Condition EditorOn
	@Condition not hostPlayer.isHoldingButton(Button.MELEE)

	hostPlayer.EditMeleeButtonPressed = false



def StartEditorCamera():
    @Name "Editor | Start Editor 3rd Person Camera"
    
    hostPlayer.setInvisibility(Invis.ALL)
    DisableAbilities()

    hostPlayer.startCamera(
        updateEveryFrame(
        raycastHitPosition(hostPlayer.CheckpointCurrent,
        hostPlayer.CheckpointCurrent - 8 * hostPlayer.getFacingDirection(),
        null, null, false) + hostPlayer.getFacingDirection()),
        hostPlayer.CheckpointCurrent, 500
    )
    

def StartEditorCamera2():
    @Name "Editor | Start Editor 3rd Person Camera | Checkpoint Movement"

    hostPlayer.startCamera(
        hostPlayer.EditCheckpointTemp - 6 * updateEveryFrame(hostPlayer.getFacingDirection()), 
        hostPlayer.EditCheckpointTemp, 
        25
    )

def StopEditorCamera():
    @Name "Editor | Stop Editor 3rd Person Camera"
    hostPlayer.stopCamera()
    hostPlayer.setInvisibility(Invis.NONE)
    EnableAbilities()


def DisableAbilities():
    @Name "Editor | Disable Movement and Abilities"
    hostPlayer.setJumpEnabled(false)
    hostPlayer.setCrouchEnabled(false)
    hostPlayer.setPrimaryFireEnabled(false)
    hostPlayer.setSecondaryFireEnabled(false)
    hostPlayer.disallowButton(Button.SECONDARY_FIRE)
    hostPlayer.setAbility1Enabled(false)
    hostPlayer.setAbility2Enabled(false)
    hostPlayer.setMoveSpeed(0)

def EnableAbilities():
    @Name "Editor | Enable Movement and Abilities"
    hostPlayer.setJumpEnabled(true)
    hostPlayer.setCrouchEnabled(true)
    hostPlayer.setPrimaryFireEnabled(true)
    hostPlayer.setSecondaryFireEnabled(true)
    hostPlayer.allowButton(Button.SECONDARY_FIRE)
    hostPlayer.setAbility1Enabled(false) # This stays off always
    hostPlayer.setAbility2Enabled(true)
    hostPlayer.setMoveSpeed(100)