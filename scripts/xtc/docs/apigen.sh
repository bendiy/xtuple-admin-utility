#!/bin/bash
export PATH="/home/deployer/.composer/vendor/bin":$PATH
echo `date -R` \
&& cd /home/deployer/source/xdruple \
&& git fetch origin \
&& git reset --hard origin/master \
&& apigen generate \
    --source /home/deployer/source/xdruple/xdruple \
    --destination /opt/xtuple/portal/xdruple/api \
    --config /home/deployer/source/xdruple/apigen.neon \
    --quiet \
&& printf "API documentation generated.\n\n"
