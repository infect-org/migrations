


        set search_path to infect;





        create table "genus" (
              "id" serial not null
            , "identifier" varchar(100) not null
            , "name" varchar(100) not null
            , constraint "genus_pk"
                primary key ("id")
            , constraint "genus_unique_identifier"
                unique ("identifier")
        );


        create table "species" (
              "id" serial not null
            , "id_genus" int not null
            , "identifier" varchar(100) not null
            , "name" varchar(50) not null
            , constraint "species_pk"
                primary key ("id")
            , constraint "species_unique_identifier"
                unique ("identifier")
            , constraint "species_fk_genus"
                foreign key ("id_genus")
                references "genus"("id")
                on update cascade
                on delete restrict
        );




        create table "grouping" (
              "id" serial not null
            , "identifier" varchar(100) not null
            , constraint "grouping_pk"
                primary key ("id")
            , constraint "grouping_unique_identifier"
                unique ("identifier")
        );

        create table "groupingLocale" (
              "id_grouping" int not null
            , "id_locale" int not null
            , "name" varchar(100) not null
            , constraint "groupingLocale_pk"
                primary key ("id_grouping", "id_locale")
            , constraint "groupingLocale_fk_grouping"
                foreign key ("id_grouping")
                references "grouping" ("id")
                on update cascade
                on delete cascade
            , constraint "groupingLocale_fk_locale"
                foreign key ("id_locale")
                references "locale" ("id")
                on update cascade
                on delete restrict
        );




        create table "shape" (
              "id" serial not null
            , "identifier" varchar(100) not null
            , constraint "shape_pk"
                primary key ("id")
            , constraint "shape_unique_identifier"
                unique ("identifier")
        );

        create table "shapeLocale" (
              "id_shape" int not null
            , "id_locale" int not null
            , "name" varchar(100) not null
            , constraint "shapeLocale_pk"
                primary key ("id_shape", "id_locale")
            , constraint "shapeLocale_fk_shape"
                foreign key ("id_shape")
                references "shape" ("id")
                on update cascade
                on delete cascade
            , constraint "shapeLocale_fk_locale"
                foreign key ("id_locale")
                references "locale" ("id")
                on update cascade
                on delete restrict
        );





        create table "bacteria" (
              "id" serial not null
            , "id_species" int not null
            , "id_shape" int
            , "id_grouping" int
            , "gram" boolean
            , "aerobic" boolean not null
            , "aerobicOptional" boolean not null
            , "anaerobic" boolean not null
            , "anaerobicOptional" boolean not null
            , constraint "bacteria_pk"
                primary key ("id")
            , constraint "bacteria_fk_species"
                foreign key ("id_species")
                references "species" ("id")
                on update cascade
                on delete restrict
            , constraint "bacteria_fk_shape"
                foreign key ("id_shape")
                references "shape" ("id")
                on update cascade
                on delete restrict
            , constraint "bacteria_fk_grouping"
                foreign key ("id_grouping")
                references "grouping" ("id")
                on update cascade
                on delete restrict
        );

        create table "bacteriaLocale" (
              "id_bacteria" int not null
            , "id_locale" int not null
            , "name" varchar(100) not null
            , constraint "bacteriaLocale_pk"
                primary key ("id_bacteria", "id_locale")
            , constraint "bacteriaLocale_fk_bacteria"
                foreign key ("id_bacteria")
                references "bacteria" ("id")
                on update cascade
                on delete cascade
            , constraint "bacteriaLocale_fk_locale"
                foreign key ("id_locale")
                references "locale" ("id")
                on update cascade
                on delete restrict
        );




        create table "compound" (
              "id" serial not null
            , "identifier" varchar(200)
            , "perOs" boolean not null
            , "intraVenous" boolean not null
            , constraint "compound_pk"
                primary key ("id")
        );

        create table "compoundLocale" (
              "id_compound" int not null
            , "id_locale" int not null
            , "name" varchar(100) not null
            , constraint "compoundLocale_pk"
                primary key ("id_compound", "id_locale")
            , constraint "compoundLocale_fk_compound"
                foreign key ("id_compound")
                references "compound" ("id")
                on update cascade
                on delete cascade
            , constraint "compoundLocale_fk_locale"
                foreign key ("id_locale")
                references "locale" ("id")
                on update cascade
                on delete restrict
        );




        create table "substance" (
              "id" serial not null
            , "identifier" varchar(100) not null
            , constraint "substance_pk"
                primary key ("id")
            , constraint "substance_unique_identifier"
                unique ("identifier")
        );

        create table "substanceLocale" (
              "id_substance" int not null
            , "id_locale" int not null
            , "name" varchar(100) not null
            , constraint "substanceLocale_pk"
                primary key ("id_substance", "id_locale")
            , constraint "substanceLocale_fk_substance"
                foreign key ("id_substance")
                references "substance" ("id")
                on update cascade
                on delete cascade
            , constraint "substanceLocale_fk_locale"
                foreign key ("id_locale")
                references "locale" ("id")
                on update cascade
                on delete restrict
        );




        create table "substanceClass" (
              "id" serial not null
            , "identifier" varchar(100) not null
            , "left" int not null
            , "right" int not null
            , constraint "substanceClass_pk"
                primary key ("id")
            , check ("left" < "right")
        );

        create table "substanceClassLocale" (
              "id_substanceClass" int not null
            , "id_locale" int not null
            , "name" varchar(100) not null
            , constraint "substanceClassLocale_pk"
                primary key ("id_substanceClass", "id_locale")
            , constraint "substanceClassLocale_fk_substanceClass"
                foreign key ("id_substanceClass")
                references "substanceClass" ("id")
                on update cascade
                on delete cascade
            , constraint "substanceClassLocale_fk_locale"
                foreign key ("id_locale")
                references "locale" ("id")
                on update cascade
                on delete restrict
        );




        create table "substance_substanceClass" (
              "id_substance" int not null
            , "id_substanceClass" int not null
            , constraint "substance_substanceClass_pk"
                primary key ("id_substanceClass", "id_substance")
            , constraint "substance_substanceClass_fk_substanceClass"
                foreign key ("id_substanceClass")
                references "substanceClass" ("id")
                on update cascade
                on delete restrict
            , constraint "substance_substanceClass_fk_substance"
                foreign key ("id_substance")
                references "substance" ("id")
                on update cascade
                on delete restrict
        );




        create table "substance_compound" (
              "id_substance" int not null
            , "id_compound" int not null
            , constraint "substance_compound_pk"
                primary key ("id_compound", "id_substance")
            , constraint "substance_compound_fk_compound"
                foreign key ("id_compound")
                references "compound" ("id")
                on update cascade
                on delete restrict
            , constraint "substance_compound_fk_substance"
                foreign key ("id_substance")
                references "substance" ("id")
                on update cascade
                on delete restrict
        );





        -- autogenerate the compound identifier
        create function "createCompoundIdentifier"() returns trigger as $$
            begin
                update "infect"."compound" set "identifier" = (
                    select string_agg(t."identifier", '/') "identifier"
                      from (
                        select s."identifier",
                               sc."id_compound"
                         from "infect"."substance_compound" sc
                         join "infect"."substance" s
                           on s."id" = sc."id_substance"
                        where sc."id_compound" = coalesce(NEW."id_compound", OLD."id_compound")
                     order by s."identifier") t
                  group by t."id_compound")
                where "id" = coalesce(NEW."id_compound", OLD."id_compound");

                return NEW;
            end;
        $$ language plpgsql;


        create trigger "createCompoundIdentifier"
            after insert or update or delete on "substance_compound"
            for each row execute procedure "createCompoundIdentifier"();






        create table "dataSource" (
              "id" serial not null
            , "identifier" varchar (50) not null
            , constraint "dataSource_pk"
                primary key ("id")
            , constraint "dataSource_unique_identifier"
                unique ("identifier")
        );

        insert into "dataSource" ("identifier") values ('defaultValue');
        insert into "dataSource" ("identifier") values ('classDefaultValue');
        insert into "dataSource" ("identifier") values ('userDefinedValue');
        insert into "dataSource" ("identifier") values ('anresis-search');



        create table "sex" (
              "id" serial not null
            , "identifier" varchar (50) not null
            , constraint "sex_pk"
                primary key ("id")
            , constraint "sex_unique_identifier"
                unique ("identifier")
        );

        insert into "sex" ("identifier") values ('female');
        insert into "sex" ("identifier") values ('male');
        insert into "sex" ("identifier") values ('unknown');
        insert into "sex" ("identifier") values ('other');


        create table "gender" (
              "id" serial not null
            , "identifier" varchar (50) not null
            , constraint "gender_pk"
                primary key ("id")
            , constraint "gender_unique_identifier"
                unique ("identifier")
        );

        insert into "gender" ("identifier") values ('female');
        insert into "gender" ("identifier") values ('male');
        insert into "gender" ("identifier") values ('other');





        create table "resistanceLevel" (
              "id" serial not null
            , "identifier" varchar (50) not null
            , constraint "resistanceLevel_pk"
                primary key ("id")
            , constraint "resistanceLevel_unique_identifier"
                unique ("identifier")
        );

        insert into "resistanceLevel" ("identifier") values ('custom');
        insert into "resistanceLevel" ("identifier") values ('suspectible');
        insert into "resistanceLevel" ("identifier") values ('intermediate');
        insert into "resistanceLevel" ("identifier") values ('resistant');






        create table "tenant" (
              "id" serial not null
            , "identifier" varchar (50) not null
            , constraint "tenant_pk"
                primary key ("id")
            , constraint "tenant_unique_identifier"
                unique ("identifier")
        );

        insert into "resistanceLevel" ("identifier") values ('insel-spital');







        create table "city" (
              "id" serial not null
            , "zip" varchar (50) not null
            , "lat" numeric(17,14) not null
            , "lng" numeric(17,14) not null
            , constraint "city_pk"
                primary key ("id")
            , constraint "city_unique_zip"
                unique ("zip")
        );

        create table "cityLocale" (
              "id_city" int not null
            , "id_locale" int not null
            , "name" varchar(100) not null
            , constraint "cityLocale_pk"
                primary key ("id_city", "id_locale")
            , constraint "cityLocale_fk_city"
                foreign key ("id_city")
                references "city" ("id")
                on update cascade
                on delete cascade
            , constraint "cityLocale_fk_locale"
                foreign key ("id_locale")
                references "locale" ("id")
                on update cascade
                on delete restrict
        );




        create table "region" (
              "id" serial not null
            , "identifier" varchar (50) not null
            , constraint "region_pk"
                primary key ("id")
            , constraint "region_unique_identifier"
                unique ("identifier")
        );

        create table "regionLocale" (
              "id_region" int not null
            , "id_locale" int not null
            , "name" varchar(100) not null
            , constraint "regionLocale_pk"
                primary key ("id_region", "id_locale")
            , constraint "regionLocale_fk_region"
                foreign key ("id_region")
                references "region" ("id")
                on update cascade
                on delete cascade
            , constraint "regionLocale_fk_locale"
                foreign key ("id_locale")
                references "locale" ("id")
                on update cascade
                on delete restrict
        );


        insert into "region" ("identifier") values ('switzerland-east');
        insert into "region" ("identifier") values ('switzerland-central');
        insert into "region" ("identifier") values ('switzerland-west');
        insert into "region" ("identifier") values ('global');



        create table "region_city" (
              "id_region" int not null
            , "id_city" int not null
            , "name" varchar(100) not null
            , constraint "region_city_pk"
                primary key ("id_region", "id_city")
            , constraint "region_city_fk_region"
                foreign key ("id_region")
                references "region" ("id")
                on update cascade
                on delete restrict
            , constraint "region_city_fk_city"
                foreign key ("id_city")
                references "city" ("id")
                on update cascade
                on delete restrict
        );



        create table "organGroup" (
              "id" serial not null
            , "identifier" varchar (50) not null
            , constraint "organGroup_pk"
                primary key ("id")
            , constraint "organGroup_unique_identifier"
                unique ("identifier")
        );

        create table "organGroupLocale" (
              "id_organGroup" int not null
            , "id_locale" int not null
            , "name" varchar(100) not null
            , constraint "organGroupLocale_pk"
                primary key ("id_organGroup", "id_locale")
            , constraint "organGroupLocale_fk_organGroup"
                foreign key ("id_organGroup")
                references "organGroup" ("id")
                on update cascade
                on delete cascade
            , constraint "organGroupLocale_fk_locale"
                foreign key ("id_locale")
                references "locale" ("id")
                on update cascade
                on delete restrict
        );



        create table "organ" (
              "id" serial not null
            , "id_organGroup" int not null
            , "identifier" varchar (50) not null
            , constraint "organ_pk"
                primary key ("id")
            , constraint "organ_unique_identifier"
                unique ("identifier")
            , constraint "organ_fk_organGroup"
                foreign key ("id_organGroup")
                references "organGroup" ("id")
                on update cascade
                on delete restrict
        );

        create table "organLocale" (
              "id_organ" int not null
            , "id_locale" int not null
            , "name" varchar(100) not null
            , constraint "organLocale_pk"
                primary key ("id_organ", "id_locale")
            , constraint "organLocale_fk_organ"
                foreign key ("id_organ")
                references "organ" ("id")
                on update cascade
                on delete cascade
            , constraint "organLocale_fk_locale"
                foreign key ("id_locale")
                references "locale" ("id")
                on update cascade
                on delete restrict
        );




        create table "classResistance" (
              "id_bacteria" int not null
            , "id_substanceClass" int not null
            , "id_resistanceLevel" int not null
            , "created" timestamp without time zone not null default now()
            , "updated" timestamp without time zone not null default now()
            , "deleted" timestamp without time zone
            , constraint "classResistance_pk"
                primary key ("id_bacteria", "id_substanceClass")
            , constraint "classResistance_fk_bacteria"
                foreign key ("id_bacteria")
                references "bacteria" ("id")
                on update cascade
                on delete restrict
            , constraint "classResistance_fk_substanceClass"
                foreign key ("id_substanceClass")
                references "substanceClass" ("id")
                on update cascade
                on delete restrict
            , constraint "classResistance_fk_resistanceLevel"
                foreign key ("id_resistanceLevel")
                references "resistanceLevel" ("id")
                on update cascade
                on delete restrict
        );





        -- create pseudo samples from the class resitances
        create function "updateResistanceSampleByResistanceClass"() returns trigger as $$
            declare "sub" "infect"."substance";
            declare "com" "infect"."compound";
            begin

                -- delete old stuff
                if TG_OP = 'DELETE' or TG_OP = 'UPDATE' then
                    delete
                      from "infect"."resistanceSample"
                     where "dataSourceId" like ('%' || OLD."id_bacteria" || ':' || OLD."id_substanceClass" || '-')
                       and "id_dataSource" = (
                            select "id"
                              from "infect"."dataSource"
                             where "identifier" = 'classDefaultValue'
                           );
                end if;


                -- add new stuff
                if TG_OP = 'INSERT' or TG_OP = 'UPDATE' then
                    for "sub" in select s.*
                                   from "infect"."substance" s
                                   join "infect"."substance_substanceClass" ssc
                                     on s."id" = ssc."id_substance"
                                   join "infect"."substanceClass" sc
                                     on ssc."id_substanceClass" = sc."id"
                                  where sc."id" = NEW."id_substanceClass"
                    loop
                        for "com" in select c.*
                                       from "infect"."compound" c
                                       join "infect"."substance_compound" "scom"
                                         on c."id" = "scom"."id_compound"
                                      where "scom"."id_substance" = "sub"."id"
                        loop
                            insert into "infect"."resistanceSample" ("id_bacteria", "id_compound", "id_dataSource", "id_resistanceLevel", "sampleYear", "dataSourceId") values (
                                  NEW."id_bacteria"
                                , com.id
                                , (select "id" from "infect"."dataSource" where "identifier" = 'classDefaultValue')
                                , NEW."id_resistanceLevel"
                                , date_part('year', current_timestamp)
                                , (NEW."id_bacteria" || ':' || NEW."id_substanceClass" || '-' || "sub"."id" || '-' || "com"."id")
                            );
                        end loop;
                    end loop;

                    return NEW;
                end if;

                if TG_OP = 'DELETE' then
                    return OLD;
                end if;
            end;
        $$ language plpgsql;


        create trigger "updateResistanceSampleByResistanceClass"
            after insert or update or delete on "classResistance"
            for each row execute procedure "updateResistanceSampleByResistanceClass"();




        -- create pseudo samples from the class resitances
        create function "updateResistanceSampleByTruncateResistanceClass"() returns trigger as $$
            begin

                -- delete old stuff
                if TG_OP = 'TRUNCATE' then
                    delete
                      from "infect"."resistanceSample"
                     where "id_dataSource" = (
                            select "id"
                              from "infect"."dataSource"
                             where "identifier" = 'classDefaultValue'
                           );
                end if;

                return null;
            end;
        $$ language plpgsql;


        create trigger "updateResistanceSampleByTruncateResistanceClass"
            after truncate on "classResistance"
            for each statement execute procedure "updateResistanceSampleByTruncateResistanceClass"();






        create table "resistanceSample" (
              "id" bigserial not null
            , "id_bacteria" int not null
            , "id_compound" int not null
            , "id_dataSource" int not null
            , "id_resistanceLevel" int not null
            , "id_sex" int
            , "id_tenant" int
            , "id_region" int
            , "id_city" int
            , "id_organ" int
            , "id_organGroup" int
            , "dataSourceId" varchar (50)
            , "sampleDate" timestamp without time zone
            , "sampleYear" int
            , "resistanceValue" decimal(5, 2)
            , "patientAge" smallint
            , "causedInfection" boolean
            , "isHospitalized" boolean
            , "isNosocomial" boolean
            , "created" timestamp without time zone not null default now()
            , "updated" timestamp without time zone not null default now()
            , "deleted" timestamp without time zone
            , constraint "resistanceSample_pk"
                primary key ("id")
            , constraint "resistanceSample_unique_dataSource"
                unique ("id_dataSource", "dataSourceId")
            , constraint "resistanceSample_fk_bacteria"
                foreign key ("id_bacteria")
                references "bacteria" ("id")
                on update cascade
                on delete restrict
            , constraint "resistanceSample_fk_compound"
                foreign key ("id_compound")
                references "compound" ("id")
                on update cascade
                on delete restrict
            , constraint "resistanceSample_fk_dataSource"
                foreign key ("id_dataSource")
                references "dataSource" ("id")
                on update cascade
                on delete restrict
            , constraint "resistanceSample_fk_resistanceLevel"
                foreign key ("id_resistanceLevel")
                references "resistanceLevel" ("id")
                on update cascade
                on delete restrict
            , constraint "resistanceSample_fk_sex"
                foreign key ("id_sex")
                references "sex" ("id")
                on update cascade
                on delete restrict
            , constraint "resistanceSample_fk_tenant"
                foreign key ("id_tenant")
                references "tenant" ("id")
                on update cascade
                on delete restrict
            , constraint "resistanceSample_fk_region"
                foreign key ("id_region")
                references "region" ("id")
                on update cascade
                on delete restrict
            , constraint "resistanceSample_fk_city"
                foreign key ("id_city")
                references "city" ("id")
                on update cascade
                on delete restrict
            , constraint "resistanceSample_fk_organ"
                foreign key ("id_organ")
                references "organ" ("id")
                on update cascade
                on delete restrict
            , constraint "resistanceSample_fk_organGroup"
                foreign key ("id_organGroup")
                references "organGroup" ("id")
                on update cascade
                on delete restrict
            , check (("id_region" is null and "id_city" is not null) or ("id_organ" is not null and "id_city" is null) or ("id_organ" is null and "id_city" is null))
            , check (("id_organ" is null and "id_organGroup" is not null) or ("id_region" is not null and "id_organGroup" is null) or ("id_region" is null and "id_organGroup" is null))
            , check ("patientAge" is null or ("patientAge" > -1 and "patientAge" < 150))
        );


        create index on "resistanceSample" ("dataSourceId");
        create index on "resistanceSample" ("sampleDate");
        create index on "resistanceSample" ("sampleYear");
        create index on "resistanceSample" ("resistanceValue");
        create index on "resistanceSample" ("patientAge");

        -- make sure the resistance level is set correctly
        create function "checkResistanceSampleLevel"() returns trigger as $$
            declare "level" "infect"."resistanceLevel";
            begin
                if NEW."resistanceValue" is not null then
                    select * into "level" from "infect"."resistanceLevel" where "id" = NEW."id_resistanceLevel";
                    if "level"."identifier" != 'custom' then
                        raise exception 'Cannot set resistanceValue while the resistanceLevel is not set to "custom"!';
                    end if;
                end if;

                return NEW;
            end;
        $$ language plpgsql;


        create trigger "checkResistanceSampleLevel"
            before insert or update on "resistanceSample"
            for each row execute procedure "checkResistanceSampleLevel"();



        -- make the year is set correctly
        create function "checkResistanceSampleYear"() returns trigger as $$
            begin
                if NEW."sampleDate" is not null then
                    NEW."sampleYear" = date_part('year', NEW."sampleDate");
                end if;

                if NEW."sampleDate" is null then
                    if NEW."sampleYear" is null then
                        raise exception 'either the smampleDate or the sampleYear must be set!';
                    end if;
                end if;

                return NEW;
            end;
        $$ language plpgsql;


        create trigger "checkResistanceSampleYear"
            before insert or update on "resistanceSample"
            for each row execute procedure "checkResistanceSampleYear"();






        create table "topic" (
              "id" serial not null
            , "identifier" varchar(50) not null
            , "created" timestamp without time zone not null default now()
            , "updated" timestamp without time zone not null default now()
            , "deleted" timestamp without time zone
            , constraint "topic_pk"
                primary key ("id")
            , constraint "topic_unique_identifer"
                unique ("identifier")
        );

        create table "topicLocale" (
              "id_topic" int not null
            , "id_locale" int not null
            , "name" varchar(100) not null
            , constraint "topicLocale_pk"
                primary key ("id_topic", "id_locale")
            , constraint "topicLocale_fk_topic"
                foreign key ("id_topic")
                references "topic" ("id")
                on update cascade
                on delete cascade
            , constraint "topicLocale_fk_locale"
                foreign key ("id_locale")
                references "locale" ("id")
                on update cascade
                on delete restrict
        );


        create table "diagnosis" (
              "id" serial not null
            , "id_country" int not null
            , "id_topic" int not null
            , "identifier" varchar(50) not null
            , "created" timestamp without time zone not null default now()
            , "updated" timestamp without time zone not null default now()
            , "deleted" timestamp without time zone
            , constraint "diagnosis_pk"
                primary key ("id")
            , constraint "diagnosis_unique_identifer"
                unique ("identifier")
            , constraint "diagnosis_fk_country"
                foreign key ("id_country")
                references "country" ("id")
                on update cascade
                on delete restrict
            , constraint "diagnosis_fk_topic"
                foreign key ("id_topic")
                references "topic" ("id")
                on update cascade
                on delete restrict
        );

        create table "diagnosisLocale" (
              "id_diagnosis" int not null
            , "id_locale" int not null
            , "title" varchar(200)
            , "description" text
            , constraint "diagnosisLocale_pk"
                primary key ("id_diagnosis", "id_locale")
            , constraint "diagnosisLocale_fk_diagnosis"
                foreign key ("id_diagnosis")
                references "diagnosis" ("id")
                on update cascade
                on delete cascade
            , constraint "diagnosisLocale_fk_locale"
                foreign key ("id_locale")
                references "locale" ("id")
                on update cascade
                on delete restrict
        );

        create table "diagnosis_bacteria" (
              "id_diagnosis" int not null
            , "id_bacteria" int not null
            , constraint "diagnosis_bacteria_pk"
                primary key ("id_diagnosis", "id_bacteria")
            , constraint "diagnosis_bacteria_fk_diagnosis"
                foreign key ("id_diagnosis")
                references "diagnosis" ("id")
                on update cascade
                on delete restrict
            , constraint "diagnosis_bacteria_fk_bacteria"
                foreign key ("id_bacteria")
                references "bacteria" ("id")
                on update cascade
                on delete restrict
        );







        create table "drug" (
              "id" serial not null
            , "created" timestamp without time zone not null default now()
            , "updated" timestamp without time zone not null default now()
            , "deleted" timestamp without time zone
            , constraint "drug_pk"
                primary key ("id")
        );

        create table "drugLocale" (
              "id_drug" int not null
            , "id_locale" int not null
            , "name" varchar(100) not null
            , constraint "drugLocale_pk"
                primary key ("id_drug", "id_locale")
            , constraint "drugLocale_fk_drug"
                foreign key ("id_drug")
                references "drug" ("id")
                on update cascade
                on delete cascade
            , constraint "drugLocale_fk_locale"
                foreign key ("id_locale")
                references "locale" ("id")
                on update cascade
                on delete restrict
        );





        create table "therapy" (
              "id" serial not null
            , "id_diagnosis" int not null
            , "created" timestamp without time zone not null default now()
            , "updated" timestamp without time zone not null default now()
            , "deleted" timestamp without time zone
            , constraint "therapy_pk"
                primary key ("id")
            , constraint "therapy_fk_diagnosis"
                foreign key ("id_diagnosis")
                references "diagnosis" ("id")
                on update cascade
                on delete restrict
        );

        create table "therapyLocale" (
              "id_therapy" int not null
            , "id_locale" int not null
            , "text" text not null
            , constraint "therapyLocale_pk"
                primary key ("id_therapy", "id_locale")
            , constraint "therapyLocale_fk_therapy"
                foreign key ("id_therapy")
                references "therapy" ("id")
                on update cascade
                on delete cascade
            , constraint "therapyLocale_fk_locale"
                foreign key ("id_locale")
                references "locale" ("id")
                on update cascade
                on delete restrict
        );



        create table "therapy_compound" (
              "id_therapy" int not null
            , "id_compound" int not null
            , constraint "therapy_compounds_pk"
                primary key ("id_therapy", "id_compound")
            , constraint "therapy_compounds_fk_therapy"
                foreign key ("id_therapy")
                references "therapy" ("id")
                on update cascade
                on delete restrict
            , constraint "therapy_compounds_fk_compound"
                foreign key ("id_compound")
                references "compound" ("id")
                on update cascade
                on delete restrict
        );



