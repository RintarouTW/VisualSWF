/* Reusable View Design */

F2CTableView = function() {
	var el = document.createElement("table");
	Object.extend(el, F2CTableView.prototype);
	el.initialize.apply(el, arguments);
	return el;
}

F2CTableView.prototype = {
    
    initialize: function() {    	
        /* init view */
        this.className = 'F2CTableView';        
        return this;
    },
    
/* Public */
    addItem: function(newItem) {
    	this.appendChild(newItem);	/* new F2CTableItemView */
    	newItem.scrollToView();
    },

    clear: function() {
    	for (i = 0; i < this.childNodes.length; i++) {
    		this.removeChild(this.childNodes[i]);
    	}
    }
};
