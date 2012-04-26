use ExtUtils::MakeMaker;
WriteMakefile(
    NAME         => 'Palm::TreoPhoneCallDB',
    META_MERGE => {
        license => 'other',
        resource => {
	    repository => 'https://github.com/DrHyde/perl-modules-Palm-TreoPhoneCallDB'
        }
    },
    VERSION_FROM => 'lib/Palm/TreoPhoneCallDB.pm',
    PREREQ_PM    => {
        Palm::PDB => 1.29,
        DateTime  => 0.30
    }
);
