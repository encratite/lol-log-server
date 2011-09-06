drop table if exists team cascade;

create table team
(
        id serial primary key
);

drop table if exists player_result cascade;

create table player_result
(
        id serial primary key,

        summoner_name text not null,
        summoner_level integer not null,

        wins integer not null,
        losses integer not null,
        leaves integer not null,

        champion text not null,
        champion_level integer not null,

        kills integer not null,
        deaths integer not null,
        assists integer not null,

        --the following values are no longer always available

        minions_killed integer,
        neutral_minions_killed integer,

        gold integer,

        physical_damage_dealt integer,
        physical_damage_taken integer,

        magical_damage_dealt integer,
        magical_damage_taken integer,

        amount_healed integer,

        turrets_destroyed integer,
        barracks_destroyed integer,

        largest_critical_strike integer,
        largest_multikill integer,
        longest_killing_spree integer,

        time_spent_dead integer,

        item0 integer,
        item1 integer,
        item2 integer,
        item3 integer,
        item4 integer,
        item5 integer
);

drop table if exists team_player cascade;

create table team_player
(
        id serial primary key,
        team_id integer references team(id) not null,
        player_id integer references player_result(id) not null
);

drop table if exists game_result cascade;

create table game_result
(
        id serial primary key,

        log_data text not null,

        log_hash bytea unique not null,

        time_finished timestamp not null,

        game_mode text not null,
        game_type text not null,

        queue_type text not null,
        duration integer not null,

        elo integer not null,
        elo_change integer not null,

        ip_earned integer not null,

        player_was_victorious boolean not null,

        defeated_team_id integer references team(id) not null,
        victorious_team_id integer references team(id) not null,

        upload_time timestamp default now(),
        uploader_address text not null
);