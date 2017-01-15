# Migration scripts for INFECT



input fields

bacteriaName        -> string, not null: name of the bacteria as used in infect
compoundName        -> string, not null: name of the compund as used in infect
dataSource          -> string, not null: anresis-search or defaultValue, classDefaultValue, userDefinedValue
resistanceLevel     -> string, not null: suspectible, intermediate, resistant, custom
sex                 -> string, not null: female, male, unknown, other
region              -> string, nullable: as defined in the mapping sheet
city                -> string, null: papiermühle, ittigen, bern, ... (currently to be ignored)
organ               -> string, nullable: as defined in the mapping sheet
organGroup          -> string, nullable: as defined in the mapping sheet
sampleDate          -> date, nullable: the date the sample was taken
sampleYear          -> number, nullable: the year the sample was taken
resistanceValue     -> number (xxx.xx), nullable: resistance percentage 0-100, only set if restistanceLevel is set to custom
patientAge          -> number, nullable: age of patient
causedInfection     -> bool, nullable
isHospitalized      -> bool, nullable
isNosocomial        -> bool, nullable


output fields:

bacteriaName        -> string, not null
compoundName        -> string, not null
resistanceClass     -> string, not null: suspectible, intermediate, resistant
resistance          -> number, not null


the output file has to be a matrix of bacteriaName*compund like it's displayed in the frontend