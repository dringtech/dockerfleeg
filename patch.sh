targets="asset-manager contentapi panopticon publisher search signon www"

for target in $targets
do
    pushd ${target}/repo
    git apply ../config.patch
    popd
done
