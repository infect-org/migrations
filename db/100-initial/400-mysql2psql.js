(function() {
    'use strict';

    const Related = require('related');
    const log = require('ee-log');


    class Migrator {


        constructor(config) {
            this.old = new Related(config.old);
            this.new = new Related(config.new);

            this.old.load().then(() => this.new.load()).then(() => {
                // nice, both dbs are online
                this.old = this.old.infect;
                this.new = this.new.infect;

                this.old.therapy.setReferenceAccessorName('id_diagnosis', 'diagnosis');

                return this.migrate();
            }).then(() => {
                log.success('imported completed!');
            }).catch(log);
        }




        migrate() {
            log.info('Database loaded, strating migration ....');
            return this.shapes()
                .then(() => this.genus())
                .then(() => this.species())
                .then(() => this.grouping())
                .then(() => this.bacteria())
                .then(() => this.substance())
                .then(() => this.substanceClass())
                .then(() => this.compound())
                .then(() => this.classResistance())
                .then(() => this.resistance())
                .then(() => this.drug())
                .then(() => this.topic())
                .then(() => this.diagnosis())
                .then(() => this.therapy());
        }










        therapy() {
            const query = this.old.therapy('*');

            query.getTherapyLocale('*').fetchLanguage('*');
            query.getDiagnosis('*').getDiagnosisLocale('*').fetchLanguage('*');
            query.getCompound('*').getSubstance('*').getSubstanceLocale('*').getLanguage('*');

            return query.find().then((therapies) => {
                return Promise.all(therapies.map((therapy) => {
                    let identifier = '';

                    therapy.diagnosis.topic.topicLocale.forEach((locale) => {
                        if (!identifier || locale.language.iso2.toLowerCase().trim() === 'en') identifier = locale.title.toLowerCase().trim();
                    });

                    const locales = therapy.therapyLocale.map((locale) => {
                        return new this.new.therapyLocale({
                              text: locale.text
                            , locale: this.new.locale({
                                alpha2: locale.language.iso2.toLowerCase()
                            })
                        })
                    });


                    const compounds = [];

                    therapy.compound.forEach((compound) => {
                        compounds.push(this.new.compound({
                            identifier: compound.substance.map((substance) => this.getSubstanceIdentifier(substance)).sort().join('/')
                        }));
                    });

                    return new this.new.therapy({
                          therapyLocale: locales
                        , diagnosis: this.new.diagnosis({
                            identifier: identifier
                        })
                        , compound: compounds
                    }).save();
                }));
            });
        }










        diagnosis() {
            const query = this.old.diagnosis('*');

            query.getDiagnosisLocale('*').fetchLanguage('*');
            query.getCountry('*');
            query.getTopic('*').getTopicLocale('*').getLanguage('*');
            query.getBacteria('*').getSpecies('*').getGenus('*');

            return query.find().then((diagnosiss) => {
                return Promise.all(diagnosiss.map((diagnosis) => {
                    let identifier = '';

                    diagnosis.topic.topicLocale.forEach((locale) => {
                        if (!identifier || locale.language.iso2.toLowerCase().trim() === 'en') identifier = locale.title.toLowerCase().trim();
                    });

                    const locales = diagnosis.diagnosisLocale.map((locale) => {
                        return new this.new.diagnosisLocale({
                              title: locale.title
                            , description: locale.description
                            , locale: this.new.locale({
                                alpha2: locale.language.iso2.toLowerCase()
                            })
                        })
                    });


                    const bacteria = [];

                    if (diagnosis.bacteria.length) {
                        diagnosis.bacteria.forEach((bact) => {
                            bacteria.push(this.new.bacteria({
                                species: this.new.species({
                                    identifier: `${bact.species.genus.name.toLowerCase().trim()} ${bact.species.name.toLowerCase().trim()}`
                                })
                            }));
                        });
                    }

                    return new this.new.diagnosis({
                          identifier: identifier
                        , diagnosisLocale: locales
                        , country: this.new.country({
                            alpha2: diagnosis.country.iso2.trim().toLowerCase()
                        })
                        , topic: this.new.topic({
                            identifier: identifier
                        })
                        , bacteria: bacteria
                    }).save();
                }));
            });
        }










        topic() {
            return this.old.topic('*').getTopicLocale('*').fetchLanguage('*').find().then((topics) => {
                return Promise.all(topics.map((topic) => {
                    let identifier = '';

                    const locales = topic.topicLocale.map((locale) => {
                        if (!identifier || locale.language.iso2.toLowerCase().trim() === 'en') identifier = locale.title.toLowerCase().trim();

                        return new this.new.topicLocale({
                              name: locale.title
                            , locale: this.new.locale({
                                alpha2: locale.language.iso2.toLowerCase()
                            })
                        })
                    });

                    return new this.new.topic({
                          identifier: identifier
                        , topicLocale: locales
                    }).save();
                }));
            });
        }








        drug() {
            return this.old.drug('*').getDrugLocale('*').fetchLanguage('*').getCountry('*').find().then((drugs) => {
                return Promise.all(drugs.map((drug) => {
                    const locales = drug.drugLocale.map((locale) => {
                        return new this.new.drugLocale({
                              name: locale.name
                            , locale: this.new.locale({
                                alpha2: `${locale.language.iso2.toLowerCase()}-${locale.country.iso2.toUpperCase()}`
                            })
                        })
                    });

                    return new this.new.drug({
                        drugLocale: locales
                    }).save();
                }));
            });
        }







        resistance() {
            const query = this.old.bacteria_compound('*');

            query.getCompound('*').getSubstance('*').getSubstanceLocale('*').getLanguage('*');
            query.getBacteria('*').getSpecies('*').getGenus('*');

            return query.find().then((resistances) => {
                return Promise.all(resistances.map((resistance) => {

                    return Promise.resolve().then(() => {
                        if (!resistance.resistanceDefault) return Promise.resolve();
                        else {

                            return new this.new.resistanceSample({
                                bacteria: this.new.bacteria({
                                    species: this.new.species({
                                        identifier: `${resistance.bacteria.species.genus.name.toLowerCase().trim()} ${resistance.bacteria.species.name.toLowerCase().trim()}`
                                    })
                                })
                                , compound: this.new.compound({
                                    identifier: resistance.compound.substance.map((substance) => this.getSubstanceIdentifier(substance)).sort().join('/')
                                })
                                , dataSource: this.new.dataSource({
                                    identifier: 'defaultValue'
                                })
                                , resistanceLevel: this.new.resistanceLevel({
                                    identifier: (resistance.resistanceDefault === 1 ? 'suspectible' : (resistance.resistanceDefault === 2 ? 'intermediate' : 'resistant'))
                                })
                                , dataSourceId: `${resistance.id_bacteria}:${resistance.id_compound}-default`
                                , sampleYear: new Date().getFullYear()
                            }).save();
                        }
                    }).then(() => {
                        if (!resistance.resistanceUser) return Promise.resolve();
                        else {
                            return new this.new.resistanceSample({
                                bacteria: this.new.bacteria({
                                    species: this.new.species({
                                        identifier: `${resistance.bacteria.species.genus.name.toLowerCase().trim()} ${resistance.bacteria.species.name.toLowerCase().trim()}`
                                    })
                                })
                                , compound: this.new.compound({
                                    identifier: resistance.compound.substance.map((substance) => this.getSubstanceIdentifier(substance)).sort().join('/')
                                })
                                , dataSource: this.new.dataSource({
                                    identifier: 'userDefinedValue'
                                })
                                , resistanceLevel: this.new.resistanceLevel({
                                    identifier: 'custom'
                                })
                                , resistanceValue: resistance.resistanceUser
                                , dataSourceId: `${resistance.id_bacteria}:${resistance.id_compound}-user`
                                , sampleYear: new Date().getFullYear()
                            }).save();
                        }
                    });
                }));
            });
        }









        classResistance() {
            const query = this.old.bacteria_substanceClass('*');

            query.getBacteria('*').getSpecies('*').getGenus('*');
            query.getSubstanceClass('*').getSubstanceClassLocale('*').getLanguage('*');


            return query.find().then((resistances) => {
                return Promise.all(resistances.map((resistance) => {

                    return new this.new.classResistance({
                        bacteria: this.new.bacteria({
                            species: this.new.species({
                                identifier: `${resistance.bacteria.species.genus.name.toLowerCase().trim()} ${resistance.bacteria.species.name.toLowerCase().trim()}`
                            })
                        })
                        , substanceClass: this.new.substanceClass({
                            identifier: this.getSubstanceClassIdentifier(resistance.substanceClass)
                        })
                        , resistanceLevel: this.new.resistanceLevel({
                            identifier: (resistance.resistanceDefault === 1 ? 'suspectible' : (resistance.resistanceDefault === 2 ? 'intermediate' : 'resistant'))
                        })
                    }).save();
                }));
            });
        }











        compound() {
            return this.old.compound('*').getSubstance('*').getSubstanceLocale('*').getLanguage('*').find().then((compounds) => {
                return Promise.all(compounds.map((compound => {
                    return new this.new.compound({
                          perOs: compound.po
                        , intraVenous: compound.iv
                        , substance: this.new.substance({
                            identifier: Related.in(compound.substance.map(substance => this.getSubstanceIdentifier(substance)))
                        })
                    }).save();
                })));
            });
        }











        substanceClass() {
            const query = this.old.substanceClass('*');

            query.getSubstanceClassLocale('*').getLanguage('*');
            query.getSubstance('*').getSubstanceLocale('*').getLanguage('*');

            return query.find().then((substanceClasses) => {
                return Promise.all(substanceClasses.map((substanceClass => {
                    const locales = substanceClass.substanceClassLocale.map((locale) => {
                        return new this.new.substanceClassLocale({
                              name: locale.name
                            , locale: this.new.locale({
                                alpha2: locale.language.iso2.toLowerCase()
                            })
                        })
                    });


                    return new this.new.substanceClass({
                          identifier: this.getSubstanceClassIdentifier(substanceClass)
                        , substanceClassLocale: locales
                        , left: substanceClass.lft
                        , right: substanceClass.rgt
                        , substance: this.new.substance({
                            identifier: Related.in(substanceClass.substance.map(substance => this.getSubstanceIdentifier(substance)))
                        })
                    }).save();
                })));
            });
        }







        substance() {
            return this.old.substance('*').getSubstanceLocale('*').getLanguage('*').find().then((substances) => {
                return Promise.all(substances.map((substance => {
                    const locales = substance.substanceLocale.map((locale) => {
                        return new this.new.substanceLocale({
                              name: locale.name
                            , locale: this.new.locale({
                                alpha2: locale.language.iso2.toLowerCase()
                            })
                        })
                    });

                    return new this.new.substance({
                          identifier: this.getSubstanceIdentifier(substance)
                        , substanceLocale: locales
                    }).save();
                })));
            });
        }






        getSubstanceIdentifier(substance) {
            let identifier = '';

            substance.substanceLocale.forEach((locale) => {
                if (!identifier || locale.language.iso2.toLowerCase() === 'en') identifier = locale.name;
            });

            return identifier.toLowerCase().trim();
        }



        getSubstanceClassIdentifier(substanceClass) {
            let identifier = '';

            substanceClass.substanceClassLocale.forEach((locale) => {
                if (!identifier || locale.language.iso2.toLowerCase() === 'en') identifier = locale.name;
            });

            return identifier.toLowerCase().trim();
        }







        bacteria() {
            const query = this.old.bacteria('*');

            query.getBacteriaLocale('*').getLanguage('*');
            query.getSpecies('*').getGenus('*');
            query.getGrouping('*');
            query.getShape('*');

            return query.find().then((bacteria) => {
                return Promise.all(bacteria.map((bact => {
                    const locales = bact.bacteriaLocale.map((locale) => {
                        return new this.new.bacteriaLocale({
                              name: locale.name
                            , locale: this.new.locale({
                                alpha2: locale.language.iso2.toLowerCase()
                            })
                        });
                    });


                    return new this.new.bacteria({
                        species: this.new.species({
                            identifier: `${bact.species.genus.name.toLowerCase().trim()} ${bact.species.name.toLowerCase().trim()}`
                        })
                        , shape: (bact.shape ? (this.new.shape({
                            identifier: bact.shape.name.toLowerCase().trim()
                        })) : null)
                        , grouping: (bact.grouping ? (this.new.grouping({
                            identifier: bact.grouping.name.toLowerCase().trim()
                        })) : null)
                        , gram: bact.gram
                        , aerobic: bact.aerobic
                        , aerobicOptional: bact.aerobicOptional
                        , anaerobic: bact.anaerobic
                        , anaerobicOptional: bact.anaerobicOptional
                        , bacteriaLocale: locales
                    }).save();
                })));
            });
        }







        species() {
            return this.old.species('*').getGenus('*').find().then((species) => {
                return Promise.all(species.map((spec => {
                    return new this.new.species({
                            identifier: `${spec.genus.name.toLowerCase().trim()} ${spec.name.toLowerCase().trim()}`
                          , name: `${spec.genus.name} ${spec.name}`
                          , genus: this.new.genus({
                                identifier: spec.genus.name.toLowerCase().trim()
                          })
                    }).save();
                })));
            });
        }







        genus() {
            return this.old.genus('*').find().then((genera) => {
                return Promise.all(genera.map((genus => {
                    return new this.new.genus({
                            identifier: genus.name.toLowerCase().trim()
                          , name: genus.name
                    }).save();
                })));
            });
        }






        shapes() {
            return this.old.shape('*').getShapeLocale('*').getLanguage('*').find().then((shapes) => {
                return Promise.all(shapes.map((shape => {
                    const shapeLocales = shape.shapeLocale.map((locale) => {
                        return new this.new.shapeLocale({
                              name: locale.name
                            , locale: this.new.locale({
                                alpha2: locale.language.iso2.toLowerCase()
                            })
                        })
                    });

                    return new this.new.shape({
                          identifier: shape.name.toLowerCase().trim()
                        , shapeLocale: shapeLocales
                    }).save();
                })));
            });
        }






        grouping() {
            return this.old.grouping('*').getGroupingLocale('*').getLanguage('*').find().then((groupings) => {
                return Promise.all(groupings.map((grouping => {
                    const groupingLocales = grouping.groupingLocale.map((locale) => {
                        return new this.new.groupingLocale({
                              name: locale.name
                            , locale: this.new.locale({
                                alpha2: locale.language.iso2.toLowerCase()
                            })
                        })
                    });

                    return new this.new.grouping({
                          identifier: grouping.name.toLowerCase().trim()
                        , groupingLocale: groupingLocales
                    }).save();
                })));
            });
        }
    }





    new Migrator(require('./config.js'));
})();
