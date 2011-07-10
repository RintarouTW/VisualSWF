/* F2C Lib */
    
function IncludeJavaScript(jsFile)
{
	document.write('<script type="text/javascript" src="' + jsFile + '"></script>'); 
}

F2CDebugger = false;

/* ==== Base ==== */
/* Libs */
IncludeJavaScript('lib/cake/cake.js');			/* MIT */
IncludeJavaScript('lib/jscolor/jscolor.js'); 	/* LGPL */
IncludeJavaScript('F2CShare.js');

IncludeJavaScript('F2CRenameController.js');

/* 1. Views */
IncludeJavaScript('view/F2CTableItemView.js');
IncludeJavaScript('view/F2CTableView.js');		/* require F2CTableItemView.js, F2CRenameController.js(TODO) */
IncludeJavaScript('view/F2CPanelView.js');		/* require F2CTTableView.js */
IncludeJavaScript('view/F2CSliderView.js');
IncludeJavaScript('view/F2CButtonView.js');
IncludeJavaScript('view/F2CInputView.js');

/* 2. Controllers */

/* 2.1 View Controllers */
IncludeJavaScript('F2CActorController.js');
IncludeJavaScript('F2CCharacterController.js');

/* 2.2 Component controllers */
IncludeJavaScript('F2CActorViewerController.js');				/* require F2CActor.js */
IncludeJavaScript('F2CCharacterEditPanelController.js');
IncludeJavaScript('F2CCharacterEditorController.js');			/* require F2CCharacterController.js, F2CCharacterEditPanelController.js */
IncludeJavaScript('F2CExportController.js');
IncludeJavaScript('F2CInfoBoxController.js');
IncludeJavaScript('F2CCastController.js');
IncludeJavaScript('F2CSceneController.js');


/* ==== Optional ==== */
IncludeJavaScript('F2CDebugController.js');