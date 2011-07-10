/* F2C Actor Viewer Controller */

F2CActorViewerController = Klass(Object, {
    /* view */
    view: false,     /* Element, also the container. */
    canvas: false,

	infoBoxController: false,

    /* model */
    actorName: "",
    width: 0,
    height: 0,

	initialize: function(infoBoxController) {
		this.infoBoxController = infoBoxController;
		this.view = new E('div', { id : 'ActorViewer', className : 'Tab' });
		this.canvas = new E('canvas', {id : 'ActorViewerCanvas'});

		this.view.appendChild(this.canvas);
        setVisibility(this.view, true);
		
		window.addEventListener('resize', this.onWindowResize.bind(this), false);
	},
	
	onWindowResize: function(e) {
		centerAlign(WorkingArea, this.view);
	},
	
    updateView: function() {
        if (this.view.style.visibility == "hidden") {
            return;
        }
		/* update Info Box */
		this.infoBoxController.update(this.actorName, this.width, this.height);

		/* update canvas size */
		this.canvas.width  = this.width;
		this.canvas.height = this.height;
		
		centerAlign(WorkingArea, this.view);
	},

	drawActor: function(actor) {
	    if(!actor) {
	        return;
	    }
	    this.width  = actor.width;
	    this.height = actor.height;
		this.updateView();
		actor.draw(this.canvas.getContext('2d'));
	},
        
	drawActorByController: function(actorController) {
		actor = actorController.actor;
		this.actorName = actorController.name;
		this.drawActor(actor);		
	},
                
	drawActorByJSON: function(newActorJSON) {

		eval("_tempCast = { " + newActorJSON + " }");    // Create a _tempCast object to hold the actor.

		for (actorName in _tempCast) {
			this.actorName = actorName;                
			currentActor = _tempCast[actorName];
			this.drawActor(currentActor);
			return true; /* One actor only per call */
		}
		
		return false;
	},

/* public */	
	setVisible: function(visible) {
		if(visible) {
			setVisibility(this.view, true);
			this.updateView();
		} else {
			setVisibility(this.view, false);
		}
	}
});