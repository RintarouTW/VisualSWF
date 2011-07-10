/* F2C Table Item View */

F2CTableItemView = function() {
	var el = document.createElement("tr");
	Object.extend(el, F2CTableItemView.prototype);
	el.initialize.apply(el, arguments);
	return el;
}

F2CTableItemView.prototype = {

	/* controls : TODO */
	icon:false,
	nameLabel:false,
	deleteIcon:false,
	
	delegate:false, /* controller of this view, the delegate */
	
	/* model */
	name:"",
	
	iconDrawer: false,  /* iconDrawer should be the actor */
	
	initialize : function(delegate, name, iconDrawer) {	/* TODO */
		this.delegate = delegate;
		this.name = name;
		this.iconDrawer = iconDrawer;
		
        /* init view */
        this.className = "F2CTableItemView";
        
        this.addEventListener('mouseover', this.triggerMouseOverEvent.bind(this), false);
        this.addEventListener('mouseout', this.onMouseOut.bind(this), false);
        this.addEventListener('DOMNodeRemoved', this.triggerRemovedFromParent.bind(this), false);

		this.icon = new E('div', { draggable : "true", className : "F2CTableItemIcon" });
		this.icon.addEventListener('dragstart', this.triggerDragStartEvent.bind(this), false);
		
		this.iconCanvas = new E.canvas(20, 20);	/* use canvas as our icon */
		this.icon.appendChild(this.iconCanvas);		
		
		this.nameLabel = new E('div', name, { className : "F2CTableItemLabel" });
        this.nameLabel.addEventListener('click', this.triggerRenameEvent.bind(this), false);
        
        this.deleteIcon = new E('img', { src:"delete_item.png", align : "right", className : "F2CTableItemDeleteIcon" });
        this.deleteIcon.addEventListener('mousedown', this.triggerDeleteEvent.bind(this), false);

		this.insertCell(0).appendChild(this.deleteIcon);
		this.insertCell(0).appendChild(this.nameLabel);
		this.insertCell(0).appendChild(this.icon);
        this.update();
    },
    
    drawIcon: function() {
        /* draw the icon */
        this.iconCanvas.width = this.iconCanvas.width;  /* clear */
        iconContext = this.iconCanvas.getContext('2d');
        iconContext.scale(16 / this.iconDrawer.width, 16 / this.iconDrawer.height);	/* 16x16 pixel */
        this.iconDrawer.draw(iconContext);
    },
    
    scrollToView: function() {
        this.scrollIntoView(true);
        this.addEventListener('webkitTransitionEnd', this.endOfTransition, false);
        this.style.backgroundColor = "#999999";
    },
    
    endOfTransition: function(e) {
        this.removeEventListener('webkitTransitionEnd', this.endOfTransition, false);
		this.style.backgroundColor = "transparent";
    },	
    
    onMouseOut: function() {
        this.style.backgroundColor = "transparent";
        this.style.borderTop = "1px solid #353637";
		this.style.borderLeft = "1px solid transparent";
    },
    
    triggerMouseOverEvent: function() {
        /* change background color */
        this.style.backgroundColor = "#666666";
        this.style.borderTop = "1px solid #999999";
		this.style.borderLeft = "1px solid #999999";
		
        /* create a new event */
        theEvent = document.createEvent("CustomEvent");
        theEvent.initCustomEvent("F2CTableItemMouseOver", true, true, this);
        this.dispatchEvent(theEvent);
    },
    
    triggerDragStartEvent: function(e) {
        theEvent = document.createEvent("CustomEvent");
        theEvent.initCustomEvent("F2CTableItemDragStart", true, true, this);
        this.dispatchEvent(theEvent);
    },    
    
    triggerRenameEvent: function() {
        /* F2C Rename Event
            - target: (this) the view which dispatch the event.
            - detail: this.nameLabel is the element which will be replaced by the renaming textfield.
         */
        theEvent = document.createEvent("CustomEvent");
        theEvent.initCustomEvent("F2CRenameEvent", true, true, this.nameLabel);
        this.dispatchEvent(theEvent);
    },    
    
    triggerDeleteEvent: function() {
        theEvent = document.createEvent("CustomEvent");
        theEvent.initCustomEvent("F2CTableItemDelete", true, true, this);
        this.dispatchEvent(theEvent);
    },
    
    triggerRemovedFromParent: function() {
    	/* let delegate know the view is going to be removed from parent */
        theEvent = document.createEvent("CustomEvent");
        theEvent.initCustomEvent("F2CTableItemRemoved", true, true, this);
        this.dispatchEvent(theEvent);    	
    },
    
    update: function(iconDrawer) {
        if (iconDrawer) {
            this.iconDrawer = iconDrawer;
        }
        this.drawIcon();
    	this.nameLabel.innerHTML = this.name;
    },
    
    /*** Public ***/
    setName: function(newName) {
        this.name = newName;
        this.update();
    },
    
    remove: function() {
        // remove the view
        this.parentNode.removeChild(this);
    },
};
