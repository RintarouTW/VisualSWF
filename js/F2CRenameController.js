/* delegate protocol
   - rename(targetElement, originalValue, newValue);
   
   renamingView should support:
   - update();  // after rename(), the renamingView will need to be updated.

   
   event.target = renamingView              // the view which dispatched the rename request event 
   event.detail = renamingTargetElement     // the element to be replaced by the text field 
*/

F2CRenameController = Klass(Object, {
    delegate: false,				/* the delegate */
    
    textField: false,               /* view */
	renamingView:false,             /* the view which dispatched the rename request event */
	renamingTargetElement: false,   /* the element to be replaced by the text field */
	originalValue: false,           /* renamingTargetElement.innerHTML */

    initialize: function(delegate, currentTarget) {
        this.delegate = delegate;
        /* renaming event */
        currentTarget.addEventListener('F2CRenameEvent', this.renameItem.bind(this), false);
    },

    /* renaming support */
    renameItem: function(e) {
    	this.renamingView          = e.target; /* the view which dispatched this rename request event */
        this.renamingTargetElement = e.detail; /* the element to be replaced by the text field */
        this.originalValue = this.renamingTargetElement.innerHTML;
        
        if (this.delegate) {
            this.textField = new E('input', { type : "text", value : this.originalValue, className : "RenamingTextField" });
            this.textField.addEventListener('keypress', this.renameItemKeyDown.bind(this), true);
            this.textField.addEventListener('mouseout', this.removeTextField.bind(this), false);

			w = getValue(this.renamingTargetElement, "width");
			h = getValue(this.renamingTargetElement, "height");
            renamingTargetParent = this.renamingTargetElement.parentNode;
            renamingTargetParent.removeChild(this.renamingTargetElement);
            renamingTargetParent.appendChild(this.textField);   // attach to the parent of the target
            
            // position and resize the text field.
            this.textField.style.width = w + "px";
            this.textField.style.height = h + "px";
            this.textField.focus();
//            this.textField.select();  // auto selected all
        }
    },
    
    removeTextField: function() {
        if (this.textField) {
            if (this.textField.parentNode) {
                this.textField.parentNode.appendChild(this.renamingTargetElement);  // reattach back the target field
            	this.textField.parentNode.removeChild(this.textField);
            }
            delete this.textField;
            this.textField = false;
        }
        this.renamingView.update();
    },
    
    /* keypress handler */
    renameItemKeyDown: function(e) {
        switch (e.charCode) {
            case 13:    // enter key
				/* ask the delegate allow to rename ? */
				newValue = this.textField.value;
				if (newValue == "") {
    		        alert("please input the name!");
            		return;
    	        }
    
        		if (newValue != this.originalValue) {
    				if (!this.delegate.rename(this.renamingView, this.originalValue, this.textField.value)) {
	    				return;	/* not allowed */
		    		}
				}
				
                this.removeTextField();
            break;
            case 27:    // escape key
                this.removeTextField();
            break;
        }
    }
});