/* F2C Debug Controller */

F2CDebugController = Klass(Object, {
    /* view */
    view:false,
    debugBox:false,
    
    /* controls */
    closeControl:false,
    
    /* model */
    initialize: function() {
        this.view = new E('div', { id : 'DebugBoxContainer' });
        this.debugBox = new E('textarea', { id : 'DebugBox'});
        
        this.closeControl = new E('input', { type : 'button', value : 'Close' });
        this.closeControl.onclick = this.hide.bind(this);
        
        this.view.appendChild(this.debugBox);
        this.view.appendChild(this.closeControl);
        
        document.body.appendChild(this.view);   /* Special case, this should be the only one instance */
    },
    
    add: function(msg) {
        this.debugBox.innerHTML += msg + '\n';
    },
    
    show: function() {
        setVisibility(this.view, true);
    },
    
    hide: function() {        
        setVisibility(this.view, false);
    }
                        
});


var test1JSON = "F2CActor1 : {    width   : 15,    height  : 15,    shapeOriginX : 8.000,    shapeOriginY : 8.000,    draw : function(ctx, anchorX, anchorY) { if (!anchorX) anchorX = 0;\n        if (!anchorY) anchorY = 0;\nwith(ctx) { /* ---- Canvas Drawing Start ---- */ translate(this.shapeOriginX - anchorX, this.shapeOriginY - anchorY); beginPath(); moveTo(1.750, -3.800); quadraticCurveTo(4.500, -4.000, 7.250, -4.200); quadraticCurveTo(5.750, -1.875, 4.250, 0.450); quadraticCurveTo(5.300, 3.000, 6.350, 5.550); quadraticCurveTo(3.675, 4.825, 1.000, 4.100); quadraticCurveTo(-1.100, 5.875, -3.200, 7.650); quadraticCurveTo(-3.350, 4.900, -3.500, 2.150); quadraticCurveTo(-5.850, 0.700, -8.200, -0.750); quadraticCurveTo(-5.600, -1.750, -3.000, -2.750); quadraticCurveTo(-2.350, -5.425, -1.700, -8.100); quadraticCurveTo(0.025, -5.950, 1.750, -3.800); fillStyle = 'rgb(56, 117, 172)'; fill(); } /* ---- Canvas Drawing End ---- */        return this;    } /* End of draw() */  }";
        
var F2CDebugger = true;


function debugInit() {        
    F2CDebugger = new F2CDebugController();
    document.body.appendChild(F2CDebugger.view);            
    

    castController.addItemByJSON(test1JSON);  /* Debug */
}

