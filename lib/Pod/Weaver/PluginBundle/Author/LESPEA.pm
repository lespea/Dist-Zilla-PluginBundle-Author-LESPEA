use strict;
use warnings;
use utf8;

package Pod::Weaver::PluginBundle::Author::LESPEA;

# ABSTRACT: A bundle that implements LESPEA's preferred Pod::Weaver config

use namespace::autoclean;
use Pod::Weaver::Config::Assembler;

=encoding utf8

=for Pod::Coverage mvp_bundle_config

=head1 SYNOPSIS

    In weaver.ini:

    [@Author::LESPEA]

=head1 DESCRIPTION

This is the bundle used by LESPEA when using L<Pod::Weaver|Pod::Weaver> to generate documentation for Perl modules.

It is nearly equivalent to the following:

    [@CorePrep]

    [Name]
    [Version]

    [Region  / prelude]

    [Generic / SYNOPSIS]
    [Generic / OVERVIEW]
    [Generic / DESCRIPTION]

    [Generic / EXPORTS]

    [Collect / OPTIONS]
    command = option

    [Collect / ATTRIBUTES]
    command = attr

    [Collect / METHODS]
    command = method

    [Collect / FUNCTIONS]
    command = func

    [Leftovers]

    [Region  / postlude]

    [SeeAlso]

    [Installation]

    [Authors]
    [Support]
    [Legal]

    [WarrantyDisclaimer]


    [-Transformer]
    transformer = List

=head1 SEE ALSO

Pod::Weaver
Pod::Weaver::Section::Installation
Pod::Weaver::Section::Support
Pod::Weaver::Section::WarrantyDisclaimer
Pod::Elemental::Transformer::List

=cut


sub _exp {
    return Pod::Weaver::Config::Assembler->expand_package($_[0]);
}


sub mvp_bundle_config {
    my (undef, $params) = @_;
    my $opts = $params->{payload};

    ## no critic 'ValuesAndExpressions::RequireInterpolationOfMetachars'
    my @setup = (
        [ '@Author::LESPEA/CorePrep'             , _exp('@CorePrep')             , {} ]                            ,

        [ '@Author::LESPEA/Name'                 , _exp('Name')                  , {} ]                            ,
        [ '@Author::LESPEA/Version'              , _exp('Version')               , {} ]                            ,

        [ '@Author::LESPEA/prelude'              , _exp('Region')                , { region_name => 'prelude' } ]  ,

        [ 'SYNOPSIS'                             , _exp('Generic')               , {} ]                            ,
        [ 'OVERVIEW'                             , _exp('Generic')               , {} ]                            ,
        [ 'DESCRIPTION'                          , _exp('Generic')               , {} ]                            ,

        [ 'EXPORTS'                              , _exp('Generic')               , {} ]                            ,

        [ 'OPTIONS'                              , _exp('Collect')               , { command => 'option' } ]       ,
        [ 'ATTRIBUTES'                           , _exp('Collect')               , { command => 'attr' } ]         ,
        [ 'METHODS'                              , _exp('Collect')               , { command => 'method' } ]       ,
        [ 'FUNCTIONS'                            , _exp('Collect')               , { command => 'func' } ]         ,

        [ '@Author::LESPEA/Leftovers'            , _exp('Leftovers')             , {} ]                            ,
        [ '@Author::LESPEA/postlude'             , _exp('Region')                , { region_name => 'postlude' } ] ,
        [ '@Author::LESPEA/SeeAlso'              , _exp('SeeAlso')               , {} ]                            ,
        [ '@Author::LESPEA/Installation'         , _exp('Installation')          , {} ]                            ,
        [ '@Author::LESPEA/Authors'              , _exp('Authors')               , {} ]                            ,
    );


    #  Don't include "support" if this isn't a cpan module
    if ($opts->{is_cpan}) {
        push @setup, [ '@Author::LESPEA/Support', _exp('Support'), {} ];
    }


    push @setup, (
        [ '@Author::LESPEA/Legal'              , _exp('Legal')              , {} ]                        ,
        [ '@Author::LESPEA/WarrantyDisclaimer' , _exp('WarrantyDisclaimer') , {} ]                        ,
        [ '@Author::LESPEA/-Transformer'       , _exp('-Transformer')       , { transformer => 'List' } ] ,
    );

    return @setup;
}


# Happy ending
1;
