trade_tweak_trades_inventory_handler_task:
    type: task
    debug: false
    script:
        - repeat 6 as:i:
            - if <context.slot.sub[<[i].sub[1].mul[9].add[5]>]> == 0:
                - determine passively cancelled
        - if <context.slot> == 5:
            - inventory open d:trade_tweak_professions_inventory
        - if <context.slot> == 50:
            - inject trade_tweak_adjust_trades_task