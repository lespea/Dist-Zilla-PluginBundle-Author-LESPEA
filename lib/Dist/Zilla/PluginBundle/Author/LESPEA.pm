use strict;
use warnings;

use utf8;

package Dist::Zilla::PluginBundle::Author::LESPEA;

# ABSTRACT: LESPEA's Dist::Zilla Configuration

use feature 'switch';

use Moose;
use Carp;
with 'Dist::Zilla::Role::PluginBundle::Easy';


=encoding utf8

=head1 SYNOPSIS

    #  In dist.ini:
    [@Author::LESPEA]


=head1 DESCRIPTION

This plugin bundle, in its default configuration, is equivalent to:

    [ArchiveRelease]
    [Authority]
    [AutoMetaResources]
    [AutoPrereqs]
    [CPANChangesTests]
    [CheckChangesTests]
    [CompileTests]
    [ConfirmRelease]
    [ConsistentVersionTest]
    [CopyFilesFromBuild]
    [CriticTests]
    [DistManifestTests]
    [DualBuilders]
    [EOLTests]
    [ExecDir]
    [ExtraTests]
    [FakeRelease]
    [GatherDir]
    [HasVersionTests]
    [InstallGuide]
    [KwaliteeTests]
    [License]
    [MakeMaker]
    [Manifest]
    [ManifestSkip]
    [MetaConfig]
    [MetaJSON]
    [MetaNoIndex]
    [MetaTests]
    [MetaYAML]
    [MinimumPerl]
    [MinimumVersionTests]
    [ModuleBuild]
    [NextRelease]
    [NoTabsTests]
    [PerlTidy]
    [PkgVersion]
    [PodCoverageTests]
    [PodSyntaxTests]
    [PodWeaver]
    [PortabilityTests]
    [PruneCruft]
    [ReportVersions::Tiny]
    [ShareDir]
    [Signature]
    [SynopsisTests]
    [TestRelease]
    [UnusedVarsTests]
    [UploadToCPAN]

=cut



#  Declare which options can be specified multiple times
sub mvp_multivalue_args { return qw( -remove copy_file move_file ) }



#  Returns true for strings of 'true', 'yes', or positive numbers;
#  false for for 'false', 'no', or 0; and dies otherwise
sub _parse_bool {
    my $val = shift // q{};

    return 1 if $val =~ m{^(?:true|yes|1)$}xsmi;
    return   if $val =~ m{^(?:false|no|0)$}xsmi;

    die "Invalid boolean value $val. Valid values are true/yes/1 or false/no/0";
}



#  Add the "variable" plugins
sub _add_variable {
    my ($self, %args) = @_;

    # Use the @Filter bundle to handle '-remove'.
    if ($args{'-remove'}) {
        $self->add_bundle('@Filter' => { %args, -bundle => '@Author::LESPEA' });  ## no critic 'RequireInterpolationOfMetachars'
        return;
    }

    # Copy files from build dir
    $self->add_plugins(
        [ 'CopyFilesFromBuild' => {
            copy => ($args{copy_file} || [ q{} ]),
            move => ($args{move_file} || [ q{} ]),
        } ]
    );

    # Decide whether to test SYNOPSIS for syntax.
    if (_parse_bool($args{tidy})) {
        $self->add_plugins('PerlTidy');
    }

    # Choose release plugin
    given ($args{release}) {
        when (lc eq 'real') {
            $self->add_plugins('UploadToCPAN')
        }
        when (lc eq 'fake') {
            $self->add_plugins('FakeRelease')
        }
        when (lc eq 'none') {
            # No release plugin
        }
        when ($_) {
            $self->add_plugins("$_")
        }
        default {
            # Empty string is the same as 'none'
        }
    }

    # Choose whether and where to archive releases
    if (_parse_bool($args{archive})) {
        $self->add_plugins(
            ['ArchiveRelease' => {
                directory => $args{archive_directory},
            } ],
        );
    }

    if (_parse_bool($args{add_meta})) {
        $self->add_plugins(
            ['AutoMetaResources' => {
                'homepage'          => 'http://search.cpan.org/dist/%{dist}',
                'bugtracker.rt'     => 1,
                'repository.github' => 'user:lespea',
            }],
        );
    }

    #  Should we sign our package?
    if (_parse_bool($args{sign})) {
        $self->add_plugins(['Signature' => { sign => 'always' }]);
    }

    # Decide whether to test SYNOPSIS for syntax.
    if (_parse_bool($args{compile_synopsis})) {
        $self->add_plugins('SynopsisTests');
    }
}



