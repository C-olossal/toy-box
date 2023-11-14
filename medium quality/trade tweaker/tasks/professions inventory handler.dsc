trade_tweak_professions_inventory_handler_task:
    type: task
    debug: false
    script:
        - if <player.flag[trade_tweak_current_villager].villager_experience> < 1:
            - adjust <player.flag[trade_tweak_current_villager]> villager_experience:1
        - if <script[trade_tweak_profession_data].data_key[professions].keys.contains_match[<context.item.flag[trade_tweak_profession]||null>]>:
            - narrate "Changed villager to <context.item.flag[trade_tweak_profession]>"
            - inventory open d:trade_tweak_trades_inventory
            - define villager <player.flag[trade_tweak_current_villager]>
            - define trades <[villager].trades>
            - adjust <player.flag[trade_tweak_current_villager]> profession:<context.item.flag[trade_tweak_profession]>
            - inventory adjust d:<player.open_inventory> slot:5 material:<script[trade_tweak_profession_data].data_key[professions].get[<[villager].profession>]>
            - inventory adjust d:<player.open_inventory> slot:5 "lore:<&f>Currently<&co> <[villager].profession>"
            - inventory adjust d:<player.open_inventory> slot:5 "display:<&f>Change Profession"
            - adjust <[villager]> trades:<[trades]>