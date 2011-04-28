create table team
(
        id serial primary key
);

create table player_result
(
        id serial primary key,

        user_id integer not null,

        summoner_name text not null,
        summoner_level integer not null,

        wins integer not null,
        leaves integer not null,
        losses integer not null,

        champion text not null,
        champion_level integer not null,

        kills integer not null,
        deaths integer not null,
        assists integer not null,

        minions_killed integer not null,
        neutral_minions_killed integer not null,

        gold integer not null,

        physical_damage_dealt integer not null,
        physical_damage_taken integer not null,

        magical_damage_dealt integer not null,
        magical_damage_taken integer not null,

        amount_healed integer not null,

        turrets_destroyed integer not null,
        barracks_destroyed integer not null,

        largest_critical_strike integer not null,
        largest_multikill integer not null,
        longest_killing_spree integer not null,

        time_spent_dead integer not null
);

create table team_player
(
        id serial primary key,
        team_id integer references team(id) not null,
        player_id integer references player_result(id) not null
);

create table game_result
(
        id serial primary key,
        game_id integer unique not null,
        time_finished date not null,
        defeated_team_id integer references team(id) not null,
        victorious_team_id integer references team(id) not null
);