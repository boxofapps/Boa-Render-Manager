fn boaFnsGetDirectoryName thePath =
(
    local d = (dotnetobject "system.io.directoryinfo" thePath)
    d.name
)

fn boaFnsGetSubFolders root recursive:false =
(
    root = pathconfig.appendPath root @"\"

    dir_array = GetDirectories (root+"/*")
    
    if recursive == true do
    (
        for d in dir_array do
            join dir_array (GetDirectories (d+"/*"))
    )
    
    dir_array
)

fn boaFnsGetFilesWithPattern root pattern recursive:false =
(
    root = pathconfig.appendPath root @"\"

    dir_array = #()
    
    if recursive == true then
    (
        dir_array = GetDirectories (root+"/*")
        for d in dir_array do
            join dir_array (GetDirectories (d+"/*"))
                
        append dir_array root
    )
    else
    (
        dir_array = #(root)
    )
    
    my_files = #()
    
    for f in dir_array do
    (
        join my_files (getFiles (f + pattern))
    )
    
    my_files
)