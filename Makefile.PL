use ExtUtils::MakeMaker;
WriteMakefile(
    NAME         => 'Palm::TreoPhoneCallDB',
    VERSION_FROM => 'lib/Palm/TreoPhoneCallDB.pm',
    PREREQ_PM    => {
        Palm::PDB => 1.29,
        DateTime  => 0.30
    }
);
