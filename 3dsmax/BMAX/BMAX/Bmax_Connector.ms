--BMAX script version.016
--BMAX ver.017: Added preserve instances
--BMAX ver.018: Added ResetXForm on import and rest ofFBX import parameters
try(destroydialog BMAX_Rollout)catch()
rollout BMAX_Rollout "BMAX Connector" 
(

	groupBox grp1 "Import/Export:" pos:[2,2] width:156 height:108 align:#left
	button btn_1 "Send to Blender"  pos:[8,20] width:144 height:40 align:#left tooltip:"Export model to Blender"
	button btn_2 "Get from Blender" pos:[8,60] width:144 height:40 align:#left tooltip:"Import model from Blender"
	
	subrollout prefs_frame "Preferences" height:675 width:156 pos:[2,115]	
	
	local BMAX_posX =  getINISetting  ("$userscripts\\BMAX\\bmax.ini") "Position" "PosX" as float 	
	local BMAX_posY =  getINISetting  ("$userscripts\\BMAX\\bmax.ini") "Position" "PosY" as float	
	local MaxVer = ((maxVersion())[1])	  
	local BMAX_INI = "$userscripts\\BMAX\\bmax.ini"
	
	
	fn BMAX_Export fileName =
	(
		local expObjs = #()
		local expLights = #()
		local expCameras = #()
		local clonedObjs = #()
		local selectionNames = #()
		local BMAX_Exp_GlobalScale = getINISetting  ("$userscripts\\BMAX\\bmax.ini") "Export" "GlobalScale" as float
		local BMAX_Exp_ConvertUnits = getINISetting  ("$userscripts\\BMAX\\bmax.ini") "Export" "ConvertUnits_sys" as string
		local BMAX_Exp_UpAxis = getINISetting  ("$userscripts\\BMAX\\bmax.ini") "Export" "UpAxis_sys" as string
		local BMAX_Exp_SmoothingGroups = getINISetting  ("$userscripts\\BMAX\\bmax.ini") "Export" "SmoothingGroups" as booleanClass
		local BMAX_Exp_Preserveinstances = getINISetting  ("$userscripts\\BMAX\\bmax.ini") "Export" "Preserveinstances" as booleanClass
		local BMAX_Exp_Cameras = getINISetting  ("$userscripts\\BMAX\\bmax.ini") "Export" "Cameras" as booleanClass
		local BMAX_Exp_Lights = getINISetting  ("$userscripts\\BMAX\\bmax.ini") "Export" "Lights" as booleanClass
		local BMAX_Exp_Animation = getINISetting  ("$userscripts\\BMAX\\bmax.ini") "Export" "Animation" as booleanClass
		local BMAX_Exp_collapseStack = getINISetting  ("$userscripts\\BMAX\\bmax.ini") "Export" "collapseStack" as booleanClass
		local BMAX_Exp_ResetXform = getINISetting  ("$userscripts\\BMAX\\bmax.ini") "Export" "ResetXform" as booleanClass
		local BMAX_Exp_convertToPoly = getINISetting  ("$userscripts\\BMAX\\bmax.ini") "Export" "convertToPoly" as booleanClass
		local BMAX_Exp_FBX_Ver = getINISetting  ("$userscripts\\BMAX\\bmax.ini") "Export" "FBX_Version_sys" as string
		
		for n in selection do (append selectionNames n.name)
		
		maxOps.cloneNodes selection cloneType:#copy newNodes:&clonedObjs
		
		for i=1 to clonedObjs.count do
		(
			o = clonedObjs[i]
			o.name = selectionNames[i]
			if superClassOf o == geometryClass and ClassOf o != Targetobject then
			(	
				local objSnapshot = o
				if BMAX_Exp_collapseStack == True then (collapsestack objSnapshot)				
				if BMAX_Exp_ResetXform == True then (resetxform objSnapshot)
				if BMAX_Exp_convertToPoly == True then 
					(
						convertToPoly objSnapshot
						polyop.collapseDeadStructs objSnapshot
						objSnapshot.DeleteIsoMapVerts()
					)				
				append expObjs objSnapshot
			)
			
			if isKindOf o.baseObject Shape then 
			(				
				local splineSnapshot = o
				convertToPoly splineSnapshot								
				append expObjs splineSnapshot
			)
			
			if BMAX_Exp_Lights == True and superClassOf o == light then
			(
				if o.target != undefined then
					(
						target = o.target
						append expLights o
						append expLights target						
					)
					else
						(
							append expLights o
						)
			)
			
			if BMAX_Exp_Cameras == True and superClassOf o == camera then
			(
				if o.target != undefined then
					(
						target = o.target
						append expCameras o
						append expCameras target						
					)
					else
						(
							append expCameras o
						)				
			)
		)
		
		max select none
		select expObjs
		if expLights.count !=0 then selectmore expLights
		if expCameras.count !=0 then selectmore expCameras			
		
		if selection.count != 0 then
			(			
				pluginManager.loadClass FBXEXP
				--Geometry------------------------------------------------------------------------
				FBXExporterSetParam "SmoothingGroups" BMAX_Exp_SmoothingGroups
				FBXExporterSetParam "NormalsPerPoly" false
				FBXExporterSetParam "TangentSpaceExport" true
				FBXExporterSetParam "SmoothMeshExport" false
				FBXExporterSetParam "Preserveinstances" BMAX_Exp_Preserveinstances
				FBXExporterSetParam "SelectionSetExport" false
				FBXExporterSetParam "GeomAsBone" false
				FBXExporterSetParam "ColladaTriangulate" true
				FBXExporterSetParam "PreserveEdgeOrientation" false
				--Animation------------------------------------------------------------------------
				FBXExporterSetParam "Animation" BMAX_Exp_Animation
				--Cameras------------------------------------------------------------------------
				FBXExporterSetParam "Cameras" BMAX_Exp_Cameras
				--Lights------------------------------------------------------------------------
				FBXExporterSetParam "Lights" BMAX_Exp_Lights
				--Embed Media--------------------------------------------------------------------
				FBXExporterSetParam "EmbedTextures" false
				--Units----------------------------------------------------------------------------
				FBXExporterSetParam "ConvertUnit" BMAX_Exp_ConvertUnits
				FBXExporterSetParam "ScaleFactor" BMAX_Exp_GlobalScale
				--Axis Conversion-----------------------------------------------------------------
				FBXExporterSetParam "AxisConversionMethod" "None"
				FBXExporterSetParam "UpAxis" BMAX_Exp_UpAxis
				--UI----------------------------------------------------------------
				FBXExporterSetParam "ShowWarnings" false
				FBXExporterSetParam "GenerateLog" false
				--FBX File Format----------------------------------------------------------------
				FBXExporterSetParam "ASCII" false
				
				FBXExporterSetParam "FileVersion" BMAX_Exp_FBX_Ver
				
				-----------------------------------------------------------------------------------						
				exportFile fileName #noPrompt selectedOnly:true	usage:FBXEXP
				for n in expObjs do delete n
				max select none					
			)			
		else
			(
				messageBox "Selection is empty! Please select some Editable poly objects." title:"Warning" beep:off 
			)
	)
	
	fn BMAX_Import fileName = 
	(		
		local BMAX_Imp_GlobalScale = getINISetting ("$userscripts\\BMAX\\bmax.ini") "Import" "GlobalScale" as float
		local BMAX_Imp_ConvertUnits = getINISetting ("$userscripts\\BMAX\\bmax.ini") "Import" "ConvertUnits_sys" as string
		local BMAX_Imp_UpAxis = getINISetting ("$userscripts\\BMAX\\bmax.ini") "Import" "UpAxis_sys" as string
		local BMAX_Imp_SmoothingGroups = getINISetting ("$userscripts\\BMAX\\bmax.ini") "Import" "SmoothingGroups" as booleanClass
		local BMAX_Imp_ResetXForm = getINISetting ("$userscripts\\BMAX\\bmax.ini") "Import" "ResetXForm" as booleanClass
		local BMAX_Imp_Cameras = getINISetting ("$userscripts\\BMAX\\bmax.ini") "Import" "Cameras" as booleanClass
		local BMAX_Imp_Lights = getINISetting ("$userscripts\\BMAX\\bmax.ini") "Import" "Lights" as booleanClass
		
		local BMAX_Imp_Animation = getINISetting ("$userscripts\\BMAX\\bmax.ini") "Import" "Animation" as booleanClass
		local BMAX_Imp_BakeAnimationLayers = getINISetting ("$userscripts\\BMAX\\bmax.ini") "Import" "BakeAnimationLayers" as booleanClass
		local BMAX_Imp_FillTimeline = getINISetting ("$userscripts\\BMAX\\bmax.ini") "Import" "FillTimeline" as booleanClass
		local BMAX_Imp_FilterKeyReducer = getINISetting ("$userscripts\\BMAX\\bmax.ini") "Import" "FilterKeyReducer" as booleanClass
		local BMAX_Imp_FilterKeySync = getINISetting ("$userscripts\\BMAX\\bmax.ini") "Import" "FilterKeySync" as booleanClass
		local BMAX_Imp_KeepFrameRate = getINISetting ("$userscripts\\BMAX\\bmax.ini") "Import" "KeepFrameRate" as booleanClass
		
		local BMAX_Imp_ImportBoneAsDummy = getINISetting ("$userscripts\\BMAX\\bmax.ini") "Import" "ImportBoneAsDummy" as booleanClass
	    local BMAX_Imp_Markers = getINISetting ("$userscripts\\BMAX\\bmax.ini") "Import" "Markers" as booleanClass
        local BMAX_Imp_PointCache = getINISetting ("$userscripts\\BMAX\\bmax.ini") "Import" "PointCache" as booleanClass
		local BMAX_Imp_Shape = getINISetting ("$userscripts\\BMAX\\bmax.ini") "Import" "Shape" as booleanClass
		local BMAX_Imp_Skin = getINISetting ("$userscripts\\BMAX\\bmax.ini") "Import" "Skin" as booleanClass


		
		
		
		
		pluginManager.loadClass FBXIMP			
		FBXImporterSetParam "Mode" #create
		--Geometry------------------------------------------------------------------------
		FBXImporterSetParam "SmoothingGroups" BMAX_Imp_SmoothingGroups					
		--Animation------------------------------------------------------------------------
		FBXImporterSetParam "Animation" BMAX_Imp_Animation		
		FBXImporterSetParam "BakeAnimationLayers" BMAX_Imp_BakeAnimationLayers
		FBXImporterSetParam "FillTimeline" BMAX_Imp_FillTimeline
		FBXImporterSetParam "FilterKeyReducer" BMAX_Imp_FilterKeyReducer 
		FBXImporterSetParam "FilterKeySync" BMAX_Imp_FilterKeySync 
		FBXImporterSetParam "ImportBoneAsDummy" BMAX_Imp_ImportBoneAsDummy
		FBXImporterSetParam "KeepFrameRate" BMAX_Imp_KeepFrameRate		
		FBXImporterSetParam "Markers" BMAX_Imp_Markers			
		FBXImporterSetParam "PointCache" BMAX_Imp_PointCache						
		FBXImporterSetParam "Shape" BMAX_Imp_Shape
		FBXImporterSetParam "Skin" BMAX_Imp_Skin	
		--Cameras------------------------------------------------------------------------
		FBXImporterSetParam "Cameras" BMAX_Imp_Cameras
		--Lights------------------------------------------------------------------------
		FBXImporterSetParam "Lights" BMAX_Imp_Lights	
		--Units----------------------------------------------------------------------------
		FBXImporterSetParam "ConvertUnit" BMAX_Imp_ConvertUnits
		FBXImporterSetParam "ScaleFactor" BMAX_Imp_GlobalScale
		FBXImporterSetParam "ScaleConversion" True
		--Axis Conversion-----------------------------------------------------------------
		FBXImporterSetParam "AxisConversion" True
		FBXImporterSetParam "UpAxis" BMAX_Imp_UpAxis		
			
		importFile fileName #noprompt usage:FBXIMP
		
		
		B_Objs = for o in selection where (isKindOf o GeometryClass and canConvertTo o Editable_Mesh) collect o
		if B_Objs.count != 0 do
			(
				for o in B_Objs do (o.wirecolor = (color 0 0 0))
				if BMAX_Imp_ResetXForm == True do 
					(
						for o in B_Objs do
						( 
							resetxform o 
							convertToPoly o
						)
					)
			)
		
	)	
	
	fn BMAX_Init = 
	(
		local theINIFile = "$userscripts\\BMAX\\bmax.ini"
		if doesFileExist theINIFile do
		(
			BMAX = getINISetting theINIFile "Path" "BMAX"
		)		
		if BMAX == "" OR BMAX == undefined do			
		(	
			BMAX = false
		)
		if BMAX == false do
		(
			local pickResult = getDirectories ((sysInfo.tempdir)+"\BMAX")
			if pickResult.count == 0 do 
			(			
				makeDir ((sysInfo.tempdir)+"\BMAX") all:False
				pickResult = getDirectories ((sysInfo.tempdir)+"\BMAX")
			)
			if pickResult[1] != undefined then
			(
				BMAX = pickResult[1] 
			)
			else
			(
				messagebox "There is no exchange folder. BMAX will now close."
				destroyDialog BMAX_Rollout
			)
			if BMAX != false then
			(
				setINISetting theINIFile "Path" "BMAX" BMAX
			)	
		)
		setDialogPos BMAX_Rollout [(BMAX_posX),(BMAX_posY)]
		format "BMAX Connector: Script version:018 - loaded, have fun!!! \n"
		format "BMAX Connector: Working folder: %,  if you want to change folder - - - RightMouseButton DoubleClick on BMAX window - - -\n" BMAX	
	) 
	
	on BMAX_Rollout open do 
	(
		BMAX_Init()	
	)	
		
	on btn_1 pressed do 		
	(		 
		BMAX_Export ((getINISetting  ("$userscripts\\BMAX\\bmax.ini") "Path" "BMAX") + ("\BMAX_TMP_MAX.fbx"))	
	)

	on btn_2 pressed do 
	(		 	
		BMAX_Import ((getINISetting  ("$userscripts\\BMAX\\bmax.ini") "Path" "BMAX") + ("\BMAX_TMP_BLENDER.fbx"))		
	)
	
	
	
	on BMAX_Rollout close do 
	(	
		NewWinPos = getDialogpos BMAX_Rollout		
		setINISetting ("$userscripts\\BMAX\\bmax.ini") "Position" "PosX" ( (NewWinPos[1]  as integer ) as string)
		setINISetting ("$userscripts\\BMAX\\bmax.ini") "Position" "PosY" ( (NewWinPos[2]  as integer ) as string)		
		format "BMAX Connector: Closed!\n"
	)
	on BMAX_Rollout rbuttondblclk val do
	(
		BMAX = getINISetting BMAX_INI "Path" "BMAX"
		newFolder = getSavePath caption:"Custom BMAX exchange folder" initialDir:BMAX
		if newFolder != undefined then
			(
				setINISetting BMAX_INI "Path" "BMAX" newFolder 
			)
			else 
			(
				setINISetting BMAX_INI "Path" "BMAX" ((sysInfo.tempdir)+"BMAX")
				messageBox "Default path restored" title:"Warning" beep:off	
			)			
	)

)
rollout BMAX_PREFS_Rollout "Preferences" rolledUp: True
(	
	groupBox grp_export "Export:" pos:[2,2] width:140 height:253 align:#left
	spinner spn_e_globalScale "Global scale:" pos:[15,20] range:[0,1000000.0,(getINISetting ("$userscripts\\BMAX\\bmax.ini") "Export" "GlobalScale" as float)] type:#float fieldWidth:50 toolTip:"Import/Export Global Scale" 
	label lbl_e_convertUnits "ConvertUnits:" pos:[9,44]
	dropdownlist dd_e_convertUnits "" pos:[78,40] items:#("mm", "cm", "dm", "m", "km", "in", "ft", "mi", "yd") selection:(getINISetting  ("$userscripts\\BMAX\\bmax.ini") "Export" "ConvertUnits" as integer) width: 59	 height:16	toolTip:"System units"
	label lbl_e_upAxis "UpAxis:" pos:[39,68]
	dropdownlist dd_e_upAxis "" pos:[78,65] items:#("Y", "Z") selection:(getINISetting ("$userscripts\\BMAX\\bmax.ini") "Export" "UpAxis" as integer) width: 59  height:16 tooltip:"Y or Z"
	label lbl_e_fbx_ver "FBX:" pos:[25,94]
	dropdownlist dd_e_fbx_ver "" pos:[52,90] items:#("FBX201200", "FBX201300", "FBX201400", "FBX201600", "FBX201800", "FBX201900", "FBX202000", "FBX202100") selection:(getINISetting ("$userscripts\\BMAX\\bmax.ini") "Export" "FBX_Version" as integer) width:85  height:16 tooltip:"Select FBX format version. Blender is using FBX Version 7.1 or newer.(FBX 2014)"
	
	checkbox ckb_e_smoothingGroups " Smoothing groups" pos:[9,115] checked:((getINISetting ("$userscripts\\BMAX\\bmax.ini") "Export" "SmoothingGroups") as booleanClass) tooltip:"Use smoothing groups, mark sharp edges in blender" 
	checkbox ckb_e_preserveInstances "Preserve instances" pos:[9,135] checked:((getINISetting ("$userscripts\\BMAX\\bmax.ini") "Export" "Preserveinstances") as booleanClass) tooltip:"Preserve instances" 
	checkbox ckb_e_cameras "Cameras" pos:[9,155] checked:((getINISetting ("$userscripts\\BMAX\\bmax.ini") "Export" "Cameras") as booleanClass) tooltip:"Export cameras"
	checkbox ckb_e_lights "Lights" pos:[80,155] checked:((getINISetting ("$userscripts\\BMAX\\bmax.ini") "Export" "Lights") as booleanClass) tooltip:"Export lights"
	checkbox ckb_e_animation "Animation" pos:[9,175] checked:((getINISetting ("$userscripts\\BMAX\\bmax.ini") "Export" "Animation") as booleanClass) tooltip:"Export animation"
	checkbox ckb_e_collapseStack "Mod.Collapse" pos:[9,195] checked:((getINISetting ("$userscripts\\BMAX\\bmax.ini") "Export" "collapseStack") as booleanClass) tooltip:"Collapse modifiers stack"
	checkbox ckb_e_resetXform "ResetXForm" pos:[9,215] checked:((getINISetting ("$userscripts\\BMAX\\bmax.ini") "Export" "ResetXform") as booleanClass) tooltip:"Apply transformation matrix = resetXform"
	checkbox ckb_e_convertToPoly "ConvertToPoly" pos:[9,235] checked:((getINISetting ("$userscripts\\BMAX\\bmax.ini") "Export" "convertToPoly") as booleanClass) tooltip:"Convert object to editable poly and delete deadVerts and deadStructs(some kind of cleanup)"
	
	groupBox grp_import "Import:" pos:[2,255] width:140 height:390 align:#left	
	spinner spn_i_globalScale "Global scale:" pos:[15,275] range:[0,1000000.0,(getINISetting ("$userscripts\\BMAX\\bmax.ini") "Import" "GlobalScale" as float)] type:#float fieldWidth:50 toolTip:"Import/Export Global Scale" 
	label lbl_i_convertUnits "ConvertUnits:" pos:[9,295]
	dropdownlist dd_i_convertUnits "" pos:[78,295] items:#("mm", "cm", "dm", "m", "km", "in", "ft", "mi", "yd") selection:(getINISetting  ("$userscripts\\BMAX\\bmax.ini") "Import" "ConvertUnits" as integer) width: 59 height:16 toolTip:"System units"
	label lbl_i_upAxis "UpAxis:" pos:[39,320]
	dropdownlist dd_i_upAxis "" pos:[78,320] items:#("Y", "Z") selection:(getINISetting ("$userscripts\\BMAX\\bmax.ini") "Import" "UpAxis" as integer) width: 59  height:16	tooltip:"Y or Z"
	checkbox ckb_i_smoothingGroups " Smoothing groups" pos:[9,345] checked:((getINISetting ("$userscripts\\BMAX\\bmax.ini") "Import" "SmoothingGroups") as booleanClass) tooltip:"Disabled - import with custom normals.\nEnabled - import with smoothing groups."	
	checkbox ckb_i_ResetXForm "ResetXForm" pos:[9,365] checked:((getINISetting ("$userscripts\\BMAX\\bmax.ini") "Import" "ResetXForm") as booleanClass) tooltip:"Reset transformation matrix for imported object(s)."	
	checkbox ckb_i_cameras "Cameras" pos:[9,385] checked:((getINISetting ("$userscripts\\BMAX\\bmax.ini") "Import" "Cameras") as booleanClass) tooltip:"Import cameras"
	checkbox ckb_i_lights "Lights" pos:[9,405] checked:((getINISetting ("$userscripts\\BMAX\\bmax.ini") "Import" "Lights") as booleanClass) tooltip:"Import lights"
	checkbox ckb_i_animation "Animation" pos:[9,425] checked:((getINISetting ("$userscripts\\BMAX\\bmax.ini") "Import" "Animation") as booleanClass) tooltip:"Import animation"	
	checkbox ckb_i_BakeAnimationLayers "BakeAnimationLayers" pos:[9,445] checked:((getINISetting ("$userscripts\\BMAX\\bmax.ini") "Import" "BakeAnimationLayers") as booleanClass) tooltip:"BakeAnimationLayers"
	checkbox ckb_i_FillTimeline "FillTimeline" pos:[9,465] checked:((getINISetting ("$userscripts\\BMAX\\bmax.ini") "Import" "FillTimeline") as booleanClass) tooltip:"FillTimeline"
	checkbox ckb_i_FilterKeyReducer "FilterKeyReducer" pos:[9,485] checked:((getINISetting ("$userscripts\\BMAX\\bmax.ini") "Import" "FilterKeyReducer") as booleanClass) tooltip:"FilterKeyReducer"
	checkbox ckb_i_FilterKeySync "FilterKeySync" pos:[9,505] checked:((getINISetting ("$userscripts\\BMAX\\bmax.ini") "Import" "FilterKeySync") as booleanClass) tooltip:"FilterKeySync"
	checkbox ckb_i_KeepFrameRate "KeepFrameRate" pos:[9,525] checked:((getINISetting ("$userscripts\\BMAX\\bmax.ini") "Import" "KeepFrameRate") as booleanClass) tooltip:"KeepFrameRate"
	checkbox ckb_i_ImportBoneAsDummy "ImportBoneAsDummy" pos:[9,545] checked:((getINISetting ("$userscripts\\BMAX\\bmax.ini") "Import" "ImportBoneAsDummy") as booleanClass) tooltip:"ImportBoneAsDummy"
	checkbox ckb_i_Markers "Markers" pos:[9,565] checked:((getINISetting ("$userscripts\\BMAX\\bmax.ini") "Import" "Markers") as booleanClass) tooltip:"Markers"
	checkbox ckb_i_PointCache "PointCache" pos:[9,585] checked:((getINISetting ("$userscripts\\BMAX\\bmax.ini") "Import" "PointCache") as booleanClass) tooltip:"PointCache"
	checkbox ckb_i_Shape "Shape" pos:[9,605] checked:((getINISetting ("$userscripts\\BMAX\\bmax.ini") "Import" "Shape") as booleanClass) tooltip:"Shape"	
	checkbox ckb_i_Skin "Skin" pos:[9,625] checked:((getINISetting ("$userscripts\\BMAX\\bmax.ini") "Import" "Skin") as booleanClass) tooltip:"Skin"
	
	
	on BMAX_PREFS_Rollout rolledUp state do
	(
		if state then 
			(			
				BMAX_Rollout.height = 790
			)
			else
				(
					BMAX_Rollout.height = 140
				)
	)
	 
	on spn_e_globalScale changed val do 
	(
		setINISetting ("$userscripts\\BMAX\\bmax.ini") "Export" "GlobalScale" ((spn_e_globalScale.value) as string)							
	)	
	on dd_e_convertUnits selected val do
	(	
		setINISetting ("$userscripts\\BMAX\\bmax.ini") "Export" "ConvertUnits" ((dd_e_convertUnits.selection) as string)
		setINISetting ("$userscripts\\BMAX\\bmax.ini") "Export" "ConvertUnits_sys" ((dd_e_convertUnits.items[val]) as string)
	)
	on dd_e_upAxis selected val do
	(
		setINISetting ("$userscripts\\BMAX\\bmax.ini") "Export" "UpAxis" ((dd_e_upAxis.selection) as string)
		setINISetting ("$userscripts\\BMAX\\bmax.ini") "Export" "UpAxis_sys" ((dd_e_upAxis.items[val]) as string)
	)
	on dd_e_fbx_ver selected val do
	(
		setINISetting ("$userscripts\\BMAX\\bmax.ini") "Export" "FBX_Version" ((dd_e_fbx_ver.selection) as string)
		setINISetting ("$userscripts\\BMAX\\bmax.ini") "Export" "FBX_Version_sys" ((dd_e_fbx_ver.items[val]) as string)
	)
	on ckb_e_preserveInstances changed state do 
 	(
 		setINISetting ("$userscripts\\BMAX\\bmax.ini") "Export" "Preserveinstances" ((ckb_e_preserveInstances.state) as string)							
 	)
	on ckb_e_smoothingGroups changed state do 
 	(
 		setINISetting ("$userscripts\\BMAX\\bmax.ini") "Export" "SmoothingGroups" ((ckb_e_smoothingGroups.state) as string)							
 	)
	on ckb_e_cameras changed state do 
 	(
 		setINISetting ("$userscripts\\BMAX\\bmax.ini") "Export" "Cameras" ((ckb_e_cameras.state) as string)							
 	)
	on ckb_e_lights changed state do 
 	(
 		setINISetting ("$userscripts\\BMAX\\bmax.ini") "Export" "Lights" ((ckb_e_lights.state) as string)							
 	)
	on ckb_e_animation changed state do 
 	(
 		setINISetting ("$userscripts\\BMAX\\bmax.ini") "Export" "Animation" ((ckb_e_animation.state) as string)							
 	)
	on ckb_e_collapseStack changed state do 
 	(
 		setINISetting ("$userscripts\\BMAX\\bmax.ini") "Export" "collapseStack" ((ckb_e_collapseStack.state) as string)							
 	)
	on ckb_e_resetXform changed state do 
 	(
 		setINISetting ("$userscripts\\BMAX\\bmax.ini") "Export" "ResetXform" ((ckb_e_resetXform.state) as string)							
 	)
	on ckb_e_convertToPoly changed state do 
 	(
 		setINISetting ("$userscripts\\BMAX\\bmax.ini") "Export" "convertToPoly" ((ckb_e_convertToPoly.state) as string)							
 	)
	
	
	
	on spn_i_globalScale changed val do 
	(
		setINISetting ("$userscripts\\BMAX\\bmax.ini") "Import" "GlobalScale" ((spn_i_globalScale.value) as string)							
	)	
	on dd_i_convertUnits selected val do
	(
		setINISetting ("$userscripts\\BMAX\\bmax.ini") "Import" "ConvertUnits" ((dd_i_convertUnits.selection) as string)
		setINISetting ("$userscripts\\BMAX\\bmax.ini") "Import" "ConvertUnits_sys" ((dd_i_convertUnits.items[val]) as string)
	)
	on dd_i_upAxis selected val do
	(
		setINISetting ("$userscripts\\BMAX\\bmax.ini") "Import" "UpAxis" ((dd_i_upAxis.selection) as string)
		setINISetting ("$userscripts\\BMAX\\bmax.ini") "Import" "UpAxis_sys" ((dd_i_upAxis.items[val]) as string)
	)
	on ckb_i_smoothingGroups changed state do 
 	(
 		setINISetting ("$userscripts\\BMAX\\bmax.ini") "Import" "SmoothingGroups" ((ckb_i_smoothingGroups.state) as string)							
 	)
	on ckb_i_cameras changed state do 
 	(
 		setINISetting ("$userscripts\\BMAX\\bmax.ini") "Import" "Cameras" ((ckb_i_cameras.state) as string)							
 	)
	on ckb_i_lights changed state do 
 	(
 		setINISetting ("$userscripts\\BMAX\\bmax.ini") "Import" "Lights" ((ckb_i_lights.state) as string)							
 	)	
	on ckb_i_animation changed state do 
 	(
 		setINISetting ("$userscripts\\BMAX\\bmax.ini") "Import" "Animation" ((ckb_i_animation.state) as string)							
 	)
	on ckb_i_ResetXForm changed state do 
 	(
 		setINISetting ("$userscripts\\BMAX\\bmax.ini") "Import" "ResetXForm" ((ckb_i_ResetXForm.state) as string)							
 	)	
	on ckb_i_BakeAnimationLayers changed state do 
 	(
 		setINISetting ("$userscripts\\BMAX\\bmax.ini") "Import" "BakeAnimationLayers" ((ckb_i_BakeAnimationLayers.state) as string)							
 	)	
	on ckb_i_FillTimeline changed state do 
 	(
 		setINISetting ("$userscripts\\BMAX\\bmax.ini") "Import" "FillTimeline" ((ckb_i_FillTimeline.state) as string)							
 	)	
	on ckb_i_FilterKeyReducer changed state do 
 	(
 		setINISetting ("$userscripts\\BMAX\\bmax.ini") "Import" "FilterKeyReducer" ((ckb_i_FilterKeyReducer.state) as string)							
 	)	
	on ckb_i_FilterKeySync changed state do 
 	(
 		setINISetting ("$userscripts\\BMAX\\bmax.ini") "Import" "FilterKeySync" ((ckb_i_FilterKeySync.state) as string)							
 	)	
	on ckb_i_KeepFrameRate changed state do 
 	(
 		setINISetting ("$userscripts\\BMAX\\bmax.ini") "Import" "KeepFrameRate" ((ckb_i_KeepFrameRate.state) as string)							
 	)	
	on ckb_i_ImportBoneAsDummy changed state do 
 	(
 		setINISetting ("$userscripts\\BMAX\\bmax.ini") "Import" "ImportBoneAsDummy" ((ckb_i_ImportBoneAsDummy.state) as string)							
 	)	
	on ckb_i_Markers changed state do 
 	(
 		setINISetting ("$userscripts\\BMAX\\bmax.ini") "Import" "Markers" ((ckb_i_Markers.state) as string)							
 	)	
	on ckb_i_PointCache changed state do 
 	(
 		setINISetting ("$userscripts\\BMAX\\bmax.ini") "Import" "PointCache" ((ckb_i_PointCache.state) as string)							
 	)	
	on ckb_i_Shape changed state do 
 	(
 		setINISetting ("$userscripts\\BMAX\\bmax.ini") "Import" "Shape" ((ckb_i_Shape.state) as string)							
 	)	
	on ckb_i_Skin changed state do 
 	(
 		setINISetting ("$userscripts\\BMAX\\bmax.ini") "Import" "Skin" ((ckb_i_Skin.state) as string)							
 	)	
)

createDialog BMAX_Rollout 160 140 style:#(#style_titlebar, #style_sysmenu, #style_toolwindow)
addSubRollout BMAX_Rollout.prefs_frame BMAX_PREFS_Rollout

