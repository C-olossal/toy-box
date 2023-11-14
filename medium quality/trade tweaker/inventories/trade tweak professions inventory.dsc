trade_tweak_professions_inventory:
    type: inventory
    inventory: chest
    gui: true
    debug: false
    procedural items:
    - foreach <script[trade_tweak_profession_data].data_key[professions]> as:profession:
        - define item <item[<[profession]>]>
        - adjust def:item display:<&f><script[trade_tweak_profession_data].data_key[professions].keys.get[<[loop_index]>].to_titlecase>
        - adjust def:item flag:trade_tweak_profession:<script[trade_tweak_profession_data].data_key[professions].keys.get[<[loop_index]>]>
        - define list:->:<[item]>
    - determine <[list]>
    slots:
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []