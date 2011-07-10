/* F2C Actor Controller */

F2CActorController = Klass(Object, {
    /* view */
    view:false,     	/* F2CTableItemView */
    
    /* model */
    actor:false,	/* Actor Object */
    name:"",  		/* back reference the actorName */

    initialize: function(theActorName, theActor) {
        this.name = theActorName;
        this.actor = theActor;

        /* init view */
        this.view = new F2CTableItemView(this, this.name, this.actor);	/* TODO */        
		this.view.addEventListener('dragstart', this.dragStart.bind(this), false);        
    },
    
    dragStart: function(event) {
    	event.dataTransfer.setData("ActorName", this.name);
    },
    
/* public */
    getActor: function() {
        return this.actor;
    },
    
    setName: function(newName) {
        if (newName != this.name) {
            
            this.name = newName;
            this.updateView();
        }
    },
    
    updateView: function() {
	    this.view.setName(this.name);
    },

    scrollIntoView: function() {
    	this.view.scrollToView();
    },
    
    remove: function() {
        // remove the view from it's parent
        this.view.remove();
    },    
        
    toJSON:function() {
        var str = "";
        for (pName in this.actor) {
            if (str)
                str += ",\n";
            str += "    " + pName + " : " + this.actor[pName];
        }
        return str;
    }
});