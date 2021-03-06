#!/bin/bash
#godot_funcs.sh


#
function download_godot_headless() {
    #
    # version eg 3.4.4
    local VERSION=$1
    
    # url to download Godot Mono Headless build from
    GD_MONO_HEADLESS_URL=https://downloads.tuxfamily.org/godotengine/${VERSION}/mono/Godot_v${VERSION}-stable_mono_linux_headless_64.zip
    # the name of the Godot Mono Headless build once it is unzipped
    GD_MONO_HEADLESS_NAME=Godot_v${VERSION}-stable_mono_linux_headless.64

    # if cache dir doesnt have file with 'godot_mono_headless.64'
    if [ ! -f $CACHE_DIR/godot_mono_headless.64 ]; then
        #
        output_section "Downloading Godot Mono Headless v$VERSION executable..."
        
        # download headless executalbe zip
        curl -s $GD_MONO_HEADLESS_URL -o godot-headless.zip || exit 1
        # unzip
        unzip -o godot-headless.zip

        # Godot mono headleass build comes with an extra 'GodotSharp' folder
        # that needs to be copied as well
        cp Godot_v${VERSION}-stable_mono_linux_headless_64/Godot_v${VERSION}-stable_mono_linux_headless.64 "$CACHE_DIR/godot_mono_headless.64"
        cp -r Godot_v${VERSION}-stable_mono_linux_headless_64/GodotSharp $CACHE_DIR
        #
        # set 'self-contained mode'
        touch "$CACHE_DIR/._sc_"
    else
        output_section "Using cached Godot v$VERSION Mono Headless executable"
    fi

    # Godot mono headless executable is stored at $CACHE_DIR/godot_mono_headless.64
    output_section "Godot Mono Headless setup done."
}


#
function download_godot_server() {
    #
    local VERSION=$1
    #
    GD_MONO_SERVER_URL=https://downloads.tuxfamily.org/godotengine/${VERSION}/mono/Godot_v${VERSION}-stable_mono_linux_server_64.zip
    #
    GD_MONO_SERVER_NAME=Godot_v${VERSION}-stable_mono_linux_server.64
    #
    if [ ! -f $CACHE_DIR/GD_MONO_SERVER_NAME ]; then
        #
        output_section "Downloading Godot Mono Server v$VERSION executable..."

        # download godot server mono executable
        curl -s $GD_MONO_SERVER_URL -o godot-server.zip || exit 1
        # unzip it
        unzip -o godot-server.zip

        # copy executable and its data folder to cache
        cp Godot_v${VERSION}-stable_mono_linux_server_64/Godot_v${VERSION}-stable_mono_linux_server.64 $CACHE_DIR/GD_MONO_SERVER_NAME
        cp -r Godot_v${VERSION}-stable_mono_linux_server_64/data_Godot_v${VERSION}-stable_mono_linux_server_64 $CACHE_DIR

        #touch "$CACHE_DIR/._sc_"
    else
        output_section "Using cached Godot v$VERSION Mono Server executable"
    fi

    # copy godot mono server executable to dist folder,<===!!!
    # as server executable will need some libraries
    # included in the mono data folder of the exported project
    cp $CACHE_DIR/GD_MONO_SERVER_NAME $BUILD_DIR/dist/godot_mono_server.64
    cp -r $CACHE_DIR/data_Godot_v${VERSION}-stable_mono_linux_server_64 $BUILD_DIR/dist

    # Godot server is stored at $BUILD_DIR/dist/godot_mono_server.64
    output_section "Godot Mono Server setup done."
}


#
function download_godot_templates() {
    #
    local VERSION=$1
    GODOT_TEMPLATES_URL=https://downloads.tuxfamily.org/godotengine/${VERSION}/mono/Godot_v${VERSION}-stable_mono_export_templates.tpz
    TEMPLATES_DEST="$CACHE_DIR/editor_data/templates/${VERSION}.stable.mono"
    #TEMPLATES_DEST = "$BUILD_DIR/.local/share/godot/templates/${VERSION}.stable.mono"

    #
    if [ ! -f $TEMPLATES_DEST/linux_x11_64_release ]; then
        #
        output_section "Downloading Godot Mono Linux Templates..."
        #
        curl -s $GODOT_TEMPLATES_URL -o godot-templates.zip || exit 1
        unzip -o godot-templates.zip
        mkdir -p $TEMPLATES_DEST

        #
        cp templates/linux_x11_64_debug $TEMPLATES_DEST
        cp templates/linux_x11_64_release $TEMPLATES_DEST

        cp -r templates/data.mono.x11.64.release $TEMPLATES_DEST
        cp -r templates/data.mono.x11.64.release_debug $TEMPLATES_DEST
    else
        output_section "Using cached Godot Mono Linux/X11 x64 Templates."
    fi

    # Godot export templates are stored at $CACHE_DIR/editor_data/templates/${VERSION}.mono.stable
    output_section "Godot Mono Templates setup done."
}


#
function export_godot_project() {
    #
    OUTPUT_DEST="$BUILD_DIR/dist"
    OUTPUT_FILE="$OUTPUT_DEST/linux.pck"
    
    #
    output_section "Exporting Godot Mono Server Project..."
    output_line "Target: '$OUTPUT_FILE'"
    
    # create folders
    mkdir -p $OUTPUT_DEST

    # Export the project to Linux/X11 
    # The project must have a Linux/X11 export template setup
    $CACHE_DIR/godot_mono_headless.64 --path "$BUILD_DIR" --export-pack "Linux/X11" "$OUTPUT_FILE" || exit 1
}