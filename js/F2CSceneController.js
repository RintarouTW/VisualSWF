/* F2C Scene Controller */

/* TODO: 
  - Import, Export, Sort
  - Scene Name Edit 
 */

F2CSceneController = Klass(Object, {
    /* view */
    view:false,     				/* F2CPanelView */
    
    /* Controls */
    clearControl: false,
    exportControl: false,
    importControl: false,

    renameController: false,
    
    exportController: false,	    /* Export Function */    

	castController: false,
	characterEditorController: false,

    /* model */
    exampleUsageCode:   "Example usage of above generated code:\n\n" + 
                        "1. Import F2CLib.js\n" +
                        '    &lt;script type="text/javascript" src="http://rintarou.dyndns.org/download/f2c/F2CLib.js"&gt;&lt;/script&gt;\n\n' +
                        "2. Draw the character\n" +
                        "    context.save();\n" + 
                        "    context.translate(100, 100);\n" + 
                        "    F2CDrawCharacter(F2CCast, F2CScene['F2CCharacter1'], context);\n" + 
                        "    context.restore();\n",
                        
    path: "",						/* path of the controller instance */
    dataObjectName: "F2CScene",		/* for code gen */
    dataObject: {},     			/* Hold the { characterName: characterController, ... } pairs */
    
    initialize: function(castController, characterEditorController, path) {
    	this.path = path;
    	this.castController = castController;
        this.castController.sceneController = this; /* for actorWasRenamed() */
    	
    	this.characterEditorController = characterEditorController;
    	this.exportController = new F2CExportController();
    	
        /* init view */
        this.view = new F2CPanelView('F2CSceneView', this);
        
        this.view.addEventListener('F2CTableItemDelete', this.deleteItem.bind(this), false);
        this.view.addEventListener('F2CTableItemMouseOver', this.onItemMouseOver.bind(this), false);
        this.view.addEventListener('dragenter', this.dragEnter, false);
        this.view.addEventListener('dragover', this.dragOver, false);
        this.view.addEventListener('drop', this.dropHandler.bind(this), false);

    	this.renameController = new F2CRenameController(this, this.view);
    	
        /* init controls */
        this.clearControl  = new F2CButtonView('Clear');
        this.clearControl.addEventListener('click', this.clear.bind(this), false);

        this.exportControl  = new F2CButtonView('Export');
        this.exportControl.addEventListener('click', this.doExport.bind(this), false);

        this.importControl  = new F2CButtonView('Import');
        this.importControl.addEventListener('click', this.doImport.bind(this), false);

        this.view.controlsContainer.appendChild(this.clearControl);
        this.view.controlsContainer.appendChild(this.exportControl);
        this.view.controlsContainer.appendChild(this.importControl);
        return this;
    },
    
    actorWasRenamed: function(oldName, newName) {
        // change the character.actorName to the new name.
        for(charName in this.dataObject) {
            characterController = this.dataObject[charName];
            
            actorName = characterController.getActorName();
            if (actorName == oldName) {
                characterController.setActorName(newName);
                
                if (characterController == this.characterEditorController.characterController) {
                    /* in order to update the name on the editor panel which is controlled by the editor controller */
                    this.characterEditorController.updateView();
                }
            }
            
            /* user may load a new cast, give the character controller a chance to update it's view 
               for the new cast automatically.
             */
            if (actorName == newName) {
                characterController.updateView();
            }
        }
    },

	/* implement panel view delegate protocol */
    getPanelLabelName: function() {
        return this.dataObjectName;
    },

	/* Drag & Drop Handlers for view */
	dragEnter: function(event) {
        event.dataTransfer.effectAllowed = "copy";
    },
    
	dragOver: function(event) {
		event.dataTransfer.dropEffect = "copy";	// must be set to make drag & drop work
		event.preventDefault(); // override default drag feedback
	},

	dropHandler: function(event) {	
		actorName = event.dataTransfer.getData("ActorName");
		this.addItem(actorName);
	},

	/* event handler for custom event 'F2CTableItemMouseOver' */
	onItemMouseOver: function(e) {
		/* e.detail is F2CTableItemView(<tr>) */
		characterController = e.detail.delegate;
		this.characterEditorController.setCharacterController(characterController);
	},
	
	getNewCharacterName: function() {
		serialNo = this.view.numItems + 1;
		while (true) {
			newCharName = 'F2CCharacter' + serialNo++;
			if (typeof(this.dataObject[newCharName]) == 'undefined') 
				break;
		}
		return newCharName;
	},
	
        
    loadDataObjectByJSON: function(dataJSON) {
        eval("_tempDataObject = " + dataJSON);
		this.loadIntoDataObject(_tempDataObject);
    },    
        
    addItemByJSON: function(newDataItemJSON) {
        eval("_tempDataObject = { " + newDataItemJSON + " }");
		this.loadIntoDataObject(_tempDataObject);        
    },
        
    loadIntoDataObject: function(_tempDataObject) {
        for (itemName in _tempDataObject) {
            // check exist or not
            if (this.dataObject[itemName]) {
                this.dataObject[itemName].scrollIntoView();
                continue;
            }
            
            newItem = _tempDataObject[itemName];	/* newItem is a F2CCharacter */
            
            newItemController = new F2CCharacterController(itemName, newItem);
            
			this.view.addItem(newItemController.view);
            newItemController.scrollIntoView();

            // check the same name..
            if (this.dataObject[itemName]) {
                // remove the old one.
                this.dataObject[itemName].remove();
                delete this.dataObject[itemName];   // Should I?
            }
            
            this.dataObject[itemName] = newItemController;
            this.view.update();
            //return newActor;
        }    	
    },
    
    rename: function(target, originalItemName, newItemName) {
        /* target is the view which dispatched the rename request */
        if (target == this.view) {
            /* must be the name label of the panel view to be renamed */
            this.dataObjectName = newItemName;
            return true;
        }

		// already there               
		if (this.dataObject[newItemName]) {
			// don't allow.
			alert(newItemName + " exist, it's not allowed.");
			return false;
		}

		// change it.
		var newDataObject = new Object();
		for (itemName in this.dataObject) {    // create a new cast and following the original order in the old cast.
			if (itemName == originalItemName) {
				newDataObject[newItemName] = this.dataObject[itemName]; // use the new name.
				this.dataObject[itemName].setName(newItemName);  		// update it.
			} else {
				newDataObject[itemName] = this.dataObject[itemName];    // copy the old one.
			}
		}
		delete this.dataObject;
		this.dataObject = newDataObject;
		return true;
    },
    
    addItem: function(actorName) {
		actorController = this.castController.dataObject[actorName];
		actor = actorController.actor;		
		
		newCharName = this.getNewCharacterName();

		tempDataObject = {};		
		tempDataObject[newCharName] = F2CCharacterCreate(actorName, actor.width, actor.height);
		
		this.loadIntoDataObject(tempDataObject);    
    },
    
    deleteItem: function(e) {
        itemName = e.detail.name;
        if (this.dataObject[itemName]) {        
            this.dataObject[itemName].remove();
            delete this.dataObject[itemName];   // Should I?
            this.view.update();
        }
    },
    
    clear: function() {
        for (itemName in this.dataObject) {
            this.dataObject[itemName].remove();
            delete this.dataObject[itemName];   // Should I?
        }
        this.view.update();
    },
    
    doExport: function() {
        this.exportController.exampleUsageCode = this.exampleUsageCode;
        this.exportController.doExport(this.dataObjectName, this.dataObject);
    },

	doImport: function() {
		window.prompt("Import " + this.dataObjectName + " " + this.path);
	},
		
	sort: function() {
		var list = [];
		/* push all controller into the list array */
		i = 0;
		for (itemName in this.dataObject) {
			list[i] = this.dataObject[itemName];
			i++;
		}
		
		/* sort by itemName */
		list.sort(function(a, b) {
			var itemNameA = a.name.toLowerCase();
			var itemNameB = b.name.toLowerCase();
			
			if (itemNameA < itemNameB) {
				return -1;
			}
			if (itemNameA > itemNameB) {
				return 1;
			}
			return 0;
		});
		
		this.clear();	// clear dataObject
		
		/* push into dataObject in sorted order */
		for (i  = 0; i < list.length; i++) {
			this.dataObject[list[i].name] = list[i];
			this.actorTable.appendChild(list[i].view);
		}
		this.view.update();
	},
	
/* public */	
	setVisible: function(visible) {
		if(visible) {
			setVisibility(this.view, true);
		} else {
			setVisibility(this.view, false);
		}
	}
		
});