package Dist::Zilla::MintingProfile::Author::LESPEA;

use strict;
use warnings;

# VERSION

# ABSTRACT: LESPEA's Minting Profile

use Moose;
use namespace::autoclean;
with 'Dist::Zilla::Role::MintingProfile::ShareDir';

=head1 SYNOPSIS

    dzil new -P Author::LESPEA Some::Dist::Name

=cut

__PACKAGE__->meta->make_immutable;
no Moose;

# Magic
1;
