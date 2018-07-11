#!/bin/bash
export PATH="/home/deployer/.composer/vendor/bin":$PATH
echo `date -R` \
&& cd /home/deployer/source/xdruple \
&& git fetch origin \
&& git reset --hard origin/master \
&& couscous generate \
    --target=/opt/xtuple/commerce/xdruple/docs /home/deployer/source/xdruple \
&& printf "Developers documentation generated.\n\n"
