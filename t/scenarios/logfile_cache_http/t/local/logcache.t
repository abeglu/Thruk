use warnings;
use strict;
use Test::More;

BEGIN {
    use lib('t');
    require TestUtils;
    import TestUtils;
}

plan tests => 62;

###########################################################
# test thruks script path
TestUtils::test_command({
    cmd  => '/bin/bash -c "type thruk"',
    like => ['/\/thruk\/script\/thruk/'],
}) or BAIL_OUT("wrong thruk path");

###########################################################
# schedule at least one check
TestUtils::test_command({
    cmd     => '/thruk/support/reschedule_all_checks.sh',
    like    => ['/successfully submitted/'],
});
# then disable checks to avoid log changes that break tests
TestUtils::test_command({
    cmd     => "/usr/bin/env thruk r -d '' /system/cmd/stop_executing_host_checks",
    like    => ['/Command successfully submitted/'],
});
TestUtils::test_command({
    cmd     => "/usr/bin/env thruk r -d '' /system/cmd/stop_executing_svc_checks",
    like    => ['/Command successfully submitted/'],
});

###########################################################
# test thruk logcache example
{
    TestUtils::test_command({
        cmd     => "/usr/bin/env thruk logcache import -q -y",
        like    => [qr(\QOK - imported\E)],
    });
    TestUtils::test_command({
        cmd     => "/thruk/examples/get_logs var/log/naemon.log",
        like    => ['/^$/'],
    });
    TestUtils::test_command({
        cmd     => "/thruk/examples/get_logs var/log/naemon.log -n",
        like    => ['/^$/'],
    });
    TestUtils::test_command({
        cmd     => "/usr/bin/env thruk r '/logs'",
        like    => ['/class/', '/starting/'],
    });
    TestUtils::test_command({
        cmd     => "/usr/bin/env thruk r '/logs?limit=1&plugin_output[ne]='",
    });
    TestUtils::test_command({
        cmd     => "/usr/bin/env thruk r '/logs?limit=1&contact_name[ne]='",
    });
};

###########################################################
# some more /logs rest calls
{
    TestUtils::test_command({
        cmd  => '/usr/bin/env thruk r \'/logs?limit=1&q=***host_name = "localhost"***\'',
        like => ['/command_name/', '/plugin_output/'],
    });
};

{
    TestUtils::test_command({
        cmd  => '/usr/bin/env thruk r \'/logs?limit=1&q=***host_name = "localhost" AND time > -24h***\'',
        like => ['/command_name/', '/plugin_output/'],
    });
};

{
    TestUtils::test_command({
        cmd  => '/usr/bin/env thruk r \'/logs?limit=1&q=***host_name != "" AND time > -24h***\'',
        like => ['/command_name/', '/plugin_output/'],
    });
};

###########################################################
# be nice and enable checks again
TestUtils::test_command({
    cmd     => "/usr/bin/env thruk r -d '' /system/cmd/start_executing_host_checks",
    like    => ['/Command successfully submitted/'],
});
TestUtils::test_command({
    cmd     => "/usr/bin/env thruk r -d '' /system/cmd/start_executing_svc_checks",
    like    => ['/Command successfully submitted/'],
});

