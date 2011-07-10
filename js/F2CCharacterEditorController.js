/*
 *	TODO:
 *  1. undo design
 */

F2CCharacterEditorController = Klass(Object, {
	view:false,			/* <div> */
	canvas: false,		/* <canvas> */
	anchor: false, 		/* <div> */
	resizer: false,   	/* <div> */
	
	/* controller */
	editPanelController: false,	/* F2CCharacterEditPanelController */
	
	castController: false,
	
	/* model */
	anchorPoint: { x: 0, y: 0},	/* anchor point (x,y) */
	character: false,
	characterController: false,
	
	initialize : function(castController) {
		this.editPanelController = new F2CCharacterEditPanelController(this);
		
		this.castController = castController;
		this.view   = new E('div', 
							{ width : 0, height: 0, className : "F2CCharacterEditorView" });

        this.view.addEventListener('dragenter', this.dragEnter, false);
        this.view.addEventListener('dragover', this.dragOver, false);
        this.view.addEventListener('drop', this.dropHandler.bind(this), false);
		
		bounds = new E('div', { className : "F2CCharacterEditorViewBounds"});
		this.canvas = new E('canvas', { className : "F2CCharacterEditorCanvas" });

		bounds.appendChild(this.canvas);
		this.view.appendChild(bounds);

		this.resizer = new E('div', { className : "F2CCharacterEditorResizer"});
		this.resizer.addEventListener('mousedown', this.beginResize.bind(this), false);
		this.resizer.addEventListener('mouseup', this.endResize.bind(this), false);
		document.body.appendChild(this.resizer);

		this.anchor = new E('div', { className : "F2CCharacterEditorAnchor"});
		this.anchor.addEventListener('mousedown', this.beginAnchorMove.bind(this), false);
		this.anchor.addEventListener('mouseup', this.endAnchorMove.bind(this), false);
		document.body.appendChild(this.anchor);

		document.body.appendChild(this.view);
		
		window.addEventListener('resize', this.onWindowResize.bind(this), false);
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
		if (actorName) {
            this.character.actorName = actorName;
            this.characterController.updateView();
            this.updateView();
		}
	},
	
	/* implement the protocol of edit panel which modified the character */
	onCharacterModified: function() {
		this.updateView();
	},
	
	onWindowResize: function(event) {
		centerAlign(WorkingArea, this.view, true);
		this.updateView();
	},	
	
	/* Resizer Event Handlers */
	beginResize: function(event) {
		document.onmousemove = this.resize.bind(this);
		document.onmouseup = this.endResize.bind(this);
	},
	
	endResize: function(event) {
		document.onmousemove = null;
	},
	
	resize: function(event) {
		orgX = getValue(this.view, "left");
		orgY = getValue(this.view, "top");
		
		newWidth = event.clientX - orgX - getValue(this.resizer, "width");
		newHeight = event.clientY - orgY - getValue(this.resizer, "height");
		
		if (newWidth < 0) newWidth = 0;
		if (newHeight < 0) newHeight = 0;
		
		this.setSize(newWidth, newHeight);
	},
	
	/* Calculate AnchorPoint */
	updateAnchorPoint: function() {
	    switch(this.character.anchorX) {
            case "left":
                _anchorX = 0;
            break;
            case "center":
                _anchorX = this.character.width / 2;
            break;
            case "right":
                _anchorX = this.character.width;
            break;
            default:
                _anchorX = this.character.anchorX;
            break;
        }
        
        switch(this.character.anchorY) {
            case "top":
                _anchorY = 0;
            break;
            case "middle":
                _anchorY = this.character.height / 2;
            break;
            case "bottom":
                _anchorY = this.character.height;
            break;
            default:
                _anchorY = this.character.anchorY;
            break;
        }
        
        this.anchorPoint.x = _anchorX;
        this.anchorPoint.y = _anchorY;
	},
	
	/* Anchor Event Handlers */
	beginAnchorMove: function(event) {
		this.mouseDownX = event.clientX;
		this.mouseDownY = event.clientY;
		document.onmousemove = this.moveAnchor.bind(this);
		document.onmouseup = this.endAnchorMove.bind(this);
	},
	
	endAnchorMove: function(event) {
		document.onmousemove = null;
	},
	
	moveAnchor: function(event) {
		offsetX = event.clientX - this.mouseDownX;
		offsetY = event.clientY - this.mouseDownY;
		this.anchorPoint.x += offsetX;
		this.anchorPoint.y += offsetY;
		this.character.anchorX = this.anchorPoint.x;
		this.character.anchorY = this.anchorPoint.y;
		
		this.mouseDownX = event.clientX;
		this.mouseDownY = event.clientY;
		this.updateView();
	},
	

/* Public */
	setCharacterController: function(characterController) {
	    if(this.characterController) {
	        this.characterController.setEditing(false);
	    }
		this.characterController = characterController;
	    if(this.characterController) {
	        this.characterController.setEditing(true);
	    }
		this.character = this.characterController.character;
		this.setVisible(true);
		this.width = this.character.width;
		this.height = this.character.height;
		
		/*
		this.anchorPoint.x = this.character.anchorX;
		this.anchorPoint.y = this.character.anchorY;
		*/
		
		this.updateView();
	},

	setSize: function(width, height) {
		this.character.width = width;
		this.character.height = height;
		this.updateView();
	},

	drawCanvas: function() {
		if (this.character) {
		    context = this.canvas.getContext('2d');
	    	 /* clear */
		    context.clearRect(0, 0, this.canvas.width, this.canvas.height);
		    
		    /* draw the background */
		    context.save();
		    context.fillStyle = "#222222";
		    for (i = 0; i < this.canvas.width; i+= 15) {
		        for (j = 0; j < this.canvas.height; j+= 30) {
		            if ((i/15) % 2) {
		                context.fillRect(i, j + 15, 15, 15);
		            } else {
		                context.fillRect(i, j, 15, 15);
		            }
		        }
		    }
		    context.restore();
		    
		    /* draw the character */
			actorName = this.character.actorName;
			actor = this.castController.dataObject[actorName].actor;
			
			context.save();
			
			context.shadowOffsetX = this.character.shadowOffsetX;
			context.shadowOffsetY = this.character.shadowOffsetY;
			context.shadowBlur    = this.character.shadowBlur;
			context.shadowColor   = this.character.shadowColor;
			context.globalAlpha   = this.character.opacity;
			context.globalCompositeOperation = this.character.compositeOperation;
			
			scaleX = this.character.width  / actor.width;
			scaleY = this.character.height / actor.height;

			context.scale(scaleX, scaleY);
			actor.draw(context, 0, 0);
			context.restore();
		}
	},

	updateView: function() {
	    if (!this.character)
	        return;
		this.view.style.width  = this.character.width + "px";
		this.view.style.height = this.character.height + "px";
		this.canvas.width  = this.character.width;
		this.canvas.height = this.character.height;
		this.drawCanvas();
		centerAlign(WorkingArea, this.view, true);
		this.resizer.style.left = getValue(this.view, "left") + this.character.width + "px";
		this.resizer.style.top  = getValue(this.view, "top") + this.character.height + "px";
        
        this.updateAnchorPoint();
		this.anchor.style.left  = getValue(this.view, "left") + this.anchorPoint.x - 7 + "px";
		this.anchor.style.top   = getValue(this.view, "top") + this.anchorPoint.y - 7 + "px";

		this.editPanelController.setCharacter(this.characterController.name, this.character);
	},

	setVisible: function(visible) {
	    if (!this.character)
	        return;
	        
		if(visible) {
			setVisibility(this.view, true);
			setVisibility(this.resizer, true);
			setVisibility(this.anchor, true);
			this.editPanelController.setVisible(true);
		} else {
			setVisibility(this.view, false);
			setVisibility(this.resizer, false);
			setVisibility(this.anchor, false);
			this.editPanelController.setVisible(false);			
		}
	}	
});
