#!/bin/bash

KEVIN="Kevin Sum"
PROJECT_OLD_NAME="Project"
PROJECT_TESTS="Tests"
PROJECT_UI_TESTS="UITests"

function set_organizer_if_need() {
	if grep -Fq "$KEVIN" $PROJECT_OLD_NAME".xcodeproj/project.pbxproj" ; then
        while [[ -z "$ORGANIZER" ]]
        do
		  read -p "Organization Name: " ORGANIZER
		  sed -i '' "s/$KEVIN/$ORGANIZER/g" $PROJECT_OLD_NAME".xcodeproj/project.pbxproj"
        done
	fi
}

function rename_project() {
    while [[ -z "$PROJECT_NAME" ]]
    do
      read -p "Project Name: " PROJECT_NAME
    done
    NEW_TESTS=$PROJECT_NAME$PROJECT_TESTS
    OLD_TESTS=$PROJECT_OLD_NAME$PROJECT_TESTS
    NEW_UI_TESTS=$PROJECT_NAME$PROJECT_UI_TESTS
    OLD_UI_TESTS=$PROJECT_OLD_NAME$PROJECT_UI_TESTS
    # Update and rename test, uitest and project source files
    sed -i '' "s/$PROJECT_OLD_NAME/$PROJECT_NAME/g" \
        $OLD_TESTS/$OLD_TESTS".swift" \
        $OLD_UI_TESTS/$OLD_UI_TESTS".swift" \
        $PROJECT_OLD_NAME/Model/$PROJECT_OLD_NAME".xcdatamodeld"/.xccurrentversion
    mv $OLD_TESTS $NEW_TESTS
    mv $OLD_UI_TESTS $NEW_UI_TESTS
    mv $NEW_TESTS/$OLD_TESTS".swift" $NEW_TESTS/$NEW_TESTS".swift"
    mv $NEW_UI_TESTS/$OLD_UI_TESTS".swift" $NEW_UI_TESTS/$NEW_UI_TESTS".swift"
    mv $PROJECT_OLD_NAME/Model/$PROJECT_OLD_NAME".xcdatamodeld" $PROJECT_OLD_NAME/Model/$PROJECT_NAME".xcdatamodeld"
    mv $PROJECT_OLD_NAME/Model/$PROJECT_NAME".xcdatamodeld"/$PROJECT_OLD_NAME".xcdatamodel" $PROJECT_OLD_NAME/Model/$PROJECT_NAME".xcdatamodeld"/$PROJECT_NAME".xcdatamodel"
    mv $PROJECT_OLD_NAME $PROJECT_NAME
    # 
    # Update and rename xcodeproj file!
    reserve_arr=( "Project object" "PBXProject" "projectDirPath" "projectRoot")
    # Reserve string in .xcodeproj that exist in above array
    index=0
    for reserve_str in "${reserve_arr[@]}"
    do
        sed -i '' "s/$reserve_str/%reserve_$index%/g" $PROJECT_OLD_NAME".xcodeproj"/project.pbxproj
        index=$(( index+1 ))
    done
    # Update files in .xcodeproj
    sed -i '' "s/$PROJECT_OLD_NAME/$PROJECT_NAME/g" \
        $PROJECT_OLD_NAME".xcodeproj"/project.xcworkspace/contents.xcworkspacedata \
        $PROJECT_OLD_NAME".xcodeproj"/project.pbxproj
    # Restore reserved strings
    index=0
    for reserve_str in "${reserve_arr[@]}"
    do
        sed -i '' "s/%reserve_$index%/$reserve_str/g" $PROJECT_OLD_NAME".xcodeproj"/project.pbxproj
        index=$(( index+1 ))
    done
    # Almost done! Rename .xcodeproj
    mv $PROJECT_OLD_NAME".xcodeproj" $PROJECT_NAME".xcodeproj"
    # Update Podfile
    sed -i '' "s/'$PROJECT_OLD_NAME/'$PROJECT_NAME/g" Podfile
}
echo ""
echo "/////////////////////////"
echo "//  Customize Project  //"
echo "/////////////////////////"
set_organizer_if_need
rename_project
echo ""
echo "/////////////////////////"
echo "//  CocoaPods Install  //"
echo "/////////////////////////"
pod install
echo ""
echo ""
echo "/////////////////////////"
echo "//  Git repo clean up  //"
echo "/////////////////////////"
rm -rf .git
rm LICENSE
rm README.md
rm install.sh
echo ""
