package Rapi::Fs;

use strict;
use warnings;

use RapidApp 1.0010_07;

use Moose;
extends 'RapidApp::Builder';

use Types::Standard qw(:all);

use RapidApp::Util ':all';
use File::ShareDir qw(dist_dir);
use FindBin;

our $VERSION = '0.01';

has 'mounts', is => 'ro', isa => ArrayRef, required => 1;

has 'share_dir', is => 'ro', isa => Str, lazy => 1, default => sub {
  my $self = shift;
  try{dist_dir(ref $self)} || 
    -d "$FindBin::Bin/share" ? "$FindBin::Bin/share" : "$FindBin::Bin/../share" ;
};

sub _build_version { $VERSION }
sub _build_plugins { ['RapidApp::TabGui'] }

sub _build_config {
  my $self = shift;
  
  my $tpl_dir = join('/',$self->share_dir,'templates');
  -d $tpl_dir or die "template dir ($tpl_dir) not found; Rapi-Fs dist may not be installed properly.\n";
  
  my $loc_assets_dir = join('/',$self->share_dir,'assets');
  -d $loc_assets_dir or die "assets dir ($loc_assets_dir) not found; Rapi-Fs dist may not be installed properly.\n";
  
  return {
    'RapidApp' => {
      load_modules => {
        files => {
          class  => 'Rapi::Fs::Module::FileTree',
          params => { mounts => $self->mounts }
        }
      },
      local_assets_dir => $loc_assets_dir
    },
    'Plugin::RapidApp::TabGui' => {
      navtrees => [{
        module => '/files',
      }]  
    },
    'Controller::RapidApp::Template' => {
      include_paths => [ $tpl_dir ]
    },
  }
}

1;
