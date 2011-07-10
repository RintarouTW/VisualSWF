
/*
 * delegate
 * - onValueChange(event); // input.onchange event
 */

F2CInputView = function() {
	var el = document.createElement("input");
	Object.extend(el, F2CInputView.prototype);
	el.initialize.apply(el, arguments);
	return el;
}

F2CInputView.prototype = {
    delegate: false,    /* delegate must implement onValueChange() protocol */
	initialize: function(delegate, defaultValue) {
	    this.delegate  = delegate;
		this.type      = "text";
		this.value     = defaultValue;
		this.className = 'F2CInputText';
        this.onchange  = this.delegate.onValueChange.bind(delegate);
	}
};
