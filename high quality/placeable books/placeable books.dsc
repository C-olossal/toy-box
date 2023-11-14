#####################################################

# - PLACEABLE BOOKS

# - CONTROLS

# - ( survival and creative only )
# RIGHT CLICK WITH BOOK IN OFFHAND: snap place book on a surface

# - ( survival and creative only )
# LEFT CLICK AN ALREADY PLACED BOOK: break that book (drops the book in survival)

# - ( creative only )
# RIGHT CLICK WITH BOOK IN OFFHAND AND CROUCHING: free place book on a surface

# - ( creative only )
# CROUCH RIGHT CLICK AN ALREADY PLACED BOOK: make a copy of that book

# - ( avaliable in all gamemodes )
# RIGHT CLICK A WRITTEN BOOK: read its contents

#####################################################


PB_main_events:
    type: world
    debug: false
    events:
        on player right clicks block with:*book using:off_hand:
            # check if they should be allowed to place a book
            - if <player.gamemode> == adventure:
                - stop
            - determine passively cancelled
            - if !<context.relative.exists>:
                - stop
            - inject PB_place_handler

        on player tries to attack place_book_entity*:
            - determine passively cancelled
            # really weird and annoying case where you can accidentally break the block a book is attached to in creative
            # this can be commented out
            - flag <player> anti_break_block_attached_to_book_flag expire:4t
            - define gamemode <player.gamemode>

            - if <[gamemode]> == adventure:
                - stop

            - define location <context.entity.location>
            - define display_ent:<context.entity.flag[attached_display]>

            # drop the book if the player is in survival
            - if <[gamemode]> == survival:
                - define book <context.entity.flag[attached_book]>
                - drop <[book]> <[location]>

            # play effects
            - playsound <[location]> sound:BLOCK_CHISELED_BOOKSHELF_PICKUP
            - repeat 10:
                - playeffect effect:item_crack special_data:book at:<[location].above[0.125]> quantity:1 offset:0.45 velocity:<location[0,0.25,0].random_offset[0.1]>

            # remove other stuff
            - remove <[display_ent]>
            - remove <context.entity>
        on player right clicks place_book_entity*:

            - ratelimit <player> 1t
            # stacks the book if the player is placing a book on a book
            - if <player.item_in_offhand> matches *book && <player.gamemode> != adventure:

                - determine passively cancelled
                - define book <player.item_in_offhand>
                - adjust def:book quantity:0
                - define item <item[player_head]>
                - adjust def:item skull_skin:<script[random_books_for_placing].data_key[books.<[book].material.name>].random>
                - define entity <context.entity>

                - define location <[entity].location>
                - define form snap
                - inject place_book_stack_<[entity].flag[type]>_task
                - stop



            # if the player IS NOT sneaking and NOT in creative show them the book
            - if <player.gamemode> != creative || !<player.is_sneaking>:
                - if <context.entity.flag[attached_book]> matches written_book:
                    - playsound <player> sound:ITEM_BOOK_PAGE_TURN
                    - adjust <player> show_book:<context.entity.flag[attached_book]>
            - else:
                # if they ARE sneaking and in CREATIVE, give them a copy of the book
                - give <context.entity.flag[attached_book]>
        on player flagged:anti_break_block_attached_to_book_flag left clicks block:
            - determine cancelled

PB_place_handler:
    type: task
    debug: false
    script:
        # creates the book to be placed
        - define book <player.item_in_offhand>
        - adjust def:book quantity:0
        - define item <item[player_head]>
        - adjust def:item skull_skin:<script[random_books_for_placing].data_key[books.<[book].material.name>].random>
        - define normal <player.eye_location.ray_trace[return=normal]>

        - if <[normal].y.abs> == 1:
            - define type normal
        - else:
            - define type leaning


        - if !<player.is_sneaking>:
            - define form snap
        - else:
            - define form free

        # Only allows free place in creative mode due to the unrestricted nature of free place
        # this can be disabled for survival to free place books
        - if <player.gamemode> != creative:
            - define form snap

        - inject PB_<[form]>_place


PB_stack_handler:
    type: task
    debug: false
    script:
        - define book <player.item_in_offhand>
        - adjust def:book quantity:0
        - define item <item[player_head]>
        - adjust def:item skull_skin:<script[random_books_for_placing].data_key[books.<[book].material.name>].random>
        - define normal <player.eye_location.ray_trace[return=normal]>

        - if <[normal].y.abs> == 1:
            - define type normal
        - else:
            - define type leaning

        - if !<player.is_sneaking>:
            - define form snap
        - else:
            - define form free

        # Only allows free place in creative mode due to the unrestricted nature of free place
        # this can be disabled for survival to free place books
        - if <player.gamemode> != creative:
            - define form snap

        - inject PB_<[form]>_place

