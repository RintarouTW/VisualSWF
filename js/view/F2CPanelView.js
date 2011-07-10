/*
 delegate protocol (model was provided by controller)
 - getPanelLabelName();
*/


F2CPanelView = function() {
	var el = document.createElement("div");
	Object.extend(el, F2CPanelView.prototype);
	el.initialize.apply(el, arguments);
	return el;
}

F2CPanelView.prototype = {
	/* view */
    tableView:false,				/* F2CTableView */
    labelContainer: false,
    nameLabel:false,
    numItemsLabel:false,
    
    controlsContainer: false,		/* The container of the controls */
    itemContainer: false,

	delegate: false,				/* model was provided by the delegate(controller) */

    /* model */
    numItems: 0,
    
    initialize: function(viewId, delegate) {

    	this.delegate = delegate;
    	
        /* init view */
        this.id = viewId;
        this.className = 'F2CPanelView';
        
        this.labelContainer = new E('table', { align: 'center', className: 'F2CPanelViewLabel'});
        tr = new E('tr');
        td = new E('td');
		this.nameLabel = new E('div', this.delegate.getPanelLabelName());
		this.nameLabel.addEventListener('click', this.triggerRenameEvent.bind(this), false);
		td.appendChild(this.nameLabel);
		tr.appendChild(td);

		td = new E('td');
		this.numItemsLabel = new E('span', " (0)");
		td.appendChild(this.numItemsLabel);
		tr.appendChild(td);
		
		this.labelContainer.appendChild(tr);
                
        /* init controlls */
        this.controlsContainer = new E('div', { align : 'center' });
        
        this.appendChild(this.labelContainer);
        this.appendChild(this.controlsContainer);
        
        this.itemContainer = new E('div', { className : 'F2CPanelViewTableContainer' });

        this.tableView = new F2CTableView();
        this.tableView.addEventListener('F2CTableItemDelete', this.deleteItem.bind(this), false);
        
        this.itemContainer.appendChild(this.tableView);
        
        this.appendChild(this.itemContainer);
        
        return this;
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

/* Public */    
    update: function() {
    	this.numItems = this.tableView.childNodes.length;
        this.nameLabel.innerHTML = this.delegate.getPanelLabelName();
        this.numItemsLabel.innerHTML = " (" + this.numItems + ")";
    },
    
    addItem: function(newItem) {
    	this.tableView.addItem(newItem);
    	this.update();
    },
    
    deleteItem: function() {
    	this.update();
    },
    
    clear: function() {
    	this.tableView.clear();
    }
    
};

