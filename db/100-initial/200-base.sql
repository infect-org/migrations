



        set search_path to infect;




        create table "language" (
              "id" serial not null
            , "alpha2" varchar(2)
            , "alpha3" varchar(3) not null
            , constraint "language_pk"
                primary key ("id")
            , constraint "language_unique_alpha2"
                unique ("alpha2")
            , constraint "language_unique_alpha3"
                unique ("alpha3")
        );


        create table "country" (
              "id" serial not null
            , "alpha2" varchar(2) not null
            , "alpha3" varchar(3) not null
            , constraint "country_pk"
                primary key ("id")
            , constraint "countryunique_alpha2"
                unique ("alpha2")
            , constraint "countryunique_alpha3"
                unique ("alpha3")
        );


        create table "country_language" (
              "id_country" int not null
            , "id_language" int not null
            , constraint "country_language_pk"
                primary key ("id_country", "id_language")
            , constraint "country_language_fk_country"
                foreign key ("id_country")
                references "country" ("id")
                on update cascade
                on delete cascade
            , constraint "country_language_fk_language"
                foreign key ("id_language")
                references "language" ("id")
                on update cascade
                on delete cascade
        );



        create table "locale" (
              "id" serial not null
            , "alpha2" varchar(5)
            , "alpha3" varchar(6) not null
            , "id_language" int not null
            , "id_country" int
            , constraint "locale_pk"
                primary key ("id")
            , constraint "locale_unique_alpha2"
                unique ("alpha2")
            , constraint "locale_unique_alpha3"
                unique ("alpha3")
            , constraint "locale_fk_language"
                foreign key ("id_language")
                references "language"("id")
                on update cascade
                on delete restrict
            , constraint "locale_fk_country"
                foreign key ("id_country")
                references "country"("id")
                on update cascade
                on delete restrict
        );


        -- make sure there are no duplicated, also if the
        -- country is null
        create unique index "locale_unique_language_and_country"
            on "locale" ("id_language", "id_country")
            where "id_country" is not null;

        create unique index "locale_unique_language"
            on "locale" ("id_language")
            where "id_country" is null;



        -- generate the identifier, it consists
        -- out of the language and the uppercase
        -- country: en-GB, de-CH, en, de, cn
        create function "createLocaleIdentifier"() returns trigger as $$
            begin
                if NEW.id_country is null then
                    NEW.alpha2 := (select "alpha2" from "language" where "id" = NEW.id_language);
                    NEW.alpha3 := (select "alpha3" from "language" where "id" = NEW.id_language);
                end if;

                if NEW.id_country is not null then
                    NEW.alpha2 := ((select "alpha2" from "language" where "id" = NEW.id_language) || '-' || (select upper("alpha2") from "country" where "id" = NEW.id_country));
                    NEW.alpha3 := ((select "alpha3" from "language" where "id" = NEW.id_language) || '-' || (select upper("alpha2") from "country" where "id" = NEW.id_country));
                end if;

                return NEW;
            end;
        $$ language plpgsql;


        create trigger "createLocaleIdentifier"
            before insert or update on "locale"
            for each row execute procedure "createLocaleIdentifier"();




        create table "countryLocale" (
              "id_country" int not null
            , "id_locale" int not null
            , "name" varchar(100) not null
            , constraint "countryLocale_pk"
                primary key ("id_country", "id_locale")
            , constraint "countryLocale_unique_country_locale"
                unique("id_country", "id_locale")
            , constraint "countryLocale_fk_country"
                foreign key ("id_country")
                references "country" ("id")
                on update cascade
                on delete restrict
            , constraint "countryLocale_fk_locale"
                foreign key ("id_locale")
                references "locale" ("id")
                on update cascade
                on delete restrict
        );




        create table "languageLocale" (
              "id_language" int not null
            , "id_locale" int not null
            , "name" varchar(100) not null
            , constraint "languageLocale_pk"
                primary key ("id_language", "id_locale")
            , constraint "languageLocaleunique_country_locale"
                unique("id_language", "id_locale")
            , constraint "languageLocale_fk_language"
                foreign key ("id_language")
                references "language" ("id")
                on update cascade
                on delete restrict
            , constraint "clanguageLocale_fk_locale"
                foreign key ("id_locale")
                references "locale" ("id")
                on update cascade
                on delete restrict
        );




        -- lanaguges
        insert into "language" ("alpha2", "alpha3") values ('de', 'deu');
        insert into "language" ("alpha2", "alpha3") values ('en', 'eng');
        insert into "language" ("alpha2", "alpha3") values ('fr', 'fra');
        insert into "language" ("alpha2", "alpha3") values ('it', 'ita');
        insert into "language" ("alpha2", "alpha3") values (null, 'gsw');
        insert into "language" ("alpha2", "alpha3") values ('la', 'lat');

        -- countries
        insert into "country" ("alpha2", "alpha3") values ('ch', 'che');
        insert into "country" ("alpha2", "alpha3") values ('de', 'deu');
        insert into "country" ("alpha2", "alpha3") values ('fr', 'fra');
        insert into "country" ("alpha2", "alpha3") values ('it', 'ita');
        insert into "country" ("alpha2", "alpha3") values ('li', 'lie');
        insert into "country" ("alpha2", "alpha3") values ('us', 'usa');
        insert into "country" ("alpha2", "alpha3") values ('gb', 'gbr');


        -- map languages to countires
        insert into "country_language" ("id_country", "id_language") values (
              (select "id" from "country" where "alpha3" = 'che')
            , (select "id" from "language" where "alpha3" = 'deu')
        );
        insert into "country_language" ("id_country", "id_language") values (
              (select "id" from "country" where "alpha3" = 'che')
            , (select "id" from "language" where "alpha3" = 'fra')
        );
        insert into "country_language" ("id_country", "id_language") values (
              (select "id" from "country" where "alpha3" = 'che')
            , (select "id" from "language" where "alpha3" = 'ita')
        );
        insert into "country_language" ("id_country", "id_language") values (
              (select "id" from "country" where "alpha3" = 'che')
            , (select "id" from "language" where "alpha3" = 'gsw')
        );

        insert into "country_language" ("id_country", "id_language") values (
              (select "id" from "country" where "alpha3" = 'deu')
            , (select "id" from "language" where "alpha3" = 'deu')
        );
        insert into "country_language" ("id_country", "id_language") values (
              (select "id" from "country" where "alpha3" = 'fra')
            , (select "id" from "language" where "alpha3" = 'fra')
        );
        insert into "country_language" ("id_country", "id_language") values (
              (select "id" from "country" where "alpha3" = 'ita')
            , (select "id" from "language" where "alpha3" = 'ita')
        );
        insert into "country_language" ("id_country", "id_language") values (
              (select "id" from "country" where "alpha3" = 'gbr')
            , (select "id" from "language" where "alpha3" = 'eng')
        );
        insert into "country_language" ("id_country", "id_language") values (
              (select "id" from "country" where "alpha3" = 'usa')
            , (select "id" from "language" where "alpha3" = 'eng')
        );


        -- german
        insert into "locale" ("id_language", "id_country") values (
              (select "id" from "language" where "alpha3" = 'deu')
            , null
        );
        insert into "locale" ("id_language", "id_country") values (
              (select "id" from "language" where "alpha3" = 'deu')
            , (select "id" from "country" where "alpha3" = 'che')
        );
        insert into "locale" ("id_language", "id_country") values (
              (select "id" from "language" where "alpha3" = 'deu')
            , (select "id" from "country" where "alpha3" = 'deu')
        );

        -- french
        insert into "locale" ("id_language", "id_country") values (
              (select "id" from "language" where "alpha3" = 'fra')
            , null
        );
        insert into "locale" ("id_language", "id_country") values (
              (select "id" from "language" where "alpha3" = 'fra')
            , (select "id" from "country" where "alpha3" = 'che')
        );
        insert into "locale" ("id_language", "id_country") values (
              (select "id" from "language" where "alpha3" = 'fra')
            , (select "id" from "country" where "alpha3" = 'fra')
        );

        -- italian
        insert into "locale" ("id_language", "id_country") values (
              (select "id" from "language" where "alpha3" = 'ita')
            , null
        );
        insert into "locale" ("id_language", "id_country") values (
              (select "id" from "language" where "alpha3" = 'ita')
            , (select "id" from "country" where "alpha3" = 'che')
        );
        insert into "locale" ("id_language", "id_country") values (
              (select "id" from "language" where "alpha3" = 'ita')
            , (select "id" from "country" where "alpha3" = 'ita')
        );

        -- english
        insert into "locale" ("id_language", "id_country") values (
              (select "id" from "language" where "alpha3" = 'eng')
            , null
        );
        insert into "locale" ("id_language", "id_country") values (
              (select "id" from "language" where "alpha3" = 'eng')
            , (select "id" from "country" where "alpha3" = 'usa')
        );
        insert into "locale" ("id_language", "id_country") values (
              (select "id" from "language" where "alpha3" = 'eng')
            , (select "id" from "country" where "alpha3" = 'gbr')
        );

        -- latin
        insert into "locale" ("id_language", "id_country") values (
              (select "id" from "language" where "alpha3" = 'lat')
            , null
        );

        -- swiss german
        insert into "locale" ("id_language", "id_country") values (
              (select "id" from "language" where "alpha3" = 'gsw')
            , null
        );


        -- language locale
        insert into "languageLocale" ("id_language", "id_locale", "name") values (
              (select "id" from "language" where "alpha3" = 'deu')
            , (select "id" from "locale" where "alpha3" = 'deu')
            , 'Deutsch'
        );
        insert into "languageLocale" ("id_language", "id_locale", "name") values (
              (select "id" from "language" where "alpha3" = 'deu')
            , (select "id" from "locale" where "alpha3" = 'fra')
            , 'Allemand'
        );
        insert into "languageLocale" ("id_language", "id_locale", "name") values (
              (select "id" from "language" where "alpha3" = 'deu')
            , (select "id" from "locale" where "alpha3" = 'ita')
            , 'Tedesco'
        );
        insert into "languageLocale" ("id_language", "id_locale", "name") values (
              (select "id" from "language" where "alpha3" = 'deu')
            , (select "id" from "locale" where "alpha3" = 'gsw')
            , 'Dütsch'
        );
        insert into "languageLocale" ("id_language", "id_locale", "name") values (
              (select "id" from "language" where "alpha3" = 'deu')
            , (select "id" from "locale" where "alpha3" = 'eng')
            , 'German'
        );


        insert into "languageLocale" ("id_language", "id_locale", "name") values (
              (select "id" from "language" where "alpha3" = 'fra')
            , (select "id" from "locale" where "alpha3" = 'deu')
            , 'Französisch'
        );
        insert into "languageLocale" ("id_language", "id_locale", "name") values (
              (select "id" from "language" where "alpha3" = 'fra')
            , (select "id" from "locale" where "alpha3" = 'fra')
            , 'Français'
        );
        insert into "languageLocale" ("id_language", "id_locale", "name") values (
              (select "id" from "language" where "alpha3" = 'fra')
            , (select "id" from "locale" where "alpha3" = 'ita')
            , 'Francese'
        );
        insert into "languageLocale" ("id_language", "id_locale", "name") values (
              (select "id" from "language" where "alpha3" = 'fra')
            , (select "id" from "locale" where "alpha3" = 'gsw')
            , 'Französisch'
        );
        insert into "languageLocale" ("id_language", "id_locale", "name") values (
              (select "id" from "language" where "alpha3" = 'fra')
            , (select "id" from "locale" where "alpha3" = 'eng')
            , 'French'
        );


        insert into "languageLocale" ("id_language", "id_locale", "name") values (
              (select "id" from "language" where "alpha3" = 'ita')
            , (select "id" from "locale" where "alpha3" = 'deu')
            , 'Italienisch'
        );
        insert into "languageLocale" ("id_language", "id_locale", "name") values (
              (select "id" from "language" where "alpha3" = 'ita')
            , (select "id" from "locale" where "alpha3" = 'fra')
            , 'Italien'
        );
        insert into "languageLocale" ("id_language", "id_locale", "name") values (
              (select "id" from "language" where "alpha3" = 'ita')
            , (select "id" from "locale" where "alpha3" = 'ita')
            , 'Italiano'
        );
        insert into "languageLocale" ("id_language", "id_locale", "name") values (
              (select "id" from "language" where "alpha3" = 'ita')
            , (select "id" from "locale" where "alpha3" = 'gsw')
            , 'Italiänisch'
        );
        insert into "languageLocale" ("id_language", "id_locale", "name") values (
              (select "id" from "language" where "alpha3" = 'ita')
            , (select "id" from "locale" where "alpha3" = 'eng')
            , 'Italian'
        );


        insert into "languageLocale" ("id_language", "id_locale", "name") values (
              (select "id" from "language" where "alpha3" = 'eng')
            , (select "id" from "locale" where "alpha3" = 'deu')
            , 'Englisch'
        );
        insert into "languageLocale" ("id_language", "id_locale", "name") values (
              (select "id" from "language" where "alpha3" = 'eng')
            , (select "id" from "locale" where "alpha3" = 'fra')
            , 'Anglais'
        );
        insert into "languageLocale" ("id_language", "id_locale", "name") values (
              (select "id" from "language" where "alpha3" = 'eng')
            , (select "id" from "locale" where "alpha3" = 'ita')
            , 'Inglese'
        );
        insert into "languageLocale" ("id_language", "id_locale", "name") values (
              (select "id" from "language" where "alpha3" = 'eng')
            , (select "id" from "locale" where "alpha3" = 'gsw')
            , 'Änglisch'
        );
        insert into "languageLocale" ("id_language", "id_locale", "name") values (
              (select "id" from "language" where "alpha3" = 'eng')
            , (select "id" from "locale" where "alpha3" = 'eng')
            , 'English'
        );


        insert into "languageLocale" ("id_language", "id_locale", "name") values (
              (select "id" from "language" where "alpha3" = 'lat')
            , (select "id" from "locale" where "alpha3" = 'deu')
            , 'Latein'
        );
        insert into "languageLocale" ("id_language", "id_locale", "name") values (
              (select "id" from "language" where "alpha3" = 'lat')
            , (select "id" from "locale" where "alpha3" = 'fra')
            , 'Latin'
        );
        insert into "languageLocale" ("id_language", "id_locale", "name") values (
              (select "id" from "language" where "alpha3" = 'lat')
            , (select "id" from "locale" where "alpha3" = 'ita')
            , 'Latino'
        );
        insert into "languageLocale" ("id_language", "id_locale", "name") values (
              (select "id" from "language" where "alpha3" = 'lat')
            , (select "id" from "locale" where "alpha3" = 'gsw')
            , 'Latin'
        );
        insert into "languageLocale" ("id_language", "id_locale", "name") values (
              (select "id" from "language" where "alpha3" = 'lat')
            , (select "id" from "locale" where "alpha3" = 'eng')
            , 'Latin'
        );
        insert into "languageLocale" ("id_language", "id_locale", "name") values (
              (select "id" from "language" where "alpha3" = 'lat')
            , (select "id" from "locale" where "alpha3" = 'lat')
            , 'Latinae'
        );



        -- country locale
        insert into "countryLocale" ("id_country", "id_locale", "name") values (
              (select "id" from "country" where "alpha3" = 'che')
            , (select "id" from "locale" where "alpha3" = 'deu')
            , 'Schweiz'
        );
        insert into "countryLocale" ("id_country", "id_locale", "name") values (
              (select "id" from "country" where "alpha3" = 'che')
            , (select "id" from "locale" where "alpha3" = 'eng')
            , 'Switzerland'
        );
        insert into "countryLocale" ("id_country", "id_locale", "name") values (
              (select "id" from "country" where "alpha3" = 'che')
            , (select "id" from "locale" where "alpha3" = 'fra')
            , 'Suisse'
        );
        insert into "countryLocale" ("id_country", "id_locale", "name") values (
              (select "id" from "country" where "alpha3" = 'che')
            , (select "id" from "locale" where "alpha3" = 'ita')
            , 'Svizzera'
        );
        insert into "countryLocale" ("id_country", "id_locale", "name") values (
              (select "id" from "country" where "alpha3" = 'che')
            , (select "id" from "locale" where "alpha3" = 'gsw')
            , 'Schwiz'
        );

        insert into "countryLocale" ("id_country", "id_locale", "name") values (
              (select "id" from "country" where "alpha3" = 'deu')
            , (select "id" from "locale" where "alpha3" = 'deu')
            , 'Deutschland'
        );
        insert into "countryLocale" ("id_country", "id_locale", "name") values (
              (select "id" from "country" where "alpha3" = 'deu')
            , (select "id" from "locale" where "alpha3" = 'eng')
            , 'Germany'
        );
        insert into "countryLocale" ("id_country", "id_locale", "name") values (
              (select "id" from "country" where "alpha3" = 'deu')
            , (select "id" from "locale" where "alpha3" = 'fra')
            , 'Allemagne'
        );
        insert into "countryLocale" ("id_country", "id_locale", "name") values (
              (select "id" from "country" where "alpha3" = 'deu')
            , (select "id" from "locale" where "alpha3" = 'ita')
            , 'Germania'
        );
        insert into "countryLocale" ("id_country", "id_locale", "name") values (
              (select "id" from "country" where "alpha3" = 'deu')
            , (select "id" from "locale" where "alpha3" = 'gsw')
            , 'Dütschland'
        );

        insert into "countryLocale" ("id_country", "id_locale", "name") values (
              (select "id" from "country" where "alpha3" = 'fra')
            , (select "id" from "locale" where "alpha3" = 'deu')
            , 'Frankreich'
        );
        insert into "countryLocale" ("id_country", "id_locale", "name") values (
              (select "id" from "country" where "alpha3" = 'fra')
            , (select "id" from "locale" where "alpha3" = 'eng')
            , 'France'
        );
        insert into "countryLocale" ("id_country", "id_locale", "name") values (
              (select "id" from "country" where "alpha3" = 'fra')
            , (select "id" from "locale" where "alpha3" = 'fra')
            , 'France'
        );
        insert into "countryLocale" ("id_country", "id_locale", "name") values (
              (select "id" from "country" where "alpha3" = 'fra')
            , (select "id" from "locale" where "alpha3" = 'ita')
            , 'Francia'
        );
        insert into "countryLocale" ("id_country", "id_locale", "name") values (
              (select "id" from "country" where "alpha3" = 'fra')
            , (select "id" from "locale" where "alpha3" = 'gsw')
            , 'Frankrich'
        );

        insert into "countryLocale" ("id_country", "id_locale", "name") values (
              (select "id" from "country" where "alpha3" = 'ita')
            , (select "id" from "locale" where "alpha3" = 'deu')
            , 'Italien'
        );
        insert into "countryLocale" ("id_country", "id_locale", "name") values (
              (select "id" from "country" where "alpha3" = 'ita')
            , (select "id" from "locale" where "alpha3" = 'eng')
            , 'Italy'
        );
        insert into "countryLocale" ("id_country", "id_locale", "name") values (
              (select "id" from "country" where "alpha3" = 'ita')
            , (select "id" from "locale" where "alpha3" = 'fra')
            , 'Italie'
        );
        insert into "countryLocale" ("id_country", "id_locale", "name") values (
              (select "id" from "country" where "alpha3" = 'ita')
            , (select "id" from "locale" where "alpha3" = 'ita')
            , 'Italia'
        );
        insert into "countryLocale" ("id_country", "id_locale", "name") values (
              (select "id" from "country" where "alpha3" = 'ita')
            , (select "id" from "locale" where "alpha3" = 'gsw')
            , 'Italie'
        );

        insert into "countryLocale" ("id_country", "id_locale", "name") values (
              (select "id" from "country" where "alpha3" = 'lie')
            , (select "id" from "locale" where "alpha3" = 'deu')
            , 'Liechtenstein'
        );
        insert into "countryLocale" ("id_country", "id_locale", "name") values (
              (select "id" from "country" where "alpha3" = 'lie')
            , (select "id" from "locale" where "alpha3" = 'eng')
            , 'Liechtenstein'
        );
        insert into "countryLocale" ("id_country", "id_locale", "name") values (
              (select "id" from "country" where "alpha3" = 'lie')
            , (select "id" from "locale" where "alpha3" = 'fra')
            , 'Liechtenstein'
        );
        insert into "countryLocale" ("id_country", "id_locale", "name") values (
              (select "id" from "country" where "alpha3" = 'lie')
            , (select "id" from "locale" where "alpha3" = 'ita')
            , 'Liechtenstein'
        );
        insert into "countryLocale" ("id_country", "id_locale", "name") values (
              (select "id" from "country" where "alpha3" = 'lie')
            , (select "id" from "locale" where "alpha3" = 'gsw')
            , 'Liechtestei'
        );

        insert into "countryLocale" ("id_country", "id_locale", "name") values (
              (select "id" from "country" where "alpha3" = 'gbr')
            , (select "id" from "locale" where "alpha3" = 'deu')
            , 'Grossbritanien'
        );
        insert into "countryLocale" ("id_country", "id_locale", "name") values (
              (select "id" from "country" where "alpha3" = 'gbr')
            , (select "id" from "locale" where "alpha3" = 'eng')
            , 'Great Britain'
        );
        insert into "countryLocale" ("id_country", "id_locale", "name") values (
              (select "id" from "country" where "alpha3" = 'gbr')
            , (select "id" from "locale" where "alpha3" = 'fra')
            , 'Grande-Bretagne'
        );
        insert into "countryLocale" ("id_country", "id_locale", "name") values (
              (select "id" from "country" where "alpha3" = 'gbr')
            , (select "id" from "locale" where "alpha3" = 'ita')
            , 'Gran Bretagna'
        );
        insert into "countryLocale" ("id_country", "id_locale", "name") values (
              (select "id" from "country" where "alpha3" = 'gbr')
            , (select "id" from "locale" where "alpha3" = 'gsw')
            , 'Grossbritannie'
        );

        insert into "countryLocale" ("id_country", "id_locale", "name") values (
              (select "id" from "country" where "alpha3" = 'usa')
            , (select "id" from "locale" where "alpha3" = 'deu')
            , 'USA'
        );
        insert into "countryLocale" ("id_country", "id_locale", "name") values (
              (select "id" from "country" where "alpha3" = 'usa')
            , (select "id" from "locale" where "alpha3" = 'eng')
            , 'USA'
        );
        insert into "countryLocale" ("id_country", "id_locale", "name") values (
              (select "id" from "country" where "alpha3" = 'usa')
            , (select "id" from "locale" where "alpha3" = 'fra')
            , 'USA'
        );
        insert into "countryLocale" ("id_country", "id_locale", "name") values (
              (select "id" from "country" where "alpha3" = 'usa')
            , (select "id" from "locale" where "alpha3" = 'ita')
            , E'Stati Uniti d\'America'
        );
        insert into "countryLocale" ("id_country", "id_locale", "name") values (
              (select "id" from "country" where "alpha3" = 'usa')
            , (select "id" from "locale" where "alpha3" = 'gsw')
            , 'Staatä'
        );


