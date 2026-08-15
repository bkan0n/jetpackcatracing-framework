#!mainFile "main.opy"



rule "Init Global":
    if not INSPECTOR_ON:
        disableInspector()
    disableAnnouncer()
    disableGamemodeCompletion()
    disableScoring()
    RestartLobbyTime = (
        createWorkshopSettingBool("Lobby Setting", "Infinite Lobby Time", false, 1) * Math.INFINITY +
        createWorkshopSettingInt("Lobby Setting", "Restart Lobby After X minutes", 15, 1, 60, 0) - 1
    )
    wait(1)
    setMatchTime(900)
    startForcingSpawn(Team.ALL, 0)
    startForcingSpawn(Team.ALL, 1)
    startForcingSpawn(Team.ALL, 2)
    stopForcingSpawn(Team.ALL)

    EditorOn = createWorkshopSettingBool("Editor", "Editor Mode Enabled", EDITOR_ON, 0)
    if not EditorOn:
        #LeaderboardText = null
        #LeaderboardRemake = null
        LeaderboardEntries = []
        #TagFG.setupTag() # Used for coloring Live Split

    wait(ELoadOrder.SETUP)
    
	if Checkpoints == 0:
    	Checkpoints = []



rule "Init Player":
    @Event playerJoined
    @Condition eventPlayer.isDummy() == false or eventPlayer in TestBotArray
	eventPlayer.disableKillFeed()
    eventPlayer.disableGamemodeHud()
    eventPlayer.disableGamemodeInWorldUi()
    eventPlayer.disableMessages()
    eventPlayer.disablePlayerCollision()

    waitUntil(getTotalTimeElapsed() > ELoadOrder.PLAYER_INIT, ELoadOrder.PLAYER_INIT) # map variables need to load first
    waitUntil(eventPlayer.hasSpawned())
    wait(0.128)
    FullReset()


rule "Server Time Elapsed":
    ServerTimeElapsed = getTotalTimeElapsed()
    wait(0)
    loop



rule "After 3s if the checkpoints are empty then provide a warning":
    @Condition getTotalTimeElapsed() > ELoadOrder.MISSING_DATA
	@Condition len(Checkpoints) == 0 
	hudHeader(null if EditorOn and localPlayer == hostPlayer else localPlayer, " {0} Warning: Map has no data ".format(iconString(Icon.WARNING)), HudPosition.TOP, 5, Color.RED, HudReeval.VISIBILITY, SpecVisibility.DEFAULT)



macro fence_delay = 3 # decrease to make it wait more often if you have load problems, keep at full int numbers no floats
macro fence_proj_size = 30 # projectile size, 30 is maximum possible atm
macro fence_grid = 16 # gridsize of 16 means a 16x16 grid with the point in the center
rule "Addon | Little Destructo - Fence Breaker":
    # Made by FishoFire version 1.1
	wait(ELoadOrder.DESTRUCTO) # wait to overwrite any from copy pastas
    # flag mode = both flag points, just incase
    # tdm/dm = first spawn points, the maps are not big so it just covers entire map. all teams defaults to team 1 spawn
    # push: payload and cp 0 are set but rest isnt. normal payload maps have more then 1 point.
    # rest of maps have up to 3 points
    MapVectorArray.append(
        [getFlagPosition(Team.1), getFlagPosition(Team.2)] if getCurrentGamemode() == Gamemode.CTF else
        getSpawnPoints(Team.ALL)[0] if getCurrentGamemode() in [Gamemode.TDM, Gamemode.FFA] else
        getPayloadPosition() if getPayloadPosition()[0] and not (getObjectivePosition(1) + getObjectivePosition(2)) else
        [getObjectivePosition(0), getObjectivePosition(1), getObjectivePosition(2)])
    # explode in a grid around the selected points
    while len(MapVectorArray) > 1:
        MapVectorArray[0] = 0
        while MapVectorArray[0] < (fence_grid * fence_grid):
            createProjectile(
                Projectile.ORB,  # the only orb available without fx extension
                null,
                # calculation for next explosion
                MapVectorArray[1] + fence_proj_size * vect(MapVectorArray[0] % fence_grid - 0.5 * fence_grid,
                0, floor(MapVectorArray[0] / fence_grid) - 0.5 * fence_grid),
                Vector.DOWN, Relativity.TO_WORLD, ModifyHealth.HEAL, Team.1, 0, 0, fence_proj_size,
                DynamicEffect.GOOD_EXPLOSION, # possible without extensions: bad, good, ring
                DynamicEffect.EXPLOSION_SOUND, # possible without extensions: explosion sound, buf sound, ring explosion sound
                1, 1, 0, 0, 0, 0)
            MapVectorArray[0]++
            if not (MapVectorArray[0] % fence_delay): # use modulo to only wait every x orbs keep the 0 change the other number
                wait(0)
        del MapVectorArray[1]

    # handle exceptions (looking at you new queen street)
    MapVectorArray = [vect(8.276, 4.113, 15.261), vect(-8.319, 2.624, 14.245), vect(0, 4.821, 18.513)]
    while len(MapVectorArray):
        # same as other projectile before
        createProjectile(
            Projectile.ORB,
            null,
            MapVectorArray[0],
            Vector.DOWN, Relativity.TO_WORLD, ModifyHealth.HEAL, Team.1, 0, 0, fence_proj_size,
            DynamicEffect.GOOD_EXPLOSION,
            DynamicEffect.EXPLOSION_SOUND,
            1, 1, 0, 0, 0, 0)
        del MapVectorArray[0]
        wait(0)
    MapVectorArray = null