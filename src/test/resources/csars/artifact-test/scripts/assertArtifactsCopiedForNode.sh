#!/bin/bash
# This is coming from nodes
if [ -z "$confs_directory" ]; then
    echo "confs_directory is not set"
    exit 1
else
    echo "confs_directory is ${confs_directory}"
fi

if [ -f "$confs_directory/log.properties" ]; then
    echo "confs_directory/log.properties is copied"
else
    echo "confs_directory/log.properties is not copied"
    exit 1
fi

if [ -f "$confs_directory/settings.properties" ]; then
    echo "confs_directory/settings.properties is copied"
else
    echo "confs_directory/settings.properties is not copied"
    exit 1
fi

if [ -f "$confs_directory/test/nestedDirTest.txt" ]; then
    echo "confs_directory/test/nestedDirTest.txt is copied"
else
    echo "confs_directory/test/nestedDirTest.txt is not copied"
    exit 1
fi

# This is to test that artifact is really copied with good content and overridden
if [ -z "$to_be_overridden" ]; then
    echo "to_be_overridden is not set, test failed"
    exit 1
fi
echo "to_be_overridden is set to $to_be_overridden"
cp $to_be_overridden ~/
if [ -z "$to_be_preserved" ]; then
    echo "to_be_preserved is not set, test failed"
    exit 1
fi
echo "to_be_preserved is set to $to_be_preserved"
cp $to_be_preserved ~/

if [ -z "$COMPLEX" ]; then
    echo "COMPLEX is not set, test failed"
    exit 1
fi
echo "COMPLEX is set to $COMPLEX"

if [ -z "$NESTED" ]; then
    echo "NESTED is not set, test failed"
    exit 1
fi
echo "NESTED is set to $NESTED"

if [ -z "$NESTED_ARRAY_ELEMENT" ]; then
    echo "NESTED_ARRAY_ELEMENT is not set, test failed"
    exit 1
fi
echo "NESTED_ARRAY_ELEMENT is set to $NESTED_ARRAY_ELEMENT"

if [ -z "$NESTED_MAP_ELEMENT" ]; then
    echo "NESTED_MAP_ELEMENT is not set, test failed"
    exit 1
fi
echo "NESTED_MAP_ELEMENT is set to $NESTED_MAP_ELEMENT"