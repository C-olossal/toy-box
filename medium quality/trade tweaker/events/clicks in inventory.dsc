player_clicks_in_trade_tweaker_inventory:
    type: world
    debug: false
    events:
        on player clicks item in trade_tweak*:
            # - define inventory <context.clicked_inventory.script>
            - choose <context.clicked_inventory.script.name||null>:
                - default:
                    - stop
                - case trade_tweak_trades_inventory:
                    - inject trade_tweak_trades_inventory_handler_task
                - case trade_tweak_professions_inventory:
                    - inject trade_tweak_professions_inventory_handler_task