event_that_fires_when_the_player_right_clicks_a_villager_with_the_trade_tweak_item:
    type: world
    debug: false
    events:
        on player right clicks villager with:item_trade_tweak:
            - determine passively cancelled
            - ratelimit <player> 1t
            - define villager <context.entity>
            - flag <player> trade_tweak_current_villager:<[villager]> expire:1h
            - inventory open d:trade_tweak_trades_inventory
            - inventory adjust d:<player.open_inventory> slot:5 material:<script[trade_tweak_profession_data].data_key[professions].get[<[villager].profession>]>
            - inventory adjust d:<player.open_inventory> slot:5 "lore:<&f>Currently<&co> <[villager].profession>"
            - inventory adjust d:<player.open_inventory> slot:5 "display:<&f>Change Profession"