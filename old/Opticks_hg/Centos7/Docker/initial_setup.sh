#! /bin/bash

if [[ -z "$BRANCH_NAME" ]]
    export BRANCH_NAME=OptiX_6_0_0
fi

    export BRANCH_BASE=$SCRATCH/opticks/${BRANCH_NAME}
    mkdir -p $BRANCH_BASE/opt/
    cp -r /opt/opticks_stuff $BRANCH_BASE/opt/
    mkdir -p $BRANCH_BASE/usr/local/opticks/
    cp -r /usr/local/opticks/ $BRANCH_BASE/usr/local/
    
