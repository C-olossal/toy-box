trade_tweak_adjust_trades_task:
    type: task
    debug: false
    script:
        - define inventory <player.open_inventory>
        - define even 0
        - define odd 0
        - define trades <list>
        - repeat 12 as:i:
            - if <[i].mod[2]> != 0:
                - define multiplier <element[1].add[<element[9].mul[<[odd]>]>]>
                - define odd:++
            - else:
                - define multiplier <element[6].add[<element[9].mul[<[even]>]>]>
                - define even:++
            # - narrate <[inventory].slot[<[multiplier]>|<[multiplier].add[1]>]>
            # - narrate <list[<item[air]>|<item[air]>]>
            - if <[inventory].slot[<[multiplier]>|<[multiplier].add[1]>]> == <list[<item[air]>|<item[air]>]>:
                - repeat next

            - define trade trade[inputs=<[inventory].slot[<[multiplier]>|<[multiplier].add[1]>]>;result=<[inventory].slot[<[multiplier].add[3]>]>;uses=1;max_uses=99999;has_xp=false]
            # - adjust def:trade inputs:<[inventory].slot[<[multiplier]>|<[multiplier].add[1]>]>
            # - narrate <[multiplier]>|<[multiplier].add[1]>
            - define trades:->:<[trade]>
        - if <player.flag[trade_tweak_current_villager].villager_experience> < 1:
            - adjust <player.flag[trade_tweak_current_villager]> villager_experience:1
        - if <[trades].any>:
            - adjust <player.flag[trade_tweak_current_villager]> trades:<[trades]>
            - narrate "<&2><bold>Changed Villager trades!"
            - inventory close
        - else:
            - narrate "<&4><bold>No trades were given!"
            - inventory close

trades_example:
    type: task
    definitions: villager
    script:
        # TRADE OFFER:
        # VILLAGER RECEIVES: 1 grass block, 2 emeralds
        # YOU RECEIVE: 32 coal pieces
        # this trade has been used 1 time. It has a max use amount of 99999
        # you will NOT get EXP for this trade
        - definemap my_trade:
            inputs:
                - grass_block
                - emerald[quantity=2]
            result: coal[quantity=32]
            uses: 1
            max_uses: 99999
            has_xp: false

        # this data action adds our trade tag we just created into a list. this is our first entry
        - define trades:->:<[my_trade]>
        # TRADE OFFER:
        # VILLAGER RECEIVES: 1 custom item (my_custom_item) from an item script
        # YOU RECEIVE: 1 diamond
        # this trade has been used 20 times. It has a max use amount of 20, meaning you wouldn't be able to use this trade.
        # you will get EXP for this trade
        - definemap my_trade_2:
            inputs:
                - my_custom_item
                - air
            result: diamond
            uses: 20
            max_uses: 20
            has_xp: true
        # this is our second entry in the list
        - define trades:->:<[my_trade_2]>


        # Adjust the villager's trades. This overwrites any previously existing trades.
        # the villager now has 2 trades! (and only one is actually tradable due to the trade limit)
        - adjust <[villager]> trades:<[trades]>
