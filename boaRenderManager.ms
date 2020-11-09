clearListener()
filein (pathConfig.appendPath (getFilenamePath (getThisScriptFilename())) "sharedFns.ms")

tasksFolder = @"D:\Temp\Tasks\"
tasksOutputFolder = @"D:\Temp\Tasks Output\"
tasks = #()

fn submitSceneAsNewRenderTask =
(
	local newTaskName = (dotnetclass "System.Datetime").Now.ToString("yyyy' 'MM' 'dd' - 'HH':'mm':'ss" ) + " - " + (getFilenameFile maxfilename)
	local newTaskFolder = pathConfig.appendPath tasksFolder newTaskName
	local newTaskMaxFilePath = pathConfig.appendPath newTaskFolder maxfilename

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
		print ("rendering task: " + getTaskFolderName)
		
		render() --sleep 5

		print ("finished task: " + getTaskFolderName)
	)
	else print "No Tasks Available"
)

rollout renderManagerRoll "Render Manager"
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
--createDialog renderManagerDialog

try(closeRolloutFloater renderManagerFloater)catch()
renderManagerFloater = newRolloutFloater "Render Manager" 250 250
addRollout renderManagerRoll renderManagerFloater 