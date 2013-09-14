#!/usr/bin/env perl

use feature ':5.10';
use strict;
use warnings;

use Cinnamon::DSL;

set application => 'maxride';
set repository  => 'git@github.com:boolfool/maxride.git';
set user        => 'boolfool';
set password    => '';

role production => 'sakura', {
    deploy_to   => '/home/boolfool/app/maxride',
    branch      => 'master'
};

task deploy => {
    setup => sub {
        my ( $host, @args ) = @_;

        my $repository = get('repository');
        my $deploy_to  = get('deploy_to');
        my $branch     = 'origin/' . get('branch');
        remote {
            run "git clone $repository $deploy_to && cd $deploy_to && git checkout -q $branch";
        } $host;
    },

    update => sub {
        my ( $host, @args ) = @_;

        my $deploy_to = get('deploy_to');
        my $branch    = 'origin/' . get('branch');
        remote {
            run "cd $deploy_to && git fetch origin && git checkout -q $branch && git submodule update --init";
        } $host;
    },
};

task server => {
    start => sub {
        my ( $host, @args ) = @_;
        remote {
            sudo 'supervisorctl start maxride';
        } $host;
    },
    stop => sub {
        my ( $host, @args ) = @_;
        remote {
            sudo 'supervisorctl stop maxride';
        } $host;
    },
    restart => sub {
        my ( $host, @args ) = @_;
        remote {
            sudo 'supervisorctl restart maxride';
        } $host;
    },
    status => sub {
        my ( $host, @args ) = @_;
        remote {
            sudo 'supervisorctl status maxride';
        } $host;
    },
};