#  Add the "static" plugins
sub _add_static {
    my $self = shift;

    $self->add_plugins(
        ################################
        ##        PRE-PROCESS         ##
        ################################

        #   Bring everything together so we can start processing everything
        'GatherDir',

        #   Set all our version strings
        'PkgVersion',

        #   My authority
        'Authority',

        #   Generates all the pod documentation into its final form
        'PodWeaver',

        #   Auto generate the next release info into the change file
        ['NextRelease' => {
            filename => 'CHANGES'
        } ],



        ################################
        ##          PRE-REQS          ##
        ################################

        #   Guess the minimum version of perl required
        'MinimumPerl',

        #   Get all of the modules used
        'AutoPrereqs',

        #   Put all the dzil modules used into the meta data
        'MetaConfig',



        ################################
        ##           TESTS            ##
        ################################

        #  Pretty much every test plugin available
        'CheckChangesTests',
        'CompileTests',
        'ConsistentVersionTest',
        'CriticTests',
        'DistManifestTests',
        'EOLTests',
        'HasVersionTests',
        'KwaliteeTests',
        'MetaTests',
        'MinimumVersionTests',
        'NoTabsTests',
        'PodCoverageTests',
        'PodSyntaxTests',
        'PortabilityTests',
        'UnusedVarsTests',
        'CPANChangesTests',

        #   Move all the xt/*.t files into the normal test directory
        'ExtraTests',



        ################################
        ##       FILE ARRANGING       ##
        ################################

        #   Remove junk that isn't needed in the package
        'PruneCruft',
        'ManifestSkip',

        #   If there is a "bin" folder then install any scripts in there as programs
        'ExecDir',

        #   Install any thing that's in "share" into the global share dir
        'ShareDir',

        #   All the modules we're using (for test reporting)
        'ReportVersions::Tiny',

        #   Generate the builders that will install the module(s)
        'ModuleBuild',
        'MakeMaker',
        'DualBuilders',



        ################################
        ##         META DATA          ##
        ################################

        #   Don't let cpan index the following dirs
        ['MetaNoIndex' => {
            directory => [qw/ inc t xt utils example examples /],
        }],

        #   Generate the meta data
        'License',
        'InstallGuide',
        'MetaJSON',
        'MetaYAML',

        #   Readme's
        ['ReadmeAnyFromPod', 'html.build', {
            filename => 'README.html',
            type => 'html',
        }],
        ['ReadmeAnyFromPod', 'text.build', {
            filename => 'README',
            type => 'text',
        }],
        # This one gets copied out of the build dir by default, and does not become part of the dist.
        ['ReadmeAnyFromPod', 'pod.root', {
            filename => 'README.pod',
            type => 'pod',
            location => 'root',
        }],

        #   Generates the manifest (needs to come last!)
        'Manifest',



        ################################
        ##          RELEASE           ##
        ################################

        #   Make double sure we pass all the tests before we push
        'TestRelease',

        #   In case the command was an accident, make sure we really want to release
        'ConfirmRelease',
    );
};



