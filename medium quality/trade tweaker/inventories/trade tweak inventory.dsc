trade_tweak_trades_inventory:
    type: inventory
    inventory: chest
    debug: false
    size: 54
    procedural items:
    - define trades <player.flag[trade_tweak_current_villager].trades||<list>>
    - if <[trades].any>:
        - foreach <[trades]> as:trade:
            - define inputs <[trade].inputs>
            - define result <[trade].result>
            - define list:->:<[inputs]>
            - define list:->:<[result]>
            - define list <[list].combine>
    - else:
        - define list <list>
    # Add some logic!
    - determine <[list]>
    slots:
    - [] [] [black_stained_glass_pane] [] [stick] [] [] [black_stained_glass_pane] []
    - [] [] [black_stained_glass_pane] [] [] [] [] [black_stained_glass_pane] []
    - [] [] [black_stained_glass_pane] [] [] [] [] [black_stained_glass_pane] []
    - [] [] [black_stained_glass_pane] [] [] [] [] [black_stained_glass_pane] []
    - [] [] [black_stained_glass_pane] [] [] [] [] [black_stained_glass_pane] []
    - [] [] [black_stained_glass_pane] [] [trade_tweak_CONFIRM_gui_item] [] [] [black_stained_glass_pane] []