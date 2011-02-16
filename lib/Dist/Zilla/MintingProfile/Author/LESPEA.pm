use strict;
use warnings;

use utf8;

package Dist::Zilla::MintingProfile::Author::LESPEA;

# ABSTRACT: LESPEA's Minting Profile

use Moose;
use namespace::autoclean;
with 'Dist::Zilla::Role::MintingProfile::ShareDir';


=encoding utf8

=head1 SYNOPSIS

    #   On the command line run:
    dzil new -P Author::LESPEA Some::Dist::Name


=head1 DESCRIPTION

This installs a Dist::Zilla profile to start a new module with

=cut


__PACKAGE__->meta->make_immutable;
no Moose;

# Happy ending
1;