PB_snap_place:
    type: task
    debug: false
    script:
        - if <[type]> == normal:
            # get the book location
            - define location <player.eye_location.ray_trace.add[<[normal].mul[0.1]>].block.add[0.5,1,0.5].with_pitch[90].ray_trace[range=1;default=air]>

            # Will auto stack if another book is occupying this block
            - inject place_book_check_for_valid_book
            - if <[entity].exists>:
                - define location <[entity].location>
                - inject place_book_stack_<[entity].flag[type]>_task
            - else:
                - inject place_book_normal

        - else if <[type]> == leaning:
            # get the book location
            - define location <player.eye_location.ray_trace.sub[<[normal].mul[0.1]>].block.add[<[normal].mul[0.50001].add[0.5,1,0.5]>].with_pitch[90].ray_trace[range=1;default=air]>

            # Will auto stack if another book is occupying this block
            - inject place_book_check_for_valid_book
            - if <[entity].exists>:
                - define location <[entity].location>
                - inject place_book_stack_<[entity].flag[type]>_task
            - else:
                - define translation <[normal].div[3].above[0.26667]>
                - define offset <[normal].mul[0.16667]>
                # randomly chooses between leaning and non-leaning if the book faces a wall
                - random:
                    - inject place_book_sideways
                    - inject place_book_sideways_leaning


PB_free_place:
    type: task
    debug: false
    script:
        - if <[type]> == normal:
            - define location <player.eye_location.ray_trace[entities=place_book_entity*]>
            - inject place_book_normal

        - else if <[type]> == leaning:
            - define location <player.eye_location.ray_trace[entities=place_book_entity*]>
            - define translation <[normal].div[3].above[0.26667]>
            - define offset <[normal].mul[0.16667]>
            - random:
                - inject place_book_sideways
                - inject place_book_sideways_leaning

place_book_stack_normal_task:
    type: task
    debug: false
    script:
        - define above 0
        # checks where the book should be placed on the stack (on the very top)
        # also checks if the book should even have been allowed to be placed there (block obstructions, etc)
        - while <[location].above[<[above]>].find_entities[place_book_entity].within[0.001].any>:
            - define above:+:0.34
        - define location <[location].above[<[above]>]>
        - if <[location].with_pitch[90].ray_trace[fluids=true;nonsolids=true;default=air;range=<[above].sub[0.001]>].backward[0.001].material> !matches *air|water|lava|*slab*|*stairs:
            - stop
        - inject place_book_normal

place_book_stack_leaning_task:
    type: task
    debug: false
    script:
        - define normal <[entity].flag[normal].normalize>
        - define forward 0
        - define location <[location].above[0.0001]>

        # checks where the book should be placed on the stack (on the very top)
        # also checks if the book should even have been allowed to be placed there (block obstructions, etc)
        - while <[location].add[<[normal].mul[<[forward]>]>].find_entities[place_book_entity_sideways*].within[0.001].any>:
            - define repetitions:++
            - define forward:+:0.33333333
        - define location <[location].sub[<[normal].mul[<[entity].width.div[2]>]>].add[<[normal].mul[<[forward].add[0.16666]>]>].face[<[location]>]>
        - if <[location].ray_trace[fluids=true;nonsolids=true;default=air;range=<[forward].sub[0.001]>].backward[0.0001].material> !matches *air|water|lava:
            - stop
        - define offset <location[0,0,0]>
        - define translation <location[0,0.26666,0].add[<[normal].mul[0.16666]>]>
        - inject place_book_sideways


place_book_check_for_valid_book:
    type: task
    debug: false
    script:
        - define entities <[location].find_entities[place_book_entity*].within[0.5]>
        - if <[entities].any>:
            - define entity <[entities].first>



place_book_normal:
    type: task
    debug: false
    script:
        - define translation 0,0.35,0
        - define offset 0,0,0
        - playsound <[location]> sound:BLOCK_CHISELED_BOOKSHELF_INSERT pitch:0.8

        # spawn and adjust the book so it looks nice
        - spawn item_display[item=<[item]>;scale=1,0.66,1;translation=<[translation]>] <[location].random_offset[0.00001].above[0.0001]> save:item
        - spawn place_book_entity <entry[item].spawned_entity.location.add[<[offset]>]> save:interact
        # this needs to be changed to left_rotation... expand on this
        - look <entry[item].spawned_entity> pitch:0 yaw:<player.location.yaw>

        # flag necessary info to the interaction entity
        - define entity <entry[interact].spawned_entity>
        - flag <[entity]> attached_display:<entry[item].spawned_entity>
        - flag <[entity]> attached_book:<[book]>
        - flag <[entity]> type:normal
        - flag <[entity]> form:<[form]>
        - flag <[entity]> normal:<location[0,1,0]>

        - if <player.gamemode> == survival:
            - take slot:41 from:<player.inventory>

