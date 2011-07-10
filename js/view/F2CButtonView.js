/* TODO : so far just like a template */

F2CButtonView = function() {
	var el = document.createElement("input");
	Object.extend(el, F2CButtonView.prototype);
	el.initialize.apply(el, arguments);
	return el;
}

F2CButtonView.prototype = {
	initialize: function(label) {
		this.type = "button";
		this.value = label;
		this.className = 'btn';
//		this.view = new E('input', { type : 'button', value : label, className : 'btn' });
        this.onmouseover = this.buttonOnMouseOver;
        this.onmouseout  = this.buttonOnMouseOut;
        this.onmousedown = this.buttonOnMouseDown;
	},
/*	
	addEventListener: function (eventType, eventHandler, useCapture) {
		this.view.addEventListener(eventType, eventHandler, useCapture);
	},
*/	
    buttonOnMouseOver: function (e) {
		this.className = 'btnHover';
    },

    buttonOnMouseOut: function (e) {
		this.className = 'btn';    
    },

    buttonOnMouseDown: function (e) {
		this.className = 'btnDown';
    }	
};
