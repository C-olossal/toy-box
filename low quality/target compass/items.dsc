item_target_compass:
    type: item
    material: recovery_compass
    display name: <&f>Target Compass
    flags:
        target_compass: <util.random_uuid>
    lore:
        - <&4>IF I'M RED, I'M CURRENTLY TRACKING.
        - <&b>IF I'M BLUE, I'M CURRENTLY TURNED OFF.

target_compass_ability:
    type: world
    debug: false
    events:
        after player right clicks block with:item_target_compass:
            - ratelimit <player> 20t
            - define player <player>
            - define item <context.item>
            - define slot <[player].held_item_slot>
            - if <[item].material.name||null> == compass:
                - inventory adjust slot:hand material:recovery_compass
            - else:
                - inventory adjust slot:hand material:compass
            - run target_compass_task def:<[player]>|<[slot]>|<[item]>
        on player picks up item_target_compass:
            - define player <player>
            - define slot <player.inventory.first_empty>
            - define item <context.item>
            - wait 1t
            - run target_compass_task def:<[player]>|<[slot]>|<[item]>
        on player clicks item_target_compass in inventory:
            # prevents the player from messing with the mana bottle in the inventory
            # the player however can still drop it
            - if <context.item.material.name> == compass && <player.gamemode> != creative:
                - determine cancelled

target_compass_task:
    type: task
    definitions: player|slot|item
    debug: false
    script:
        - define uuid <[item].flag[target_compass]>
        - while <[player].is_online||false> && <[player].inventory.slot[<[slot]>].flag[target_compass]||null> == <[uuid]> && <[player].inventory.slot[<[slot]>].material.name||null> == compass && <server.flag[target_compass_current_player].is_spawned||false>:
            - if <server.flag[target_compass_current_player]> != <[player]>:
                - compass <server.flag[target_compass_current_player].location>
            - wait 20t
        - if <[player].is_online||false>:
            - compass reset
        - if !<server.flag[target_compass_current_player].is_spawned||false> && <[player].inventory.slot[<[slot]>].flag[target_compass]||null> == <[uuid]>:
            - inventory adjust slot:<[slot]> material:recovery_compass