#  Setup DZIL how I like it
sub configure {
    my $self = shift;

    my $defaults = {
        # By default release to cpan
        release => 'real',

        # Archive releases
        archive => 1,
        archive_directory => 'releases',

        # Copy README.pod from build dir to dist dir, for Github and suchlike.
        copy_file => [],
        move_file => [],

        # Munge the authority?
        auth_munge => 1,

        # Use perl-tidy
        tidy => 0,

        # Add CPAN meta-info (adds git stuff too)
        add_meta => 1,

        # Assume that synopsis is perl code and should compile cleanly.
        compile_synopsis => 1,

        # To sign or not to sign, that is the question
        sign => 0,
    };

    my %args = (%$defaults, %{$self->payload});


    #  Actually set everything up
    _add_variable($self, %args);
    _add_static($self);

    return;
}

__PACKAGE__->meta->make_immutable;
no Moose;


# Happy ending
1;




=option -remove

This option can be used to remove specific plugins from the bundle. It
can be used multiple times.

Obviously, the default is not to remove any plugins.

Example:

; Remove these two plugins from the bundle
-remove = CriticTests
-remove = GithubMeta

=option version, version_major

This option is used to specify the version of the module. The default
is 'auto', which uses the AutoVersion plugin to choose a version
number. You can also set the version number manually, or choose
'disable' to prevent this bundle from supplying a version.

Examples:

; Use AutoVersion (default)
version = auto
version_major = 0
; Use manual versioning
version = 1.14.04
; Provide no version, so that another plugin can handle it.
version = disable

=option copy_file, move_file

If you want to copy or move files out of the build dir and into the
distribution dir, use these two options to specify those files. Both
of these options can be specified multiple times.

The most common reason to use this would be to put automatically
generated files under version control. For example, Github likes to
see a README file in your distribution, but if your README file is
auto-generated during the build, you need to copy each newly-generated
README file out of its build directory in order for Github to see it.

If you want to include an auto-generated file in your distribution but
you I<don't> want to include it in the build, use C<move_file> instead
of C<copy_file>.

The default is to move F<README.pod> out of the build dir. If you use
C<move_file> in your configuration, this default will be disabled, so
if you want it, make sure to include it along with your other
C<move_file>s.

Example:

copy_file = README
move_file = README.pod
copy_file = README.txt

=option synopsis_is_perl_code

If this is set to true (the default), then the SynopsisTests plugin
will be enabled. This plugin checks the perl syntax of the SYNOPSIS
sections of your modules. Obviously, if your SYNOPSIS section is not
perl code (case in point: this module), you should set this to false.

Example:

synopsis_is_perl_code = false

=option release

This option chooses the type of release to do. The default is 'real,'
which means "really upload the release to CPAN" (i.e. load the
C<UploadToCPAN> plugin). You can set it to 'fake,' in which case the
C<FakeRelease> plugin will be loaded, which simulates the release
process without actually doing anything. You can also set it to 'none'
if you do not want this module to load any release plugin, in which
case your F<dist.ini> file should load a release plugin directly. Any
other value for this option will be interpreted as a release plugin
name to be loaded.

Examples:

; Release to CPAN for real (default)
release = real
; For testing, you can do fake releases
release = fake
; Or you can choose no release plugin
release = none
; Or you can specify a specific release plugin.
release = OtherReleasePlugin

=option archive, archive_directory

If set to true, the C<archive> option copies each released version of
the module to an archive directory, using the C<ArchiveRelease>
plugin. This is the default. The name of the archive directory is
specified using C<archive_directory>, which is F<releases> by default.

Examples:

; archive each release to the "releases" directory
archive = true
archive_directory = releases
; Or don't archive
archive = false

=option vcs

This option specifies which version control system is being used for
the distribution. Integration for that version control system is
enabled. The default is 'git', and currently the only other option is
'none', which does not load any version control plugins.

=option allow_dirty

This corresponds to the option of the same name in the Git::Check and
Git::Commit plugins. Briefly, files listed in C<allow_dirty> are
allowed to have changes that are not yet committed to git, and during
the release process, they will be checked in (committed).

The default is F<dist.ini>, F<Changes>, and F<README.pod>. If you
override the default, you must include these files manually if you
want them.

This option only has an effect if C<vcs> is 'git'.

=for Pod::Coverage configure mvp_multivalue_args
