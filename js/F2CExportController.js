/* F2C Export Controller */

F2CExportController = Klass(Object, {
    /* view */
    view:false,
    layoutContainer:false,
    numBytesControl:false,
    codeBox:false,
    exampleUsage:false,
        
    /* controls */    
    closeControl:false,
    saveAsControl:false,
    
    /* model */
    dataObjectName: "",
    exampleUsageCode: "Example usage of above generated code:\n\n    context.save();\n\n    /* The (100, 100) in the canvas is where we want to draw the actor. */\n    context.translate(100, 100);\n\n    /* Draw the actor */\n    F2CCast['F2CActor1'].draw(context);\n\n    context.restore();\n",
    
    initialize: function() {
        this.view = new E('div', { className : 'F2CExportBox' });
        
        this.layoutContainer = new E('div', { className : 'F2CExportLayoutContainer' });
        
        this.exampleUsage = new E('pre', this.exampleUsageCode, { className : 'F2CExportExampleUsage' });
        
        controlContainer = new E('div');

        this.closeControl = new E('input', { type : 'button', value : 'Close', className : 'btn' });
        this.closeControl.onclick = this.hide.bind(this);
        this.closeControl.onmouseover = this.buttonOnMouseOver;
        this.closeControl.onmouseout  = this.buttonOnMouseOut;
        this.closeControl.onmousedown = this.buttonOnMouseDown;

        this.saveAsControl = new E('input', { type : 'button', value : 'Save As', className : 'btn' });
        this.saveAsControl.onclick = this.saveAs.bind(this);
        this.saveAsControl.onmouseover = this.buttonOnMouseOver;
        this.saveAsControl.onmouseout  = this.buttonOnMouseOut;
        this.saveAsControl.onmousedown = this.buttonOnMouseDown;
        
        controlContainer.appendChild(this.closeControl);
        controlContainer.appendChild(this.saveAsControl);

		this.numBytesControl = new E('div', { className : 'F2CExportNumBytes' });
		
        this.codeBox = new E('textarea', { className : 'F2CExport' });
        this.codeBox.readOnly = true;

        this.layoutContainer.appendChild(controlContainer);
        this.layoutContainer.appendChild(this.codeBox);
        this.layoutContainer.appendChild(this.numBytesControl);        
        this.layoutContainer.appendChild(this.exampleUsage);        

        
        this.view.appendChild(this.layoutContainer);
        document.body.appendChild(this.view);   /* Special case, this should be the only one instance */
        this.onresize.call(this);
        window.addEventListener('resize', this.onresize.bind(this), false);        
    },    
    
    doExport: function(dataObjectName, dataObject) {
    	this.dataObjectName = dataObjectName;
        var prefix_str = dataObjectName + " = {\n";
        var postfix_str = "} /* End Of " + dataObjectName + " */\n";
        
        var str = "";
        for (itemName in dataObject) {
            if (str) {
                str += ",\n";
            }
            str += "  " + itemName + " : {\n";
            str += dataObject[itemName].toJSON();
            str += "\n  } /* End of " + itemName + " */\n";
        }
        
        str = prefix_str + str + postfix_str;
        
        this.codeBox.innerHTML = str;
        
        this.numBytesControl.innerHTML = "Code Size : " + str.length + " bytes";
        this.show();
    },
    
    saveAs: function() {
        window.prompt('Export ' + this.dataObjectName, this.codeBox.innerHTML);
    },
    
    onresize: function() {
        centerAlign(this.view, this.layoutContainer, true);
        return true;
    },
    
    show: function() {
        this.exampleUsage.innerHTML = this.exampleUsageCode;
        setVisibility(this.view, true);
        this.view.style.opacity = 0.95;  /* for opacity animation */
    },
    
    hide: function() {        
        setVisibility(this.view, false);
        this.view.style.opacity = 0; /* for opacity animation */
    },

    buttonOnMouseOver: function (e) {
		this.className = 'btnHover';
    },

    buttonOnMouseOut: function (e) {
		this.className = 'btn';    
    },

    buttonOnMouseDown: function (e) {
		this.className = 'btnDown';
    }
    
});