railGunItem:
  type: item
  material: diamond_axe
  display name: <&4><bold>Railgun
  debug: true
  lore:
    - <&b>A mystical Weapon that
    - <&b>eliminates anything in it's path.
    - ""
    - <&5><&l>Right Click:<&d> Rail Beam
    - <&9>Charges up a beam that kills anything
    - <&9>in it's path. Major kickback.
    - ""
    - <&6><bold>LEGENDARY
  mechanisms:
    unbreakable: true
    flags: HIDE_ENCHANTS
    quantity: 1
  enchantments:
    - damage_all: 8

railGunAbility:
  type: world
  debug: true
  events:
    on player right clicks block with:railGunItem:

      # Damage. For if whatever reason you didn't want a railgun to instantly smite the target...
      # default = 9999

      - define damage:9999

      # How much time you need to wait before using the ability again. Use t for ticks and s for seconds. (20t = 1s)
      # default = 53t
    
      - define cooldown:53t

      # How long it takes to fire. Setting this to zero makes it instantly activate. chargeUp does not need a time, it is automatically converted into ticks.
      # default = 33

      - define chargeUp:33

      # Controls the sound that plays while the weapon charges up. Set this to zero to turn off the volume.
      # default = 0.8

      - define chargeUpVolume:0.8

      # This number is equal a block's length. Making the range very long (over 100 blocks in most cases) can cause lag/crashes.
      # default = 50

      - define range:50

      # This number launches the player exponentially.
      # Setting this number negative will launch you forward. Setting this number very high can cause weird kickback angles.
      # default = 4

      - define kickback:4

      - if <player.has_flag[railGun_Anti_Spam]>:
        - stop
      - flag <player> railGun_Anti_Spam duration:0.3s
      - if <player.has_flag[railGun_cooldown]>:
        - narrate "<bold><&c>Ability refreshes in <player.flag_expiration[railGun_cooldown].from_now>s" <player>
        - stop
      - flag <player> railGun_cooldown duration:<[cooldown]>
      - flag <player> railGunCharge:!
      - repeat <[chargeUp]>:
          - flag <player> railGunCharge:+:0.09
          - playsound <player> sound:ENTITY_IRON_GOLEM_ATTACK volume:<[chargeUpVolume]> pitch:<player.flag[railGunCharge]>
          - wait 1t
      - if <player.item_in_hand> != <context.item>:
        - stop
      - define bubbleLocation:<player.eye_location.forward[<[range]>]>
      - foreach <player.eye_location.points_between[<[bubbleLocation]>].distance[1.0]> as:bubbleExact:
        - playsound <[bubbleExact]> sound:ENTITY_EVOKER_PREPARE_SUMMON volume:0.6 pitch:2
        - playsound <[bubbleExact]> sound:ENTITY_GENERIC_EXPLODE volume:0.3 pitch:0.4
        - playeffect effect:FIREWORKS_SPARK at:<[bubbleExact]> visibility:200 quantity:8 offset:0.17
        - foreach <[bubbleExact].find.living_entities.within[1.2].exclude[<player>]> as:target:
          - if <entity[<[target]>].entity_type> == ARMOR_STAND || <entity[<[target]>].entity_type> == VILLAGER || <entity[<[target]>].entity_type> == WANDERING_TRADER:
            - foreach next
          - hurt <[damage]> <[target]> cause:VOID source:<player>
      - push <player> destination:<player.location.backward[<[kickback]>]> speed:<[kickback]> duration:1t no_rotate no_damage