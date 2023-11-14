item_bounce_bomb:
    type: item
    material: slime_ball
    display name: <&6><bold>Bounce Bomb
    debug: false
    lore:
        - <&b>This bomb can't stop bouncing!
        - <&b>Consumed on use.

bounce_bomb_ability:
    type: world
    debug: false
    events:
        on player left clicks block with:item_bounce_bomb:
            - determine passively cancelled
            - define player <player>
            - playsound <[player].location> sound:ENTITY_EGG_THROW volume:1 pitch:1
            - if <[player].is_sneaking>:
                - define power:0.5
            - else:
                - define power:1.2
            - shoot snowball origin:<[player].eye_location.backward_flat[0.1]> destination:<[player].eye_location.add[<[player].velocity.mul[10]>].forward[10]> speed:<[power]> shooter:<[player]> spread:0 save:bounce_bomb_proj
            - run bounce_bomb_task def.entity:<entry[bounce_bomb_proj].shot_entity> def.bounces:0


bounce_bomb_task:
    type: task
    debug: false
    definitions: entity|bounces
    script:
        - adjust <[entity]> item:slime_ball
        # While the ball is in the air, check its velocity
        # also set where it's looking based on that velocity
        - define location:<[entity].location>
        - while <[entity].is_truthy>:
            - define velocity:<[entity].velocity>
            - look <[entity]> <[location].add[<[velocity].mul[100]>]>
            - define location:<[entity].location>
            - wait 1t
            - playeffect effect:sneeze at:<[location]> visibility:200 quantity:5 offset:0.3
        # After the ball isn't in the air anymore (when it despawns)

        # If the ball is in the void, stop the script
        - if <[location].y> < -128:
            - stop

        # If condition placed here to make the ball do something (can be replaced with your choice, example below)
        # This if condition passes if the ball is moving too slow when it lands
        # - if <[velocity].vector_length> < 0.5:
        # In this case, it'll stop bouncing and explode after 3 bounces
        - define bounces:++
        - if <[bounces]> >= 5:
            - playeffect effect:EXPLOSION_HUGE at:<[location]> visibility:200 quantity:10 offset:2
            - explode power:5 location:<[location]>
            - stop
        - playsound <[location]> sound:BLOCK_SLIME_BLOCK_FALL volume:1 pitch:1
        - playeffect effect:slime at:<[location]> visibility:100 offset:0.3 quantity:100

        # Finds the normal based on the block it hit
        - define hit <[location].backward[1].ray_trace[return=normal;entities=*;raysize=0.3]||null>
        - define velocity_y <[velocity].y>

        # Attempts to the find the normals very close to the original hit location
        # Getting the correct normal ensures the ball cannot get stuck inside a wall
        - repeat 2 as:i:
            - repeat 2 as:j:
                - define hit:->:<[location].backward[1].rotate_pitch[<[i].mul[8].sub[12]>].rotate_yaw[<[j].mul[8].sub[12]>].ray_trace[return=normal]||null>
        - define hit <[hit].exclude[null]>

        # Gets the mode of the list (which ever normal appeared the most) and uses that
        - foreach <[hit]> as:i:
            - define list:->:<[hit].count[<[i]>]>
        - if <[list]||null> != null:
            - define highest:<[list].highest>
            - foreach <[list]> as:i:
                - if <[i]> == <[highest]>:
                    - define hit:<[hit].get[<[i]>]>
                    - foreach stop
                - else:
                    - foreach next
        - else:
        # Fallback in case something goes wrong
            - define hit <[location].backward[1].ray_trace[return=normal;entities=*;raysize=0.3]||null>
        # Second fallback for when things go REALLY wrong
        - if <[hit]> == null:
            - debug log "<&4><bold>Something went wrong with the bouncy ball script!"
            - debug log "<&4><bold>If you'd like, report this as a bug."
            - stop

        # Change one of the velocities depending on the normal
        # Keeps y velocity the same if it hit a wall and not the floor
        # There are plenty of other ways to do this!
        # This is how the ball "bounces"
        - if <[hit].x.abs> > 0:
            - define velocity <[velocity].rotate_around_z[180]>
            - define velocity <[velocity].with_y[<[velocity_y]>]>
            - define hit_location <[location].add[<[hit].mul[0.5]>]>
        - else if <[hit].z.abs> > 0:
            - define velocity <[velocity].rotate_around_x[180]>
            - define velocity <[velocity].with_y[<[velocity_y]>]>
            - define hit_location <[location].add[<[hit].mul[0.5]>]>
        - else if <[hit].y.abs> > 0:
            - define velocity <[velocity].with_y[<[velocity].y.mul[-1]>]>
            - define hit_location <[location]>

        # Make the ball "bounce" by creating a new one at the previous location
        # and applying the velocity that was calculated above
        # Applies only 75% of the calculated velocity to make the ball bounce less
        # applying 100% velocity means the ball will bounce for a very long time
        # since it cannot lose momentum from bouncing
        - spawn snowball origin:<[hit_location]> save:bounce_bomb_proj
        - define entity <entry[bounce_bomb_proj].spawned_entity>
        - adjust <[entity]> item:slime_ball
        - adjust <[entity]> velocity:<[velocity].mul[0.75]>
        - if <[entity].is_truthy>:
            - run bounce_bomb_task def.entity:<[entity]> def.bounces:<[bounces]>