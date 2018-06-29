#!/bin/sh

# based on: https://github.com/buildbot/buildbot/blob/master/master/docker/start_buildbot.sh
# simplified and modified to workaround missing support for secrets with GitHubAuth

B=`pwd`
GITHUB_CLIENT=$(cat $B/secrets/github-auth-client)
GITHUB_SECRET=$(cat $B/secrets/github-auth-secret)

if [ ! -f $B/buildbot.tac ]
then
    cp /usr/src/buildbot/docker/buildbot.tac $B
fi

cp $B/master.cfg $B/master.cfg.secret
sed -i -e "s/@@GITHUB_CLIENT@@/$GITHUB_CLIENT/" $B/master.cfg.secret
sed -i -e "s/@@GITHUB_SECRET@@/$GITHUB_SECRET/" $B/master.cfg.secret
sed -i -e "s/'master.cfg'/'master.cfg.secret'/" $B/buildbot.tac

rm -f $B/twistd.pid

until buildbot upgrade-master $B
do
    echo "Cant upgrade master yet. Waiting for database ready?"
    sleep 5
done

exec twistd -ny $B/buildbot.tac