place_book_sideways:
    type: task
    debug: false
    script:
        - playsound <[location]> sound:BLOCK_CHISELED_BOOKSHELF_INSERT pitch:0.8

        # get the correct leaning direction in the form of a quaternion
        - define q <[normal].normalize.above.mul[1].xyz>,0
        - define q <[q].as[quaternion].normalize>
        - define normal <[normal].normalize>

        # spawn and adjust the book so it looks nice
        - spawn item_display[item=<[item]>;scale=1,0.66,1;translation=<[translation].div[2]>;left_rotation=<[q]>] <[location].add[<[translation].div[2]>].random_offset[0.0001]> save:item
        - spawn place_book_entity_sideways <[location].add[<[offset]>]> save:interact

        # flag necessary info to the interaction entity
        - define entity <entry[interact].spawned_entity>
        - flag <[entity]> attached_display:<entry[item].spawned_entity>
        - flag <[entity]> attached_book:<[book]>
        - flag <[entity]> type:leaning
        - flag <[entity]> form:<[form]>
        - flag <[entity]> normal:<[normal]>

        - if <player.gamemode> == survival:
            - take slot:41 from:<player.inventory>

place_book_sideways_leaning:
    type: task
    debug: false
    script:
        - define offset <[normal].mul[0.666667]>
        - playsound <[location]> sound:BLOCK_CHISELED_BOOKSHELF_INSERT pitch:0.8


        # get the correct leaning direction in the form of a quaternion
        - define q <[normal].mul[-2].above.xyz>,0
        - define q <[q].as[quaternion].normalize>
        # sideways leaning books have a normal of 2 applied
        - define normal <[normal].normalize.mul[2]>
        - define translation <[translation].sub[<[normal].mul[0.08125]>].below[0.04205]>

        # spawn and adjust the book so it looks nice
        - spawn item_display[item=<[item]>;scale=1,0.66,1;translation=<[translation]>;left_rotation=<[q]>] <[location].add[<[normal].div[600]>]> save:item
        - spawn place_book_entity_sideways_leaning <[location].add[<[offset].mul[0.5]>]> save:interact

        # flag necessary info to the interaction entity
        - define entity <entry[interact].spawned_entity>
        - flag <[entity]> attached_display:<entry[item].spawned_entity>
        - flag <[entity]> attached_book:<[book]>
        - flag <[entity]> type:leaning
        - flag <[entity]> form:<[form]>
        - flag <[entity]> normal:<[normal]>

        - if <player.gamemode> == survival:
            - take slot:41 from:<player.inventory>

place_book_entity:
    type: entity
    entity_type: interaction
    debug: false
    mechanisms:
        height: 0.333333
        width: 0.7125
        is_aware: true

place_book_entity_sideways:
    type: entity
    entity_type: interaction
    debug: false
    mechanisms:
        height: 0.7125
        width: 0.3333334
        is_aware: true

place_book_entity_sideways_leaning:
    type: entity
    entity_type: interaction
    debug: false
    mechanisms:
        height: 0.7125
        width: 0.6666667
        is_aware: true

