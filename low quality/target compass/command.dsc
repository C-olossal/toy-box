target_compass_command:
    type: command
    name: target_compass
    usage: /target_compass (player)
    debug: false
    aliases:
        - tc
    description: Target a player on the server
    tab completions:
        1: <server.online_players.parse[name]>
    script:
        - if !<player.is_op>:
            - narrate "<&4>You don't have access to that command!"
            - stop
        - define args <context.args>
        - if <[args].size> < 1:
            - narrate "USAGE: /target_compass (player)"
            - stop
        - if <[args].size> > 1:
            - narrate "<&4>Too many arguments!"
            - stop
        - if !<player[<[args].get[1]>].exists>:
            - narrate "<&4>This player does not exist!"
            - stop
        - flag server target_compass_current_player:<server.match_player[<[args].get[1]>]>