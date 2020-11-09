clearListener()
filein (pathConfig.appendPath (getFilenamePath (getThisScriptFilename())) "sharedFns.ms")

tasksFolder = @"D:\Temp\Tasks\"
tasksOutputFolder = @"D:\Temp\Tasks Output\"
tasks = #()

fn submitSceneAsNewRenderTask =
(	
	local sceneMaxFileName = maxfilename
	if sceneMaxFileName == "" do sceneMaxFileName = "untitled.max" 
	local sceneName = (getFilenameFile sceneMaxFileName)
	if sceneName == "" do sceneName = "untitled"
	
	local newTaskName = (dotnetclass "System.Datetime").Now.ToString("yyyy' 'MM' 'dd' - 'HH' 'mm' 'ss" ) + " - " + sceneName
	local newTaskFolder = pathConfig.appendPath tasksFolder newTaskName
	local newTaskMaxFilePath = pathConfig.appendPath newTaskFolder sceneMaxFileName

	makeDir newTaskFolder

	saveMaxFile newTaskMaxFilePath
)

fn readTasks =
(
	local completedTasks = for f in boaFnsGetSubFolders tasksOutputFolder collect boaFnsGetDirectoryName f
	local taskFolders = for f in boaFnsGetSubFolders tasksFolder where findItem completedTasks (boaFnsGetDirectoryName f) == 0 and (boaFnsgetFilesWithPattern f "*.max").count > 0 collect f
	tasks = for f in taskFolders collect (boaFnsgetFilesWithPattern f "*.max")[1]
)

fn renderNext =
(
	if tasks.count > 0 then
	(
		local task = tasks[1]
		deleteItem tasks 1
		local getTaskFolderName = boaFnsGetDirectoryName (getFilenamePath task)
		local taskOutputFolderPath = pathConfig.appendPath tasksOutputFolder getTaskFolderName
		makeDir taskOutputFolderPath

		loadMaxFile task quiet:true

		print ("rendering task: " + getTaskFolderName)
		
		max quick render --render() --sleep 5

		print ("finished task: " + getTaskFolderName)
	)
	else print "No Tasks Available"
)


--createDialog renderManagerDialog

global RenderManagerProcessorFloater
fn openRenderManagerProcessor = 
(
	rollout roll "BOA Render Manager - Processor"
	(
	  timer clock "testClock" interval:1000 --tick once a second
	  label lblStatus ""
	  on clock tick do
	  (
		print "tick"
		  
		readTasks()
		  
		lblStatus.text = "remaining tasks: " + (tasks.count as string)
		  
		renderNext()
	  )
	)

	try(closeRolloutFloater RenderManagerProcessorFloater)catch()
	RenderManagerProcessorFloater = newRolloutFloater "Render Manager Processor" 250 250
	addRollout roll RenderManagerProcessorFloater 
)


global renderManagerSubmiterFloater
fn openRenderManagerSubmiter = 
(
	rollout roll "BOA Render Manager - Submiter"
	(
	  button btnSubmit "Submit"
		
	  on btnSubmit pressed do
	  (
		submitSceneAsNewRenderTask()
	  )
	)

	try(closeRolloutFloater renderManagerSubmiterFloater)catch()
	renderManagerSubmiterFloater = newRolloutFloater "Render Manager" 250 250
	addRollout roll renderManagerSubmiterFloater 
)