random_books_for_placing:
    type: data
    debug: false
    books:
        written_book:
            - d73f0a1f-0b47-444a-a03d-302be42d3d67|ewogICJ0aW1lc3RhbXAiIDogMTY5OTc2NTg1OTU4MywKICAicHJvZmlsZUlkIiA6ICJiMGQ3MzJmZTAwZjc0MDdlOWU3Zjc0NjMwMWNkOThjYSIsCiAgInByb2ZpbGVOYW1lIiA6ICJPUHBscyIsCiAgInNpZ25hdHVyZVJlcXVpcmVkIiA6IHRydWUsCiAgInRleHR1cmVzIiA6IHsKICAgICJTS0lOIiA6IHsKICAgICAgInVybCIgOiAiaHR0cDovL3RleHR1cmVzLm1pbmVjcmFmdC5uZXQvdGV4dHVyZS8yYWU5N2Q4ZGI3MTUzZDRkZGYzMGEyN2E4ZTVmY2Y1NDQ0ZmI5OTk3NzdiNmEzY2Y4NjY2ZGExNDI3ZjNkZjIxIgogICAgfQogIH0KfQ==|Vanilla Book 1'
            - 9f9dbe1d-2e9c-4d0c-a082-80b35187996a|ewogICJ0aW1lc3RhbXAiIDogMTY5OTc2NjMxMjMzNSwKICAicHJvZmlsZUlkIiA6ICI0MzFhMmRlYTQ4YTE0NTMxYjEyZDU5MzY0NDUxNmIyNSIsCiAgInByb2ZpbGVOYW1lIiA6ICJpQ2FwdGFpbk5lbW8iLAogICJzaWduYXR1cmVSZXF1aXJlZCIgOiB0cnVlLAogICJ0ZXh0dXJlcyIgOiB7CiAgICAiU0tJTiIgOiB7CiAgICAgICJ1cmwiIDogImh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvYjM2MzUyN2M4ZjU0ODNlY2M2OWM1MTUzNmI5YTUxMDk0ZDU3ZjVjNDM3YmM3YTFmZmY3YjAwMTkyMjg3NzE5NyIKICAgIH0KICB9Cn0=|Quilled Book'
        book:
            - d73f0a1f-0b47-444a-a03d-302be42d3d67|ewogICJ0aW1lc3RhbXAiIDogMTY5OTc2NTg1OTU4MywKICAicHJvZmlsZUlkIiA6ICJiMGQ3MzJmZTAwZjc0MDdlOWU3Zjc0NjMwMWNkOThjYSIsCiAgInByb2ZpbGVOYW1lIiA6ICJPUHBscyIsCiAgInNpZ25hdHVyZVJlcXVpcmVkIiA6IHRydWUsCiAgInRleHR1cmVzIiA6IHsKICAgICJTS0lOIiA6IHsKICAgICAgInVybCIgOiAiaHR0cDovL3RleHR1cmVzLm1pbmVjcmFmdC5uZXQvdGV4dHVyZS8yYWU5N2Q4ZGI3MTUzZDRkZGYzMGEyN2E4ZTVmY2Y1NDQ0ZmI5OTk3NzdiNmEzY2Y4NjY2ZGExNDI3ZjNkZjIxIgogICAgfQogIH0KfQ==|Vanilla Book 1'
            - 9f9dbe1d-2e9c-4d0c-a082-80b35187996a|ewogICJ0aW1lc3RhbXAiIDogMTY5OTc2NjMxMjMzNSwKICAicHJvZmlsZUlkIiA6ICI0MzFhMmRlYTQ4YTE0NTMxYjEyZDU5MzY0NDUxNmIyNSIsCiAgInByb2ZpbGVOYW1lIiA6ICJpQ2FwdGFpbk5lbW8iLAogICJzaWduYXR1cmVSZXF1aXJlZCIgOiB0cnVlLAogICJ0ZXh0dXJlcyIgOiB7CiAgICAiU0tJTiIgOiB7CiAgICAgICJ1cmwiIDogImh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvYjM2MzUyN2M4ZjU0ODNlY2M2OWM1MTUzNmI5YTUxMDk0ZDU3ZjVjNDM3YmM3YTFmZmY3YjAwMTkyMjg3NzE5NyIKICAgIH0KICB9Cn0=|Quilled Book'
        writable_book:
            - 9f9dbe1d-2e9c-4d0c-a082-80b35187996a|ewogICJ0aW1lc3RhbXAiIDogMTY5OTc2NjMxMjMzNSwKICAicHJvZmlsZUlkIiA6ICI0MzFhMmRlYTQ4YTE0NTMxYjEyZDU5MzY0NDUxNmIyNSIsCiAgInByb2ZpbGVOYW1lIiA6ICJpQ2FwdGFpbk5lbW8iLAogICJzaWduYXR1cmVSZXF1aXJlZCIgOiB0cnVlLAogICJ0ZXh0dXJlcyIgOiB7CiAgICAiU0tJTiIgOiB7CiAgICAgICJ1cmwiIDogImh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvYjM2MzUyN2M4ZjU0ODNlY2M2OWM1MTUzNmI5YTUxMDk0ZDU3ZjVjNDM3YmM3YTFmZmY3YjAwMTkyMjg3NzE5NyIKICAgIH0KICB9Cn0=|Quilled Book'
        enchanted_book:
            - a9eb1ca8-2fef-4f60-b640-57cb7876100d|ewogICJ0aW1lc3RhbXAiIDogMTY5OTc2NDQ0Njc0NSwKICAicHJvZmlsZUlkIiA6ICJiM2E3NjExNGVmMzI0ZjYyYWM4NDRiOWJmNTY1NGFiOSIsCiAgInByb2ZpbGVOYW1lIiA6ICJNcmd1eW1hbnBlcnNvbiIsCiAgInNpZ25hdHVyZVJlcXVpcmVkIiA6IHRydWUsCiAgInRleHR1cmVzIiA6IHsKICAgICJTS0lOIiA6IHsKICAgICAgInVybCIgOiAiaHR0cDovL3RleHR1cmVzLm1pbmVjcmFmdC5uZXQvdGV4dHVyZS82NjdmNWIzMGQ2YTNlN2NmMWU1MjhhYzJhNDZhOWM2ODQ2YzYxZjQ5YjllMzY3NDBiMWRiNDE3ZDQxMzI0NTkzIgogICAgfQogIH0KfQ==|Enchanted Book 1'