/* F2C Cast Controller */

/* TODO: Cast Name Edit */

F2CCastController = Klass(Object, {
    /* view */
    view:false,							/* F2CPanelView */
    
    /* Controls */
    clearControl: false,
    exportControl: false,
    importControl: false,

    renameController: false,
    
    exportController: false,	    /* Export Function */
    
    actorViewerController:false,	/* The actor viewer to preview the selected actor */
    
    sceneController: false,         /* Scene Controller will be notified for the rename event in rename() */
    
    exampleUsageCode: "Example usage of above generated code:\n\n    context.save();\n\n    /* The (100, 100) in the canvas is where we want to draw the actor. */\n    context.translate(100, 100);\n\n    /* Draw the actor */\n    F2CCast['F2CActor1'].draw(context);\n\n    context.restore();\n",

    /* model */
    path: "",						/* path of the controller instance */    
    dataObjectName: "F2CCast",		/* for code gen */
    dataObject: {},     			/* Hold the (actorName: actorController) pairs */

    initialize: function(avc, path) {
    	this.path = path;
    	this.actorViewerController = avc;
    	this.exportController = new F2CExportController();
    	
        /* init view */
        this.view = new F2CPanelView('F2CCastView', this);
        this.view.addEventListener('F2CTableItemDelete', this.onItemDelete.bind(this), false);   		/* handle the delete request event */
        this.view.addEventListener('F2CTableItemMouseOver', this.onItemMouseOver.bind(this), false);	/* handle the MouseOver Event */

    	this.renameController = new F2CRenameController(this, this.view);

        /* init controlls , TODO */
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
	
	

	/* event handler for custom event 'F2CTableItemMouseOver' */
	onItemMouseOver: function(e) {
		actorController = e.detail.delegate;
		this.actorViewerController.drawActorByController(actorController);
	},

    onItemDelete: function(e) {
        itemName = e.detail.name;
        if (this.dataObject[itemName]) {        
            this.dataObject[itemName].remove();
            delete this.dataObject[itemName];   // Should I?
            this.view.update();
        }
    },

	/* implement panel view delegate protocol */
    getPanelLabelName: function() {
        return this.dataObjectName;
    },
	
    /* implement rename controller's delegate protocol */
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
		
		// notifiy the scene controller the actor was renamed.
		if (this.sceneController) {
		    this.sceneController.actorWasRenamed(originalItemName, newItemName);
		}
		return true;
    },
    
    loadIntoDataObject: function(_tempDataObject) {
    	
        for (itemName in _tempDataObject) {
            // check exist or not
            if (this.dataObject[itemName]) {
                this.dataObject[itemName].scrollIntoView();
                continue;
            }
            
            newItem = _tempDataObject[itemName];	/* newItem is a F2CCharacter */
            
            newItemController = new F2CActorController(itemName, newItem);
            
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
    
/* public */

    loadDataObjectByJSON: function(dataJSON) {
        eval("_tempDataObject = " + dataJSON);
		this.loadIntoDataObject(_tempDataObject);
    },    
        
    addItemByJSON: function(newDataItemJSON) {
        eval("_tempDataObject = { " + newDataItemJSON + " }");
		this.loadIntoDataObject(_tempDataObject);        
    },
    
    clear: function(event) {
        for (itemName in this.dataObject) {
            this.dataObject[itemName].remove();
            delete this.dataObject[itemName];   // Should I?
        }
        this.view.update();
    },
    
    getActorControllerByName: function(actorName) {
        return this.dataObject[actorName];
    },    
        
    doExport: function(event) {
        this.exportController.exampleUsageCode = this.exampleUsageCode;
        this.exportController.doExport(this.dataObjectName, this.dataObject);
    },

	doImport: function(event) {
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
	}
	
});